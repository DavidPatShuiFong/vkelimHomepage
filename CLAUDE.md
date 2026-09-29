# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

David Fong's personal website (https://www.davidfong.org): a **Quarto website**, converted in 2026 from an R blogdown / Hugo site with the Academic theme. Netlify builds and deploys it from `master`. The old Hugo sources are in git history (before the cutover commit).

## Build and deploy

- Render with `quarto render`. If `quarto` isn't on PATH, use RStudio's bundled copy at `/usr/lib/rstudio/resources/app/bin/quarto/bin/quarto`. Rendering also needs **`uv` on PATH** (installed in `~/.local/bin`) for the photo-gallery extension. Without it, `/postgallery/` shows "photo-gallery: script produced no output".
- Netlify runs `scripts/netlify-build.sh` (see `netlify.toml`). It installs pinned uv and Quarto, runs `quarto render` and publishes `_site/`, which is gitignored. Keep `QUARTO_VERSION` in step with the local Quarto. The Quarto Netlify plugin can't be used, because it renders in a separate step that doesn't see uv.
- Netlify can't run R. Posts with R code (`mhtpdisadvantage`, `universalbulkbilling*`, `gpmanagmentplannew`) render locally with `execute: freeze: auto`; commit `_freeze/`.
- `scripts/copy-static.ts` (post-render) copies `static/` into `_site/`, as Hugo served `static/` from the site root (`/CV/`, `/media/`, `/document/`…). `static/` is excluded from rendering: some documents there are separate Quarto projects (e.g. `static/document/PatientComplexityNeeds/`), rendered on their own.
- CV: `Rscript scripts/build-cv.R` renders `static/CV/index.Rmd` (datadrivencv; data in `static/CV/assets/datadrivencv/`) to `index.html` and, via pagedown and Chrome/Chromium, `cv.pdf`. Commit both.
- `netlify.toml` also holds 301 redirects for old Hugo addresses with no page here (tag/category/author pages, `/post/`, RSS `index.xml` feeds, theme demo pages). Missing pages get `404.qmd`.

## Where things live

| Path | What |
|---|---|
| `_quarto.yml` | site config, navbar, footer line, render list (`*.qmd` except `static/`), theme |
| `index.qmd` | home page (sections and listings) |
| `post/<slug>/index.qmd`, `project/…`, `publication/…` | content, at the old lowercase Hugo URLs |
| `post/_metadata.yml` (and in `project/`, `publication/`) | defaults for every page in that folder: featured-image filter and comments |
| `postgallery/` | flower photos: `img/` album + one page per photo |
| `posts.qmd`, `project/index.qmd`, `publication/index.qmd`, `postgallery/index.qmd`, `spurafrika20xx/index.qmd` | listing pages |
| `theme/common.scss`, `light.scss`, `dark.scss` | all custom styling |
| `_templates/*.ejs*` | custom listing templates (masonry cards, tag cloud) |
| `_filters/featured-image.lua`, `_includes/utterances.html` | shared page furniture |
| `_extensions/andrewheiss/photo-gallery` | masonry photo gallery (installed with `quarto add`) |
| `static/` | served as-is from the site root: CV, documents, media, old Hugo-era assets |
| `scripts/` | Netlify build, static copy, CV build |

## Writing a post

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

- Put the post in `post/<slug>/index.qmd`, with images alongside. Every `.qmd` outside `static/` is rendered.
- The picture at the top comes from `image` (`_filters/featured-image.lua`). Don't repeat it in the body; set `image-banner: false` to hide it.
- Comments are automatic (`_includes/utterances.html`). Each thread is a GitHub issue titled with the page path (`post/<slug>/`), matching the Hugo site's threads, including when a page is visited as `…/index.html`.
- Photo groups use Quarto figure layout plus its built-in lightbox: `::: {layout="[[63,35],[49,49]]"}`, then one `![](photo.jpg){.lightbox group="<slug>"}` per image, **separated by blank lines**. Otherwise they become one cell. A negative width is empty space, e.g. `[45,-55]`.
- Videos: `{{< video /media/clip.mp4 >}}` (files in `static/media/`) or `{{< video https://www.youtube.com/embed/ID >}}`.
- Trip pages list posts by category, e.g. `spurafrika2023/index.qmd` includes `categories: "Spur Afrika 2023"`. Categories are case-sensitive in Quarto.

