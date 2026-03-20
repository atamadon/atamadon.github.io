# Pages CMS Startup Checklist

Use this checklist when connecting the repository to Pages CMS for the first time or rehearsing the PI demo workflow.

## 1. Connect and Inspect

- Connect Pages CMS to this repository
- Confirm the root `.pages.yml` is detected automatically
- Confirm these editor-facing surfaces appear:
  - Team
  - News Posts
  - Teaching Page
  - Site Settings
  - Theme Settings
  - Navigation
- Confirm these remain maintainer-owned in practice:
  - Home
  - Research Landing Page
  - Contact Page
  - News Landing Page

## 2. Rehearse the Two Main Demo Flows

### Team Flow

- Open an existing team entry
- Edit one harmless public field such as:
  - `bio_short`
  - `show_email`
  - one public link
- Save the change
- Confirm the resulting Markdown still matches the public `_team/` schema

### News Flow

- Create or edit one news post
- Set:
  - title
  - publish date
  - body
  - optional featured image and alt text
- Save the change
- Confirm the post appears correctly in the news archive

## 3. Verify Supporting PI-Owned Surfaces

- Teaching Page: one small copy edit saves correctly
- Site Settings: one harmless metadata edit saves correctly
- Navigation: one label or link edit saves correctly
- Theme Settings: one small design-control change saves correctly

For each surface, verify:

- field labels make sense to a non-maintainer
- the save path is correct
- the source format remains valid
- the public result changes where expected

## 4. Keep the Boundary Honest

Do not use Pages CMS for:

- private onboarding intake
- IT/access records
- publication generation internals
- generated publication JSON
- implementation-sensitive page structure
- code-managed landing-page composition

Use Pages CMS for already-approved public website content and editor-safe settings only.

## 5. Validation After Rehearsal

Run:

```bash
ruby scripts/validate_theme.rb
ruby scripts/validate_team.rb
ruby scripts/validate_embeds.rb
bundle exec jekyll build
```

## 6. PI Demo Story

The PI should be able to understand the difference between:

- `Pages CMS` for already-approved public content
- `Google Form` for new-member intake
- `GitHub/local repo` for maintainer-only or source-level work
