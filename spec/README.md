# Website Specification

This directory defines the lab website independently of any one framework.

The specification answers:

- what content the site must support
- what components and behaviors the site must provide
- what editors versus maintainers own
- what quality and policy requirements the site must satisfy

The current GitHub Pages/Jekyll site in this repository is the reference implementation of this specification.

Use this directory when:

- evaluating whether a change is a product decision or an implementation detail
- deciding whether a future platform migration should preserve a behavior
- reviewing whether Pages CMS, validators, and templates still reflect the intended website contract

Implementation-specific details such as Liquid templates, Sass partial names, workflow files, and JavaScript event wiring do not belong here unless they are needed to explain how the reference implementation maps to the spec.

Files in this directory:

- `site-architecture.md`: page taxonomy, navigation model, and system boundaries
- `content-model.md`: schemas and ownership rules for content and settings
- `design-tokens.yml`: canonical visual tokens and motion policy
- `components.md`: reusable component behaviors and interaction constraints
- `editorial-workflow.md`: PI/CMS workflow versus maintainer workflow
- `acceptance-criteria.md`: responsiveness, accessibility, branding, and deployment requirements
- `jekyll-mapping.md`: how the current Jekyll implementation maps to this specification
