---
name: NextShow user_app
description: Ticketing app for movies, comedy, music, and theatre — clean royal-blue utility screens with one dark, cinematic exception at Discovery.
colors:
  royal-blue: "#2563EB"
  sky-blue: "#60A5FA"
  deep-navy: "#0F172A"
  snow-white: "#FCFCFD"
  ice-blue: "#DBEAFE"
  text-primary: "#0F172A"
  text-secondary: "#64748B"
  border: "#E2E8F0"
  success: "#22C55E"
  warning: "#F59E0B"
  error: "#EF4444"
  cinema-background: "#0A0E17"
  cinema-surface-elevated: "#161B29"
  cinema-text-primary: "#F5F7FA"
  cinema-text-muted: "#94A3B8"
  cinema-text-body: "#C7CDD9"
  cinema-shimmer-highlight: "#2A3450"
  cinema-glass-fill: "rgba(255,255,255,0.06)"
  cinema-glass-border: "rgba(255,255,255,0.10)"
  category-movie: "#E0435D"
  category-comedy: "#F5A623"
  category-music: "#22C55E"
  category-theatre: "#8B5CF6"
typography:
  display:
    fontFamily: "Manrope, sans-serif"
    fontSize: "57px"
    fontWeight: 800
    lineHeight: 1.1
  headline:
    fontFamily: "Manrope, sans-serif"
    fontSize: "32px"
    fontWeight: 700
    lineHeight: 1.15
  title:
    fontFamily: "Manrope, sans-serif"
    fontSize: "22px"
    fontWeight: 700
    lineHeight: 1.2
  body:
    fontFamily: "Inter, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.4
  label:
    fontFamily: "Inter, sans-serif"
    fontSize: "14px"
    fontWeight: 500
    lineHeight: 1.2
  cinema-display:
    fontFamily: "Space Grotesk, sans-serif"
    fontSize: "28px"
    fontWeight: 800
    lineHeight: 1.1
    letterSpacing: "-0.5px"
rounded:
  sm: "8px"
  md: "12px"
  lg: "16px"
  pill: "20px"
  full: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
components:
  button-primary:
    backgroundColor: "{colors.royal-blue}"
    textColor: "{colors.snow-white}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    height: "50px"
  button-secondary:
    backgroundColor: "transparent"
    textColor: "{colors.text-primary}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    height: "50px"
  chip-category-selected:
    backgroundColor: "{colors.royal-blue}"
    textColor: "{colors.snow-white}"
    typography: "{typography.body}"
    rounded: "{rounded.pill}"
  chip-category-unselected:
    backgroundColor: "{colors.snow-white}"
    textColor: "{colors.text-primary}"
    typography: "{typography.body}"
    rounded: "{rounded.pill}"
  card-event:
    backgroundColor: "{colors.snow-white}"
    rounded: "{rounded.md}"
    width: "150px"
  cinema-button-secondary:
    backgroundColor: "{colors.cinema-glass-fill}"
    textColor: "{colors.cinema-text-primary}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    height: "50px"
---

# Design System: NextShow user_app

## Overview

**Creative North Star: "The Box Office"** *(inferred from the incumbent implementation — not yet confirmed with the user; treat as a working label, not a locked brand decision.)*

The app reads as a ticket counter: efficient, legible, trustworthy. Royal blue is the one accent that recurs everywhere — buttons, links, selected states, the brand gradient in the wordmark — sitting on near-white surfaces with a restrained Manrope/Inter type pairing. Screens are flat, high-contrast, and built for scanning a list of showtimes fast; there is no ornamental chrome, no gratuitous shadow, no decorative color beyond the functional success/warning/error trio.

One screen breaks the rule on purpose: **Discovery** (the home tab) drops to a near-black, glassmorphic "Cinema" system — dark background, frosted-blur badges and nav, Space Grotesk display type, and one saturated color per event category. The code comments already frame this precisely: *"Dark, cinematic design tokens for the Discovery homepage only — the rest of the app stays on `ui_kit`'s light `NSColors`/`NSTextStyles`."* It's the moment the app becomes the thing it sells tickets to — walking from the lobby (light, functional) into the screening room (dark, immersive) — before returning to the light system for every task screen (search, booking, seat selection, profile).

