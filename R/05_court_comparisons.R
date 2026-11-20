# Give the verified court index the direction used in the research question.
# In a model with an intercept, this changes signs and leaves fit unchanged.
court_sample <- transform(study, Confidence = 100 - BREADY_DISP3,
                          Peer_group = interaction(region, year, sep = "/", drop = TRUE))
court_sample <- court_sample[order(court_sample$Confidence, court_sample$economy, method = "radix"), ]
court_sample$Confidence_group <- factor(ceiling(4 * seq_len(nrow(court_sample)) / nrow(court_sample)))
court_groups <- split(court_sample, court_sample$Peer_group)
region_labels <- unique(regions[c("region", "region_label")])
stopifnot(!anyDuplicated(region_labels$region))
region_names <- setNames(region_labels$region_label, region_labels$region)
stopifnot(all(court_sample$Confidence >= 0 & court_sample$Confidence <= 100),
          !anyDuplicated(court_sample$economy))
court_country_profiles <- data.frame(
  Economy = court_sample$name, Code = court_sample$economy,
  Region = unname(region_names[court_sample$region]), Wave = court_sample$year,
  Confidence = court_sample$Confidence, Credit = court_sample$FIN14,
  Severe_obstacle = court_sample$CRIME9, Bribery = court_sample$GRAFT3,
  Fully_constrained = court_sample$FIN23
)
court_country_profiles <- court_country_profiles[order(court_country_profiles$Economy), ]

court_quartiles <- do.call(rbind, lapply(split(court_sample, court_sample$Confidence_group), function(d) {
  data.frame(Group = paste("Q", d$Confidence_group[1], sep = ""),
             N = nrow(d), Low = min(d$Confidence), High = max(d$Confidence),
             Confidence = mean(d$Confidence), Credit = mean(d$FIN14))
}))

# Select teaching pairs using only region, year, coverage and confidence.
# Within each region keep its largest eligible wave, breaking ties by year.
# Use internal quartile ranks so examples do not depend on single extremes.
paired_cells <- do.call(rbind, lapply(court_groups, function(g) {
  data.frame(Key = as.character(g$Peer_group[1]), Region = g$region[1],
             Wave = g$year[1], N = nrow(g))
}))
paired_cells <- paired_cells[order(-paired_cells$N, paired_cells$Region, -paired_cells$Wave,
                                   method = "radix"), ]
paired_cells <- head(subset(paired_cells, N >= 8 & !duplicated(Region)), 4)
court_pairs <- do.call(rbind, lapply(seq_len(nrow(paired_cells)), function(i) {
  g <- court_groups[[paired_cells$Key[i]]]
  # split() preserves the confidence/ISO sort inherited from court_sample.
  ranks <- round(1 + (nrow(g) - 1) * c(0.25, 0.75))
  a <- g[ranks[1], ]
  b <- g[ranks[2], ]
  data.frame(Region = unname(region_names[a$region]), Wave = a$year, Group_N = nrow(g),
             Lower_confidence = a$name, Lower_score = a$Confidence, Lower_credit = a$FIN14,
             Higher_confidence = b$name, Higher_score = b$Confidence, Higher_credit = b$FIN14,
             Credit_difference = b$FIN14 - a$FIN14)
}))
stopifnot(all(court_pairs$Higher_score >= court_pairs$Lower_score))

# Exact region-by-year comparisons use cells of at least four economies so
# they do not depend on singleton or two-economy groups. Refit the pooled
# model on those same rows before adding the group-specific intercepts.
peer_sample <- subset(court_sample, Peer_group %in% names(Filter(function(g) nrow(g) >= 4, court_groups)))
peer_sample$Peer_group <- droplevels(peer_sample$Peer_group)
court_controls <- FIN14 ~ Confidence + GRAFT3 + log_workers
court_models <- list(
  "Confidence alone" = ols(FIN14 ~ Confidence, court_sample),
  "Add bribery and firm size" = ols(court_controls, court_sample),
  "Same peer sample, without peer controls" = ols(court_controls, peer_sample),
  "Compare within region and survey year" = ols(update(court_controls, . ~ . + Peer_group), peer_sample),
  "Use full credit constraint as outcome" = ols(update(court_controls, FIN23 ~ .), subset(court_sample, !is.na(FIN23)))
)
stopifnot(isTRUE(all.equal(unname(coef(court_models[[1]])["Confidence"]),
                          -unname(coef(models$Simple)["BREADY_DISP3"]))),
          isTRUE(all.equal(unname(coef(court_models[[2]])["Confidence"]),
                          -unname(coef(core)["BREADY_DISP3"]))),
          identical(rownames(model.frame(court_models[[3]])), rownames(model.frame(court_models[[4]]))))
