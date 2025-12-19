library(udpipe)
library(data.table)
library(ggplot2)
library(dplyr)

tokens <- readRDS("outputs/tokens.rds")
tokens_df <- as.data.frame(tokens)

coll <- keywords_collocation(
  x = tokens_df,
  term = "lemma",
  group = "doc_id",
  ngram_max = 2
)

df <- as.data.frame(coll)

df$collocation <- if (!is.null(df$keyword)) as.character(df$keyword) else paste(df$left, df$right)

df$pmi  <- as.numeric(df$pmi)
df$freq <- as.numeric(df$freq)

df <- df |>
  filter(!is.na(pmi), !is.na(collocation), nzchar(collocation), freq >= 3) |>
  arrange(desc(pmi)) |>
  distinct(collocation, .keep_all = TRUE) |>
  slice_head(n = 30)

df$collocation <- factor(df$collocation, levels = rev(df$collocation))

p <- ggplot(df, aes(x = collocation, y = pmi)) +
  geom_col() +
  coord_flip() +
  labs(x = "Коллокации", y = "PMI", title = "Топ коллокаций по PMI")

ggsave("outputs/collocations_top.png", p, width = 10, height = 7)
write.csv(df, "outputs/collocations_top30.csv", row.names = FALSE)