**Key Characteristics:**
- One brand accent (Royal Blue), used sparingly and consistently across both light and dark worlds.
- Light system is flat and utilitarian; the Discovery-only dark system is glassmorphic and cinematic.
- Manrope for headings/emphasis, Inter for body/labels, Space Grotesk reserved exclusively for Discovery's dark screens.
- A single named category-color set (movie/comedy/music/theatre) exists only inside Discovery's category grid — nowhere else uses these hues.
- Every primary interactive element (buttons, nav items, cards) scales to 96% on press (`NSPressScale`) — the app's one consistent tactile signature.

## Colors

The palette is a single-accent system: one blue carries all brand and interactive meaning, layered on near-white in the main app and near-black in Discovery.

### Primary
- **Royal Blue** (`#2563EB`): the only brand/interactive accent — primary buttons, active nav/tab state, selected chips, links, focus rings, progress indicators. Same value in both light and dark contexts; never substituted.

### Secondary
- **Sky Blue** (`#60A5FA`): pairs with Royal Blue only in the brand gradient (wordmark, hero text treatments). Not used standalone as an interactive color.

### Tertiary (Discovery-only category set)
- **Category Red** (`#E0435D`): Movie category tile.
- **Category Amber** (`#F5A623`): Comedy category tile.
- **Category Green** (`#22C55E`): Music category tile — reuses the semantic Success hue by coincidence of value, not by reference; keep them as separate tokens since their roles never overlap.
- **Category Violet** (`#8B5CF6`): Theatre category tile.

### Neutral
- **Snow White** (`#FCFCFD`): default scaffold background and card surface across the light system.
- **Ice Blue** (`#DBEAFE`): light tint fill for inputs and subtle highlighted rows (OTP fields, search fill, price tag背景). Always used at reduced opacity (40–50%) except as a flat icon-chip background.
- **Deep Navy** (`#0F172A`): primary text color in the light system; also the literal background of the splash screen and voice-search overlay, and the tint source for all light-system shadows (`deepNavy.withOpacity(0.06–0.08)`).
- **Text Secondary** (`#64748B`): secondary/meta text, disabled states, captions.
- **Border** (`#E2E8F0`): all light-system hairlines, dividers, unselected chip/button outlines.
- **Cinema Background** (`#0A0E17`): Discovery's page background — distinct from, and darker than, Deep Navy.
- **Cinema Surface Elevated** (`#161B29`): reserved elevated-surface tone for Discovery (shimmer/skeleton base).
- **Cinema Text Primary** (`#F5F7FA`) / **Cinema Text Muted** (`#94A3B8`) / **Cinema Text Body** (`#C7CDD9`): the three-step dark-mode text ramp — heading, short label, and long-form paragraph respectively, deliberately kept distinct so paragraphs don't glare against headings.

### Semantic
- **Success** (`#22C55E`): confirmed/published status, price display, positive distance/availability text.
- **Warning** (`#F59E0B`): draft status, rating badges.
- **Error** (`#EF4444`): cancelled status, error states/icons.

### Named Rules
**The One Accent Rule.** Royal Blue is the only color ever used for interactive/brand meaning. Every other hue (semantic, category, neutral) stays fixed to its single role and never substitutes for the brand accent.

**The Discovery Exception.** Dark surface tokens (`cinema-*`) exist only for the Discovery tab. No other screen may use them, and Discovery may not fall back to the light system's `NSColors`/`AppColors` — its own `CinemaColors` set is a closed, deliberate palette.

## Typography

**Display/Headline/Title Font:** Manrope (weights 600–800)
**Body/Label Font:** Inter (weights 400–500)
**Discovery-only Display Font:** Space Grotesk (weight 600–800)

