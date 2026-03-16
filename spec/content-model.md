# Content Model

## Ownership Tiers

### PI/CMS-owned

- team entries
- news posts
- teaching copy
- site metadata and contact details
- navigation structure
- theme settings
- structured embeds on editor-facing pages

### Maintainer-owned

- layouts and templates
- component markup
- CSS/Sass architecture
- JavaScript behavior
- generator scripts
- validators and tests
- workflows and deployment config
- pages with Liquid-heavy or data-driven bodies

### Generated

- generated publication data
- local publication cache artifacts

## Core Data Contracts

### Site Settings

Purpose:
- institutional identity
- contact information
- governance and accessibility links
- publication source settings

Must support:
- site name and short name
- header title label and URL
- ordered linked subtitle items
- department and university
- public contact details
- accessibility support path
- governance links
- PI identity metadata
- publication source configuration

### Theme Settings

Purpose:
- editor-safe tuning of high-level visual decisions

Must support:
- semantic color tokens for light and dark themes
- content width
- card and pill radii
- light and dark shadow presets
- motion enablement and timing scale

This model is editorially safe and must not require stylesheet edits for routine tuning.

### Navigation

Purpose:
- define public primary navigation and optional child links

Must support:
- top-level title
- top-level URL
- optional child items with title and URL

### Team Entry

Required fields:

- `berkeley_username`
- `name`
- `role`
- `status`
- `group`
- `email`
- `image`
- `active`
- `sort_order`

Optional fields:

- `website`
- `scholar`
- `orcid`
- `bio_short`
- long-form body content
- placeholder marker

Rules:

- `berkeley_username` is the public stable key
- active members must render cleanly with valid public content
- this schema is public-facing only and must not absorb private IT data

### News Post

Required fields:

- `title`
- `date`
- body content

Optional fields:

- `featured_image`
- `featured_image_alt`
- structured embeds

Rules:

- posts should render cleanly with or without an image
- the archive should not depend on separate detail-page navigation for basic usability

### Research Topic

Required fields:

- `title`
- body content

Optional fields:

- structured embeds

Rules:

- topic pages may remain maintainer-owned if they include data-driven structure or implementation-sensitive content

### Publications

Canonical generated source:

- generated publication dataset

Editorial overlay:

- publication overrides

Must support:

- external source URL
- title
- date
- authors
- truthful display type
- optional image
- optional research-area label
- optional featured state

Rules:

- generated records are not directly CMS-edited
- local publication detail pages are not required
- the archive is external-link-first

### Structures / Mol*

Must support:

- stable structure ID
- source file path and format
- optional PDB fallback
- poster image
- caption
- display height

Rules:

- structure config is data-driven
- the viewer implementation stays replaceable
- editor-managed fields should remain limited to safe configuration values
