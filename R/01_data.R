save_table <- function(x, name) {
  write.csv(x, file.path("generated", paste0(name, ".csv")), row.names = FALSE,
            na = "", fileEncoding = "UTF-8")
}

raw_files <- sort(list.files("dataset", "^WB_ES_T_.*[.]csv$", recursive = TRUE,
                             full.names = TRUE))
names(raw_files) <- sub("^WB_ES_T_(.*)[.]csv$", "\\1", basename(raw_files))
stopifnot(!anyDuplicated(names(raw_files)))
pitch_codes <- c("FIN14", "BREADY_DISP3", "CRIME9", "DISP2", "GRAFT3", "FIN11",
                 "FIN20", "WK21", "DISP1")
stopifnot(all(pitch_codes %in% names(raw_files)))
total_dimensions <- c("SEX", "AGE", "URBANISATION", paste0("COMP_BREAKDOWN_", 1:3))

read_national <- function(path, code) {
  raw <- read.csv(path, colClasses = "character", na.strings = c("", "NA"),
                  fileEncoding = "UTF-8-BOM", check.names = FALSE)
  total <- Reduce(`&`, lapply(raw[total_dimensions], function(x) !is.na(x) & x == "_T"))
  selected <- raw[total, ]
  stopifnot(nrow(selected) > 0L,
            all(selected$INDICATOR == paste0("WB_ES_T_", code)),
            all(selected$DATABASE_ID == "WB_ES"),
            all(selected$FREQ == "A"), all(selected$UNIT_MULT == "0"),
            all(selected$AGG_METHOD == "_Z"), all(selected$OBS_STATUS == "A"),
            all(grepl("^[A-Z]{3}$", selected$REF_AREA)),
            all(grepl("^[0-9]{4}$", selected$TIME_PERIOD)))
  unit <- unique(selected$UNIT_MEASURE)
  stopifnot(length(unit) == 1L)
  value <- as.numeric(selected$OBS_VALUE)
  stopifnot(all(is.na(selected$OBS_VALUE) | is.finite(value)))
  if (unit %in% c("PT", "IX")) {
    # Allow a few units of single-precision roundoff at 100 in the archived file.
    stopifnot(all(value >= -0.00002 & value <= 100.00002, na.rm = TRUE))
  }
  x <- data.frame(economy = selected$REF_AREA, name = selected$REF_AREA_LABEL,
                  year = as.integer(selected$TIME_PERIOD), value = value)
  stopifnot(!anyDuplicated(x[c("economy", "year")]))
  list(data = x,
       audit = data.frame(code = code, unit = unit, rows = nrow(raw),
                          national = sum(total), observed = sum(!is.na(value)),
                          first = min(x$year), last = max(x$year)))
}

series <- Map(read_national, raw_files, names(raw_files))
source_audit <- do.call(rbind, lapply(series, `[[`, "audit"))
national <- lapply(series, `[[`, "data")
regions <- read.csv("config/regions.csv", colClasses = "character")
stopifnot(!anyDuplicated(regions$economy))

panel <- unique(do.call(rbind, lapply(national, function(x) x[c("economy", "year")])))
panel <- panel[order(panel$economy, panel$year, method = "radix"), ]
for (code in names(national)) {
  values <- national[[code]][c("economy", "year", "value")]
  names(values)[3] <- code
  panel <- merge(panel, values, by = c("economy", "year"), all.x = TRUE, sort = FALSE)
}
panel <- panel[order(panel$economy, panel$year, method = "radix"), ]
stopifnot(!anyDuplicated(panel[c("economy", "year")]),
          all(panel$economy %in% regions$economy), all(panel$WK21 > 0, na.rm = TRUE))
panel$name <- national$FIN14$name[match(panel$economy, national$FIN14$economy)]
stopifnot(!anyNA(panel$name))
panel$region <- regions$region[match(panel$economy, regions$economy)]
panel$log_workers <- log(panel$WK21)

