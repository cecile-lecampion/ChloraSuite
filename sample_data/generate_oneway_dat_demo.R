set.seed(20260522)

base_dir <- file.path("sample_data")
out_dir <- file.path(base_dir, "fluorcam_oneway_demo_dat")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

build_area_values <- function(base_value, n_areas = 4, sd_value = 6) {
  vals <- stats::rnorm(n_areas, mean = base_value, sd = sd_value)
  pmax(vals, 1)
}

line_from_values <- function(label, values, digits = 2) {
  formatted <- if (is.numeric(values)) {
    sprintf(paste0("%.", digits, "f"), values)
  } else {
    values
  }
  paste(c(label, formatted), collapse = "\t")
}

write_fluorcam_dat <- function(file_path, base_fo, base_fm) {
  fo_vals <- build_area_values(base_fo, sd_value = 3)
  fm_vals <- build_area_values(base_fm, sd_value = 10)
  fv_vals <- pmax(fm_vals - fo_vals, 1)

  fm_l1_vals <- fm_vals * runif(4, 0.70, 0.76)
  fm_l2_vals <- fm_vals * runif(4, 0.54, 0.60)
  fm_l3_vals <- fm_vals * runif(4, 0.48, 0.54)
  fm_d1_vals <- fm_vals * runif(4, 0.62, 0.69)
  fm_d2_vals <- fm_vals * runif(4, 0.78, 0.84)

  txt_lines <- c(
    "FluorCam7 Numeric Avg Export File",
    "",
    "-----------------------------------",
    "",
    "\tArea 1\tArea 2\tArea 3\tArea 4",
    "",
    line_from_values("Size [pixels]", as.integer(round(runif(4, min = 38000, max = 76000), 0)), digits = 0),
    "",
    line_from_values("Fo", fo_vals),
    "",
    line_from_values("Fm", fm_vals),
    "",
    line_from_values("Fv", fv_vals),
    "",
    line_from_values("Fm_L1", fm_l1_vals),
    "",
    line_from_values("Fm_L2", fm_l2_vals),
    "",
    line_from_values("Fm_L3", fm_l3_vals),
    "",
    line_from_values("Fm_D1", fm_d1_vals),
    "",
    line_from_values("Fm_D2", fm_d2_vals)
  )

  writeLines(txt_lines, file_path)
}

oneway_grid <- expand.grid(
  Batch = c("B1", "B2"),
  Treatment = c("Ctrl", "TreatA", "TreatB"),
  Rep = 1:2,
  stringsAsFactors = FALSE
)

for (i in seq_len(nrow(oneway_grid))) {
  row <- oneway_grid[i, ]

  batch_effect <- if (row$Batch == "B2") 6 else 0
  treatment_effect <- switch(
    row$Treatment,
    Ctrl = 0,
    TreatA = 18,
    TreatB = -12,
    0
  )

  base_fo <- 150 + batch_effect * 0.3 + treatment_effect * 0.1 + stats::rnorm(1, 0, 1.5)
  base_fm <- 680 + batch_effect + treatment_effect + stats::rnorm(1, 0, 8)

  file_name <- paste(row$Batch, row$Treatment, paste0("R", row$Rep), sep = "_")
  write_fluorcam_dat(file.path(out_dir, paste0(file_name, ".dat")), base_fo, base_fm)
}

README_path <- file.path(out_dir, "README_dat_demo.txt")
writeLines(c(
  "One-way FluorCam demo in .dat format",
  "",
  "Files follow the same Batch_Treatment_R*.dat naming pattern as fluorcam_oneway_demo.",
  "Use them to test file assembly and plots with .dat inputs."
), README_path)

cat("Generated one-way DAT demo in:", out_dir, "\n")
cat("Files:", nrow(oneway_grid), "DAT files\n")
