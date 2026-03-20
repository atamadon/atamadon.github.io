# AGENTS.md

This repository is a Jekyll site intended to be edited from source and built locally or in CI.
It is also the reference implementation of the implementation-agnostic website spec under `spec/`.

## Repo Map

- `spec/`: implementation-agnostic website specification. Treat this as the product-level source of truth.
- `index.md`, `contact/`, `news/`, `research/`, `publications/`, `teaching/`, `team/`: top-level pages and sections.
- `_team/`: public team entries keyed by `berkeley_username`.
- `_data/`: site metadata, theme settings, navigation, structure configs, publication overrides, and generated publication data.
- `_publications/`: legacy publication seed entries used to bootstrap the generator.
- `.pages.yml`: Pages CMS configuration for editable site content and settings.
- `TODO.md`: authoritative backlog for unfinished website work.
- `_layouts/default.html`, `_includes/`, `_sass/`: shell, reusable UI, and design system styles.
- `assets/js/site.js`: site navigation behavior.
- `assets/js/molstar-viewer.js`: Mol* embed behavior.
- `assets/vendor/molstar/`: pinned Mol* browser assets. Treat this directory as versioned static vendor content.
- `lib/`, `scripts/`, `test/`: generation, validation, and test code.
- `_site/`: generated output only. Never edit it by hand and do not review it as source.

## Source-Only Rules

- Check `spec/` before making product-level changes to content models, design tokens, component behavior, or editing ownership.
- Keep header title/subtitle settings in `_data/site.yml` aligned with the header component contract in `spec/`.
- Edit source files only. Treat `_site/`, `.jekyll-cache/`, and other build artifacts as disposable output.
- Preserve valid YAML front matter on Markdown content files.
- Keep links and asset references consistent with the existing Jekyll site structure.
- When changing layouts or styles, prefer patterns already used in `_layouts/default.html`, `_includes/`, and `_sass/`.
- Keep site motion CSS-first and restrained. Avoid animation-specific JavaScript unless the task explicitly requires behavior that CSS cannot provide.
- Preserve `prefers-reduced-motion` support when adding or changing animated effects.
- Preserve the four homepage hero variants in `_sass/_components.scss` (`structural`, `mechanical`, `molecular`, `editorial`). Change the active variant by updating the class on `index.md` instead of deleting unused options.
- Keep editor-managed embeds in front matter under `embeds:` and route them through the shared embed includes. Prefer schema-backed blocks over raw iframe or script snippets.
- Do not change dependency or Pages runtime files unless the task requires it.
- Avoid hand-editing `_data/generated/publications.json` unless the task is explicitly fixing generated output.
- Keep publications external-link-only. Curate the `/publications/`, `/publications/journals/`, and `/publications/books/` surfaces through `_data/publication_overrides.yml` instead of adding local publication detail pages.
- Preserve the publication image precedence order: manual `image_override`, then best-effort Figure 1, then generic cover/preview, then placeholder.
- Keep real team onboarding records and IT checklists outside this public repo. Only approved public profile exports should be rendered into `_team/`.
- Preserve the current v1 intake policy: Berkeley-restricted Google Form, PI-owned, with response access limited to the PI and selected lab admins.
- Choose the team-entry workflow by source and ownership:
  - `Google Form` for new-member private intake that requires admin review
  - `GitHub/local repo` for maintainer backfills, bulk edits, and source-level corrections
  - `Pages CMS` for PI/editor updates to already-approved public team content only
- Rehearse Pages CMS against the current demo-safe surfaces first: `team`, `news posts`, `teaching`, `site settings`, `navigation`, and `theme settings`.
- Use `_templates/pages-cms-startup-checklist.md` when preparing or reviewing the PI demo workflow.
- For legacy-site migration, prefer WordPress export and media copies as the primary source. Use the public site and Wayback only as the recovery path for missing or hacked content.
- Keep migration work reviewable with `_templates/legacy-content-migration-ledger.csv` and `_templates/wordpress-migration-request.md`.
- Keep the current milestone focused on a credible PI demo: core Pages CMS editorial surfaces first, broader publish-ready cleanup second.
- Treat `.cache/publication_generator/` as disposable local cache output, not source.
- Keep `.pages.yml` aligned with the actual file schema whenever CMS-managed content changes.
- Keep `spec/` aligned with any change that alters the website contract rather than just the Jekyll implementation.
- Treat `_data/theme.yml` as the editor-safe design control surface. Use it for colors, corners, shadows, and motion settings instead of editing Sass for routine theme tweaks.
- Keep repo docs in sync with workflow changes, especially when updating vendored assets or maintenance steps.
- Do not mix Mol* asset versions inside `assets/vendor/molstar/`.
- Preserve the current branding decision: keep the lab logo active for now, and treat the official Berkeley unit lockup as a deferred follow-up tracked in `TODO.md`.

## Standard Commands

Run all commands from the repository root.

- Install gems: `bundle install`
- Validate theme and site settings: `ruby scripts/validate_theme.rb`
- Validate team data: `ruby scripts/validate_team.rb`
- Validate embed blocks: `ruby scripts/validate_embeds.rb`
- Regenerate publications from legacy seeds only: `ruby scripts/generate_publications.rb --use-legacy-only`
- Run Ruby tests: `ruby -Ilib test/test_publication_generator.rb && ruby -Ilib test/test_theme_validator.rb && ruby -Ilib test/test_team_validator.rb && ruby -Ilib test/test_embed_validator.rb && ruby -Ilib test/test_structures_config.rb`
- Run team onboarding export test: `ruby -Ilib test/test_team_onboarding_export.rb`
- Check Mol* wrapper syntax: `node --check assets/js/molstar-viewer.js`
- Local build check: `bundle exec jekyll build`
- Local preview server: `bundle exec jekyll serve`

Run `bundle exec jekyll build` after every source change. For layout or style changes, also do a browser check on the affected pages and capture screenshots if the change will be reviewed by others.

## Done Criteria

- Product-level changes remain consistent with `spec/` or update `spec/` in the same change.
- The changed pages build successfully with `bundle exec jekyll build`.
- Theme and site settings validate successfully with `ruby scripts/validate_theme.rb`.
- No generated files are committed from `_site/` or Jekyll caches.
- Content edits keep front matter, links, and section structure valid.
- Visual changes include a quick manual check for desktop and mobile layouts.

## Review Focus

Use `.github/code_review.md` as the shared review checklist for both humans and agents.
