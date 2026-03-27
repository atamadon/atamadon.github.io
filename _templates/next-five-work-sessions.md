# Next 5 Work Sessions

Use this file as the concrete maintainer sequence for the current milestone.

## Session 1: Team Completion Audit and Triage

- Use `_templates/team-content-triage.csv` as the working roster checklist.
- Confirm every placeholder record is assigned to one of:
  - `must-fix-before-demo`
  - `can-temporarily-hide`
  - `safe-to-leave-inactive`
- Verify that placeholder profiles meant to stay hidden are still excluded from `/team/`.

Exit criteria:

- every placeholder team record has one action
- the PI profile is either fixed or explicitly the top remaining blocker

## Session 2: Replace Public-Facing Team Placeholders

- Keep the recovered PI photo in place unless a newer approved headshot replaces it.
- Replace any other public-facing placeholder image or bio that becomes available.
- If a profile is not ready, keep it hidden rather than publishing a placeholder.

Exit criteria:

- `/team/` shows no active placeholder cards
- the PI card uses a real approved image or a deliberate non-placeholder fallback

## Session 3: Finish News Migration and Cleanup

- Treat the current news archive as complete enough for demo use unless new missing legacy posts are discovered.
- Prefer local asset paths over live WordPress media URLs.
- If an old gallery asset is unrecoverable, reduce the post to recovered text plus any surviving lead image rather than keeping a broken hotlink.

Exit criteria:

- `_data/site.yml` keeps `news.migration_status: migration_complete`
- `/news/` reads as a coherent archive rather than an import in progress

## Session 4: Pages CMS Demo Cleanup

- Keep the demo-safe surfaces focused on:
  - `team`
  - `news posts`
  - `teaching`
  - `site settings`
  - `navigation`
  - `theme settings`
- Keep publication curation in `_data/publication_overrides.yml` maintainer-owned for now.
- Rehearse one team edit and one news edit before the PI demo.

Exit criteria:

- the PI demo can show a clean `edit a person` flow
- the PI demo can show a clean `publish or update a news item` flow

## Session 5: Final Style, Browser QA, and Launch Checklist

- Review:
  - `/`
  - `/research/`
  - `/publications/`
  - `/team/`
  - `/teaching/`
  - `/news/`
  - `/contact/`
- Use `_templates/pi-demo-launch-checklist.md` as the final QA checklist.
- Fix remaining spacing, broken media, stale copy, and header/footer inconsistencies before declaring publish-ready.

Exit criteria:

- desktop and mobile passes are complete on the main public routes
- remaining open items are truly minor or external
