# Google Forms v1 Team Onboarding Setup

Use this document when creating or reviewing the private Google Form for lab onboarding.
This is an implementation-specific operating policy for the current workflow.
Do not commit real responses, screenshots, or exported Google files to this repository.

## Ownership and Access

- Primary owner: PI Berkeley Google account
- Editors: selected lab admins only
- Submitters: Berkeley Google users only
- Response access: PI + designated lab admins only
- Link distribution: send directly to each new member; do not publish publicly

## Required Google Form Settings

- Restrict submissions to Berkeley Google users
- Collect submitter email automatically
- Enable file uploads for profile photos
- Keep response viewing private to owners/editors
- Do not expose response summaries or editing access to the broader lab

## Privacy Notice Text

Place this at the top of the form:

> This onboarding form is a private lab intake record. Submitting it does not automatically publish anything on the website or trigger IT access. A lab admin will review your responses, public visibility choices, and requested access before any action is taken. Private administrative and IT information is kept outside the public website repository.

## Required Acknowledgment

Add a required acknowledgment item:

> I understand that my submission will be reviewed before anything is published or acted on.

## Form Sections and Questions

### 1. Identity

- Full name
- Berkeley email

### 2. Website Participation Gateway

- Should you appear on the public lab website: yes/no

Routing:

- Yes -> Public-profile path
- No -> Hidden-profile path

### 3. Website Profile: Public-Profile Path

- Preferred public display name
- Short bio
- Longer bio
- Profile photo upload
- Website URL
- Google Scholar URL
- ORCID URL
- LinkedIn URL
- GitHub URL

### 4. Website Profile: Hidden-Profile Path

- Preferred display name
- Optional short internal-facing description or note
- Optional note about future website participation

Do not include:

- public photo upload
- public links
- public visibility preference questions

### 5. Public Visibility Preferences

- Show public email link: yes/no
- Show profile photo publicly: yes/no
- Show external links publicly: yes/no
- Optional note for links or fields the member wants hidden

Only show this section when the member chose to appear on the public website.

### 6. Lab Placement

- Requested role/category
- Requested research groups
- Supervisor / sponsor
- Start date or start term

### 7. IT Gateway

- Do you have any additional IT or access requests beyond standard onboarding: yes/no

Routing:

- Yes -> Detailed IT requests
- No -> Consent / acknowledgments

### 8. Detailed IT Requests

- Mailing lists needed
- GitHub/org access needed
- Shared drive/storage access needed
- Slack/communication access needed
- Server/compute access needed
- Equipment/workstation needs
- Other requests

Only show this section when the member answered Yes to additional IT or access requests.

### 9. Consent / Acknowledgments

- Confirm Berkeley affiliation
- Confirm that public profile fields may be reviewed and normalized before publication
- Confirm that IT requests are requests, not automatic approvals

## Control-Flow Rules

- Keep the form to two major branch points only: website participation and additional IT needs.
- Do not ask for Berkeley username separately; derive it later from the Berkeley email during admin review.
- If a member opts out of public website participation, that should map to `active: false` in any later public export unless an admin explicitly changes it after follow-up.
- Do not let any branch skip Identity, Lab Placement, or Consent / Acknowledgments.

## Admin Workflow Summary

1. New member submits the form.
2. Response lands in the private response Sheet and PI-owned Google storage.
3. Lab admin reviews and resolves missing or invalid public data.
4. Lab admin records approval state in the private Sheet.
5. Approved public data is copied into a private YAML file matching `_templates/team-onboarding-public-export.yml`.
6. IT work is tracked privately using `_templates/team-onboarding-it-checklist.yml`.
