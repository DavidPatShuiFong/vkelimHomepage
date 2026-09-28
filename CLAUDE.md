# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

David Fong's personal website (https://www.davidfong.org): an R **blogdown** project on **Hugo 0.76.4** with the **hugo-academic** theme. Netlify deploys it from `master`.

## Build and deploy model

- Netlify runs only `hugo` (see `netlify.toml`, Hugo pinned to 0.76.4). It does **not** run R or Quarto. Every rendered output (`index.html` / `index.md`, `*_files/` figure and lib folders, CV PDFs) **must be committed**. If you change an `.Rmd` or `.qmd` without re-rendering it, the live site does not change.
- `public/` and `resources/` are gitignored build output. Don't edit them.
- Keep Hugo at 0.76.4. It is pinned in both `.Rprofile` (`blogdown.hugo.version`) and `netlify.toml`. The theme and templates depend on this old version.

Common commands, run from an R session at the repo root. `.Rprofile` sets blogdown options, so restart R after editing it:

```r
blogdown::serve_site()                 # local preview with livereload
blogdown::build_site(build_rmd = TRUE) # full build including knitting Rmd
options(blogdown.server.timeout = 1200) # may be needed for slow builds (README)
source("R/build.R")                    # blogdown build hook; see below
```

`R/build.R` runs `blogdown::build_dir('static')` and renders the CV. It needs **chromium** for `pagedown::chrome_print`. Required packages: `blogdown`, `pagedown`. `git` must be on PATH (`enableGitInfo = true`).

## Content authoring formats

Posts are Hugo page bundles, `content/post/<Name>/index.*`, with a `featured.jpg` for the card image. The repo uses two source formats:

1. **R Markdown** (most older posts): `index.Rmd` is knit by blogdown to `index.html` (`blogdown.method = 'html'`, knit on save).
2. **Quarto** (newer posts, e.g. `MHTPdisadvantage`, `UniversalBulkBilling*`, `GPManagmentPlanNew`): `index.qmd` uses `format: hugo-md` and `engine: knitr`. Run `quarto render index.qmd` in the post directory. This produces the `index.md` that Hugo serves, plus `index.markdown_strict_files/` figures. Commit both. Some posts carry Quarto extensions in a local `_extensions/` folder (e.g. `coatless/webr`).

`config.toml` `ignoreFiles` makes Hugo skip `.Rmd`, `.qmd`, `.Rmarkdown`, `.py`, and `_cache`. Only the rendered outputs are published.

Standalone documents live in `static/document/<Name>/`. For example, `PatientComplexityNeeds` is its own Quarto project with `_quarto.yml`, `references.bib`, CSL files and HTML/PDF outputs, and posts link to it. Files in `static/` are copied to the site root as-is, so `static/Paulus/` is served at `/Paulus/`.

## CV

`static/CV/` uses the `datadrivencv` package. The data is in `static/CV/assets/datadrivencv/` and the template is `index.Rmd`, which takes a `pdf_mode` param. `static/CV/render_cv.r` (run from inside `static/CV/`) or `R/build.R` (run from the root) produce `cv.html`/`index.html` and `cv.pdf`. Commit the regenerated PDF.

## Site configuration and theme

- `config.toml`: core Hugo settings, including permalinks (singular taxonomies) and the goldmark `unsafe = true` setting that allows raw HTML in Markdown.
- `config/_default/params.toml`, `menus.toml`, `languages.toml`: Academic theme params and nav menus.
- `content/home/*.md`: homepage widgets. Each file is one section, with its order and visibility set in front matter.
- `themes/hugo-academic/` is **vendored** (not a submodule). Put customisations in the root `layouts/` overrides instead of editing the theme. Existing overrides include utterances comments (`layouts/partials/comments/`), the post gallery section (`layouts/section/postGallery.html`), portfolio/pages widgets, and custom RSS templates (`layouts/post/rss.xml`, `layouts/categories/rss.xml`) used for feeds.

## Quarto transition (`develop` branch)

`develop` is moving the site from Hugo to a Quarto website. `master` still deploys Hugo. On `develop`:

