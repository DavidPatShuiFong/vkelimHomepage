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

## Quarto site (`develop` branch)

`develop` is moving the site from Hugo to a Quarto website. `master` still deploys Hugo, and the Hugo sources (`content/`, `config/`, `layouts/`, `themes/`) stay in place until cutover.

### Build and deploy

- Render with `quarto render`. If `quarto` isn't on PATH, use RStudio's bundled copy at `/usr/lib/rstudio/resources/app/bin/quarto/bin/quarto`. Rendering also needs **`uv` on PATH** (installed in `~/.local/bin`) for the photo-gallery extension. Without it, `/postgallery/` shows "photo-gallery: script produced no output".
- `quarto render` deletes the tracked root `index.html` (blogdown output of `index.Rmd`) because it sits next to `index.qmd`. Run `git restore index.html` afterwards until cutover.
- Netlify runs `scripts/netlify-build.sh` (see `netlify.toml`). It installs pinned uv and Quarto, runs `quarto render` and publishes `_site/`, which is gitignored. Keep `QUARTO_VERSION` in step with the local Quarto. The Quarto Netlify plugin can't be used, because it renders in a separate step that doesn't see uv.
- Netlify can't run R. Posts with R code (`mhtpdisadvantage`, `universalbulkbilling*`, `gpmanagmentplannew`) render locally with `execute: freeze: auto`; commit `_freeze/`.
- `scripts/copy-static.ts` (post-render) copies `static/` into `_site/`, as Hugo served `static/` from the site root (`/CV/`, `/media/`, `/document/`…).

### Where things live

| Path | What |
|---|---|
| `_quarto.yml` | site config, navbar, footer line, render list, theme |
| `index.qmd` | home page (sections and listings) |
| `post/<slug>/index.qmd`, `project/…`, `publication/…` | content, at the old lowercase Hugo URLs |
| `post/_metadata.yml` (and in `project/`, `publication/`) | defaults for every page in that folder: featured-image filter and comments |
| `postgallery/` | flower photos: `img/` album + one page per photo |
| `posts.qmd`, `project/index.qmd`, `publication/index.qmd`, `postgallery/index.qmd`, `spurafrika20xx/index.qmd` | listing pages |
| `theme/common.scss`, `light.scss`, `dark.scss` | all custom styling |
| `_templates/*.ejs*` | custom listing templates (masonry cards, tag cloud) |
| `_filters/featured-image.lua`, `_includes/utterances.html` | shared page furniture |
| `_extensions/andrewheiss/photo-gallery` | masonry photo gallery (installed with `quarto add`) |

### Writing a post

```yaml
---
title: "…"
author: David Fong          # or a list
date: 2025-06-01
categories: [Kenya, Spur Afrika, Spur Afrika 2025]   # Hugo categories + tags merged
image: featured.jpg         # shown at the top of the page and in listings
image-caption: "Photo by …" # optional (Markdown/HTML)
featured: true              # optional: appears in the home page Featured Posts
---
```

- Put the post in `post/<slug>/index.qmd`, with images alongside. It is rendered automatically (`/post/*/index.qmd` in `project.render`).
- The picture at the top comes from `image` (`_filters/featured-image.lua`). Don't repeat it in the body; set `image-banner: false` to hide it.
- Comments are automatic (`_includes/utterances.html`). Each thread is a GitHub issue titled with the page path (`post/<slug>/`), matching the Hugo site's threads, including when a page is visited as `…/index.html`.
- Photo groups use Quarto figure layout plus its built-in lightbox: `::: {layout="[[63,35],[49,49]]"}`, then one `![](photo.jpg){.lightbox group="<slug>"}` per image, **separated by blank lines**. Otherwise they become one cell. A negative width is empty space, e.g. `[45,-55]`.
- Videos: `{{< video /media/clip.mp4 >}}` (files in `static/media/`) or `{{< video https://www.youtube.com/embed/ID >}}`.
- Trip pages list posts by category, e.g. `spurafrika2023/index.qmd` includes `categories: "Spur Afrika 2023"`. Categories are case-sensitive in Quarto.

