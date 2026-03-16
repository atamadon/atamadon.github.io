# Components

## Principles

- Components must be reusable and predictable.
- Decorative behavior must remain secondary to content.
- Visual tuning should come from semantic tokens, not component-local hard-coded values where avoidable.
- Components should degrade cleanly when optional data is missing.

## Header

Must provide:

- institutional context
- lab identity
- primary navigation
- theme toggle

Rules:

- main title is a direct home link
- subtitle items are separate direct links
- dropdown-capable items should signal that state visually
- for items with subpages, the text link navigates and the arrow toggle expands/collapses the submenu
- desktop supports hover-open dropdowns
- navigation must remain usable on desktop and mobile
- compact mode is triggered by width breakpoints rather than device detection
- lab logo may remain active in the current reference implementation

## Footer

Must provide:

- lab or institutional context
- governance links
- accessibility path

Rules:

- privacy and nondiscrimination links are required
- accessibility reporting must be discoverable

## Hero

Must provide:

- concise lab positioning
- primary actions

Rules:

- motion must remain subtle
- multiple visual variants may exist in an implementation, but the product only requires one active hero treatment at a time
- hero variants are implementation options, not separate product modes

## Cards

Includes:

- research cards
- callout cards
- team cards
- publication cards
- embed wrappers

Rules:

- cards should share consistent radius, shadow, and hover behavior
- optional media must fail gracefully
- card styling should reuse global tokens

## News Feed

Must provide:

- chronological vertical feed
- optional image per entry
- readable archive format without requiring interaction-heavy expansion patterns

## Publications Archive

Must provide:

- all-publications surface
- type-specific browse surfaces
- featured records when curated

Rules:

- records link out to canonical external sources
- local detail pages are not required
- display types must be truthful

## Team Listing

Must provide:

- public roster grouped in a clear and stable way
- support for active and inactive members

Rules:

- placeholder entries should be obvious to maintainers and removable without template changes
- public-safe fields only

## Embedded Content

Supported classes:

- Mol* structure viewer
- video
- document
- map

Rules:

- embeds must be schema-backed rather than raw pasted code for ordinary editors
- embed wrappers should remain visually contained
- failure states should leave the page usable

## Mol*

Must provide:

- structure display within a page
- minimal controls or hidden chrome
- compatibility with site theming at the background level

Rules:

- local vendored assets are preferred for reliability
- data-driven structure configuration is required
- the viewer is an enhancement, not the site foundation