latest <- function(x) x[!duplicated(x$economy, fromLast = TRUE), ]
anchor <- latest(panel[!is.na(panel$FIN14), ])
latest_union <- latest(panel)
years <- data.frame(economy = latest_union$economy, union_year = latest_union$year,
                    credit_year = anchor$year[match(latest_union$economy, anchor$economy)])
wave_disagreements <- years[is.na(years$credit_year) | years$union_year != years$credit_year, ]

origin_file <- "dataset/external/qog_std_cs_jan22.csv"
origin_header <- names(read.csv(origin_file, nrows = 0L, fileEncoding = "UTF-8-BOM"))
origin_classes <- rep("NULL", length(origin_header))
origin_classes[match(c("ccodealp", "lp_legor"), origin_header)] <- "character"
origin <- read.csv(origin_file, colClasses = origin_classes, na.strings = c("", "NA"),
                   fileEncoding = "UTF-8-BOM")
origin <- origin[!is.na(origin$ccodealp), ]
stopifnot(!anyDuplicated(origin$ccodealp), all(is.na(origin$lp_legor) | origin$lp_legor %in% 1:5))

origin_match <- match(anchor$economy, origin$ccodealp)
anchor$origin_row <- !is.na(origin_match)
anchor$origin <- as.integer(origin$lp_legor[origin_match])
anchor$common <- as.integer(anchor$origin == 1L)
anchor$civil_comparison <- anchor$origin %in% c(1L, 2L, 4L, 5L)
pitch_overrides <- c("ATG", "BLZ", "VCT", "HKG", "BRN", "NAM", "SSD", "VUT")
anchor$pitch_common <- ifelse(is.na(anchor$common),
                              as.integer(anchor$economy %in% pitch_overrides), anchor$common)
clear_common <- c("ATG", "BLZ", "HKG", "VCT")
anchor$documented_common <- anchor$common
anchor$documented_common[is.na(anchor$common) & anchor$economy %in% clear_common] <- 1L
anchor$documented_common[is.na(anchor$common) & anchor$economy == "DEU"] <- 0L

study <- anchor[anchor$year >= 2021L, ]
complete_pitch <- complete.cases(study[c(pitch_codes, "pitch_common")])
stopifnot(!anyDuplicated(study$economy), length(study$economy) > 0L)
joint_rows <- complete.cases(panel[pitch_codes])
latest_joint <- latest(panel[joint_rows, ])

describe <- function(x) {
  x <- x[is.finite(x)]
  c(N = length(x), Mean = mean(x), SD = sd(x), Min = min(x), Max = max(x))
}

visual_values <- rbind(
  FIN14 = c(36.5, 19.6, 2.1, 88.5),
  BREADY_DISP3 = c(26.4, 16.4, 0, 71.7),
  CRIME9 = c(10.1, 10.2, 0, 43.4),
  DISP2 = c(54, 20.1, 0, 100),
  GRAFT3 = c(10.8, 10.8, 0, 50.5),
  FIN11 = c(66.8, 22.5, 16.9, 100),
  FIN20 = c(51.4, 17.7, 5.6, 89.7),
  WK21 = c(39, 30.8, 9.7, 318.5),
  DISP1 = c(14, 8.1, 0.5, 46.9),
  pitch_common = c(0.33, 0.47, 0, 1)
)
colnames(visual_values) <- c("Mean", "SD", "Min", "Max")
pitch_summary <- as.data.frame(t(vapply(study[rownames(visual_values)], describe, numeric(5))))
pitch_comparison <- data.frame(
  indicator = rep(rownames(visual_values), times = ncol(visual_values)),
  statistic = rep(colnames(visual_values), each = nrow(visual_values)),
  pitch = as.vector(visual_values),
  rebuilt = as.vector(as.matrix(pitch_summary[colnames(visual_values)]))
)
precision <- ifelse(pitch_comparison$indicator == "pitch_common", 2L, 1L)
pitch_comparison$rounded <- round(pitch_comparison$rebuilt, precision)
pitch_differences <- subset(pitch_comparison, rounded != pitch)
pitch_differences$two_stage <- round(round(pitch_differences$rebuilt, 2L), 1L)

