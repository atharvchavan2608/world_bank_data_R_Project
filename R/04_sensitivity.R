study$cohort <- cut(study$year, breaks = c(-Inf, 2022, 2023, 2024, Inf),
                    labels = c("2021-22", "2023", "2024", "2025-26"))
known$cohort <- study$cohort[match(known$economy, study$economy)]
matched_fin23 <- subset(study, !is.na(FIN23))
documented <- subset(study, !is.na(documented_common))
largest_leverage <- core_diagnostics$Economy[which.max(core_diagnostics$Leverage)]
influence_cases <- unique(c(head(top_core_cook$Economy, 2), largest_leverage))
historical <- subset(anchor, complete.cases(anchor[c("FIN14", "CRIME9", "GRAFT3", "log_workers")]))
obstacle_formula <- update(core_formula, . ~ . - BREADY_DISP3 + CRIME9)
pitch_original <- update(pitch_formula, . ~ . - common + pitch_common)
digital_sample <- subset(study, !is.na(T5))

sensitivity_models <- c(list(
  Core = core,
  `Workers in levels` = ols(update(core_formula, . ~ . - log_workers + WK21), study),
  `Surveys from 2023` = ols(core_formula, subset(study, year >= 2023)),
  `Surveys from 2024` = ols(core_formula, subset(study, year >= 2024)),
  `Survey cohort controls` = ols(update(core_formula, . ~ . + cohort), study),
  `Region controls` = ols(update(core_formula, . ~ . + region), study),
  `Region and cohort controls` = ols(update(core_formula, . ~ . + region + cohort), study),
  `Website-sample core` = ols(core_formula, digital_sample),
  `Firm websites added` = ols(update(core_formula, . ~ . + T5), digital_sample),
  `Region, cohort and websites` = ols(update(core_formula, . ~ . + region + cohort + T5),
                                       digital_sample),
  `Court obstacle, recent` = ols(obstacle_formula, study),
  `Court obstacle, all vintages` = ols(obstacle_formula, historical),
  `FIN14 on FIN23 sample` = ols(core_formula, matched_fin23),
  `Fully credit constrained` = ols(update(core_formula, FIN23 ~ .), matched_fin23),
  `Full pitch terms, QoG codes` = models[["Full specification on QoG sample"]],
  `Full pitch terms and coding` = ols(pitch_original, study)
), setNames(lapply(influence_cases, function(code) ols(core_formula, subset(study, economy != code))),
            paste("Omit", influence_cases)))

effects_for <- function(fit, term, change) {
  linear_test(fit, setNames(change, term))[c("Estimate", "Lower", "Upper", "p")]
}

comparison_row <- function(fit, label) {
  court <- if ("CRIME9" %in% names(coef(fit)) && !"BREADY_DISP3" %in% names(coef(fit))) {
    "CRIME9"
  } else {
    "BREADY_DISP3"
  }
  court_test <- effects_for(fit, court, 10)
  bribe_test <- effects_for(fit, "GRAFT3", 10)
  data.frame(Model = label, N = nobs(fit), Court_measure = court,
             Court = court_test["Estimate"], Court_low = court_test["Lower"],
             Court_high = court_test["Upper"], Court_p = court_test["p"],
             Bribery = bribe_test["Estimate"], Bribe_low = bribe_test["Lower"],
             Bribe_high = bribe_test["Upper"], Bribe_p = bribe_test["p"], row.names = NULL)
}
compare_models <- function(fits) {
  do.call(rbind, Map(comparison_row, fits, names(fits)))
}
sensitivity <- compare_models(sensitivity_models)

contrast_models <- c("Core", "Survey cohort controls", "Region controls",
                     "Region and cohort controls", "Firm websites added",
                     "Region, cohort and websites")
sensitivity_contrasts <- do.call(rbind, lapply(contrast_models, function(label) {
  fit <- sensitivity_models[[label]]
  frame <- model.frame(fit)
  weights <- c(BREADY_DISP3 = sd(frame$BREADY_DISP3), GRAFT3 = -sd(frame$GRAFT3))
  data.frame(Model = label, N = nobs(fit), t(linear_test(fit, weights)), row.names = NULL)
}))

region_omissions <- setNames(lapply(region_levels, function(id) {
  ols(core_formula, subset(study, region != id))
}), region_levels)
region_sensitivity <- compare_models(region_omissions)

origin_sensitivity_models <- list(
  `QoG, all observed origins` = origin_fit,
  `English vs civil codes` = models[["English vs civil codes"]],
  `QoG with region and cohort controls` =
    ols(update(origin_formula, . ~ . + region + cohort), known),
  `Documented extension` = ols(update(origin_formula, . ~ . - common + documented_common), documented),
  `Original pitch dummy, core terms` = ols(update(origin_formula, . ~ . - common + pitch_common), study),
  `Original pitch dummy, full terms` = sensitivity_models[["Full pitch terms and coding"]]
)
origin_sensitivity <- do.call(rbind, Map(function(fit, label) {
  term <- intersect(c("common", "documented_common", "pitch_common"), names(coef(fit)))
  test <- effects_for(fit, term, 1)
  data.frame(Model = label, N = nobs(fit), t(test), row.names = NULL)
}, origin_sensitivity_models, names(origin_sensitivity_models)))
origin_region_overlap <- as.data.frame.matrix(table(known$region, known$common))
origin_region_overlap <- data.frame(Region = rownames(origin_region_overlap),
                                    setNames(origin_region_overlap, c("Other", "English")),
                                    row.names = NULL)