- `_quarto.yml` is the site config, and `netlify.toml` uses `@quarto/netlify-plugin-quarto` (Quarto pinned to the local version, publish `_site`). Netlify branch deploys give the preview. Netlify can't run R, so render locally with `execute: freeze: auto` and commit `_freeze/`. `_site/` is gitignored.
- Hugo sources stay in `content/` until cutover, and `project.render` lists only the Quarto files. **Quarto globs match at any depth unless they start with `/`.** Unanchored `post/*/index.qmd` also matched `content/post/*/index.qmd` and re-rendered the Hugo originals, so keep `/post/*/index.qmd` anchored and avoid broad `resources:` entries.
- All posts are migrated: 61 from Rmd, 4 from `hugo-md` .qmd, and 1 from .md. The Rmd conversion removed the setup chunk. `htmltools::HTML(...)` gallery chunks were evaluated once and embedded as raw ```` ```{=html} ```` blocks, blogdown `video` shortcodes became `<video>` tags pointing at `/media/`, and `eval=FALSE` chunks became plain ```` ```r ```` blocks. Only the analysis posts (`mhtpdisadvantage`, `universalbulkbilling*`, `gpmanagmentplannew`) still execute R.
- Publications and projects are migrated to `publication/<lowercase-dir>/` and `project/<lowercase-dir>/`, with listing pages at `/publication/` and `/project/`. For publications, the venue goes in `subtitle`, and the Academic link fields (`url_pdf`, `doi`, `links`, bundle PDF, `cite.bib`) are written into the body as `.btn` links. One project page embeds a document from `static/` in an iframe and defines its own `resizeIframe` script, which was in `layouts/projects/single.html` in Hugo.
- The home page (`index.qmd`) rebuilds the active Hugo home widgets in the same order, with the old `#anchors`: featured posts (posts with `featured: true`), recent posts, projects, gallery, publications, biography, tag cloud and contact. The contact form is a Netlify Form named `contact`, the same as Hugo's. The tag cloud is a custom listing template (`_templates/tagcloud.ejs`) that merges tags differing only in case, as Hugo did. Listing template output is parsed as Markdown, so the template emits its HTML on one line.
- The flower gallery (`content/postGallery/`) is migrated to `postgallery/<hugo-slug>/` (lowercase, spaces become `-`), with a listing at `/postgallery/`.
- Home-page listings of a whole section use `"project/*/index.qmd"` rather than `project`. The directory form also picks up the section's own `index.qmd` listing page.
- Deliberately not migrated: `content/courses/` and `content/slides/`, which are the Academic theme's demo pages (unedited since the theme was added, and not linked from anywhere), and the Talks section, which is inactive on the Hugo home page and only holds the theme's example talk. Their URLs stop existing at cutover.
- Listings in subfolders (`spurafrika2021/`, `spurafrika2023/`) need `contents: "../post/**/index.qmd"`. `../post` and `/post` match nothing.
- `styles.css` restores Academic behaviour for the old fancybox/isotope galleries (Bootstrap 5's `.grid` class is a CSS grid) and caps image and video width.
- Migrated posts go in `post/<lowercase-hugo-dir-or-slug>/index.qmd`, which keeps the old Hugo URLs (Hugo lowercases paths). Convert Hugo `categories` plus `tags` to Quarto `categories`, `lastmod` to `date-modified`, and use `image: featured.jpg`.
- `scripts/copy-static.ts` (post-render) copies `static/` into `_site/`, the same way Hugo serves `static/` from the site root.
- **Comments:** existing utterances threads are GitHub issues titled with the lowercase Hugo pathname (e.g. `post/kdeoverview/`). Each migrated post sets the full `comments.utterances` block (`repo`, `issue-term: "post/<slug>/"`, `theme`) in its front matter. A per-document block replaces the site-level one rather than merging, and Quarto's template ignores `label`.
- `quarto render` deletes the tracked root `index.html` (blogdown output of `index.Rmd`) because it sits next to `index.qmd`. Run `git restore index.html` after rendering until cutover.
- If `quarto` isn't on PATH, use RStudio's bundled copy: `/usr/lib/rstudio/resources/app/bin/quarto/bin/quarto render`.
