# lab-website

Reference Jekyll implementation for the Molecular Cell Biomechanics Laboratory website.

The product definition for the website now lives in [spec/README.md](/home/ali/GitHub/atamadon.github.io/spec/README.md). This repository remains the GitHub Pages/Jekyll reference implementation of that specification.

## Local Setup

This repository now treats generated site output as disposable. Work from source files only.
Run all Bundler and Jekyll commands from the repository root.

## Specification vs Implementation

- `spec/`: implementation-agnostic website specification
- Jekyll source directories and files: reference implementation

Read these first when making product-level changes:

- [site architecture](/home/ali/GitHub/atamadon.github.io/spec/site-architecture.md)
- [content model](/home/ali/GitHub/atamadon.github.io/spec/content-model.md)
- [design tokens](/home/ali/GitHub/atamadon.github.io/spec/design-tokens.yml)
- [components](/home/ali/GitHub/atamadon.github.io/spec/components.md)
- [editorial workflow](/home/ali/GitHub/atamadon.github.io/spec/editorial-workflow.md)
- [acceptance criteria](/home/ali/GitHub/atamadon.github.io/spec/acceptance-criteria.md)
- [Jekyll mapping](/home/ali/GitHub/atamadon.github.io/spec/jekyll-mapping.md)

## Reduced Component Model

The site should be understood as a small static-first system built from four core primitives:

- `Shell`
- `Section`
- `Content Block`
- `Archive/List`

The intended implementation bias is:

- content starts as Markdown
- shared structure comes from HTML emitted by layouts and includes
- styling comes from shared CSS tokens and classes
- JavaScript is a narrow exception layer, not a primary component category

In practice, Jekyll and Liquid are build-time glue for a Markdown + HTML + CSS site. New work should prefer adapting existing section, card, and archive patterns over inventing new top-level component families.

### Prerequisites

- Ruby `3.3.4`
- Bundler

### Install and Build

```bash
bundle install
ruby scripts/validate_theme.rb
ruby scripts/validate_team.rb
ruby -Ilib test/test_team_onboarding_export.rb
bundle exec jekyll build
```

### Generated Content

Publications are rendered from committed generated data in `_data/generated/publications.json`.

```bash
ruby scripts/generate_publications.rb --use-legacy-only
```

Use the legacy-only mode when you want to regenerate from the checked-in `_publications/` seed entries without a live OpenAlex fetch. The `workflow_dispatch` refresh workflow is the intended path for live OpenAlex-based updates later.
The generator script now prints its mode, phase-level progress, elapsed runtime, and a short record summary so long live refreshes are easier to track.
The OpenAlex author is pinned in `_data/site.yml` for deterministic refreshes, and the generator now applies a curation pass before writing: low-value records like contributor pages or author responses are dropped, duplicate manifestations are collapsed when a stronger published version exists, and non-book book-derived records are labeled more accurately.
Publication image selection now follows a fixed precedence order: `image_override` from `_data/publication_overrides.yml`, then a best-effort Figure 1 scrape from the source page, then a generic cover/social preview image, then the type-specific placeholder. The generator also records `image_source` on each record and reports image-source counts in its CLI summary.
Image resolution results are cached locally at `.cache/publication_generator/image_cache.json` so repeated live refreshes do not need to re-scrape every publication page and image.
The public publication surface centers on `/publications/` as a featured-plus-filter archive, with separate subtype pages still available where they add value. Curate the featured carousel order through `_data/featured_publications.yml`, and keep research-area tags, summaries, and image overrides in `_data/publication_overrides.yml`; do not add local publication detail pages.

### Preview Locally

```bash
bundle exec jekyll serve
```

The preview server will rebuild the site from source. Do not edit `_site/` directly.

## Pages CMS

This repository includes a root `.pages.yml` configuration for Pages CMS.
Use it for human-authored pages, team entries, featured-publication ordering, site settings, navigation, theme settings, and Mol* structure metadata.

Generated publications in `_data/generated/publications.json` remain generator-owned. Manage featured-carousel ordering through `_data/featured_publications.yml`, and keep broader publication presentation changes in `_data/publication_overrides.yml` or the generator scripts instead of editing generated records directly.

### Editing Ownership

- `PI/CMS-owned`: team entries, news posts, teaching copy, header/site metadata, navigation, `_data/theme.yml`, and the featured-publication ordering list
- `Maintainer-owned`: layouts, includes, Sass architecture, JavaScript, generators, workflows, and data-driven landing pages with Liquid-heavy bodies
- `Generated`: `_data/generated/publications.json` and `.cache/publication_generator/`

Not every page body is treated the same in Pages CMS. Pure content surfaces use structured forms or rich text. Pages that compose dynamic sections or Liquid-backed lists stay maintainer-owned on purpose.

