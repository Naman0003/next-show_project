---
name: NextShow User App
description: Berlin's night program as a cinema marquee after dark
colors:
  ground: "#0B0B0C"
  surface: "#161615"
  surface-high: "#201F1D"
  hairline: "#2E2D2A"
  bone: "#EDE9E1"
  muted: "#9B988F"
  accent-amber: "#FFA424"
  accent-ink: "#0B0B0C"
  glass-fill: "rgba(237,233,225,0.06)"
  glass-border: "rgba(237,233,225,0.14)"
typography:
  display-xl:
    fontFamily: "Bricolage Grotesque, Georgia, serif"
    fontSize: "44px"
    fontWeight: 800
    lineHeight: 0.98
    letterSpacing: "-1.6px"
  display:
    fontFamily: "Bricolage Grotesque, Georgia, serif"
    fontSize: "26px"
    fontWeight: 800
    lineHeight: 1.02
    letterSpacing: "-0.9px"
  title:
    fontFamily: "Bricolage Grotesque, Georgia, serif"
    fontSize: "17px"
    fontWeight: 700
    lineHeight: 1.1
    letterSpacing: "-0.4px"
  body:
    fontFamily: "Bricolage Grotesque, Georgia, serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.45
    letterSpacing: "normal"
  mono:
    fontFamily: "Martian Mono, ui-monospace, monospace"
    fontSize: "11px"
    fontWeight: 500
    lineHeight: 1.3
    letterSpacing: "0.8px"
  mono-tiny:
    fontFamily: "Martian Mono, ui-monospace, monospace"
    fontSize: "9.5px"
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: "1px"
rounded:
  tag: "2px"
  card: "4px"
  panel: "16px"
  pill: "999px"
spacing:
  x1: "4px"
  x2: "8px"
  x3: "12px"
  x4: "16px"
  x5: "20px"
  x6: "24px"
  x7: "32px"
  x8: "48px"
components:
  chip-filter:
    backgroundColor: "{colors.ground}"
    textColor: "{colors.bone}"
    rounded: "{rounded.tag}"
    padding: "6px 12px"
    typography: "{typography.mono}"
  chip-filter-selected:
    backgroundColor: "{colors.accent-amber}"
    textColor: "{colors.accent-ink}"
    rounded: "{rounded.tag}"
    padding: "6px 12px"
    typography: "{typography.mono}"
  search-field:
    backgroundColor: "{colors.glass-fill}"
    textColor: "{colors.muted}"
    rounded: "{rounded.panel}"
    padding: "14px 16px"
    typography: "{typography.mono}"
  nav-dock:
    backgroundColor: "{colors.glass-fill}"
    textColor: "{colors.bone}"
    rounded: "{rounded.pill}"
    padding: "8px 10px"
---

# Design System: NextShow User App

<!-- Recorded from the shipped "Marquee After Dark" redesign of the Discovery
surface + shared navigation (apps/user_app/lib/features/discovery/,
lib/shell/). The other three apps and the pre-redesign screens are not part of
this world yet. -->

## Overview

**Creative North Star: "Marquee After Dark"**

NextShow's consumer surface is a repertory cinema's marquee after the lights
drop: one monumental, printed title fills the field, and everything around it is
precise typewriter signage. It is near-monochrome — a warm near-black ground,
warm bone ink — lit by a single amber that behaves like a marquee bulb: it only
ever marks what is live or chosen. The register is confident and technical, not
friendly; hierarchy comes from scale and material, never from color variety or
decoration.

Two materials are held deliberately far apart. Frosted glass — genuine backdrop
blur with a crisp 1px inner edge and a top inner-glow — is used only for
floating, interactive surfaces (the nav dock, icon buttons, the search field).
Hard-edged neo-brutalist tags — a 1px border, a 2px radius, no shadow — carry
fixed information (category, filter state). Imagery is never raw: every picture
passes through a duotone + film-grain + fine-linework treatment so it reads as a
pressed plate, not a stock photo.

Motion is physics, not decoration. Tap targets punch down and spring back with a
small overshoot; the spotlight arrives with one authored sequence (poster
scale-settle, title wipe-up, metadata fade) and nothing else animates on load.

This world explicitly rejects: purple or multi-stop gradients as surface;
glossy 3D "SaaS blob" shapes and rounded-everything friendliness; raw stock
photography; generic icon-grid feature rows; Inter or system fonts as the voice;
and evenly-distributed colorful palettes.

**Key Characteristics:**
- Warm near-black ground; one amber accent, live/selected state only.
- Typographic extremes: monumental grotesque display against tight uppercase mono.
- Frosted pills for interaction, hard 1px tags for information — never mixed.
- Every image duotone + grain + linework; no raw photography.
- Spring-physics feedback on every touch; one authored entrance per screen.

