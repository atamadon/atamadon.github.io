# Website Backlog

`TODO.md` is the authoritative source for unfinished website work in this repository.
Use `spec/` for the product contract and use this file for the remaining implementation,
content, and launch-readiness backlog.

## Open Work

- PI demo readiness: finish a credible Pages CMS demo around core editorial surfaces only (`team`, `news`, `teaching`, `site settings`, `navigation`, and `theme settings`) without expanding the CMS surface just for breadth.
- Legacy-content migration inventory: obtain a WordPress export and media copy if available, maintain a migration ledger, and use Wayback only as the recovery path for missing or hacked content.
- Berkeley brand follow-up: obtain and integrate an official UC Berkeley unit lockup in the site header or footer. Keep the current lab logo in place for now as the active lab identity element unless that branding decision changes.
- News migration: backfill the news archive from the previous WordPress site, recover missing entries from Wayback as needed, and clear `_data/site.yml` `news.migration_status: pending_wordpress_backfill`.
- Team content completion: replace placeholder public profiles with real roster data, bios, and images. The current source still contains 19 `placeholder: true` team records and 20 uses of `/assets/images/team/profile-placeholder.svg`, including the PI image.
- Research and alumni migration: backfill the public research summaries and alumni history from the legacy website once the migration ledger is in place.
- Style consistency polish: remove remaining under-construction cues, enforce a consistent editorial tone across key routes, and align cards, spacing, link treatments, and imagery with the current Berkeley/editorial system.
- Pages CMS publication curation: expose `_data/publication_overrides.yml` through Pages CMS so editors can manage featured state, research-area labels, summaries, and image overrides without editing YAML directly.
- Pages CMS landing-page accessibility: move editor-owned copy on the homepage and other maintainer-managed landing pages out of code-only page bodies and into structured CMS-safe fields or data files where possible, while keeping Liquid-heavy rendering maintainer-owned.
- Pages CMS schema hardening: reduce freeform editorial inputs where practical by converting fields like team grouping into controlled values, adding clearer field descriptions, and strengthening validation for editor-entered URLs, images, and accessibility-sensitive fields such as image alt text.
- Cleanup and hardening pass: remove unnecessary complexity, keep interactive features minimal, verify accessibility/reporting paths, and produce a short launch-readiness checklist for performance, reliability, placeholders, and broken media.
- Final public-content QA pass: once branding, news, and team content are real, do a desktop and mobile review of the main routes (`/`, `/research/`, `/publications/`, `/team/`, `/teaching/`, `/news/`, `/contact/`) and remove any temporary placeholder messaging that is no longer needed.

## Maintenance Rule

- If a task is still open, add or keep it here.
- If work is complete, remove it from this file in the same change that lands the completion.
