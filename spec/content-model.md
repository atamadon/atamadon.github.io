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
- motion enablement

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
- `active`

Optional fields:

- `groups`
- `email`
- `image`
- `join_date`
- `leave_date`
- `show_email`
- `website`
- `scholar`
- `orcid`
- `linkedin`
- `github`
- `bio_short`
- `current_position`
- `alumni_since`
- `sort_order`
- long-form body content
- placeholder marker

Rules:

- `berkeley_username` is the public stable key
- `groups` is a controlled public list, not freeform IT metadata
- `show_email` controls whether the public site renders the email link
- active members must render cleanly with valid public content
- active current-team records should include `groups`, `email`, `image`, and `join_date`
- inactive historical alumni records may omit `groups`, `email`, and `image` when those fields are not public-safe or not needed for the alumni list, but they should include `leave_date`
- alumni records may be minimal historical records built from `name`, `status`, optional `current_position`, and ordering fields alone
- current team display order should prefer existing public fields over extra tuning knobs:
  - top-level grouping comes from `role`
  - empty public role sections should be omitted
  - active members are ranked by `join_date`
  - alumni are ranked by `leave_date`
  - within graduate students, `status` establishes a soft hierarchy of `PhD Candidate`, then `PhD Student`, then master's-level entries, with `join_date` preserved inside each band
  - `sort_order` is a legacy fallback and should not be the primary public ranking control
- this schema is public-facing only and must not absorb private IT data

### Team Onboarding Export

Purpose:
- receive approved public profile data from a private onboarding system
- map that data into the public team-entry schema without retyping

Must support:
- approved public identity fields
- approved public visibility preferences
- approved public links
- approved team placement fields needed by the public site

Rules:
- the canonical onboarding record lives outside this public repository
- this repository may contain templates and import tooling, but not real private onboarding records
- website exports must not include private IT-only fields such as internal notes, access approvals, or provisioning state

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
- ordered featured-publications list

Must support:

- external source URL
- title
- date
- authors
- truthful subtype
- truthful display type
- optional image
- optional research-area label
- optional curated featured-carousel membership and order

Rules:

- generated records are not directly CMS-edited
- the featured carousel on `/publications/` should be driven by an ordered list of generated publication IDs rather than a per-record checkbox
- local publication detail pages are not required
- the archive is external-link-first
- browse surfaces should group records by truthful subtype rather than a misleading journal-only umbrella
- the main `/publications/` surface may use in-page filter chips rather than routing every subtype browse action to a separate page
- the `/publications/journal-articles/` surface may group records into the lab's three current research areas, using curated labels when available and implementation-level fallback logic for unlabeled historical records

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
