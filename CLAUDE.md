# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a static personal website for Danil Pismenny (pismenny.ru) hosted on GitHub Pages. The repository contains:

- Personal homepage (`index.html`) - main landing page with bio, links, and contact information
- Event subdirectory (`events/neuroconf/`) - archived conference page from 2016
- SSH public keys (`id_ed25519.pub`, `id_rsa.pub`) - publicly accessible for SSH authentication
- Shell script (`add_keys.sh`) - utility to add SSH keys to authorized_keys on remote servers

## Architecture

**Static HTML Site**: No build process or frameworks. Pure HTML with external CSS dependencies:
- Uses Tacit CSS framework from CDN for styling
- Calendly widget integration for meeting scheduling
- Custom inline styles for responsive layout

**Directory Structure**:
```
/
├── index.html              # Main homepage
├── events/
│   └── neuroconf/         # Archived event page (Tilda-generated)
├── add_keys.sh            # SSH key deployment script
├── id_ed25519.pub         # SSH public key (Ed25519)
├── id_rsa.pub             # SSH public key (RSA)
└── [image files]          # Photos and icons
```

## Deployment

The site is deployed via GitHub Pages with custom domain `pismenny.ru` (configured via `CNAME` file).

**To deploy changes**: Push to the `master` branch. The explicit workflow in
`.github/workflows/pages.yml` publishes the static site to GitHub Pages.

### Draft articles

Articles may be published on the site in draft status so they can be reviewed by
direct link. A draft article must:

- include `noindex,nofollow,noarchive` for `robots` and `googlebot`;
- be clearly marked as `Черновик` in the visible article metadata;
- not be linked from `articles/index.html`, `sitemap.xml`, or `articles/feed.xml`.

When an article is approved, remove the draft marker and `noindex` directives,
then add it to the article index and other discovery feeds as appropriate.

## Working with the Codebase

**Viewing locally**: Open `index.html` directly in a browser. No local server required.

**External dependencies** (loaded from CDN):
- Tacit CSS: `https://cdn.jsdelivr.net/gh/yegor256/tacit@gh-pages/tacit-css-1.3.9.min.css`
- Calendly widget: `https://assets.calendly.com/assets/external/widget.*`

**SSH key script** (`add_keys.sh`):
- Downloads public keys from pismenny.ru
- Appends them to `~/.ssh/authorized_keys` if not already present
- Usage: `curl -sfL https://pismenny.ru/add_keys.sh | bash`

## Language

All content is in Russian. The site targets Russian-speaking audience.