**Character:** Manrope's geometric, slightly condensed heaviness carries confidence in headings; Inter stays neutral and highly legible underneath it for body and label text. Space Grotesk is deliberately swapped in only on Discovery's dark screens for a cooler, more editorial, more "cinema marquee" feel — it never appears anywhere else in the app.

### Hierarchy
- **Display** (w800, 57px / 45px, Manrope): rare — largest hero moments only.
- **Headline** (w600–700, 24–32px, Manrope): section headers, screen titles.
- **Title** (w600–700, 14–22px, Manrope): card titles, list headers, app bar title (18px/w700).
- **Body** (w400, 14–16px, Inter): running text, descriptions.
- **Label** (w500, 11–14px, Inter): buttons, chips, badges, captions — usually the smallest legible size in the system.
- **Cinema Display** (w800, 22–28px, Space Grotesk, −0.5 letter-spacing on the largest size): Discovery spotlight title and section headers only.

### Named Rules
**The Two-Typeface Rule.** Only Manrope and Inter appear outside Discovery. Space Grotesk is a Discovery-only accent typeface, not a system-wide third voice — introducing it elsewhere would blur the one deliberate tonal shift the app has.

## Layout

Screens are single-column, edge-padded lists and grids rather than complex multi-region layouts — consistent with a mobile ticketing app where the primary job is scanning a list of showtimes/events. Horizontal scrollers (category chips, event card rails, showtime chip `Wrap`) are the standard pattern for browsing without a full page navigation. Spacing follows a loose 8px rhythm (`4px` for tight icon/text gaps, `8px` for internal component padding, `16px`/`24px` for section and screen padding, `32px` for empty/error-state padding). The bottom navigation bar is a fixed glass overlay (`Scaffold(extendBody: true)`) so scrolling content passes behind it rather than stopping above it — this is a load-bearing layout choice, not a style choice: removing `extendBody` breaks the blur effect.

## Elevation & Depth

The system is hybrid: flat by default, with two deliberate uses of depth. (1) Soft ambient shadows (`deepNavy` at 6–8% opacity) lift cards and the bottom nav bar off the background — never used for anything else. (2) Glassmorphism (`BackdropFilter` blur + translucent white/near-black fill + hairline border) marks a small, consistent set of "floating over content" surfaces: the bottom nav bar (light), and on Discovery specifically, glass badges, glass icon buttons, and the glass search bar (dark). Buttons, inputs, chips, and screen backgrounds themselves stay flat — shadow and blur are reserved for surfaces that visually float over other content.

### Shadow Vocabulary
- **Card lift** (`box-shadow: 0 4px 16px rgba(15,23,42,0.08)`): event/cinema cards.
- **Nav bar lift** (`box-shadow: 0 -6px 24px rgba(15,23,42,0.06)`): bottom navigation bar only, shadow direction inverted (cast upward) since the bar sits at the screen's bottom edge.

### Named Rules
**The Float Rule.** Blur and shadow are reserved for elements that are conceptually floating above the content (nav bar, glass badges/buttons). Everything else — cards, buttons, chips — sits flush with its surface at rest.

## Shapes

Corner radius scales in five steps and is applied by role, not by component type: `8px` for small/tight elements (skeleton blocks, thumbnail crops), `12px` for the default control size (buttons, inputs, cards, the discovery secondary button), `16px` for the nav bar's active-tab highlight, `20px` for pill-shaped filter/category chips, and `999px` (true pill/circle) for Discovery's glass badges and glass icon buttons. Borders are single 1px hairlines (`border` in light mode, `cinema-glass-border` in dark) — never doubled, never colored beyond those two tokens.

## Components

### Buttons
- **Shape:** 12px radius, fixed 50px height, full-width by default.
- **Primary:** Royal Blue fill, Snow White label text (Inter, w500). Loading state swaps the label for a white `CircularProgressIndicator` at the same size — the button never changes size or shape while loading.
- **Secondary / Outlined:** transparent fill, `border`-token 1px outline, `text-primary` label.
- **Cinema Secondary (Discovery only):** glass fill + glass border instead of the light system's outline, `cinema-text-primary` label — exists because the light secondary button is unreadable on Discovery's dark background.
- **Press state:** every button (and nav item, card) scales to 0.96 via `NSPressScale` on pointer-down — the app's one universal tactile affordance.

