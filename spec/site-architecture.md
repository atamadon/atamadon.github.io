# Site Architecture

## Purpose

The website is a static academic lab site for long-term maintenance by a lab PI and future lab maintainers.

The site must favor:

- low operational complexity
- long-lived content structures
- minimal JavaScript
- predictable static deployment
- editor-safe maintenance through Pages CMS

## Primary Sections

The site must provide these public sections:

- Home
- Research
- Publications
- Team
- Teaching
- News
- Contact

These are stable navigation sections, not campaign pages or temporary landing pages.

## Page Classes

The site supports four page classes:

1. Pure content pages
   - primarily editorial copy
   - may include structured embeds

2. Data-driven landing pages
   - composed from site data, generated records, or collection entries
   - examples include publications, team listings, and news archive surfaces

3. Generated archive pages
   - rendered from generated data
   - publication listings are the primary example

4. Embedded interactive pages
   - still static pages
   - include a minimal, contained interactive embed such as Mol*

## Navigation Model

- Primary navigation is persistent and site-wide.
- Dropdowns are allowed only when they clarify a stable content hierarchy.
- Primary navigation items must continue to work without JavaScript.
- The mobile navigation pattern may change by implementation, but it must preserve access to all primary and secondary destinations.

## System Boundaries

The website is made of three logical layers:

1. Specification layer
   - product definition, schemas, tokens, behavior rules, and acceptance criteria

2. Implementation layer
   - the current Jekyll reference implementation, including templates, styles, JavaScript, CMS config, validators, and workflows

3. Generated content layer
   - machine-produced artifacts that are committed for deterministic rendering

## Static Deployment Constraints

- The site must be deployable as a static website.
- Public pages must not require a runtime application server.
- Embeds may use client-side JavaScript only when they are isolated, optional enhancements.
- Core content must remain accessible without custom backend services.

## Content Boundaries

- Publications are external-link-first and do not require local detail pages.
- Team records are public-safe and must not contain private IT data.
- News is an editorial feed, not a discussion system.
- Mol* and other embeds are enhancements to content, not the site architecture itself.
