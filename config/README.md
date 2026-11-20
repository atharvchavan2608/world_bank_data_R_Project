# Classification metadata

`regions.csv` records only economy and World Bank geographic region labels.
It was derived from the World Bank country API on 21 November 2026 for economy
codes in WB_ES FIN14. Taiwan, China is absent from that API response. Its
region follows the World Bank's published country and lending groups list.
The file contains no national-income values or categories. Its role is to audit
coverage and assess sensitivity to regional dependence and common conditions.

- [World Bank country API](https://api.worldbank.org/v2/country?format=json&per_page=400)
- [World Bank country and lending groups](https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-groups)

The primary legal-origin specification uses the archived QoG January 2022
`lp_legor` classification as supplied. It codes English (1), French (2),
Socialist (3), German (4) and Scandinavian (5) origins of company law or the
commercial code. The series is from La Porta et al. (1999). Their 2008 review
uses a different convention for some post-socialist economies.

| Economy | Audit of the pitch rule | Treatment in a documented-extension sensitivity |
|---|---|---|
| ATG | English common-law model | Common-law proxy |
| BLZ | English common law | Common-law proxy |
| VCT | English common-law model | Common-law proxy |
| HKG | Common law preserved by the Basic Law | Common-law proxy |
| BRN | Common law and Islamic law | Missing |
| NAM | Roman-Dutch civil law alongside common and customary law | Missing |
| SSD | Statutory and customary systems, with common-law elements | Missing |
| VUT | English common law alongside French and customary law | Missing |
| DEU | German commercial-code origin documented in the literature | German civil-law proxy |

These supplemental descriptors are used only to stress-test the archived
classification. All other unclassified economies remain missing except in the
literal pitch reconstruction, which assigns zero unless named in its override
list.

- [QoG code and provenance](https://datafinder.qog.gu.se/variable/lp_legor)
- [CIA World Factbook legal-system entries, archived](https://www.thefactbook.org/fields/legal-system/2024)
- [Hong Kong Basic Law, Article 8](https://www.basiclaw.gov.hk/en/basiclaw/chapter1.html)
- [La Porta, López-de-Silanes, and Shleifer (2008), pp. 289–290](https://doi.org/10.1257/jel.46.2.285)
