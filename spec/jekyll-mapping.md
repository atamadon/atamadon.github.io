# Jekyll Mapping

This file explains how the current GitHub Pages/Jekyll site implements the website specification.

## Specification to Jekyll Adapters

### Design tokens

- Spec source: `spec/design-tokens.yml`
- Jekyll adapter: `_data/theme.yml`
- Runtime wiring: `_includes/theme-vars.html` and `_sass/_tokens.scss`

### Site metadata

- Spec source: `spec/content-model.md`
- Jekyll adapter: `_data/site.yml`
- Header implementation: `_includes/site-header.html` and `assets/js/site.js`

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
  - `_data/publication_overrides.yml`
  - `scripts/generate_publications.rb`
  - `lib/lab_site/publication_generator.rb`

### Embeds and Mol*

- Spec source: `spec/components.md`
- Jekyll adapter:
  - `_data/structures.yml`
  - `_includes/embed-blocks.html`
  - `_includes/embed-block.html`
  - `_includes/molstar-viewer.html`
  - `assets/js/molstar-viewer.js`

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
- Sass partial structure
- exact CSS selectors
- JavaScript event names
- GitHub Actions workflow file names
- validator implementation details

## Decision Rule

If a future change affects what any implementation must preserve, it should be recorded in `spec/` first.

If a change only affects how Jekyll delivers the current site while preserving the same public contract, it can remain implementation-specific.