cluster_se <- function(fit, group) {
  X <- model.matrix(fit)
  scores <- rowsum(X * residuals(fit), group)
  groups <- nrow(scores)
  bread <- summary(fit)$cov.unscaled
  adjustment <- groups / (groups - 1) * (nobs(fit) - 1) / df.residual(fit)
  sqrt(diag(adjustment * bread %*% crossprod(scores) %*% bread))
}

region_se <- do.call(rbind, lapply(c("Core", "QoG origin"), function(label) {
  fit <- models[[label]]
  sample <- if (label == "Core") study else known
  results <- coefficient_tests(fit)
  result_terms <- intersect(c("BREADY_DISP3", "GRAFT3", "common"), results$Term)
  data.frame(Model = label, Term = result_terms, HC3 = sqrt(diag(hc3(fit)))[result_terms],
             Region_CR1 = cluster_se(fit, sample$region)[result_terms],
             Groups = length(unique(sample$region)),
             Min_size = min(table(sample$region)), Max_size = max(table(sample$region)),
             row.names = NULL)
}))

fractional <- glm(I(FIN14 / 100) ~ BREADY_DISP3 + GRAFT3 + log_workers,
                  data = study, family = quasibinomial(), na.action = na.fail)
stopifnot(fractional$converged, all(is.finite(coef(fractional))))
fractional_X <- model.matrix(fractional)
fractional_bread <- summary(fractional, dispersion = 1)$cov.unscaled
fractional_scores <- fractional_X *
  (residuals(fractional, type = "response") / (1 - hatvalues(fractional)))
fractional_vcov <- fractional_bread %*% crossprod(fractional_scores) %*% fractional_bread
fractional_changes <- do.call(rbind, lapply(c("BREADY_DISP3", "GRAFT3", "log_workers"), function(term) {
  step <- if (term == "log_workers") log(2) else 10
  shifted <- fractional_X
  shifted[, term] <- shifted[, term] + step
  p0 <- fitted(fractional)
  p1 <- plogis(drop(shifted %*% coef(fractional)))
  estimate <- 100 * mean(p1 - p0)
  gradient <- 100 * colMeans(shifted * (p1 * (1 - p1)) - fractional_X * (p0 * (1 - p0)))
  se <- sqrt(drop(crossprod(gradient, fractional_vcov %*% gradient)))
  critical <- qnorm(0.975)
  data.frame(Term = term, Change = step, Estimate = estimate, SE = se,
             Lower = estimate - critical * se, Upper = estimate + critical * se)
}))
fractional_range <- range(100 * fitted(fractional))

skewness <- function(x) {
  centered <- x - mean(x)
  mean(centered^3) / mean(centered^2)^(3 / 2)
}
workers_form <- data.frame(
  Scale = c("Workers", "Log workers"),
  Skewness = c(skewness(study$WK21), skewness(study$log_workers)),
  Median = c(median(study$WK21), median(study$log_workers)),
  Max = c(max(study$WK21), max(study$log_workers))
)

# Equal-strength omitted-variable benchmark for moving an OLS point estimate to zero.
confounding <- do.call(rbind, lapply(c("BREADY_DISP3", "GRAFT3"), function(term) {
  f2 <- coef(summary(core))[term, "t value"]^2 / df.residual(core)
  other_terms <- setdiff(c("BREADY_DISP3", "GRAFT3", "log_workers"), term)
  auxiliary <- ols(reformulate(c(other_terms, "T5"), response = term), digital_sample)
  data.frame(Term = term, Equal_partial_R2 = (sqrt(f2^2 + 4 * f2) - f2) / 2,
             Website_with_regressor = partial_r2(auxiliary, "T5"),
             Website_with_credit = partial_r2(sensitivity_models[["Firm websites added"]], "T5"),
             Website_N = nrow(digital_sample))
}))

save_table(sensitivity, "sensitivity")
save_table(sensitivity_contrasts, "sensitivity_contrasts")
save_table(region_sensitivity, "leave_one_region_out")
save_table(origin_sensitivity, "origin_sensitivity")
save_table(origin_region_overlap, "origin_region_overlap")
save_table(region_se, "region_standard_errors")
save_table(fractional_changes, "fractional_effects")
save_table(data.frame(Min = fractional_range[1], Max = fractional_range[2]), "fractional_range")
save_table(workers_form, "workers_form")
save_table(confounding, "confounding_sensitivity")
