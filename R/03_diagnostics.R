diagnostic_models <- models[c("Core", "QoG origin", "Full specification on QoG sample")]
names(diagnostic_models)[3] <- "Full pitch terms"
diagnostic_samples <- list(study, known, known)

koenker_bp <- function(fit) {
  X <- model.matrix(fit)
  e2 <- residuals(fit)^2
  aux <- lm.fit(X, e2)
  r2 <- 1 - sum(aux$residuals^2) / sum((e2 - mean(e2))^2)
  statistic <- nobs(fit) * r2
  df <- fit$rank - 1L
  c(Chi_squared = statistic, df = df, p = pchisq(statistic, df, lower.tail = FALSE))
}

bp <- data.frame(Model = names(diagnostic_models),
                 do.call(rbind, lapply(diagnostic_models, koenker_bp)), row.names = NULL)

dw_stat <- function(e) sum(diff(e)^2) / sum(e^2)

dw_checks <- function(fit, data, draws = 4999L) {
  stopifnot(identical(rownames(model.frame(fit)), rownames(data)))
  e <- residuals(fit)
  n <- length(e)
  orders <- list(
    `Economy code` = order(data$economy, method = "radix"),
    `Survey year, then code` = order(data$year, data$economy, method = "radix"),
    `Region, then code` = order(data$region, data$economy, method = "radix")
  )
  # Conditional reference under independent normal homoskedastic errors and fixed X.
  reference <- qr.resid(fit$qr, matrix(rnorm(n * draws), nrow = n))
  order_checks <- lapply(orders, function(rows) {
    ordered <- reference[rows, , drop = FALSE]
    simulated <- colSums((ordered[-1, ] - ordered[-n, ])^2) / colSums(ordered^2)
    observed <- dw_stat(e[rows])
    left <- (1 + sum(simulated <= observed)) / (draws + 1)
    right <- (1 + sum(simulated >= observed)) / (draws + 1)
    c(DW = observed, p = min(1, 2 * min(left, right)))
  })
  data.frame(Order = names(order_checks), do.call(rbind, order_checks), row.names = NULL)
}

set.seed(50611)
dw <- do.call(rbind, Map(function(fit, data, label) {
  data.frame(Model = label, dw_checks(fit, data))
}, diagnostic_models, diagnostic_samples, names(diagnostic_models)))
random_dw <- quantile(replicate(4999L, dw_stat(sample(residuals(core)))), c(0.025, 0.975))

model_vif <- function(fit) {
  X <- model.matrix(fit)[, -1, drop = FALSE]
  setNames(diag(solve(cor(X))), colnames(X))
}

vifs <- do.call(rbind, Map(function(fit, label) {
  values <- model_vif(fit)
  data.frame(Model = label, Term = names(values), VIF = unname(values))
}, diagnostic_models, names(diagnostic_models)))
court_correlations <- cor(known[c("BREADY_DISP3", "CRIME9", "DISP2", "DISP1", "GRAFT3")])
stopifnot(all(vifs$VIF >= 1 - 1e-10))

regression_diagnostics <- function(fit, data) {
  stopifnot(identical(rownames(model.frame(fit)), rownames(data)))
  data.frame(Economy = data$economy, Year = data$year, Region = data$region,
             Fitted = unname(fitted(fit)), Residual = unname(residuals(fit)),
             Studentized = unname(rstudent(fit)), Leverage = unname(hatvalues(fit)),
             Cook = unname(cooks.distance(fit)))
}
core_diagnostics <- regression_diagnostics(core, study)
origin_diagnostics <- regression_diagnostics(origin_fit, known)
pitch_diagnostics <- regression_diagnostics(models[["Full specification on QoG sample"]], known)
top_core_cook <- head(core_diagnostics[order(-core_diagnostics$Cook), ], 5)

form_checks <- do.call(rbind, Map(function(fit, data, label) {
  z <- as.numeric(scale(fitted(fit)))
  expanded <- ols(update(formula(fit), . ~ . + fitted_sq + fitted_cube),
                  transform(data, fitted_sq = z^2, fitted_cube = z^3))
  reset <- block_test(expanded, c("fitted_sq", "fitted_cube"))
  predictors <- fitted(fit)
  data.frame(Model = label, Min_fit = min(predictors), Max_fit = max(predictors),
             Outside = sum(predictors < 0 | predictors > 100), t(reset))
}, diagnostic_models, diagnostic_samples, names(diagnostic_models)))

se_comparison <- do.call(rbind, lapply(c("Core", "QoG origin"), function(label) {
  fit <- models[[label]]
  terms <- intersect(c("BREADY_DISP3", "GRAFT3", "common"), names(coef(fit)))
  classical <- subset(coefficient_tests(fit, vcov(fit)), Term %in% terms)
  robust <- subset(coefficient_tests(fit), Term %in% terms)
  data.frame(Model = label, Term = classical$Term, Estimate = classical$Estimate,
             Classical_SE = classical$SE, HC3_SE = robust$SE,
             Classical_p = classical$p, HC3_p = robust$p)
}))

save_table(bp, "breusch_pagan")
save_table(dw, "durbin_watson")
save_table(data.frame(Percentile = names(random_dw), DW = unname(random_dw)), "dw_random_order")
save_table(vifs, "vif")
save_table(cbind(Term = rownames(court_correlations), as.data.frame(court_correlations)),
           "court_correlations")
save_table(core_diagnostics, "core_residuals")
save_table(origin_diagnostics, "origin_residuals")
save_table(pitch_diagnostics, "pitch_residuals")
save_table(top_core_cook, "core_top_cooks")
save_table(form_checks, "functional_form")
save_table(se_comparison, "se_comparison")
