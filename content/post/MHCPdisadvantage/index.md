---
title: Use of mental health care plans and disadvantage
date: '2025-05-29'
format:
  hugo-md:
    code-fold: true
    code-summary: Show the code
  html:
    code-fold: true
    code-summary: Show the code
number-sections: true
toc: true
tags:
  - medicine
  - Medicare
  - mental health
  - disadvantage
engine: knitr
summary: ''
---


<link href="index_files/libs/table1-1.0/table1_defaults.css" rel="stylesheet" />

Photo by <a href="https://unsplash.com/@tex450?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Matthew Ball</a> on <a href="https://unsplash.com/photos/woman-in-black-and-white-long-sleeve-shirt-OJQFlWvUb2E?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a>

Exploring the question of whether Mental Health Care Plans (and the billing of them) are driven by patients, and the patient's expected utility of MHCPs to unlock government funding for private psychological services.

The number of MHCP-eligible patients at coHealth who were billed MHCPs in the previous twelve months were divided into groups according to Health Care Card (HCC)/pension status and high-prevalence and low-prevalence mental health disorders. It is postulated that HCC/pension holders have lower financial resources and are less able to utilise the government subsidies unlocked by MHCP plans for private psychology (as private psychology fees are far greater than the government subsidy to use private psychology). It is additionally postulated that patients with low-prevalence mental health disorders have more severe mental health conditions and are at greater need of mental health assessments and services.

<details class="code-fold">
<summary>Show the code</summary>

``` r
library(dplyr)
library(tidyr)
library(lme4)
library(table1)
library(sjPlot) # regression table plotting
```

</details>
<details class="code-fold">
<summary>Show the code</summary>

