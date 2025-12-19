library(stringr)
library(readr)
library(purrr)

dir.create("data_text/clean", recursive = TRUE, showWarnings = FALSE)

files <- list.files("data_text/raw", pattern = "\\.txt$", full.names = TRUE)

clean_one <- function(x) {
  x <- str_replace_all(x, "\r", "\n")
  x <- str_replace_all(x, "\u00A0", " ")
  x <- str_replace_all(x, "[ \t]+", " ")
  x <- str_replace_all(x, "\n{3,}", "\n\n")

  lines <- str_split(x, "\n", simplify = TRUE)
  keep <- apply(lines, 1, function(s) {
    letters <- str_count(s, "\\p{L}")
    letters >= 2
  })
  x <- paste(lines[keep], collapse = "\n")

  str_trim(x)
}

walk(files, function(p) {
  txt <- read_file(p)
  out <- file.path("data_text/clean", basename(p))
  write_lines(clean_one(txt), out)
})
