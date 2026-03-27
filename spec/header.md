# Header Contract

## Purpose

The header is the primary shell component. It must provide:

- institutional context
- lab identity
- primary navigation
- logo control
- stable interaction across desktop and mobile
- CSS-first behavior with no site-level JavaScript dependency

## Structure

The header consists of:

1. brand block
2. primary navigation
3. controls block

The controls block contains:

- mobile menu toggle
- logo-based theme toggle

## Alignment Rules

- The main title, primary navigation row, and logo button share the same center line.
- The main title, primary navigation row, and logo-based theme toggle share the same center line.
- This center line is invariant and must not shift when subtitle rows are added or removed.
- Subtitle rows reserve vertical space above or below the title without changing that center line.
- The mobile menu toggle may appear only in compact/mobile layouts, but when present it aligns to the same control row as the logo button.

## Brand Block

The brand block contains:

- one main title link
- zero or more subtitle rows

Rules:

- the main title is a direct link to the configured home URL
- subtitle rows are linked visible subtitles
- subtitle placement is derived from their order in the configured list
- the separate logo control may toggle theme without affecting the title link

## Header Content Model

Header settings must support:

- title label
- title URL
- ordered subtitle links

## Desktop Navigation Behavior

For top-level items without children:

- clicking the text navigates directly

For top-level items with children:

- clicking the text navigates to the parent landing page
- the submenu should not repeat the parent landing page as its first child
- hovering over the text opens the submenu
- hovering over the caret opens the submenu
- focus-within opens the submenu for keyboard use
- only one submenu may be open at a time
- moving hover/focus to another parent closes the prior submenu
- leaving the header closes the open submenu

## Mobile Navigation Behavior

- the hamburger toggles the full mobile menu through HTML/CSS state
- the logo-based theme toggle stays at the far right of the control row
- clicking a top-level text link navigates to the parent page
- clicking a caret toggles the submenu
- clicking the spacer area between the text and the caret also toggles the submenu
- there is no hover behavior on mobile
- multiple mobile submenus may remain open at once
- dismissing the full mobile menu closes all open mobile submenus

## Submenu Presentation

Desktop:

- submenu appears as an anchored contrasting surface below the parent item
- submenu items are vertically stacked

Mobile:

- submenu appears as a rounded contrasting panel directly under the parent row
- submenu items are stacked rows
- rows use explicit vertical padding and separators
- submenu height is defined only by row content
- no oversized blank slab is allowed

## Color and Theme Behavior

- the site follows the user's system theme using CSS `prefers-color-scheme` by default
- the logo control may invert the current light/dark theme through HTML/CSS state only
- the header includes no JavaScript theme toggle
- header and submenu contrast must remain readable in both light and dark themes
- mobile submenu surfaces should use the active theme's contrast surface

## Accessibility

- keyboard focus must remain visible
- motion must respect reduced-motion expectations
