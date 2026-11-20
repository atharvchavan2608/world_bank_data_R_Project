simple_formula <- FIN14 ~ BREADY_DISP3
core_formula <- FIN14 ~ BREADY_DISP3 + GRAFT3 + log_workers
origin_formula <- update(core_formula, . ~ . + common)
pitch_formula <- update(origin_formula, . ~ . + CRIME9 + DISP2 + FIN11 + FIN20 + DISP1)
known <- subset(study, !is.na(common))
civil <- subset(study, civil_comparison)

ols <- function(formula, data) {
  fit <- lm(formula, data = data, na.action = na.fail)
  stopifnot(fit$rank == length(coef(fit)), df.residual(fit) > 0L)
  fit
}

models <- list(
  Simple = ols(simple_formula, study),
  Core = ols(core_formula, study),
  `Core on QoG sample` = ols(core_formula, known),
  `QoG origin` = ols(origin_formula, known),
  `English vs civil codes` = ols(origin_formula, civil),
  `Full specification on QoG sample` = ols(pitch_formula, known)
)

hc3 <- function(fit) {
  X <- model.matrix(fit)
  scaled_residuals <- residuals(fit) / (1 - hatvalues(fit))
  bread <- summary(fit)$cov.unscaled
  scores <- X * scaled_residuals
  bread %*% crossprod(scores) %*% bread
}

linear_test <- function(fit, contrast, V = hc3(fit)) {
  beta <- coef(fit)
  weights <- setNames(numeric(length(beta)), names(beta))
  stopifnot(all(names(contrast) %in% names(beta)))
  weights[names(contrast)] <- contrast
  estimate <- drop(crossprod(weights, beta))
  se <- sqrt(drop(crossprod(weights, V %*% weights)))
  df <- df.residual(fit)
  statistic <- estimate / se
  critical <- qt(0.975, df)
  c(Estimate = estimate, SE = se, t = statistic, df = df,
    p = 2 * pt(abs(statistic), df, lower.tail = FALSE),
    Lower = estimate - critical * se, Upper = estimate + critical * se)
}

coefficient_tests <- function(fit, V = hc3(fit)) {
  terms <- names(coef(fit))
  estimates <- lapply(terms, function(term) linear_test(fit, setNames(1, term), V))
  data.frame(Term = terms, do.call(rbind, estimates), row.names = NULL)
}

block_test <- function(fit, terms, V = hc3(fit)) {
  b <- coef(fit)[terms]
  V <- V[terms, terms, drop = FALSE]
  df1 <- length(b)
  df2 <- df.residual(fit)
  F_stat <- drop(crossprod(b, solve(V, b))) / df1
  c(F = F_stat, df1 = df1, df2 = df2, p = pf(F_stat, df1, df2, lower.tail = FALSE))
}

fit_stats <- function(fit) {
  fit_sum <- summary(fit)
  c(N = nobs(fit), Slopes = length(coef(fit)) - 1,
    R2 = fit_sum$r.squared, Adjusted_R2 = fit_sum$adj.r.squared,
    Residual_SD = sigma(fit))
}

model_fit <- data.frame(Model = names(models), do.call(rbind, lapply(models, fit_stats)),
                        row.names = NULL)
model_coefficients <- do.call(rbind, Map(function(fit, label) {
  rbind(data.frame(Model = label, Inference = "Classical", coefficient_tests(fit, vcov(fit))),
        data.frame(Model = label, Inference = "HC3", coefficient_tests(fit)))
}, models, names(models)))

joint_results <- do.call(rbind, Map(function(fit, label) {
  slopes <- setdiff(names(coef(fit)), "(Intercept)")
  institutions <- intersect(c("BREADY_DISP3", "GRAFT3", "common"), slopes)
  V <- hc3(fit)
  classical <- block_test(fit, slopes, vcov(fit))
  stopifnot(isTRUE(all.equal(unname(classical["F"]), unname(summary(fit)$fstatistic["value"]))))
  rbind(data.frame(Model = label, Test = "Overall classical", t(classical)),
        data.frame(Model = label, Test = "Overall HC3", t(block_test(fit, slopes, V))),
        data.frame(Model = label, Test = "Institutional HC3", t(block_test(fit, institutions, V))))
}, models, names(models)))

core <- models$Core
origin_fit <- models[["QoG origin"]]
stopifnot(nobs(models$Simple) == nobs(core),
          identical(rownames(model.frame(models$Simple)), rownames(model.frame(core))),
          identical(rownames(model.frame(models[["Core on QoG sample"]])),
                    rownames(model.frame(origin_fit))))

core_frame <- model.frame(core)
court_sd <- sd(core_frame$BREADY_DISP3)
bribe_sd <- sd(core_frame$GRAFT3)
effect_weights <- list(
  `Court doubt, 10 points` = c(BREADY_DISP3 = 10),
  `Bribery incidence, 10 points` = c(GRAFT3 = 10),
  `Average employment, doubled` = c(log_workers = log(2)),
  `Court doubt, one SD` = c(BREADY_DISP3 = court_sd),
  `Bribery incidence, one SD` = c(GRAFT3 = bribe_sd),
  `Court minus bribery, one SD each` = c(BREADY_DISP3 = court_sd, GRAFT3 = -bribe_sd),
  `Court plus bribery, one SD each` = c(BREADY_DISP3 = court_sd, GRAFT3 = bribe_sd)
)
core_effects <- data.frame(
  Comparison = names(effect_weights),
  do.call(rbind, lapply(effect_weights, function(w) linear_test(core, w))),
  row.names = NULL
)
contrast_t <- setNames(core_effects$t, core_effects$Comparison)
bribe_magnitude_p <- max(
  pt(contrast_t["Court minus bribery, one SD each"], df.residual(core), lower.tail = FALSE),
  pt(contrast_t["Court plus bribery, one SD each"], df.residual(core))
)
partial_r2 <- function(fit, term) {
  # Squared partial correlation is t^2 / (t^2 + residual degrees of freedom)
  # with the classical t statistic for a single OLS restriction.
  t_stat <- coef(summary(fit))[term, "t value"]
  t_stat^2 / (t_stat^2 + df.residual(fit))
}
partial_fit <- data.frame(
  Term = c("Court doubt", "Bribery incidence"), SD = c(court_sd, bribe_sd),
  Partial_R2 = vapply(c("BREADY_DISP3", "GRAFT3"), function(term) partial_r2(core, term),
                     numeric(1)), row.names = NULL
)

# Cross-check the HC3 fit against the equivalent delete-one coefficient formula.
deleted <- vapply(seq_len(nrow(core_frame)), function(i) {
  coef(ols(core_formula, core_frame[-i, ])) - coef(core)
}, numeric(length(coef(core))))
stopifnot(isTRUE(all.equal(hc3(core), tcrossprod(deleted), tolerance = 1e-10,
                          check.attributes = FALSE)))

save_table(model_fit, "model_fit")
save_table(model_coefficients, "model_coefficients")
save_table(joint_results, "joint_tests")
save_table(core_effects, "core_effects")
save_table(partial_fit, "partial_fit")
save_table(data.frame(Test = "Negative bribery slope exceeds court slope in magnitude",
                      p = bribe_magnitude_p), "bribery_magnitude_test")
