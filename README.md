# vkelimHomepage

[![Netlify Status](https://api.netlify.com/api/v1/badges/67c5fa84-2de0-4806-8a46-7649ec193da5/deploy-status)](https://app.netlify.com/sites/davidfong/deploys)

https://www.davidfong.org

A [Quarto](https://quarto.org/) website (converted from Hugo/blogdown with the
Academic theme in 2026). Netlify builds and publishes it from `master`.

## Requirements

- [Quarto](https://quarto.org/docs/get-started/) (RStudio includes a copy).
  Netlify uses the version pinned in `scripts/netlify-build.sh`.
- [uv](https://docs.astral.sh/uv/), used by the photo-gallery extension on the
  Gallery page.
- R, only for posts with R code (they are rendered locally and their results
  stored in `_freeze/`), and for the CV.

## Build and preview

```bash
quarto preview      # live preview while editing
quarto render       # full build into _site/
```

Commit any changes in `_freeze/` after rendering posts with R code: Netlify
cannot run R.

## Writing a post

Create `post/<slug>/index.qmd` with its pictures alongside:

```yaml
---
title: "…"
author: David Fong
date: 2026-01-31
categories: [Kenya, Spur Afrika]
image: featured.jpg          # shown at the top of the post and in lists
image-caption: "Photo by …"  # optional
featured: true               # optional: home page "Featured Posts"
---
```

Comments (utterances) and the header picture are added automatically. See
`CLAUDE.md` for photo layouts, videos, the home page and the theme.

## CV

The CV is built from `static/CV/` (data in `static/CV/assets/datadrivencv/`):

```bash
Rscript scripts/build-cv.R
```

This needs Chrome or Chromium for the PDF. Commit `static/CV/index.html` and
`static/CV/cv.pdf`.
