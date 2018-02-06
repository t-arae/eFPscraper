
DATASOURCE <-
  c(
    "Abiotic_Stress", #1
    "Abiotic_Stress_II", #2
    "Biotic_Stress", #3
    "Biotic_Stress_II", #4
    "Chemical", #5
    "Developmental_Map", #6
    "Developmental_Mutants", #7
    "Guard_Cell", #8
    "Hormone", #9
    "Lateral_Root_Initiation", #10
    "Light_Series", #11
    "Natural_Variation", #12
    "Regeneration", #13
    "Root", #14
    "Root_II", #15
    "Seed", #16
    "Tissue_Specific" #17
  )
usethis::use_data(DATASOURCE, overwrite = TRUE)

sampledata_relative <- eFPscraper::get_efp_relative("At1g01010", eFPscraper::DATASOURCE)
usethis::use_data(sampledata_relative, overwrite = TRUE)

sampledata_absolute<- eFPscraper::get_efp_absolute("At1g01010", eFPscraper::DATASOURCE)
usethis::use_data(sampledata_absolute, overwrite = TRUE)
