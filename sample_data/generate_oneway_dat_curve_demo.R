set.seed(20260522)

base_dir <- file.path("sample_data")
out_dir <- file.path(base_dir, "fluorcam_oneway_demo_curve_dat")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

make_curve_values <- function(time_points, base_level, amplitude, decay, noise_sd = 4) {
  curve <- base_level + amplitude * exp(-pmax(time_points, 0) / decay)
  curve + stats::rnorm(length(time_points), mean = 0, sd = noise_sd)
}

build_dat_lines <- function(time_points, matrix_values) {
  column_names <- paste0("E ", 5:13)
  header <- paste(c("", column_names, ""), collapse = ",")
  lines <- c(header)
  for (i in seq_along(time_points)) {
    row_vals <- c(sprintf("%.2f", time_points[i]), sprintf("%.4f", matrix_values[i, ]), "")
    lines <- c(lines, paste(row_vals, collapse = ","))
  }
  lines
}

write_curve_dat <- function(file_path, time_points, condition_effect = 0, rep_effect = 0) {
  n_cols <- 9
  n_rows <- length(time_points)
  matrix_values <- matrix(0, nrow = n_rows, ncol = n_cols)

  # Keep the first row as zeros, like the user-provided prototype.
  for (j in seq_len(n_cols)) {
    if (j <= 4) {
      matrix_values[-1, j] <- make_curve_values(
        time_points[-1],
        base_level = 120 + condition_effect + rep_effect + j * 1.5,
        amplitude = 20 + j,
        decay = 900 + j * 40,
        noise_sd = 2.5
      )
    } else {
      matrix_values[-1, j] <- make_curve_values(
        time_points[-1],
        base_level = 420 + condition_effect * 2 + rep_effect + j * 8,
        amplitude = 260 + j * 15,
        decay = 350 + j * 20,
        noise_sd = 6
      )
    }
  }

  # Make the later time points resemble the sharp increase / plateau seen in the prototype.
  matrix_values[14:n_rows, ] <- matrix_values[14:n_rows, ] + 180
  matrix_values[15:n_rows, ] <- matrix_values[15:n_rows, ] - 60
  matrix_values[16:n_rows, ] <- matrix_values[16:n_rows, ] - 100
  matrix_values[17:n_rows, ] <- matrix_values[17:n_rows, ] - 130
  matrix_values[18:n_rows, ] <- matrix_values[18:n_rows, ] - 150

  dat_lines <- build_dat_lines(time_points, matrix_values)
  writeLines(dat_lines, file_path)
}

time_points <- c(-34.86, -24.86, 5.17, 45.2, 103.23, 171.26, 259.29, 377.32,
                 545.35, 763.38, 981.41, 1199.44, 1417.47, 1715.5, 1740.5,
                 1840.5, 2040.5, 2340.5)

oneway_grid <- expand.grid(
  Batch = c("B1", "B2"),
  Treatment = c("Ctrl", "TreatA", "TreatB"),
  Rep = 1:2,
  stringsAsFactors = FALSE
)

for (i in seq_len(nrow(oneway_grid))) {
  row <- oneway_grid[i, ]
  condition_effect <- switch(row$Treatment, Ctrl = 0, TreatA = 10, TreatB = -8, 0)
  batch_effect <- if (row$Batch == "B2") 6 else 0
  rep_effect <- if (row$Rep == 2) 3 else 0

  file_name <- paste(row$Batch, row$Treatment, paste0("R", row$Rep), sep = "_")
  write_curve_dat(
    file.path(out_dir, paste0(file_name, ".dat")),
    time_points = time_points,
    condition_effect = condition_effect + batch_effect,
    rep_effect = rep_effect
  )
}

writeLines(c(
  "One-way FluorCam demo in .dat format (curve-style)",
  "",
  "This dataset matches the user's initial prototype structure:",
  "- first row of zeros",
  "- first column = time values",
  "- columns E 5 ... E 13",
  "",
  "Use it to test file assembly and plotting with .dat inputs."
), file.path(out_dir, "README_curve_dat_demo.txt"))

cat("Generated curve-style one-way DAT demo in:", out_dir, "\n")
cat("Files:", nrow(oneway_grid), "DAT files\n")