``` r
# outcome
#   MHCP - false/true
# 
# predictors
#   concession - false = no, true = yes
#   mental health condition - "high" = high-frequency, "low" = low-frequency
# 
# random effects
#   (not considered to be a predictor of interest)
#   clinic - the clinic's name, a categorical variable

# the initial data was created as counts (i.e. aggregated data)
# the original patient data can be recreated from the counts

summary_df <- tibble(
  mhcp = logical(),
  concession = logical(),
  condition = factor(),
  clinic = character(),
  n = integer() # the number of times this patient type occurs. this column will be removed
)

summary_df <- summary_df |>
  add_row(mhcp = TRUE, concession = TRUE, condition = "high", clinic = "Kensington", n = 42) |>
  add_row(mhcp = FALSE, concession = TRUE, condition = "high", clinic = "Kensington", n = 243) |>
  add_row(mhcp = TRUE, concession = TRUE, condition = "low", clinic = "Kensington", n = 7) |>
  add_row(mhcp = FALSE, concession = TRUE, condition = "low", clinic = "Kensington", n = 66) |>
  add_row(mhcp = TRUE, concession = FALSE, condition = "high", clinic = "Kensington", n = 9) |>
  add_row(mhcp = FALSE, concession = FALSE, condition = "high", clinic = "Kensington", n = 75) |>
  add_row(mhcp = TRUE, concession = FALSE, condition = "low", clinic = "Kensington", n = 2) |>
  add_row(mhcp = FALSE, concession = FALSE, condition = "low", clinic = "Kensington", n = 6) |>
  add_row(mhcp = TRUE, concession = TRUE, condition = "high", clinic = "Paisley", n = 26) |>
  add_row(mhcp = FALSE, concession = TRUE, condition = "high", clinic = "Paisley", n = 404) |>
  add_row(mhcp = TRUE, concession = TRUE, condition = "low", clinic = "Paisley", n = 13) |>
  add_row(mhcp = FALSE, concession = TRUE, condition = "low", clinic = "Paisley", n = 110) |>
  add_row(mhcp = TRUE, concession = FALSE, condition = "high", clinic = "Paisley", n = 21) |>
  add_row(mhcp = FALSE, concession = FALSE, condition = "high", clinic = "Paisley", n = 110) |>
  add_row(mhcp = TRUE, concession = FALSE, condition = "low", clinic = "Paisley", n = 1) |>
  add_row(mhcp = FALSE, concession = FALSE, condition = "low", clinic = "Paisley", n = 7) |>
  add_row(mhcp = TRUE, concession = TRUE, condition = "high", clinic = "Laverton", n = 14) |>
  add_row(mhcp = FALSE, concession = TRUE, condition = "high", clinic = "Laverton", n = 65) |>
  add_row(mhcp = TRUE, concession = TRUE, condition = "low", clinic = "Laverton", n = 10) |>
  add_row(mhcp = FALSE, concession = TRUE, condition = "low", clinic = "Laverton", n = 28) |>
  add_row(mhcp = TRUE, concession = FALSE, condition = "high", clinic = "Laverton", n = 7) |>
  add_row(mhcp = FALSE, concession = FALSE, condition = "high", clinic = "Laverton", n = 36) |>
  add_row(mhcp = TRUE, concession = FALSE, condition = "low", clinic = "Laverton", n = 1) |>
  add_row(mhcp = FALSE, concession = FALSE, condition = "low", clinic = "Laverton", n = 3) |>
  add_row(mhcp = TRUE, concession = TRUE, condition = "high", clinic = "Collingwood", n = 35) |>
  add_row(mhcp = FALSE, concession = TRUE, condition = "high", clinic = "Collingwood", n = 311) |>
  add_row(mhcp = TRUE, concession = TRUE, condition = "low", clinic = "Collingwood", n = 5) |>
  add_row(mhcp = FALSE, concession = TRUE, condition = "low", clinic = "Collingwood", n = 82) |>
  add_row(mhcp = TRUE, concession = FALSE, condition = "high", clinic = "Collingwood", n = 14) |>
  add_row(mhcp = FALSE, concession = FALSE, condition = "high", clinic = "Collingwood", n = 74) |>
  add_row(mhcp = TRUE, concession = FALSE, condition = "low", clinic = "Collingwood", n = 1) |>
  add_row(mhcp = FALSE, concession = FALSE, condition = "low", clinic = "Collingwood", n = 5) |>
  add_row(mhcp = TRUE, concession = TRUE, condition = "high", clinic = "Fitzroy", n = 74) |>
  add_row(mhcp = FALSE, concession = TRUE, condition = "high", clinic = "Fitzroy", n = 371) |>
  add_row(mhcp = TRUE, concession = TRUE, condition = "low", clinic = "Fitzroy", n = 18) |>
  add_row(mhcp = FALSE, concession = TRUE, condition = "low", clinic = "Fitzroy", n = 147) |>
  add_row(mhcp = TRUE, concession = FALSE, condition = "high", clinic = "Fitzroy", n = 20) |>
  add_row(mhcp = FALSE, concession = FALSE, condition = "high", clinic = "Fitzroy", n = 71) |>
  add_row(mhcp = TRUE, concession = FALSE, condition = "low", clinic = "Fitzroy", n = 3) |>
  add_row(mhcp = FALSE, concession = FALSE, condition = "low", clinic = "Fitzroy", n = 7)
```

</details>
<details class="code-fold">
<summary>Show the code</summary>

``` r
# duplicate rows according to the weighting 'n',
# hence "re-creating" the original patient-level data from the counts
df <- summary_df |>
  uncount(n) |>
  mutate(
    condition = as.factor(condition),
    clinic = as.factor(clinic)
  )

label(df$mhcp) = "Mental Health Plan"
label(df$concession) = "Concession card"
label(df$condition) = "Condition frequency"

table1(
  x = ~ mhcp + concession + condition | clinic,
  data = df,
  overall = c(left = "Total"),
  caption = "Mental health care plans",
  footnote = "coHealth clinics, May 2025, 'active' patients"
  )
```

</details>
<div class="Rtable1"><table class="Rtable1"><caption>Mental health care plans</caption>