## Colors

Near-monochrome: a single warm near-black field, warm bone ink at two
brightnesses, one amber accent. Nothing else carries hue.

### Primary
- **Marquee Amber** (`#FFA424`): the only chromatic color. Fills the selected
  filter chip, the active nav-dock indicator, the active page dot, the wordmark's
  chair mark, and section counts. Never a fill for large regions, never
  decorative, never more than one live region per viewport.

### Neutral
- **Cinema Black** (`#0B0B0C`): the ground under every surface. Warm, not the
  blue-black slate that dark UIs drift toward.
- **Plate Surface** (`#161615`): raised panels — poster fallbacks, loading
  skeletons.
- **Riser Surface** (`#201F1D`): the rare second elevation step.
- **Bone** (`#EDE9E1`): primary ink. A warm off-white; never pure `#FFFFFF`
  (which glares on OLED).
- **Muted Bone** (`#9B988F`): secondary ink — mono metadata, captions, inactive
  hints. ~7:1 on Cinema Black.
- **Hairline** (`#2E2D2A`): 1px borders, dividers, unselected tag strokes.
- **Glass Fill / Glass Border** (`rgba(237,233,225,0.06)` / `0.14`): the frosted
  surface fill and its inner edge, tuned for backdrop blur over the dark ground.

### Named Rules
**The One Amber Rule.** The accent marks only what is live, selected, or current.
If two things on screen are amber, one of them is wrong. Its rarity is the light.

## Typography

**Display Font:** Bricolage Grotesque (bundled variable TTF; fallback Georgia)
**Mono / Label Font:** Martian Mono (bundled variable TTF; fallback ui-monospace)
**Body Font:** Bricolage Grotesque at weight 400 — the display family does the
small amount of running copy rather than adding a third face.

**Character:** A monumental, slightly idiosyncratic grotesque set very tight
(`-1.6px` on the largest role) against a squarish technical monospace set wide
and uppercase. The gap between them is the hierarchy — there is almost nothing
in the middle.

### Hierarchy
- **Display XL** (800, 44px, line-height 0.98, `-1.6px`): the spotlight title.
  Steps down to 34px for titles over ~20 characters.
- **Display** (800, 26px, 1.02, `-0.9px`): section headings ("Now Showing").
- **Title** (700, 17px, 1.1, `-0.4px`): card titles.
- **Body** (400, 14px, 1.45): venue names, one-line descriptions.
- **Mono** (500, 11px, `+0.8px`, uppercase): every metadata run, category tag,
  filter chip, nav label, search hint.
- **Mono Tiny** (600, 9.5px, `+1px`, uppercase): the location strip, page
  counters, poster sub-labels.

### Named Rules
**The Mono Signage Rule.** All metadata, labels, counts, and navigation text are
uppercase Martian Mono. The display face never does label work; mono never does
headline work.

## Layout

Single-column, full-bleed. Page gutter is 20px (`spacing.x5`); the spotlight
anchor and processed imagery run edge to edge past it. Vertical rhythm is a 4px
scale (`x1`–`x8`); sections are separated by `x7` (32px), tight groups by `x2`–`x3`.
The Discovery screen is a `CustomScrollView`: pinned header row → mono location
strip → glass search field → spotlight anchor (~46% of viewport height, clamped
320–460px) → horizontal filter strip → horizontal "Now Showing" rail → 108px
(`spacing.dockClearance`) of trailing space so content can scroll clear of the
floating dock. Text scales with the OS Dynamic Type / font-size setting; the
mono strip and display title wrap rather than clip at the largest steps.

## Elevation & Depth

Mostly flat. Information surfaces (tags, cards, the ground itself) cast no
shadow; depth between them is conveyed by the 1px hairline border and the two
surface tones. The exception is the floating navigation dock, which is a genuine
raised plane over scrolling content.

### Shadow Vocabulary
- **Dock lift** (`0 18px 40px -4px rgba(0,0,0,0.6)` + `0 3px 10px rgba(0,0,0,0.25)`):
  the only real drop shadow in the system. Two layers — a wide soft ambient and
  a tight contact shadow — so the dock reads as hovering, not painted on.
- **Glass edge-glow** (top-anchored `rgba(237,233,225,0.19)` → transparent over
  the top 40%): an inner highlight, not a shadow; gives frosted pills a lit top
  lip.

### Named Rules
**The Flat-Information Rule.** Anything that carries fixed information is flat
with a 1px edge. Shadow is reserved for the one element that genuinely floats.

