# Rebuild the CV (served at /CV/ from static/CV/). Run from the repo root:
#
#   Rscript scripts/build-cv.R
#
# Then commit static/CV/index.html and static/CV/cv.pdf. The CV data is in
# static/CV/assets/datadrivencv/. Needs the rmarkdown, datadrivencv, fs and
# pagedown packages, and Chrome/Chromium for the PDF.
#
# (Replaces the blogdown build hook R/build.R, which did the same after
# `blogdown::build_dir("static")`.)

# HTML version, served as /CV/
rmarkdown::render("static/CV/index.Rmd",
                  params = list(pdf_mode = FALSE),
                  output_file = "index.html")

# PDF version: knit a print layout to a temporary HTML file, then print it
tmp_html_cv_loc <- fs::file_temp(ext = ".html")
rmarkdown::render("static/CV/index.Rmd",
                  params = list(pdf_mode = TRUE),
                  output_file = tmp_html_cv_loc)

pagedown::chrome_print(
  input = tmp_html_cv_loc,
  output = "static/CV/cv.pdf"
)