### Look and feel

- Colours and fonts reproduce the Hugo Academic site: theme "1950s", fonts "Rose", size "L". `theme/common.scss` starts with a contents list and a **design values** block (font sizes, card shadow, gutter widths); change values there rather than in the rules. `light.scss` is the 1950s palette. `dark.scss` is Academic's default day/night dark palette, since 1950s defines none. Each palette starts with named colours, and everything else refers to them. The coral accent is `$primary` (links, buttons and focus rings derive from it) and has to be changed in both palettes. The palettes can't use variables from `common.scss`, because Quarto compiles the palettes' defaults first. Form-field colours (`$input-*`) are set in the palettes too.
- Home page layout is chosen in `index.qmd` with classes on each `##` heading, which Pandoc moves onto its section: default = title in a 3/12 left gutter; `.gutter-wide` = 4/12; `.full-width`; `.title-hidden` (visually hidden, anchor kept); `.profile-section` (gutter holds `::: {.profile}`, the title heads `::: {.bio}`). Everything stacks below `lg`. Old Hugo `#anchors` are kept as heading ids.
- Home "Featured Posts" (posts with `featured: true`) and "Posts" use `_templates/cards-masonry.ejs.md` (Masonry 4.2.2 from jsDelivr; 3/2/1 columns). The tag cloud is `_templates/tagcloud.ejs` (top 20 categories, case-insensitive like Hugo). Its section links are root-relative, so they work on any page. The contact form is a Netlify Form named `contact`, the same as Hugo's.
- `/postgallery/` uses the photo-gallery extension in masonry layout. Captions come from `postgallery/img/album.yml`. An inline script reverses the extension's filename order to newest first. Thumbnails (`img/thumbs/`, gitignored) are regenerated only when the original is newer, so delete `thumbs/` after changing thumbnail settings.
- Footer line and back-to-top button are set in `_quarto.yml` (`website.page-footer`, `back-to-top-navigation`). The footer is styled in `common.scss` section 9.
- `/project/` has All/Kenya filter buttons (inline script in `project/index.qmd`) that drive Quarto's own category filter. Add a button there for another category.

### Gotchas

- **Quarto render globs match at any depth unless they start with `/`.** An unanchored `post/*/index.qmd` also matched `content/post/…` and re-rendered the Hugo originals. For the same reason, avoid broad `resources:` globs.
- Listing `contents`: from the site root, a whole section is `"project/*/index.qmd"`; plain `project` also picks up the section's own index page. From a subfolder use `"../post/**/index.qmd"`; `../post` and `/post` match nothing.
- Custom listing templates receive only `items` (no `listing`, so no `fields`), and their output is parsed as Markdown: keep generated HTML on one line or inside ```` ```{=html} ```` blocks.
- A per-page `comments:` block replaces the site-level one rather than merging, and Quarto's utterances support drops `label`. That is why comments come from `_includes/utterances.html` instead.
- Selectors restyling Quarto listings start with `div.quarto-post …` to match the specificity of Quarto's own rules.

### Migration notes

- Converted from Hugo: 61 Rmd posts, 4 `hugo-md` .qmd posts, 1 .md post, 5 publications, 8 projects, 11 gallery photos. Posts' Hugo-era fancybox + isotope galleries became Quarto layouts with `.lightbox`, keeping the original row widths. The exception is `post/blogdownmasonrygallery`, a tutorial about that technique. Its code sample and demo were corrected in September 2026, with a note in the post (the original had an unpinned fancybox CSS and invalid `data-isotope` JSON, so isotope never ran). They are self-contained, with inline styles and isotope set up by script.
- Deliberately not migrated: `content/courses/` and `content/slides/`, which are the Academic theme's demo pages (not linked anywhere); the Talks section, which is inactive on the Hugo home page and only holds the theme's example talk; and `content/privacy.md` and `content/terms.md`, which are unpublished theme drafts (404 on the live site).
