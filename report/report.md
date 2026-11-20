# Trust in Courts, Trust in Credit?

*Do firms tend to have more credit where managers trust the courts to be fair?*

Across 163 economies, we find no clear evidence that countries where firms trust the courts more have more firms holding credit. Some country pairs fit that story and others go the other way. The average difference is small and uncertain, both before and after accounting for other observed differences. Bribery has a stronger association in the basic model, but that association weakens when we account for geography and business conditions.

## 1. Introduction and Literature Review

A bank deciding whether to lend asks what it can recover if the borrower defaults. A fair hearing and a judgment the bank can enforce may reduce that risk. Our question is simple. **Is credit more widespread where firms believe courts are fair?** We use managers' views on the independence and impartiality of courts in commercial disputes. Those views could reflect real enforcement conditions, experiences of difficult cases or differences in how managers report their concerns.

Prior research gives a reason to ask the question. La Porta et al. (1998, 2008) relate legal traditions to investor protection and economic outcomes. Djankov et al. (2007) find that creditor rights and the sharing of borrower information are associated with larger private credit markets. A market can be large because it lends a great deal to a few firms. We ask how many firms hold credit. Visaria (2009) studies an Indian reform that created debt recovery tribunals. Faster recovery lowered delinquency and reduced interest rates on larger loans. Our comparisons use country survey averages and cannot isolate a reform in that way.

We also examine bribery exposure and legal origin. Beck et al. (2005) report that legal, financial and corruption obstacles matter particularly for smaller firms, which motivates checking firm size. Bribe requests in this study arise in covered public transactions such as licensing and taxation. The measure differs from bribery by lenders, as studied by Barth et al. (2009). The legal-origin classification records the heritage of company law or the commercial code. Legal origin and colonial history can overlap, so a comparison between origin groups can reflect other long-standing differences (Klerman et al., 2011).

## 2. Methodology and Model Specification

**Why start with a simple comparison?** It answers the question as stated: do countries with more confidence also have more firms holding credit? Let $Y_i$ be the percentage of firms in economy $i$ with a loan or credit line and $C_i$ the 0–100 court confidence score. The population regression function is $E[Y_i\mid C_i]=\alpha+\beta C_i$ if the conditional mean is linear. Observed credit includes a disturbance, $u_i$, for differences such as credit demand, banking conditions and survey measurement error. Ordinary least squares (OLS) finds the line that minimizes the sum of squared residuals. The residual is the difference between observed credit and the fitted share.

The extended equation allows for bribery, firm size and legal origin:

$$
Y_i=\alpha+\beta C_i+\gamma B_i+\theta\log(W_i)+\delta L_i+u_i .
$$

$B_i$ is the percentage of firms reporting a bribe request, $W_i$ is average employment and $L_i=1$ identifies English common-law origin. We first fit the model with bribery and size on the full sample. We then refit it on the classified sample before adding origin. With the other terms fixed, a ten-point difference in confidence corresponds to $10\beta$ percentage points in fitted credit holding. The dummy compares the fitted credit shares of two documented origin groups. We use log employment because recorded average size is highly skewed. A doubling of size changes log employment by $\log(2)$.

The classical model is linear in its coefficients and needs enough independent variation to estimate them separately. An appropriate sampling model and $E[u_i\mid X_i]=0$ support interpretation as a conditional mean. Constant variance and uncorrelated errors support classical standard errors and OLS efficiency. Conditional normality also gives exact classical t and F tests. The available surveys are an imperfect basis for generalizing across countries and years. Missing influences, including national income, can matter even if the fitted residuals look well behaved. With appropriate sampling and moments, the line can still describe an average linear association.