## Shapes

Two corner languages, assigned by function:
- **Hard tags** — 2px radius, 1px border (`rounded.tag`): category tags, filter
  chips. Rectangular, blunt.
- **Frosted pills & panels** — 999px for the nav dock and icon buttons, 16px for
  the search field and larger glass panels (`rounded.pill` / `rounded.panel`).
- **Poster cards** — 4px radius (`rounded.card`) inside a 1px hairline frame.

### Named Rules
**The Hard Tag / Soft Pill Rule.** If it states information, it is a hard-edged
rectangle. If it floats and responds to touch, it is a frosted pill. Never the
reverse, never a blend.

## Components

### Buttons
No traditional filled button on this surface — primary action is the full-bleed
spotlight tap and the dock. Secondary actions use the ghost style:
- **Ghost:** glass-fill background, 1px glass-border, 12px radius, uppercase
  Mono label; `SpringTap` press feedback.

### Chips
- **Filter chip:** uppercase Mono. Unselected — transparent-dark fill, 1px
  hairline border, bone text. Selected — Marquee Amber fill, Cinema Black text,
  amber border. 2px radius, `6px 12px` padding. Tapping toggles; tapping the
  selected chip (or "ALL") clears the filter.
- **Category tag** (non-interactive): same shape, sits in the spotlight's
  caption block above the title.

### Cards / Containers
- **Poster card:** 2:3 processed image in a 4px-radius, 1px-hairline frame;
  Title (17→15px) + uppercase Mono meta (`GENRE · IMDB 8.4`) + Body venue name
  below. `SpringTap` → event detail. No shadow.
- **Glass surface:** backdrop blur (sigma ≤ 22, never animated), `glass-fill`,
  1px `glass-border`, top inner-glow. Bounded to small elements only.

### Inputs / Fields
- **Search field:** a glass panel (16px radius), search glyph left, uppercase
  Mono hint (`SEARCH EVENTS · TIMES · VENUES`), amber sparkle glyph right.
  Non-editable entry point — tapping routes to the Search tab.

### Navigation — Floating Glass Dock (signature)
A frosted pill hovering 16px above the bottom safe area, 20px side margins, the
"Dock lift" shadow. Four destinations, drawn icons in one weight. The active
destination is marked by a **44px amber circle** (the "blob") with its icon in
Cinema Black; inactive icons are bone at 72%, scaling to 1.07 as the blob nears.

**Gesture-driven.** A horizontal pan anywhere on the pill drags the blob 1:1
with the finger (its position is a continuous fractional slot value, 0…N-1). The
blob **stretches toward its travel direction** — an elongated capsule up to +34px
wide, magnitude from the frame-to-frame velocity — and every icon morphs its
colour and scale continuously by proximity, so state changes mid-drag rather than
flipping. On release the blob **spring-snaps** (`spring-settle`, seeded with the
fling velocity) to the nearest slot, projecting a little in the fling direction
so a decisive flick past halfway lands on the next tab; the tab switches and
`HapticFeedback.selectionClick` fires. A plain tap still selects directly.
Reduced motion: the blob tracks linearly (no stretch) and snaps with a 120ms
tween.

**The Continuous Track Rule.** The indicator follows the finger in real time and
resolves with physics — never a stepped or instant jump between tabs. Movement is
information: its speed drives the stretch, its direction drives the icon morph.