## Look and feel

- Colours and fonts reproduce the Hugo Academic site: theme "1950s", fonts "Rose", size "L". `theme/common.scss` starts with a contents list and a **design values** block (font sizes, card shadow, gutter widths); change values there rather than in the rules. `light.scss` is the 1950s palette. `dark.scss` is Academic's default day/night dark palette, since 1950s defines none. Each palette starts with named colours, and everything else refers to them. The coral accent is `$primary` (links, buttons and focus rings derive from it) and has to be changed in both palettes. The palettes can't use variables from `common.scss`, because Quarto compiles the palettes' defaults first. Form-field colours (`$input-*`) are set in the palettes too.
- Home page layout is chosen in `index.qmd` with classes on each `##` heading, which Pandoc moves onto its section: default = title in a 3/12 left gutter; `.gutter-wide` = 4/12; `.full-width`; `.title-hidden` (visually hidden, anchor kept); `.profile-section` (gutter holds `::: {.profile}`, the title heads `::: {.bio}`). Everything stacks below `lg`. Old Hugo `#anchors` are kept as heading ids.
- Home "Featured Posts" (posts with `featured: true`) and "Posts" use `_templates/cards-masonry.ejs.md` (Masonry 4.2.2 from jsDelivr; 3/2/1 columns). The tag cloud is `_templates/tagcloud.ejs` (top 20 categories, case-insensitive like Hugo). Its section links are root-relative, so they work on any page. The contact form is a Netlify Form named `contact`, the same as Hugo's.
- `/postgallery/` uses the photo-gallery extension in masonry layout. Captions come from `postgallery/img/album.yml`. An inline script reverses the extension's filename order to newest first. Thumbnails (`img/thumbs/`, gitignored) are regenerated only when the original is newer, so delete `thumbs/` after changing thumbnail settings.
- Footer line and back-to-top button are set in `_quarto.yml` (`website.page-footer`, `back-to-top-navigation`). Both are styled in `common.scss` section 9 (the back-to-top button in coral).
- `/project/` has All/Kenya filter buttons (inline script in `project/index.qmd`) that drive Quarto's own category filter. Add a button there for another category.

## Gotchas

- **Quarto globs match at any depth unless they start with `/`** (e.g. a `resources: images/` entry matched every `images/` folder). Keep `resources:` globs narrow.
- Listing `contents`: from the site root, a whole section is `"project/*/index.qmd"`; plain `project` also picks up the section's own index page. From a subfolder use `"../post/**/index.qmd"`; `../post` and `/post` match nothing.
- Custom listing templates receive only `items` (no `listing`, so no `fields`), and their output is parsed as Markdown: keep generated HTML on one line or inside ```` ```{=html} ```` blocks.
- A per-page `comments:` block replaces the site-level one rather than merging, and Quarto's utterances support drops `label`. That is why comments come from `_includes/utterances.html` instead.
- Selectors restyling Quarto listings start with `div.quarto-post …` to match the specificity of Quarto's own rules.

## History: migration from Hugo

- Converted from Hugo: 61 Rmd posts, 4 `hugo-md` .qmd posts, 1 .md post, 5 publications, 8 projects, 11 gallery photos. Posts' Hugo-era fancybox + isotope galleries became Quarto layouts with `.lightbox`, keeping the original row widths. The exception is `post/blogdownmasonrygallery`, a tutorial about that technique. Its code sample and demo were corrected in September 2026, with a note in the post (the original had an unpinned fancybox CSS and invalid `data-isotope` JSON, so isotope never ran). They are self-contained, with inline styles and isotope set up by script.
- Deliberately not migrated: the Hugo `content/courses/` and `content/slides/`, which are the Academic theme's demo pages (not linked anywhere); the Talks section, which is inactive on the Hugo home page and only holds the theme's example talk; and `privacy.md` / `terms.md`, which were unpublished theme drafts. The favicon of the Hugo site was the Academic theme's logo, so it was not carried over.
