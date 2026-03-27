# Editorial Workflow

## Goal

The site should be maintainable in perpetuity by the lab PI or future lab members without requiring them to edit implementation code for routine updates.

## PI / Editor Workflow

Primary editing surface:

- Pages CMS

Expected editor tasks:

- update team profiles
- add or revise news posts
- update teaching copy
- adjust contact and site metadata
- update header title and subtitle links
- change navigation labels or links
- tune approved theme settings
- reorder featured publications
- manage safe structured embeds

Recommended first rehearsal for a new Pages CMS setup:

- edit one team profile
- create or revise one news post
- verify teaching, site settings, navigation, and theme settings with one small change each

News-post editing contract:

- editors should be able to create a valid public news post with `title`, `date`, and `body`
- `featured_image` should remain optional so recovered legacy entries can stay text-only
- editors should be able to add or replace `featured_image` and alt text later in Pages CMS without touching source code
- the first paragraph of the body should serve as the archive summary unless a future structured summary field is introduced

Editors should not need to:

- edit Liquid templates
- edit Sass or JavaScript
- touch generator code
- hand-edit generated publication JSON
- update vendored Mol* assets

## Maintainer Workflow

Maintainers own:

- implementation architecture
- component markup and styling
- JS behavior
- generator logic
- validation and test coverage
- workflow automation
- Pages CMS schema design

Maintainers also handle:

- publication refreshes
- Mol* upgrades
- structural page refactors
- accessibility and policy fixes that require code changes
- legacy-site migration planning, imports, and recovery

## Generated Content Workflow

Publications:

- refreshed manually by a maintainer or a maintainer-triggered workflow
- featured-carousel order may be curated through a small ordered ID list
- broader presentation curation stays in overrides, not direct JSON editing

Team onboarding:

- starts from a member-facing intake form in a private system
- uses a lab-admin approval step before any website or IT action
- exports only approved public profile data into this repository
- keeps IT checklist records and private review state outside this repository

Local cache artifacts:

- disposable
- not part of the source model

Legacy migration:

- should use WordPress export and media copies as the primary source when available
- may use the public legacy site and Wayback only for recovery of missing or hacked content
- should be tracked in a reviewable migration ledger instead of ad hoc notes

## Editing Safety Rules

- content and settings should be represented as structured fields or rich text where possible
- implementation-sensitive pages may remain maintainer-owned instead of being forced into WYSIWYG editing
- CMS descriptions should explain operational meaning, not implementation jargon
- a small, demo-safe CMS surface is better than exposing more pages with a weak editing contract

## Long-Term Principle

Routine editorial work must be possible without understanding the reference implementation. If an editor-facing task requires touching implementation code, the boundary is too weak and should be revisited.

The team onboarding pipeline should reduce duplicate data entry: member-supplied public profile data should be collected once, approved privately, and exported into the public site schema without mixing in IT-private operational fields.
The immediate milestone may prioritize a small, credible Pages CMS demo over full historical completeness, as long as the public editing boundary remains honest and maintainable.
