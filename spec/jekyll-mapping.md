# Jekyll Mapping

This file explains how the current GitHub Pages/Jekyll site implements the website specification.

## Reduced Component Map

The product-level component model is intentionally small and static-first:

- `Shell`
- `Section`
- `Content Block`
- `Archive/List`

In the Jekyll reference implementation, those map to the current source like this:

- `Shell`
  - `_layouts/default.html`
  - `_includes/site-header.html`
  - `_includes/site-footer.html`
  - `_includes/theme-vars.html`
  - `assets/css/style.css`
  - `assets/css/site/`
- `Section`
  - `_includes/section-heading.html`
  - page-level section wrappers in Markdown and layouts
- `Content Block`
  - `feature-card` patterns in Markdown
  - `_includes/team-card.html`
  - `_includes/publication-card.html`
  - `_includes/publications/`
  - `_includes/embed-block.html`
  - `_includes/molstar-viewer.html`
- `Archive/List`
  - `_includes/publication-browse.html`
  - `_includes/publication-archive.html`
  - news timeline composition in `news/index.md`
  - grouped team roster composition in `team/index.md`
  - `_includes/team-member-grid.html`

Jekyll and Liquid remain build-time assembly tools. They are not a separate product-level component family.

## Specification to Jekyll Adapters

### Design tokens

- Spec source: `spec/design-tokens.yml`
- Jekyll adapter: `_data/theme.yml`
- Runtime wiring: `_includes/theme-vars.html`, `assets/css/style.css`, and `assets/css/site/_tokens.scss`

### Site metadata

- Spec source: `spec/content-model.md` and `spec/header.md`
- Jekyll adapter: `_data/site.yml`
- Shell implementation: `_includes/site-header.html` and `_includes/site-footer.html`

### Navigation

- Spec source: `spec/site-architecture.md` and `spec/content-model.md`
- Jekyll adapter: `_data/navigation.yml`

### Team

- Spec source: `spec/content-model.md`
- Jekyll adapter: `_team/`
- Validation: `lib/lab_site/team_validator.rb`
- Approved public-export renderer: `lib/lab_site/team_onboarding_export.rb` and `scripts/render_team_onboarding_export.rb`

### News

- Spec source: `spec/content-model.md`
- Jekyll adapter: `_posts/` and `news/index.md`

### Publications

- Spec source: `spec/content-model.md` and `spec/components.md`
- Jekyll adapter:
  - `_data/generated/publications.json`
  - `_data/featured_publications.yml`
  - `_data/publication_overrides.yml`
  - `scripts/generate_publications.rb`
  - `lib/lab_site/publication_generator.rb`
  - `lib/lab_site/publication_generator/`

### Embeds and Mol*

- Spec source: `spec/components.md`
- Jekyll adapter:
  - `_data/structures.yml`
  - `_includes/embed-blocks.html`
  - `_includes/embed-block.html`
  - `_includes/molstar-viewer.html`
  - `assets/js/molstar-viewer.js`

## Minimalism Rule in the Reference Implementation

- Content should begin as Markdown whenever possible.
- Shared structure should come from layouts and includes that emit plain HTML.
- Styling should come from shared CSS tokens and classes.
- JavaScript is reserved for optional Mol* enhancement rather than routine shell behavior.
- New visual work should prefer existing `Section`, `Content Block`, and `Archive/List` patterns over adding new top-level component concepts.

### Editorial workflow

- Spec source: `spec/editorial-workflow.md`
- Jekyll adapter:
  - `.pages.yml`
  - `README.md`
  - `CONTRIBUTING.md`
  - `AGENTS.md`
  - `_templates/team-onboarding-google-form-v1.md`
  - `_templates/team-onboarding-google-sheet-columns.csv`
  - `_templates/team-onboarding-public-export.yml`
  - `_templates/team-onboarding-it-checklist.yml`
  - `_templates/wordpress-migration-request.md`
  - `_templates/legacy-content-migration-ledger.csv`
  - `_templates/pi-demo-launch-checklist.md`
  - `_templates/pages-cms-startup-checklist.md`

## What is implementation-specific

These details belong to the Jekyll reference implementation, not to the website specification:

- Liquid include names and template composition
- modular stylesheet source structure under `assets/css/site/`
- exact CSS selectors
- JavaScript event names
- GitHub Actions workflow file names
- validator implementation details

## Decision Rule

If a future change affects what any implementation must preserve, it should be recorded in `spec/` first.

If a change only affects how Jekyll delivers the current site while preserving the same public contract, it can remain implementation-specific.
