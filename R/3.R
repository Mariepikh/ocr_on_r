library(udpipe)
library(data.table)
library(readr)
library(dplyr)
library(stringr)

dir.create("outputs", showWarnings = FALSE)

ud_model <- udpipe_load_model('./russian-gsd-ud-2.5-191206.udpipe')

txt_files <- list.files("data_text/clean", pattern = "\\.txt$", full.names = TRUE)

anno_one <- function(path) {
  doc_id <- tools::file_path_sans_ext(basename(path))
  x <- read_file(path)
  a <- udpipe_annotate(ud_model, x = x, doc_id = doc_id)
  as.data.frame(a)
}

anno <- rbindlist(lapply(txt_files, anno_one), fill = TRUE)

tokens <- anno |>
  filter(!is.na(lemma), upos != "PUNCT") |>
  mutate(lemma = tolower(lemma)) |>
  filter(str_detect(lemma, "\\p{L}"))

lemma_freq <- tokens |>
  count(lemma, sort = TRUE)

fwrite(lemma_freq, "outputs/lemma_frequency.csv")
saveRDS(tokens, "outputs/tokens.rds")