### Pages CMS Startup

Use `_templates/pages-cms-startup-checklist.md` when first connecting the repo to Pages CMS or rehearsing the PI demo.

Start with these editor-facing surfaces only:

- `team`
- `news posts`
- `teaching`
- `featured publications`
- `site settings`
- `navigation`
- `theme settings`

Treat `home`, `research landing`, `contact`, and `news landing` as maintainer-owned unless their current editing contract is intentionally revised later.
Broader publication curation in `_data/publication_overrides.yml` remains maintainer-owned for now. The small featured-carousel ordering surface in `_data/featured_publications.yml` is editor-safe and may be exposed separately in Pages CMS.

For `news posts`, the intended editor contract is:

- new posts should be easy to create from `title`, `date`, and `body`
- `featured_image` is optional and may be added later in Pages CMS
- recovered legacy entries may remain text-only until an editor supplies an approved image
- the first paragraph of the post body becomes the archive summary card text

## Team Onboarding Pipeline

Team onboarding is now modeled as a private intake and approval workflow that exports only approved public profile data into this repository.

- The current v1 private intake implementation is a Berkeley-restricted Google Form owned by the PI account and administered by selected lab admins.
- Use `_templates/team-onboarding-google-form-v1.md` as the operating policy for form settings, access, question structure, and required privacy language.
- Use `_templates/team-onboarding-google-sheet-columns.csv` as the suggested private response Sheet header layout.
- Use `_templates/team-onboarding-public-export.yml` as the public-export contract from the private onboarding system.
- Use `_templates/team-onboarding-it-checklist.yml` as the private IT checklist shape.
- Render an approved public export into a proposed `_team/` entry with:

```bash
ruby scripts/render_team_onboarding_export.rb path/to/approved-public-export.yml
```

Add `--write` to write the rendered Markdown into the proposed `_team/<role>/<berkeley_username>.md` path.
The approved export file itself should remain outside this public repository.
The Google Form, response Sheet, and uploaded files are also private operational records and must remain outside this repository.

### Team Entry Paths

All team-entry workflows converge on the same public source of truth: Markdown entries in `_team/`.

- `Google Form`: default path for new members. Use it when the source data comes from the member and needs private intake, privacy choices, and admin review before publication.
- `GitHub/local repo`: maintainer path. Use it for backfills, bulk edits, schema-level fixes, or any case where an admin needs full source control. Prefer rendering from a private approved export with `scripts/render_team_onboarding_export.rb`; direct `_team/` edits are the fallback for one-off fixes.
- `Pages CMS`: PI/editor path. Use it for already-approved public website changes only, such as updating a bio, headshot, link, or active status. Do not use Pages CMS for private intake, approvals, or IT/access records.

Decision rule:

- New member with private intake data -> `Google Form`
- Admin-maintained or bulk/source-level change -> `GitHub/local repo`
- PI/editor updating approved public content only -> `Pages CMS`

## Legacy Content Migration

Legacy content migration should use a two-source workflow:

- `WordPress export` as the primary source for posts, pages, metadata, and media references
- `Public site + Wayback` as the recovery path for content that is missing, corrupted, or deleted from the legacy system

Use `_templates/wordpress-migration-request.md` when requesting source data from the PI or legacy-site admin.
Track all imports and recoveries in `_templates/legacy-content-migration-ledger.csv` so migration stays reviewable and does not turn into ad hoc copy-paste work.

To inventory a WordPress export and optionally draft migration-ledger rows from its posts and pages, run:

```bash
ruby scripts/inventory_wordpress_export.rb path/to/export.xml
ruby scripts/inventory_wordpress_export.rb path/to/export.xml --ledger-out path/to/ledger.csv
```

To preview or import published WordPress news posts into `_posts/`, run:

```bash
ruby scripts/import_wordpress_news.rb path/to/export.xml
ruby scripts/import_wordpress_news.rb path/to/export.xml --write
```

To download legacy WordPress media used by imported news posts and rewrite those posts to local asset paths, run:

```bash
ruby scripts/localize_wordpress_news_media.rb
ruby scripts/localize_wordpress_news_media.rb --write
```

To recover older lab-news entries from an archived Wayback category page that is no longer present in the WordPress export, run:

```bash
ruby scripts/import_wayback_lab_news.rb path/to/wayback-lab-news.html
ruby scripts/import_wayback_lab_news.rb path/to/wayback-lab-news.html --write
```

Migration priority is:

1. News archive
2. Alumni and team history
3. Research summaries
4. Remaining secondary pages

## PI Demo and Launch Readiness

The current milestone is a credible PI demo, not full historical completeness.