<thead>
<tr>
<th class='rowlabel firstrow lastrow'></th>
<th class='firstrow lastrow'><span class='stratlabel'>Total<br><span class='stratn'>(N=2544)</span></span></th>
<th class='firstrow lastrow'><span class='stratlabel'>Collingwood<br><span class='stratn'>(N=527)</span></span></th>
<th class='firstrow lastrow'><span class='stratlabel'>Fitzroy<br><span class='stratn'>(N=711)</span></span></th>
<th class='firstrow lastrow'><span class='stratlabel'>Kensington<br><span class='stratn'>(N=450)</span></span></th>
<th class='firstrow lastrow'><span class='stratlabel'>Laverton<br><span class='stratn'>(N=164)</span></span></th>
<th class='firstrow lastrow'><span class='stratlabel'>Paisley<br><span class='stratn'>(N=692)</span></span></th>
</tr>
<tfoot><tr><td colspan="7" class="Rtable1-footnote"><p>coHealth clinics, May 2025, 'active' patients</p>
</td></tr></tfoot>
</thead>
<tbody>
<tr>
<td class='rowlabel firstrow'>Mental Health Plan</td>
<td class='firstrow'></td>
<td class='firstrow'></td>
<td class='firstrow'></td>
<td class='firstrow'></td>
<td class='firstrow'></td>
<td class='firstrow'></td>
</tr>
<tr>
<td class='rowlabel'>Yes</td>
<td>323 (12.7%)</td>
<td>55 (10.4%)</td>
<td>115 (16.2%)</td>
<td>60 (13.3%)</td>
<td>32 (19.5%)</td>
<td>61 (8.8%)</td>
</tr>
<tr>
<td class='rowlabel lastrow'>No</td>
<td class='lastrow'>2221 (87.3%)</td>
<td class='lastrow'>472 (89.6%)</td>
<td class='lastrow'>596 (83.8%)</td>
<td class='lastrow'>390 (86.7%)</td>
<td class='lastrow'>132 (80.5%)</td>
<td class='lastrow'>631 (91.2%)</td>
</tr>
<tr>
<td class='rowlabel firstrow'>Concession card</td>
<td class='firstrow'></td>
<td class='firstrow'></td>
<td class='firstrow'></td>
<td class='firstrow'></td>
<td class='firstrow'></td>
<td class='firstrow'></td>
</tr>
<tr>
<td class='rowlabel'>Yes</td>
<td>2071 (81.4%)</td>
<td>433 (82.2%)</td>
<td>610 (85.8%)</td>
<td>358 (79.6%)</td>
<td>117 (71.3%)</td>
<td>553 (79.9%)</td>
</tr>
<tr>
<td class='rowlabel lastrow'>No</td>
<td class='lastrow'>473 (18.6%)</td>
<td class='lastrow'>94 (17.8%)</td>
<td class='lastrow'>101 (14.2%)</td>
<td class='lastrow'>92 (20.4%)</td>
<td class='lastrow'>47 (28.7%)</td>
<td class='lastrow'>139 (20.1%)</td>
</tr>
<tr>
<td class='rowlabel firstrow'>Condition frequency</td>
<td class='firstrow'></td>
<td class='firstrow'></td>
<td class='firstrow'></td>
<td class='firstrow'></td>
<td class='firstrow'></td>
<td class='firstrow'></td>
</tr>
<tr>
<td class='rowlabel'>high</td>
<td>2022 (79.5%)</td>
<td>434 (82.4%)</td>
<td>536 (75.4%)</td>
<td>369 (82.0%)</td>
<td>122 (74.4%)</td>
<td>561 (81.1%)</td>
</tr>
<tr>
<td class='rowlabel lastrow'>low</td>
<td class='lastrow'>522 (20.5%)</td>
<td class='lastrow'>93 (17.6%)</td>
<td class='lastrow'>175 (24.6%)</td>
<td class='lastrow'>81 (18.0%)</td>
<td class='lastrow'>42 (25.6%)</td>
<td class='lastrow'>131 (18.9%)</td>
</tr>
</tbody>
</table>
</div>
<details class="code-fold">
<summary>Show the code</summary>

``` r
table1(
  x = ~ mhcp | concession,
  data = df |>
    mutate(concession = factor(concession, levels = c(FALSE, TRUE), label = c("No Concession", "Concession"))),
  overall = FALSE
)
```

</details>
<div class="Rtable1">

