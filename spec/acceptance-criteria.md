# Acceptance Criteria

## Deployment and Runtime

- The public site must remain deployable as a static website.
- Core content must render without a custom backend.
- JavaScript must remain limited to behavior that materially improves navigation, theming, or isolated embeds.

## Editing and Longevity

- Routine PI maintenance must be possible through Pages CMS for supported content and settings.
- Generated data must remain deterministic and reviewable in version control.
- High-level design adjustments must be possible without editing implementation stylesheets.

## Design and Branding

- The site should remain Berkeley-inspired in typography, color usage, and institutional tone.
- Governance and accessibility links must remain present.
- Styling must remain internally consistent across cards, buttons, feeds, and embeds.

## Accessibility

- The site must support keyboard navigation.
- Decorative motion must remain subtle and compatible with reduced-motion preferences.
- Interactive enhancements must fail gracefully.
- Accessibility reporting information must remain publicly visible.

## Responsiveness

- Core routes must remain usable on desktop and mobile.
- Navigation, feeds, cards, publications, and Mol* surfaces must remain readable without horizontal overflow or broken controls.

## Embedded Content

- Embeds must be minimal, contained, and reliable.
- Mol* must remain an isolated enhancement rather than a page framework.
- Unsupported or broken embeds must not compromise page readability.

## Publications

- Publication rendering must remain generator-driven with a separate editorial override layer.
- The public archive must remain external-link-first.
- Displayed record types and imagery must remain curated enough to be publicly credible.

## Reference Implementation Discipline

- The Jekyll implementation must continue to map cleanly to the specification.
- New implementation details must not silently become product requirements without first being expressed in the spec.