### Chips
- **Category filter chip:** pill (20px radius), 1px `border` outline when unselected, Royal Blue fill + white bold label when selected.
- **Showtime chip:** 8px radius, Royal Blue 1px border, stacked time/format/price in descending emphasis (label-bold / label-small-skyBlue / label-small-secondary).
- **Glass pill badge (Discovery only):** 999px radius, glass fill/border, icon + label, used for meta tags floating over imagery.

### Cards / Containers
- **Event card:** 12px image radius, 150px fixed width, title/category/price stacked below the image with 1-line ellipsis truncation. An IMDb-style rating badge (black 80% opacity, 6px radius) overlays the image's bottom-left corner when rating data exists.
- **Cinema card:** 12px radius, Snow White background, ambient card-lift shadow, showtime chips wrapped inside.
- **Corner Style:** 12px, consistent with buttons/inputs.
- **Shadow Strategy:** card-lift shadow only (see Elevation & Depth); no border.

### Inputs / Fields
- **Style:** filled (white or Ice Blue-tinted fill), 12px radius, 1px `border` outline, 16/14px content padding.
- **Focus:** border switches to 2px Royal Blue.
- **Error:** border switches to `error` red, same width as default.

### Navigation
- **Bottom nav bar:** frosted glass (`sigma 20` blur, white 72% opacity fill, top hairline), rides over content via `extendBody`. Active tab: Royal Blue icon/label (bold) on a 16px-radius Royal-Blue-at-12%-opacity pill; inactive: `text-secondary` icon/label (medium weight), no background.
- **App bar:** flat white, no elevation, 18px/w700 Manrope title, `text-primary` icons.

### Status & Category Badges
- **Status badge** (draft/published/cancelled/archived): 12px-radius pill, semantic color at 15% opacity fill with the same color at full opacity for bold label text — background and text always derive from one semantic token, never mixed.
- **Venue type badge:** 16px-radius pill, Royal Blue at 10% opacity fill, Royal Blue icon + label.

### Discovery Wordmark (signature component)
The logo swaps its icon glyph for a director's-chair mark inline in the word itself ("Ne[chair]tShow"), rendered on the transparent-background asset variant so it sits directly on Discovery's dark background rather than in a white icon tile — the one place branding gets literal about the cinema metaphor.

## Do's and Don'ts

### Do:
- **Do** keep Royal Blue as the only interactive/brand accent across both the light and dark systems.
- **Do** confine `CinemaColors`/`CinemaTextStyles`/Space Grotesk strictly to Discovery; every other screen reads from `ui_kit`'s `NSColors`/`NSTextStyles`.
- **Do** reserve blur + shadow for surfaces that are conceptually floating (nav bar, glass badges) — keep buttons, chips, and cards flat at rest.
- **Do** apply the 0.96 press-scale to every new tappable primary/card component for tactile consistency.
- **Do** treat `shared/ui_kit` as the single canonical source for cross-app component tokens; `apps/user_app/lib/theme/app_theme.dart` exists only to wire the same values into Flutter's `ThemeData` and must stay value-identical to `ui_kit`'s `NSColors`/`NSTextStyles`, not drift into a third palette.

### Don't:
- **Don't** introduce a second accent color; semantic and category colors stay fixed to their single roles.
- **Don't** use the light system's `NSSecondaryButton`/`NSEmptyState`/`NSErrorState` on Discovery's dark background — they hardcode dark-on-light colors and render illegibly; use the `Cinema*` equivalents.
- **Don't** add drop shadows to flat elements (buttons, chips, screen backgrounds) — shadow is reserved for nav bar and cards only.
- **Don't** hardcode hex values in screens; reference `NSColors`/`NSTextStyles` (or `CinemaColors`/`CinemaTextStyles` on Discovery) so a future palette change stays a one-file edit.