### Monumental Spotlight (signature)
A swipeable stack (≤3 picks) filling ~46% of the viewport. Full-bleed
`ProcessedImage` (duotone + grain + linework) under a top+bottom scrim. Glass
bookmark button top-right. A bottom-anchored caption block: hard Mono category
tag → Display XL title (≤3 lines) → one Mono metadata run
(`150 MIN · OV · IMDB 8.6 · €24`) → amber-marked page dots + `01 / 03` counter.
**Entrance (the screen's one authored motion):** on mount and on each swipe, the
poster scale-settles 1.05→1.0 while the title wipes up (clip height-factor +
16px lift) and the metadata fades in — `expoOut` over 700ms.

### Auth Sheet (signature)
Sign-in and OTP are a **frosted bottom-sheet fragment over a blurred backdrop**,
never a full screen — the caller's Discovery position stays mounted and visible.
A non-opaque route lays a `BackdropFilter` (blur 10) + 32%-ground scrim over the
live screen (tap-to-dismiss), then slides the sheet up (`expoOut`). The sheet is
a `glass-fill` panel (20px top corners, blur 22) with a drag handle, wrapped in
`AnimatedSize` so it grows/shrinks as its phase changes; it is capped to the
space above the keyboard + status bar and scrolls internally past that (Sign Up
with the keyboard open on a small phone). Two phases swap in place
via an `AnimatedSwitcher` (horizontal slide + fade), **no route push between
them**: **email** — a Sign In / Sign Up mode toggle (see below), a Display
heading + one Mono-muted sub-line that both track the mode, glass email +
password fields (a third "confirm password" field on Sign Up, revealed via the
`AnimatedSize`), amber `NsxButton` "SIGN IN" / "CREATE ACCOUNT", a Mono-muted
"EMAIL ME A CODE INSTEAD" link (drops to the **otp** phase), "OR" hairline,
ghost `NsxButton` "Continue with Google";
**otp** — a back-arrow + `CODE SENT TO {email}` Mono line, a centred letter-spaced
code field, amber "VERIFY", Mono "RESEND CODE". Reduced motion: the sheet fades
in place; phases cross-fade.

Email + password is the primary path; the passwordless one-time code is kept as
the fallback link and as Sign Up's confirmation channel. Sign In and Sign Up are
the same sheet — the toggle only reframes copy and reveals the confirm field.

**The No-Redirect Rule.** Identity is never a destination. Any flow that needs
sign-in opens this sheet over the current screen; there are no `/login` routes.

### Auth Mode Toggle
A full-width segmented control at the top of the sheet's email phase: two Mono
labels, an amber pill that slides behind the active one (`easeOutCubic`, snaps
instantly under reduced motion), hairline track. It is the email phase's single
live/selected amber region — the "code instead" link stays Mono-muted, not amber.
Built on `ui_kit`'s theme-agnostic `NSSegmentedToggle` (light `NS` defaults,
overridden here with the dark tokens), so other apps can reuse the base.

### Buttons — NsxButton
A hard 2px-radius stamp, 52px tall, uppercase Mono label, `SpringTap` + haptic.
**Filled** = amber ground / Cinema Black label (the primary action). **Ghost** =
`glass-fill` / hairline border / bone label (the secondary). Disabled drops to
Riser Surface / Muted Bone. One shape for both variants — never a rounded
secondary next to a stamped primary.

### ProcessedImage (signature)
Every image passes through: full desaturate + hard contrast bump with a warm
bias → shadow-crush gradient toward the ground → thin amber wash → edge vignette
→ optional 1px horizontal linework (large anchors only) → seeded film grain.
Loading = shimmer skeleton; error = a hairline-framed `NO IMAGE` Mono label.

### Motion tokens
- **expoOut** (`cubic-bezier(0.16, 1, 0.3, 1)`): entrances and layout moves.
- **spring-press** (mass 1, stiffness 420, damping 22): tap release — snappy,
  slight overshoot.
- **spring-settle** (mass 1, stiffness 240, damping 26): the dock blob snap
  (seeded with fling velocity), spotlight swap.
- **Continuous drag:** a pan-tracked element follows the pointer 1:1 with no
  animation; its per-frame velocity drives a secondary deform (the dock blob's
  stretch). Physics resolves the release, never a tween.
- Durations: 120ms feedback · 240ms state · 420ms layout · 700ms focal.

### Named Rules
**The Spring-Back Rule.** Every tap target punches to ~0.94 scale and springs
back past 1.0 to rest — physics, never a linear ease. Under OS reduced-motion it
collapses to a 90ms fade with no overshoot; haptics and state changes stay.

## Do's and Don'ts

### Do:
- **Do** keep amber to one live/selected region per viewport (The One Amber Rule).
- **Do** set every label, count, and metadata run in uppercase Martian Mono.
- **Do** run every image through `ProcessedImage` — duotone + grain + linework.
- **Do** use hard 1px-edge rectangles for information, frosted pills for touch.
- **Do** give every tap target `SpringTap` feedback and a reduced-motion path.
- **Do** let the OS text-size setting scale type; wrap, never clip.
- **Do** open sign-in as the auth sheet over the current screen (The No-Redirect
  Rule) and use one `NsxButton` shape for both button variants.
- **Do** make draggable indicators track the finger and resolve with a spring
  (The Continuous Track Rule).

### Don't:
- **Don't** introduce a second accent hue or a colored-category palette.
- **Don't** route to a full-screen sign-in or OTP page.
- **Don't** ship a raw image, or fake the treatment with a low-opacity wash.
- **Don't** use gradients as a surface fill (scrims over imagery are the only
  gradients allowed).
- **Don't** add drop shadows to information surfaces; shadow is the floating
  dock's alone.
- **Don't** use the display face for labels or the mono face for headlines.
- **Don't** use Unicode glyphs or emoji as icons — draw them.