- Keep the CMS demo focused on `team`, `news`, `teaching`, `site settings`, `navigation`, and `theme settings`
- Prefer a smaller, dependable editorial surface over a broader but fragile one
- Use `_templates/next-five-work-sessions.md` as the working execution order for the current milestone
- Use `_templates/pi-demo-launch-checklist.md` to track demo readiness, migration readiness, and the later publish-ready hardening pass
- Use `_templates/pages-cms-startup-checklist.md` to rehearse the actual Pages CMS demo flows before showing them to the PI

## Theme Settings

Editor-safe visual controls now live in `_data/theme.yml`.

Use that file or the matching Pages CMS form to tune:

- site-wide content width
- card and pill corner radius
- light and dark card shadows
- motion enablement
- light and dark semantic color tokens

Do not edit `assets/css/site/_tokens.scss` for routine design changes. The modular stylesheet remains the implementation layer; `_data/theme.yml` is the high-level interface.
The canonical product-level token definition is [spec/design-tokens.yml](/home/ali/GitHub/atamadon.github.io/spec/design-tokens.yml); `_data/theme.yml` is the Jekyll adapter that powers this implementation.

## Mol* Viewer Assets

Mol* is vendored locally under `assets/vendor/molstar/` and is published as static site content.
Normal site publishes do not require rebuilding Mol*.

Only repeat the Mol* update workflow when you intentionally upgrade Mol* or replace the vendored files:

1. Build the pinned Mol* release from its tagged source.
2. Copy `build/viewer/molstar.js`, `build/viewer/molstar.css`, and `build/viewer/images/` into `assets/vendor/molstar/`.
3. Keep all Mol* files on the same pinned version.
4. Run `node --check assets/js/molstar-viewer.js`, `bundle exec jekyll build --trace`, and a browser check on the molecular viewer page.

The current pinned Mol* browser build is `v5.7.0`.

## Homepage Top Banner Variants

The homepage top banner supports four CSS-only visual variants. Keep all four variants in `assets/css/style.css` so they remain available for comparison and future tuning.

- `hero-section-structural`: network/scaffold feel, balanced biomechanics default
- `hero-section-mechanical`: track/tension/band feel, more engineering-forward
- `hero-section-molecular`: softer node/field feel, more structural-biology-forward
- `hero-section-editorial`: minimal accent treatment, most conservative/institutional

Switch variants by changing the second class on the top banner section in `index.md`. When previewing with `bundle exec jekyll serve`, saving `index.md` is usually enough; do a hard refresh in the browser to compare the updated class if the CSS appears cached.

## Embedded Content

Embeds are now managed through structured front matter blocks under `embeds:` instead of raw iframe or script snippets.
The shared renderer lives in `_includes/embed-blocks.html` and `_includes/embed-block.html`, and Pages CMS exposes the same schema as form-based blocks.

Supported embed block types:

- `molstar`: references a structure by `structure_id` from `_data/structures.yml`
- `video`: stores a provider embed URL plus optional title, description, and caption
- `document`: links to a local or external document, with optional preview URL
- `map`: stores an iframe-ready map URL plus optional title, description, and caption

Use `page.embeds` for editor-managed embedded content. Keep raw layout includes and JavaScript for maintainer-only infrastructure.

## Repo Structure

- `index.md`, `contact/`, `news/`, `research/`, `publications/`, `teaching/`, `team/`: site content pages
- `_team/`: public team collection keyed by Berkeley username
- `_data/`: navigation, site metadata, Mol* structures, publication overrides, and generated publication data
- `_publications/`: legacy publication seed entries for generator bootstrapping
- `_layouts/`, `_includes/`, `assets/css/style.css`, `assets/css/site/`: shared shell, UI components, built stylesheet entrypoint, and modular design-system styles
- `assets/vendor/molstar/`: pinned Mol* browser assets served directly by the site
- `assets/`: compiled CSS, JavaScript, images, and structure files
- `lib/`, `scripts/`, `test/`: generation, validation, and test code
- `_templates/`: content templates
- `TODO.md`: authoritative backlog for unfinished website work
- `_site/`: generated build output only

## Current Backlog

See [TODO.md](/home/ali/GitHub/atamadon.github.io/TODO.md) for the authoritative backlog.

## Workflow

1. Branch from `main`.
2. Make changes to source files only.
3. Run `ruby scripts/validate_theme.rb`.
4. Run `ruby scripts/validate_team.rb`.
5. Run `ruby scripts/validate_embeds.rb`.
6. If you changed files under `assets/css/site/`, run `ruby scripts/build_stylesheet.rb`.
7. Run `bundle exec jekyll build`.
8. For visual changes, preview locally and capture screenshots.
9. Keep work local until you are ready to push.

## Humans and Agents

- Agents should read `AGENTS.md` before making changes.
- Contributors should follow `CONTRIBUTING.md`.
- Reviewers should use `.github/code_review.md`.