The individual null hypotheses set the confidence, bribery or legal-origin slope to zero, with a two-sided alternative. The expected directions are positive for confidence, negative for bribery and positive for the common-law dummy. F tests assess the slopes jointly or ask whether the included institution variables add information. We report 95% intervals and use HC3 standard errors, which allow error variance to differ across economies. The HC3 t and Wald F tests use approximate reference distributions under economy independence. To compare the strength of the two institutions, we put court *doubt* and bribery in the adverse direction, use one standard deviation of each and account for the covariance between their estimates. [MacKinnon and White](https://doi.org/10.1016/0304-4076%2885%2990158-7)

**Why add a closer country comparison?** Economies from different regions or survey years may face very different credit conditions. We compare countries within the same World Bank region and survey year by adding an intercept for each group, retaining groups with at least four countries. We refit the previous model on these same rows to show how the comparison changes when the group effects enter. We also allow for a pattern across four ranked confidence groups, and replace credit holding with the share of firms fully credit constrained. A separate repeat-wave check subtracts each economy's earlier observations from its later ones. It uses the longer-running question about severe court obstacles. The adjustment adds changes in bribery and size and controls for the wave gap.

## 3. Data Description

**What are we comparing?** World Bank Enterprise Surveys include registered establishments in selected formal, nonagricultural industries. National statistics use the survey's firm weights. Our regression gives each economy equal weight, so a large economy enters with the same regression weight as a small one. FIN14's questionnaire asks whether a firm holds a loan or line from a financial institution. Credit holding depends on whether firms want credit, whether they qualify and how long credit remains outstanding. It measures the stock of current borrowing relationships. [Enterprise Surveys methodology](https://www.enterprisesurveys.org/en/methodology), [indicator definitions](https://www.enterprisesurveys.org/content/dam/enterprisesurveys/documents/methodology/Indicator-Description.pdf)

The archive has rows for national totals and subgroups of firms. We keep the national-total code `_T` across all six breakdown dimensions and validate each indicator–economy–year key. We then match the measures by economy and wave, using `TIME_PERIOD` as the year key. We pick the latest FIN14 wave. The latest wave in the union of the archived files agrees with that choice for all 181 economies. The 2021–2026 sample retains 163 economies with all nine survey measures from the same wave. Credit holding averages 36.5% and ranges from 2.1% to 88.5%. The 18 economies with older waves averaged 30.9%, so the date cutoff changes who we compare. The pitch's wave counts match, and two small display differences are consistent with rounding in two stages. [World Bank Data360](https://data360.worldbank.org/en/dataset/WB_ES)

The World Bank's court question asks whether courts are independent and impartial in resolving commercial disputes. The published BREADY_DISP3 measure increases with disagreement. We use $C_i=100-\mathrm{BREADY\_DISP3}_i$ so a higher score means more favorable views. This changes the coefficient's sign and leaves the fitted shares unchanged. In the archive, each of the 163 economies with this measure has one observation. To compare changes, we use CRIME9, the share of firms rating courts a major or very severe obstacle. That question concerns obstacles to business operations. Favorable perceptions and operational obstacles are different measures. The World Bank's separate Business Ready project gathers litigation-time and enforcement-cost data. Here we use national Enterprise Survey views of courts, with no separate court or case observations. [World Bank indicator guide](https://www.enterprisesurveys.org/content/dam/enterprisesurveys/documents/methodology/Indicator-Description.pdf), [Business Ready dispute-resolution methods](https://www.worldbank.org/en/businessready/about-us/faq)

The QoG archive provides usable legal-origin codes for 129 economies, including 46 with English origin. It draws on La Porta et al. (1999) and classifies commercial-code or company-law origin (Teorell et al., 2022). The 34 missing classifications are geographically concentrated, and we keep them missing. A narrower comparison with named civil-code families omits the Socialist-origin category, leaving 119 economies. The appendix shows what changes when we use the pitch's imputation rule or the documented extension. [QoG legal-origin codebook](https://datafinder.qog.gu.se/variable/lp_legor)

## 4. Hypotheses Testing and Results

### Do countries with more confidence have more credit?

Country pairs give two ways the result can go. In the 2024 Europe and Central Asia surveys, Spain scored 86.4 and Armenia 63.7 on court confidence. Credit holding was 61.7% in Spain and 48.6% in Armenia. In the 2025 Latin America and Caribbean surveys, Trinidad and Tobago scored 75.5 versus Brazil's 67.7, while 28.6% held credit versus 57.6% in Brazil. The appendix shows all four pairs from the largest eligible groups in distinct regions. We chose the examples by confidence rank before using their credit data. The examples explain why a country pair can illustrate the hypothesis without settling it.

Across 163 economies, ten points more confidence corresponds to **0.60 points more** credit holding [−1.39, 2.59], $p=.552$. The one-restriction HC3 test gives $F(1,161)=0.355$, the square of the t statistic. The simple line explains about 0.25% of the variation and its adjusted $R^2$ is slightly negative. Adding bribery and average employment raises $R^2$ to 0.215 and adjusted $R^2$ to 0.200. The two variables collectively improve the fit after the penalty for adding slopes. The confidence estimate itself becomes **0.67 points lower** [−2.41, 1.07], $p=.449$. The two confidence estimates differ in direction, and both intervals include zero.

The peer check retains 144 economies in 13 region-year groups. The remaining 19 economies do not have enough peers in the same region and year. On the peer sample, the ten-point estimate is −1.03 before adding group intercepts and −1.20 [−3.09, 0.69] when comparing within the same region and survey year. The change is small relative to the interval. Raw credit holding averages 40.2% for the highest-confidence group and 35.1% for the lowest. The adjusted gap points the other way, at ?2.89 points [?11.54, 5.76]. The four-group model adjusted for bribery and size gives a joint $p=.748$. Switching the outcome to full credit constraint gives a confidence estimate of −0.01 [−1.27, 1.25]. The results give little basis for using the national confidence score to predict whether credit is more widespread, even when we allow a non-linear pattern.

### What if an economy is compared with itself?

We compare its latest two complete surveys, using an earlier wave from 2013 or later in the main repeat-wave check. The 108 economies in this comparison have a median wave gap of six years. A ten-point drop in the share calling courts a severe obstacle corresponds to a −0.61-point change in credit holding [−3.92, 2.71], after allowing for changes in bribery and size and for the wave gap. The result leaves room for credit to increase or decrease. Other date cutoffs give the same uncertainty about direction. Subtracting two waves removes differences that stay fixed in a country. Banking conditions, the economy and the mix of firms surveyed can still change. This check concerns reports of business obstacles over time and gives no estimate of how the same firms respond to a court reform.

### Does bribery or legal origin tell us more?

In the core model, ten points more bribery is associated with **7.06 points less** credit holding [−9.38, −4.73], $t(159)=-6.00$. Doubling average employment is associated with 6.03 points more [2.90, 9.15]. The overall classical F is 14.53, the HC3 version is 18.42, and the HC3 test of the two institution slopes is $F(2,159)=18.17$, each with $p<.001$. The joint result is consistent with one measure explaining much more of the variation than the other. An adverse standard deviation of bribery corresponds to 7.65 points lower credit. An adverse SD of court doubt corresponds to 1.10 points higher, with an interval spanning zero. The signed difference is 8.75 [4.89, 12.62]; the exploratory absolute-magnitude test also favors bribery in the core comparison.

English common-law origin has a −4.45-point difference [−11.34, 2.44], $p=.204$, compared with all documented other origins. It has a −4.69-point difference [−11.80, 2.43], $p=.195$, compared with the named civil-code families. Those intervals allow meaningful gaps in either direction. On the fixed QoG sample, adding origin moves adjusted $R^2$ from 0.198 to 0.202. Adding the full pitch terms moves it to 0.340. The extra terms improve the fit. Collateral is measured on loans that exist, dispute-resolution use is measured among firms with disputes, and reported lack of credit need reflects firms' circumstances. These terms can condition on outcomes of the same process. We keep them as a specification check.

### What could make those estimates misleading?

**Unequal spread.** Some countries may have more volatile credit outcomes or less precise survey figures. The studentized Breusch–Pagan test finds little evidence of the type of unequal variance it tests in the core ($\chi^2(3)=0.75$, $p=.862$). The full QoG model is nearer the usual threshold ($p=.052$). HC3 changes the core bribery slope's standard error from 0.131 to 0.118, with the same fitted effect and qualitative conclusion. It adjusts uncertainty for unequal variance and leverage. It cannot address omitted variables. (Koenker, 1981)

**Country ordering.** Durbin–Watson compares neighboring residuals. Under a suitable ordering its null is no first-order dependence. It is 1.916 when sorted by code, 1.643 by survey year and code, and 1.711 by region and code. Nominal p-values from the fixed-design simulation are .586, .025 and .065. The result changes with the order because countries have no natural time-series sequence. The year result motivates checking survey vintage, and shared regional shocks are more plausible than a dependence between alphabetical neighbors. Region-clustered standard errors are a sensitivity with only seven uneven groups. (Durbin & Watson, 1950)

**Overlapping measures and the fitted line.** VIF measures how much a slope's variance rises when its predictor overlaps with the other predictors. The largest VIF is 1.07 in the core and 1.74 with all pitch terms, so the measures can be distinguished reasonably well in this design. Employment is right-skewed; the level and log versions give the same broad institutional conclusion. The core fitted-powers check gives $p=.226$, but the linear model gives one negative predicted share. Fractional logit keeps fitted shares within their feasible range. The ten-point association is still negative for bribery, −7.47 [−9.89, −5.05], with an uncertain court slope. Dropping the most influential economies individually leaves the broad pattern. These checks support using the simple line to describe the main associations on these data. (Papke & Wooldridge, 1996)

## 5. Findings and Interpretation

The story about fair courts and credit is plausible. The data tell us that a national measure of managers' views is a weak guide to how many firms hold credit. Credit can be widespread even when firms doubt the courts, for example when banks rely more on borrower information, collateral or relationships. The estimates cannot separate those channels from demand or identify what a court reform would change. The country pairs differ, the averages change direction after adjustment, and the older court-obstacle measure does not show a clear pattern over time. The results leave open the importance of court performance for specific loan markets, recovery cases or reforms.

Bribery has a stronger association in the basic model. It also goes with a higher share of fully constrained firms, by 4.57 points [2.14, 7.01] for ten points more bribery. The comparison using current credit holding falls to −2.81 [−5.53, −0.08] with region and cohort controls. It falls to −1.43 [−4.14, 1.28] when website adoption is added alongside them. The contrast with court confidence then also becomes uncertain. Websites capture one aspect of business development and can themselves respond to financing. National income and financial depth remain unmeasured. A benchmark for the strength of an omitted variable appears in the appendix. It illustrates how confounding can change a regression; it cannot identify which mechanism explains the attenuation. (Cinelli & Hazlett, 2020)

For banks the next useful measurements are recovery time, collateral enforceability and approval rates for comparable applicants. Regulators and business associations can study bribe requests in specific public transactions alongside applications, denials and reasons for failing to apply. That would help distinguish obstacles to borrowing from a firm's decision that it does not need a loan. The country-level results give a reason to investigate these links and little basis for ranking reforms.

## 6. Conclusion

We asked whether firms tend to have more credit where managers trust the courts. The World Bank country comparisons give no clear positive relationship. A repeat-wave check on severe court obstacles is also inconclusive. Bribery goes with less credit in the basic model, but that difference shrinks with broader controls. The legal-origin comparison is too uncertain to guide a lending decision. Stronger evidence would link particular enforcement outcomes to particular credit decisions and exploit changes in courts or policies that can be separated from other shifts.

## 7. References

Barth, J. R., Lin, C., Lin, P., & Song, F. M. (2009). Corruption in bank lending to firms: Cross-country micro evidence on the beneficial role of competition and information sharing. *Journal of Financial Economics, 91*(3), 361–388. [https://doi.org/10.1016/j.jfineco.2008.04.003](https://doi.org/10.1016/j.jfineco.2008.04.003)

Beck, T., Demirgüç-Kunt, A., & Maksimovic, V. (2005). Financial and legal constraints to growth: Does firm size matter? *The Journal of Finance, 60*(1), 137–177. [https://doi.org/10.1111/j.1540-6261.2005.00727.x](https://doi.org/10.1111/j.1540-6261.2005.00727.x)

Cinelli, C., & Hazlett, C. (2020). Making sense of sensitivity: Extending omitted variable bias. *Journal of the Royal Statistical Society: Series B (Statistical Methodology), 82*(1), 39–67. [https://doi.org/10.1111/rssb.12348](https://doi.org/10.1111/rssb.12348)

Djankov, S., McLiesh, C., & Shleifer, A. (2007). Private credit in 129 countries. *Journal of Financial Economics, 84*(2), 299–329. [https://doi.org/10.1016/j.jfineco.2006.03.004](https://doi.org/10.1016/j.jfineco.2006.03.004)

Durbin, J., & Watson, G. S. (1950). Testing for serial correlation in least squares regression. I. *Biometrika, 37*(3–4), 409–428. [https://doi.org/10.1093/biomet/37.3-4.409](https://doi.org/10.1093/biomet/37.3-4.409)

Klerman, D. M., Mahoney, P. G., Spamann, H., & Weinstein, M. I. (2011). Legal origin or colonial history? *Journal of Legal Analysis, 3*(2), 379–409. [https://doi.org/10.1093/jla/lar002](https://doi.org/10.1093/jla/lar002)

Koenker, R. (1981). A note on studentizing a test for heteroscedasticity. *Journal of Econometrics, 17*(1), 107–112. [https://doi.org/10.1016/0304-4076(81)90062-2](https://doi.org/10.1016/0304-4076%2881%2990062-2)

La Porta, R., López-de-Silanes, F., & Shleifer, A. (2008). The economic consequences of legal origins. *Journal of Economic Literature, 46*(2), 285–332. [https://doi.org/10.1257/jel.46.2.285](https://doi.org/10.1257/jel.46.2.285)

La Porta, R., López-de-Silanes, F., Shleifer, A., & Vishny, R. W. (1998). Law and finance. *Journal of Political Economy, 106*(6), 1113–1155. [https://doi.org/10.1086/250042](https://doi.org/10.1086/250042)

La Porta, R., López-de-Silanes, F., Shleifer, A., & Vishny, R. W. (1999). The quality of government. *Journal of Law, Economics, and Organization, 15*(1), 222–279. [https://doi.org/10.1093/jleo/15.1.222](https://doi.org/10.1093/jleo/15.1.222)

MacKinnon, J. G., & White, H. (1985). Some heteroskedasticity-consistent covariance matrix estimators with improved finite sample properties. *Journal of Econometrics, 29*(3), 305–325. [https://doi.org/10.1016/0304-4076(85)90158-7](https://doi.org/10.1016/0304-4076%2885%2990158-7)

Papke, L. E., & Wooldridge, J. M. (1996). Econometric methods for fractional response variables with an application to 401(k) plan participation rates. *Journal of Applied Econometrics, 11*(6), 619–632. [https://doi.org/10.1002/(SICI)1099-1255(199611)11:6<619::AID-JAE418>3.0.CO;2-1](https://onlinelibrary.wiley.com/doi/abs/10.1002/%28SICI%291099-1255%28199611%2911%3A6%3C619%3A%3AAID-JAE418%3E3.0.CO%3B2-1)

Teorell, J., Sundström, A., Holmberg, S., Rothstein, B., Alvarado Pachon, N., & Dalli, C. M. (2022). *The Quality of Government Standard Dataset* (Version Jan22) [Data set]. University of Gothenburg, The Quality of Government Institute. [https://doi.org/10.18157/qogstdjan22](https://doi.org/10.18157/qogstdjan22)

Visaria, S. (2009). Legal reform and loan repayment: The microeconomic impact of debt recovery tribunals in India. *American Economic Journal: Applied Economics, 1*(3), 59–81. [https://doi.org/10.1257/app.1.3.59](https://doi.org/10.1257/app.1.3.59)

World Bank. (n.d.-a). *Business Ready frequently asked questions*. [Dispute-resolution methods](https://www.worldbank.org/en/businessready/about-us/faq)

World Bank. (n.d.-b). *Enterprise Surveys* [Data set]. Data360. [Data360 WB_ES](https://data360.worldbank.org/en/dataset/WB_ES)

World Bank. (n.d.-c). *Enterprise Surveys methodology*. [Survey methodology](https://www.enterprisesurveys.org/en/methodology)

World Bank. (2026, October 26). *Enterprise Surveys indicator descriptions*. [Indicator guide](https://www.enterprisesurveys.org/content/dam/enterprisesurveys/documents/methodology/Indicator-Description.pdf)
