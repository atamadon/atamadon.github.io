# Contributing

## Prerequisites

- Ruby `3.3.4`
- Bundler

## Local Setup

1. Install the Ruby version in `.ruby-version`.
2. Change into the repository root.
3. Install dependencies with `bundle install`.
4. Regenerate publications if needed with `ruby scripts/generate_publications.rb --use-legacy-only`.
5. Start a local preview with `bundle exec jekyll serve` or run a one-off build with `bundle exec jekyll build`.

## Branch Workflow

- Branch from `main`.
- Keep new work local until it is ready to push.
- Use focused branch names for discrete changes.

## Editing Rules

- Treat `spec/` as the product-level definition of the site and the Jekyll code as the reference implementation.
- Edit source files only.
- Do not hand-edit `_site/`.
- Keep front matter valid YAML.
- Use `_data/theme.yml` for routine visual tuning. Treat `_sass/` as maintainer-owned implementation code.
- If a change affects the content contract, token model, component behavior, or editorial ownership, update `spec/` in the same change.
- Keep `_team/` entries aligned to the public schema and Berkeley-username filenames.
- Treat `_data/generated/publications.json` as generated output; change overrides or run the generator instead of editing it by hand when possible.
- Keep publications external-link-only. Use `_data/publication_overrides.yml` for featured state, research-area tags, summaries, and image overrides instead of creating local publication detail pages.
- Publication images are generator-owned by default. The order is manual `image_override`, then best-effort Figure 1 discovery, then generic cover/preview image, then placeholder.
- `.cache/publication_generator/` is a local cache for publication image enrichment. Do not commit it.
- Keep `.pages.yml` in sync when you add or rename CMS-managed pages, collections, or data files.
- Keep `README.md`, `CONTRIBUTING.md`, and `AGENTS.md` updated when workflow, vendored assets, or maintenance steps change.
- Reuse existing URL and asset path patterns unless the task requires a broader refactor.
- For layout or style changes, verify the affected pages visually and capture screenshots for review.
- Keep all files in `assets/vendor/molstar/` on one pinned Mol* version; do not mix versions.
- Keep animations subtle, CSS-first, and compatible with `prefers-reduced-motion`.
- Preserve all homepage hero variants in `_sass/_components.scss`; switch the active one through the class on `index.md` instead of deleting alternates.
- Keep editor-managed embeds in front matter under `embeds:` and rendered through the shared embed includes. Do not ask nontechnical editors to paste raw iframe or script code into page bodies.
- Keep real onboarding records and IT checklists outside this public repo. Only approved public profile exports should be rendered into `_team/`.
- Preserve the current private intake policy for v1: Berkeley-restricted Google Form, PI-owned, with response access limited to the PI and selected lab admins.
- Use the team-entry path that matches the change:
  - `Google Form` for new-member intake that needs private review before publication
  - `GitHub/local repo` for maintainer backfills, bulk edits, and schema/source-level fixes
  - `Pages CMS` for PI/editor updates to already-approved public team content only
- Rehearse Pages CMS against the current demo-safe surfaces first: `team`, `news posts`, `teaching`, `site settings`, `navigation`, and `theme settings`.
- Use `_templates/pages-cms-startup-checklist.md` when connecting the repo to Pages CMS or preparing the PI demo.
- For legacy-site migration, prefer WordPress export and media copies as the primary source. Use the public site and Wayback only as the recovery layer for missing or hacked content.
- Keep migration work reviewable with `_templates/legacy-content-migration-ledger.csv` instead of ad hoc notes.
- Keep the current milestone focused on a credible PI demo: core Pages CMS editorial surfaces first, broader publish-ready cleanup second.

## Validation

Run these commands before handing work off:

```bash
bundle install
ruby scripts/validate_theme.rb
ruby scripts/validate_team.rb
ruby scripts/validate_embeds.rb
ruby -Ilib test/test_publication_generator.rb
ruby -Ilib test/test_theme_validator.rb
ruby -Ilib test/test_team_validator.rb
ruby -Ilib test/test_team_onboarding_export.rb
ruby -Ilib test/test_embed_validator.rb
ruby -Ilib test/test_structures_config.rb
node --check assets/js/molstar-viewer.js
bundle exec jekyll build
```

Use `bundle exec jekyll serve` for manual browser checks when the change affects layout, styling, navigation, or JavaScript behavior.
When comparing homepage hero variants, save `index.md`, wait for `jekyll serve` to regenerate, then hard refresh the browser.

## Ownership Tiers

- `PI/CMS-owned`: team entries, news posts, teaching copy, header/navigation/site metadata, and `_data/theme.yml`
- `Maintainer-owned`: layouts, includes, Sass architecture, JavaScript, generators, validators, and workflows
- `Generated`: `_data/generated/publications.json` and `.cache/publication_generator/`

Pages with Liquid-heavy or data-driven bodies remain maintainer-owned even if they appear in Pages CMS. Keep those surfaces aligned with the documented editing contract instead of broadening the CMS surface casually.

## Specification Layer

Use the files in `spec/` to reason about:

- what the website must support
- which behaviors are product requirements
- which editing surfaces are PI/CMS-owned
- which design tokens are part of the intended system

Use the Jekyll implementation files to reason about how this repository currently fulfills that contract.

## Review Expectations

- Include the exact commands you ran.
- Call out any pages that need manual visual review.
- Follow `.github/code_review.md` for Jekyll-specific review priorities.