pitch_years <- data.frame(Year = 2021:2026, Pitch = c(1, 4, 45, 49, 62, 2))
pitch_years$Rebuilt <- as.integer(table(factor(study$year, levels = pitch_years$Year)))
coverage <- data.frame(
  Sample = c("Latest FIN14, all years", "Latest WB_ES union, all years",
             "Latest FIN14, 2021+", "Latest joint pitch WB_ES wave, 2021+",
             "Complete pitch WB_ES cases, 2021+", "QoG code known, 2021+",
             "English or named civil-code origin, 2021+",
             "Latest FIN14, 2023+", "Latest FIN14, 2024+"),
  N = c(nrow(anchor), nrow(latest_union), nrow(study), sum(latest_joint$year >= 2021L),
        sum(complete_pitch), sum(!is.na(study$origin)), sum(study$civil_comparison),
        sum(study$year >= 2023L), sum(study$year >= 2024L))
)

profile <- function(label, x) {
  data.frame(Group = label, N = nrow(x), Credit = mean(x$FIN14),
             First = min(x$year), Last = max(x$year),
             Median = median(x$year), check.names = FALSE)
}
profiles <- rbind(profile("Recent", study), profile("Pre-2021", subset(anchor, year < 2021)),
                  profile("QoG origin known", subset(study, !is.na(origin))),
                  profile("QoG origin missing", subset(study, is.na(origin))),
                  profile("English or named civil-code origin", subset(study, civil_comparison)),
                  profile("Excluded from English/civil contrast", subset(study, !civil_comparison)))
origin_audit <- study[is.na(study$origin),
                      c("economy", "name", "year", "region", "FIN14", "origin_row", "pitch_common",
                        "documented_common")]
region_levels <- sort(unique(anchor$region))
count_regions <- function(x) as.integer(table(factor(x, levels = region_levels)))
region_counts <- data.frame(Region = region_levels, Recent = count_regions(study$region),
                            Earlier = count_regions(anchor$region[anchor$year < 2021L]),
                            QoG_missing = count_regions(origin_audit$region),
                            Outside_civil_contrast = count_regions(study$region[!study$civil_comparison]))
origin_counts <- as.data.frame(table(
  factor(study$origin, levels = 1:5, labels = c("English", "French", "Socialist",
                                              "German", "Scandinavian")),
  useNA = "always"
), responseName = "N")
names(origin_counts)[1] <- "Origin"
origin_counts$Origin <- as.character(origin_counts$Origin)
origin_counts$Origin[is.na(origin_counts$Origin)] <- "Unknown"
direction_values <- study[study$economy %in% c("DEU", "PAK") |
                            study$BREADY_DISP3 %in% range(study$BREADY_DISP3),
                          c("economy", "year", "BREADY_DISP3", "CRIME9", "BREADY_DISP6", "CORR11")]
direction_cor <- cor(study[c("BREADY_DISP3", "CRIME9", "BREADY_DISP6", "CORR11")],
                     use = "complete.obs")

save_table(source_audit, "source_audit")
save_table(panel, "wave_panel")
save_table(anchor, "latest_all_years")
save_table(study, "study")
save_table(wave_disagreements, "wave_disagreements")
save_table(cbind(Indicator = rownames(pitch_summary), pitch_summary), "pitch_summary")
save_table(pitch_comparison, "pitch_reconciliation")
save_table(pitch_years, "pitch_year_counts")
save_table(coverage, "coverage")
save_table(profiles, "selection_profiles")
save_table(region_counts, "region_coverage")
save_table(origin_counts, "origin_counts")
save_table(origin_audit, "origin_missing")
save_table(subset(anchor, year < 2021L, select = c(economy, name, year, region, FIN14)),
           "earlier_waves")
save_table(direction_values, "direction_checks")
