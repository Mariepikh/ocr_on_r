library(tesseract)
library(magick)
library(stringr)
library(readr)
library(dplyr)
library(purrr)
library(progress)

dir.create("data_proc/img", recursive = TRUE, showWarnings = FALSE)
dir.create("data_text/raw", recursive = TRUE, showWarnings = FALSE)

ocr_lang <- "rus"
engine <- tesseract(ocr_lang)

imgs <- list.files("data_raw/img", pattern = "\\.(jpg|jpeg|png)$", full.names = TRUE, ignore.case = TRUE)

preprocess <- function(path) {
  img <- image_read(path)

  img <- image_convert(img, colorspace = "Gray")
  img <- image_resize(img, "2000x")
  img <- image_deskew(img, threshold = 40)
  img <- image_trim(img)
  img <- image_normalize(img)
  img <- image_threshold(img, "white", threshold = "55%")

  img
}

pb <- progress_bar$new(
  total = length(imgs),
  format = "OCR [:bar] :current/:total (:percent) eta: :eta"
)

walk(imgs, function(p) {
  pb$tick()

  base <- tools::file_path_sans_ext(basename(p))
  out_img  <- file.path("data_proc/img", paste0(base, ".png"))
  out_txt  <- file.path("data_text/raw", paste0(base, ".txt"))

  if (file.exists(out_txt)) return(invisible(NULL))

  img2 <- preprocess(p)

  image_write(img2, path = out_img, format = "png")

  txt <- ocr(img2, engine = engine)

  txt <- str_replace_all(txt, "[ \t]+", " ")
  txt <- str_replace_all(txt, "\n{3,}", "\n\n")

  write_lines(txt, out_txt)
})