court_effects <- do.call(rbind, lapply(names(court_models), function(label) {
  fit <- court_models[[label]]
  data.frame(Comparison = label, N = nobs(fit), t(linear_test(fit, c(Confidence = 10))))
}))

# Allow the relationship to vary across confidence groups. The top-versus-
# bottom contrast is secondary to the joint test of all three differences.
court_group_fit <- ols(FIN14 ~ Confidence_group + GRAFT3 + log_workers, court_sample)
group_terms <- grep("^Confidence_group", names(coef(court_group_fit)), value = TRUE)
court_group_joint <- block_test(court_group_fit, group_terms)
court_high_low <- linear_test(court_group_fit, c(Confidence_group4 = 1))

# Direct confidence is too sparse over time to estimate within-economy change
# in this snapshot. Count observed waves rather than assuming the same firms
# were interviewed across years.
court_waves <- table(panel$economy[!is.na(panel$BREADY_DISP3)])
court_time_coverage <- data.frame(
  Measure = c("Court confidence", "Severe court obstacle"),
  Economies = c(length(court_waves), length(unique(panel$economy[!is.na(panel$CRIME9)]))),
  Repeat_economies = c(sum(court_waves >= 2),
                      sum(table(panel$economy[!is.na(panel$CRIME9)]) >= 2))
)

repeat_vars <- c("FIN14", "CRIME9", "GRAFT3", "log_workers")
repeat_panel <- subset(panel, economy %in% study$economy & complete.cases(panel[repeat_vars]))
wave_pairs <- lapply(split(repeat_panel, repeat_panel$economy), function(g) {
  # The aligned panel is sorted by economy and year. Require two full waves.
  if (nrow(g) < 2L) return(NULL)
  g <- tail(g, 2L)
  data.frame(Economy = g$name[2], Code = g$economy[2],
             Earlier = g$year[1], Later = g$year[2],
             Gap = diff(g$year),
             Credit_change = diff(g$FIN14),
             Fewer_obstacles = -diff(g$CRIME9),
             Bribery_change = diff(g$GRAFT3),
             Employment_change = diff(g$log_workers))
})
court_changes <- do.call(rbind, wave_pairs)
stopifnot(all(court_changes$Later == study$year[match(court_changes$Code, study$economy)]),
          all(court_changes$Gap > 0), !anyDuplicated(court_changes$Code))
common_change_sample <- subset(court_changes, Earlier >= 2013)
change_formula <- Credit_change ~ Fewer_obstacles + Bribery_change + Employment_change + Gap
change_models <- list(
  "Change in obstacles alone (earlier wave 2013+)" =
    ols(Credit_change ~ Fewer_obstacles, common_change_sample),
  "Add changes in bribery, size and years between waves" =
    ols(change_formula, common_change_sample),
  "Allow older earlier waves" = ols(change_formula, court_changes),
  "Restrict both waves to 2016 or later" = ols(change_formula, subset(court_changes, Earlier >= 2016))
)
court_change_effects <- do.call(rbind, lapply(names(change_models), function(label) {
  fit <- change_models[[label]]
  data.frame(Comparison = label, N = nobs(fit), t(linear_test(fit, c(Fewer_obstacles = 10))))
}))

save_table(court_country_profiles, "court_country_profiles")
save_table(court_pairs, "court_country_pairs")
save_table(court_quartiles, "court_quartiles")
save_table(court_effects, "court_confidence_effects")
save_table(data.frame(Contrast = "Highest vs lowest confidence group", t(court_high_low)), "court_high_low")
save_table(data.frame(Test = "All confidence-group differences", t(court_group_joint)), "court_group_test")
save_table(court_time_coverage, "court_repeat_coverage")
save_table(court_changes, "court_within_economy_changes")
save_table(court_change_effects, "court_change_effects")
