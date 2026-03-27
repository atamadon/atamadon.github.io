# Legacy WordPress Migration Request

Use this checklist when asking the PI or legacy-site admin for source material from the current WordPress website.

## Requested Access and Exports

- WordPress `Tools > Export` output for:
  - posts
  - pages
  - media or attachments
  - any custom post types used by the old site
- A zipped copy of `wp-content/uploads` or an equivalent media export
- Temporary WordPress admin access, if easy to grant, so post types, categories, tags, and permalinks can be inspected directly
- A short list of known hacked or deleted sections that must be recovered from historical snapshots

## Why This Is Needed

- WordPress export is the cleanest migration source for titles, dates, slugs, and body content
- Media exports reduce the risk of broken images during migration
- Wayback recovery is slower and should be used only for content missing from the live site or export

## Migration Priority

1. News archive
2. Alumni and team history
3. Research summaries and legacy page content
4. Remaining secondary pages

## Recovery Rule

Treat WordPress export and media copies as the primary source of truth when available.
Use the current public site and Wayback Machine only to recover content that is missing, corrupted, or deleted from the old system.
