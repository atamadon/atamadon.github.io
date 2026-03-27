# Components

## Principles

- The core site model is static-first: Markdown content rendered into HTML and styled with CSS.
- Jekyll and Liquid are build-time assembly tools, not a product-level component category.
- Components must be reusable and predictable.
- Decorative behavior must remain secondary to content.
- Visual tuning should come from semantic tokens, not component-local hard-coded values where avoidable.
- Components should degrade cleanly when optional data is missing.
- Site shell behavior should remain HTML/CSS-driven. JavaScript is reserved for embeddable scientific components such as Mol*.

## Minimalism Rule

- Do not introduce a new top-level component when an existing `Section`, `Content Block`, or `Archive/List` pattern is sufficient.
- Prefer adapting existing card and list patterns over creating one-off templates.
- Do not add JavaScript for presentation-only behavior that CSS can handle.
- Treat specialized variants as implementation details of the core primitives, not as separate architectural families.

## Shell

Must provide:

- institutional context
- lab identity
- primary navigation
- logo control
- page wrapper and footer

Includes:

- header
- footer
- main page shell

Rules:

- main title is a direct home link
- subtitle items are separate direct links
- dropdown-capable items should signal that state visually
- for items with subpages, the text link navigates and the arrow toggle expands or collapses the submenu
- navigation must remain usable on desktop and mobile
- compact mode is triggered by width breakpoints rather than device detection
- privacy and nondiscrimination links are required
- accessibility reporting must remain discoverable
- lab logo may remain active in the current reference implementation
- the exhaustive header contract lives in `spec/header.md`

## Section

Must provide:

- page rhythm
- a clear sectional title
- optional eyebrow or supporting link

Includes:

- section heading
- section container or spacing rhythm

Rules:

- section framing should remain lightweight and reusable
- headings should support editorial pages and data-driven pages equally
- section structure should not depend on JavaScript

## Content Block

Must provide:

- a contained unit of content that can stand alone inside a section or list

Includes:

- generic cards
- research cards
- callout cards
- team or person cards
- publication cards
- featured publication cards
- book-shelf publication cards
- teaching item cards
- contact or information cards
- news item body and media treatments
- embed blocks, including Mol*, video, document, and map

Rules:

- cards and blocks should share consistent radius, shadow, and hover behavior
- cards and blocks should share a consistent padding and internal spacing rhythm
- card grids and card stacks should share a common outer cluster gap by default, unless a compact list variant is intentionally different
- optional media must fail gracefully
- styling should reuse global tokens
- embeds must be schema-backed rather than raw pasted code for ordinary editors
- advanced embeds are content-block enhancements, not a separate top-level component family
- Mol* is an enhancement, not the site foundation

## Archive/List

Must provide:

- clear repeated-record presentation
- stable grouping or browse structure where needed

Includes:

- team roster groupings
- featured publications carousel
- news feed or timeline
- publication browse controls
- publication archive surfaces
- other repeated-record page structures

Rules:

- lists should remain readable without interaction-heavy expansion patterns
- chronological or grouped ordering must be explicit
- publication records link out to canonical external sources
- local publication detail pages are not required
- publication display types must remain truthful
- the main publications page may use CSS-only in-page filter chips instead of subtype-navigation links
- the main publications filter chips may allow multiple active subtype selections at once
- publication filter chips should remain a single physical row, with overflow on narrow screens instead of wrapping into multiple rows
- the journal-articles page may render as a three-column research-area view instead of a year-grouped single stack, and it does not need to repeat the main-page filter chips
- the books page may use a cover-first shelf layout, but covers and metadata should align consistently rather than relying on decorative randomness, and it does not need to repeat the main-page filter chips
- team listings must support active and inactive members
- inactive alumni may render as stripped-down cards rather than full profile cards or plain text lists
- empty public team sections should be omitted rather than rendering placeholder empty-state copy
- current team ordering should be derived from existing public fields before introducing new ranking controls
- placeholder team entries should be obvious to maintainers and removable without template changes

## Implementation Exceptions

The current reference implementation keeps JavaScript only for embeddable scientific components:

- optional Mol* viewer initialization

These are implementation exceptions, not top-level product components, and should not be treated as a template for future component growth.
