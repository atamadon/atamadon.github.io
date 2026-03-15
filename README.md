# lab-website

Jekyll source for the Molecular Cell Biomechanics Laboratory website.

## Local Setup

This repository now treats generated site output as disposable. Work from source files only.
Run all Bundler and Jekyll commands from the repository root.

### Prerequisites

- Ruby `3.3.4`
- Bundler

### Install and Build

```bash
bundle install
bundle exec jekyll build
```

### Preview Locally

```bash
bundle exec jekyll serve
```

The preview server will rebuild the site from source. Do not edit `_site/` directly.

## Repo Structure

- `index.md`, `contact/`, `news/`, `research/`, `publications/`, `teaching/`, `team/`: site content pages
- `_team/`: team collection
- `_publications/`: publication collection
- `_layouts/default.html`: shared page shell
- `assets/`: CSS, JavaScript, images, and structure files
- `_templates/`: content templates
- `_site/`: generated build output only

## Workflow

1. Branch from `main`.
2. Make changes to source files only.
3. Run `bundle exec jekyll build`.
4. For visual changes, preview locally and capture screenshots.
5. Keep work local until you are ready to push.

## Humans and Agents

- Agents should read `AGENTS.md` before making changes.
- Contributors should follow `CONTRIBUTING.md`.
- Reviewers should use `.github/code_review.md`.