<table class="Rtable1" data-quarto-postprocess="true">
<colgroup>
<col style="width: 33%" />
<col style="width: 33%" />
<col style="width: 33%" />
</colgroup>
<thead>
<tr>
<th class="rowlabel firstrow lastrow" data-quarto-table-cell-role="th"></th>
<th class="firstrow lastrow" data-quarto-table-cell-role="th"><span class="stratlabel">No Concession<br />
<span class="stratn">(N=473)</span></span></th>
<th class="firstrow lastrow" data-quarto-table-cell-role="th"><span class="stratlabel">Concession<br />
<span class="stratn">(N=2071)</span></span></th>
</tr>
</thead>
<tbody>
<tr>
<td class="rowlabel firstrow">Mental Health Plan</td>
<td class="firstrow"></td>
<td class="firstrow"></td>
</tr>
<tr>
<td class="rowlabel">Yes</td>
<td>79 (16.7%)</td>
<td>244 (11.8%)</td>
</tr>
<tr>
<td class="rowlabel lastrow">No</td>
<td class="lastrow">394 (83.3%)</td>
<td class="lastrow">1827 (88.2%)</td>
</tr>
</tbody>
</table>

</div>
<details class="code-fold">
<summary>Show the code</summary>

``` r
model <- glm(
  mhcp ~ concession + condition,
  family = binomial(link = "logit"),
  data = df
)

model_effects <- glmer(
  mhcp ~ concession + condition + (1|clinic),
  family = binomial(link = "logit"),
  data = df
)

# in this case, using 'clinic' as a random effect makes little difference to the model
```

</details>
<details class="code-fold">
<summary>Show the code</summary>

``` r
label(df$condition) = "condition"

tab_model(
  model, model_effects,
  dv.labels = c(
    "Logistic model",
    "Logistic model - clinic random effects"
  ),
  show.aic = TRUE,
  title = paste(
    "The odds ratio of having been billed a mental health care plan,",
    "according to concession card status and low-vs-high prevalence mental health condition",
    "(coHealth GP clinics, May 2025)"
  )
)
```

</details>
<table style="border-collapse:collapse; border:none;">
<caption style="font-weight: bold; text-align:left;">The odds ratio of having been billed a mental health care plan, according to concession card status and low-vs-high prevalence mental health condition (coHealth GP clinics, May 2025)</caption>
<tr>
<th style="border-top: double; text-align:center; font-style:normal; font-weight:bold; padding:0.2cm;  text-align:left; ">&nbsp;</th>
<th colspan="3" style="border-top: double; text-align:center; font-style:normal; font-weight:bold; padding:0.2cm; ">Logistic model</th>
<th colspan="3" style="border-top: double; text-align:center; font-style:normal; font-weight:bold; padding:0.2cm; ">Logistic model - clinic random effects</th>
</tr>
<tr>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  text-align:left; ">Predictors</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  ">Odds Ratios</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  ">CI</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  ">p</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  ">Odds Ratios</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  ">CI</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal;  col7">p</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(Intercept)</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.20</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.16&nbsp;&ndash;&nbsp;0.26</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.21</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.15&nbsp;&ndash;&nbsp;0.30</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  col7"><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">concessionTRUE</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.67</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.51&nbsp;&ndash;&nbsp;0.89</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.005</strong></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.66</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.50&nbsp;&ndash;&nbsp;0.88</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  col7"><strong>0.004</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">condition: low</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.95</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.70&nbsp;&ndash;&nbsp;1.27</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.730</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.91</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.67&nbsp;&ndash;&nbsp;1.23</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  col7">0.543</td>
</tr>
<tr>
<td colspan="7" style="font-weight:bold; text-align:left; padding-top:.8em;">Random Effects</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&sigma;<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:left;" colspan="3">&nbsp;</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:left;" colspan="3">3.29</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>00</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:left;" colspan="3">&nbsp;</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:left;" colspan="3">0.08 <sub>clinic</sub></td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">ICC</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:left;" colspan="3">&nbsp;</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:left;" colspan="3">0.02</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">N</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:left;" colspan="3">&nbsp;</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:left;" colspan="3">5 <sub>clinic</sub></td>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm; border-top:1px solid;">Observations</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:left; border-top:1px solid;" colspan="3">2544</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:left; border-top:1px solid;" colspan="3">2544</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">R<sup>2</sup> Tjur</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:left;" colspan="3">0.003</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:left;" colspan="3">0.008 / 0.032</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">AIC</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:left;" colspan="3">1934.345</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:left;" colspan="3">1922.609</td>
</tr>

</table>
