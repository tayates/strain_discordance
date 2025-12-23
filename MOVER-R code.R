## Code to calculate proportion of TB attributable to recent household transmission

# Written by Tom Yates, December 2025
# Requires users to load 'MOVER-R data.csv' file into Studies, i.e. Studies <- read.csv("FILEPATH")
# As R is not Tom's favoured statistical package, ChatGPT used to debug code
# Requires the following packages: dplyr, purrr, officer, MOVER


# Calculate number of concordant pairs
Studies$concordant_pairs <- Studies$total_household_pairs - Studies$discordant_pairs

# Calculate proportion concordant with binomial confidence interval

Studies <- Studies %>%
  mutate(result = map2(concordant_pairs, total_household_pairs,
                       ~ binom.test(.x, .y))) %>%
  mutate(
    concordant     = map_dbl(result, ~ .x$estimate),
    concordant_ll  = map_dbl(result, ~ .x$conf.int[1]),
    concordant_ul  = map_dbl(result, ~ .x$conf.int[2])
  ) %>%
  select(-result)

# Fill in estimates of exposure

Studies <- Studies %>%
  mutate(
    exposed = case_when(
      sampling_duration_category == "lowmid_1" ~ 0.158008135,
      sampling_duration_category == "lowmid_2" ~ 0.186847558,
      sampling_duration_category == "lowmid_3" ~ 0.223908467, 
      sampling_duration_category == "lowmid_4" ~ 0.240053671,
      sampling_duration_category == "lowmid_5" ~ 0.257770549,
      sampling_duration_category == "high_1" ~ 0.128967452,
      sampling_duration_category == "high_2" ~ 0.134436406,
      sampling_duration_category == "high_3" ~  0.14276969, 
      sampling_duration_category == "high_4" ~ 0.14994543,
      sampling_duration_category == "high_5" ~ 0.155984651
    ),
    exposed_ll = case_when(
      sampling_duration_category == "lowmid_1" ~ 0.106381793,
      sampling_duration_category == "lowmid_2" ~ 0.129102688,
      sampling_duration_category == "lowmid_3" ~ 0.156081509, 
      sampling_duration_category == "lowmid_4" ~ 0.168132008,
      sampling_duration_category == "lowmid_5" ~ 0.182497387,
      sampling_duration_category == "high_1" ~ 0.087082525,
      sampling_duration_category == "high_2" ~ 0.089843879,
      sampling_duration_category == "high_3" ~  0.092822075, 
      sampling_duration_category == "high_4" ~ 0.095384893,
      sampling_duration_category == "high_5" ~ 0.097201566
    ),
    exposed_ul = case_when(
      sampling_duration_category == "lowmid_1" ~ 0.229836571,
      sampling_duration_category == "lowmid_2" ~ 0.265568279,
      sampling_duration_category == "lowmid_3" ~ 0.31501118, 
      sampling_duration_category == "lowmid_4" ~ 0.335969232,
      sampling_duration_category == "lowmid_5" ~ 0.357074704,
      sampling_duration_category == "high_1" ~ 0.185905212,
      sampling_duration_category == "high_2" ~ 0.196616503,
      sampling_duration_category == "high_3" ~  0.219217816, 
      sampling_duration_category == "high_4" ~ 0.238734246,
      sampling_duration_category == "high_5" ~ 0.258042395
    )
  )

# Create columns with the inverse values

Studies <- Studies %>%
  mutate(
    inv_exposed       = 1 / exposed,
    inv_exposed_ll    = 1 / exposed_ul,
    inv_exposed_ul    = 1 / exposed_ll,
    inv_concordant    = 1 / concordant,
    inv_concordant_ll = 1 / concordant_ul,
    inv_concordant_ul = 1 / concordant_ll
  )

# MOVERR for A/(1/B)

moverr_results1 <- apply(Studies, 1, function(row) {
  result <- MOVERR(
    theta1 = as.numeric(row["concordant"]),
    ci1 = as.numeric(row[c("concordant_ll", "concordant_ul")]),
    theta0 = as.numeric(row["inv_exposed"]),
    ci0 = as.numeric(row[c("inv_exposed_ll", "inv_exposed_ul")])
  )
  return(c(
    estimate1 = result$estimate,
    lower1    = result$conf.int[1],
    upper1    = result$conf.int[2]
  ))
})

moverr_results1_df <- as.data.frame(t(moverr_results1))

# MOVERR for B/(1/A)

moverr_results2 <- apply(Studies, 1, function(row) {
  result <- MOVERR(
    theta1 = as.numeric(row["exposed"]),
    ci1 = as.numeric(row[c("exposed_ll", "exposed_ul")]),
    theta0 = as.numeric(row["inv_concordant"]),
    ci0 = as.numeric(row[c("inv_concordant_ll", "inv_concordant_ul")])
  )
  return(c(
    estimate2 = result$estimate,
    lower2    = result$conf.int[1],
    upper2    = result$conf.int[2]
  ))
})

moverr_results2_df <- as.data.frame(t(moverr_results2))

# Combine both MOVERR results with the original data

Studies_final <- cbind(Studies, moverr_results1_df, moverr_results2_df)

# Compute geometric means of the estimates and their confidence intervals

Studies_final$geo_mean        <- sqrt(Studies_final$estimate1 * Studies_final$estimate2) * 100
Studies_final$geo_mean_lower  <- sqrt(Studies_final$lower1    * Studies_final$lower2) * 100
Studies_final$geo_mean_upper  <- sqrt(Studies_final$upper1    * Studies_final$upper2) * 100

# Generate headline result column for export into Word table

Studies_final <- Studies_final %>%
  mutate(
    mainresult = paste0(
      round(geo_mean, 1),
      " (",
      round(geo_mean_lower, 1),
      "-",
      round(geo_mean_upper, 1),
      ")"
    )
  )

# Export to Word

Studies_selected <- Studies_final[, c("study", "sampling_duration_months", "mainresult")]

doc <- read_docx()
doc <- body_add_table(doc, value = Studies_selected)
print(doc, target = "/Users/tyates/Documents/Paired cases review - update/Manuscript/MOVER-R/Table2c.docx")


