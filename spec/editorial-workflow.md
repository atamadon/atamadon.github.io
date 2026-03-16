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
- manage safe structured embeds

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

## Generated Content Workflow

Publications:

- refreshed manually by a maintainer or a maintainer-triggered workflow
- curated through overrides, not direct JSON editing

Local cache artifacts:

- disposable
- not part of the source model

## Editing Safety Rules

- content and settings should be represented as structured fields or rich text where possible
- implementation-sensitive pages may remain maintainer-owned instead of being forced into WYSIWYG editing
- CMS descriptions should explain operational meaning, not implementation jargon

## Long-Term Principle

Routine editorial work must be possible without understanding the reference implementation. If an editor-facing task requires touching implementation code, the boundary is too weak and should be revisited.
