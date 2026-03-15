# Code Review Guidance

Prioritize concrete regressions over style feedback.

## Build and Content Integrity

- Confirm the site still builds with `bundle exec jekyll build`.
- Check Markdown files for valid front matter and obvious content structure mistakes.
- Verify collection entries still fit the existing `_team/` and `_publications/` patterns.

## Links, Assets, and Generated Output

- Flag broken internal links, incorrect asset paths, and references to missing files.
- Flag any committed `_site/` or Jekyll cache changes unless the task explicitly required generated artifacts.

## Layout and Accessibility

- Review navigation, page hierarchy, and responsive layout behavior when templates or CSS change.
- Check for regressions in alt text, heading structure, focus flow, and obvious keyboard traps.

## Scope Discipline

- Prefer findings that are discrete, user-facing, or build-breaking.
- Ignore broad style preferences unless they hide a real defect.
