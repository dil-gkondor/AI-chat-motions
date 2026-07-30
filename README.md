# AI chat motions

A pure HTML/CSS/JS prototype of the Diligent AI chat home screen, built from the
Figma file *[Not to merge] AI chat box ideation — Zsofi*. No build step, no
dependencies, no framework — one self-contained `index.html`.

The focus is the **chat input**: its three interaction states and the
proximity-driven motion of the gradient behind it.

## Running it

Double-click `serve.command`, or:

```bash
python3 -m http.server 8000
# then open http://localhost:8000/index.html
```

Opening the file directly with `file://` also works.

## Views

| View | Source node | Content |
|---|---|---|
| **Home** | `80977:42583` | Welcome block + four suggestion cards, composer pinned to the bottom |
| **New chat** | `81011:107509` | No cards; two suggestion chips under the composer, welcome + composer grouped |

Switching happens through the sidebar — `Home` and `New chat` toggle
`.mode-chat` on the app shell. Both views share the same composer and the same
interaction code.

## Composer interaction states

Priority is strict: **focused > proximity > default**.

| | default | proximity | focused |
|---|---|---|---|
| border | `#dee0e9` | `#888b9a` | `#888b9a` |
| send fill | `#dee0e9` | `#dee0e9` | `linear-gradient(180deg,#002e9f,#002585)` |
| send icon | `#a5a7b3` | `#a5a7b3` | `#ffffff` |
| glow A | resting | translated | scaled to `0.7924` |

The drop-shadow stack is identical in all three states.

### Proximity motion

A single `pointermove` listener feeds a `requestAnimationFrame` loop that writes
`--glow-x`, `--glow-y` and `--glow-boost` as CSS custom properties. Nothing
re-renders; only a `translate3d` on the glow layer changes.

- Activates within **100px** of the composer, measured to the nearest point on
  its rectangle rather than its centre.
- The glow moves **opposite** the cursor, proportionally: at the far-left edge
  it sits `+115px` right, at the centre `0`, at the far-right edge `-115px`.
  Halfway across gives exactly half the shift.
- Horizontal travel is `15%` of the composer width (capped at 140px) so it
  scales with the layout; vertical is a gentle ±12px.
- Values are interpolated at `0.085` per frame; the loop parks itself once
  settled and restarts on the next pointer move.
- Focus zeroes the targets, so cursor motion stops while the input is active.

### Deliberate constraints

- **The composer never moves.** Only the decorative glow does.
- **The drop shadow is static.** Figma's stack is `-12px 40px` against a 10px
  blur — a hard-edged offset rectangle. Translating it detaches the shadow's own
  rounded corner from the box, which reads as a doubled edge.
- `prefers-reduced-motion` drops translation entirely and keeps only the
  intensity fade.
- Proximity tracking is gated behind `(hover: hover) and (pointer: fine)`;
  `pointerdown` from touch clears the state so nothing sticks.

## Layer order

The glow and shadow are the only negative z-index work in the file, and it is
load-bearing. Anything added near the composer has to be lifted deliberately.

```
.chatbox            isolation: isolate
├── .composer-stage   z-index: 0   isolation: isolate
│   ├── .glow-layer     z-index: -2
│   └── .composer        (no z-index — must not create a stacking context)
├── .chip-row         z-index: 1
└── .disclaimer       z-index: 1
```

## Responsive

| width | behaviour |
|---|---|
| ≤1440 / ≤1200 | gutters tighten 80 → 56 → 40px, sidebar 300 → 264px |
| ≤1024 | cards go 4 → 2 columns |
| ≤900 | sidebar becomes an off-canvas drawer with a scrim |
| ≤640 | Tools label goes icon-only, disclaimer wraps, glow shortens |
| ≤520 | cards single-column, titles wrap instead of truncating |

## Design fidelity

Colours, spacing, radii and type come from the Figma variable collection as
**resolved in the mode the frames actually use** — not the fallbacks emitted
alongside the reference code, which belong to a different (dark/red) brand mode
and are wrong for this screen. Where the two disagree, the resolved values won.

Icons are Material Symbols outlined weight 400, inlined as SVG symbols so
nothing depends on an icon webfont at runtime. Inter loads from Google Fonts
with a system fallback stack.

Two known approximations:

1. **Glow gradient stops.** Both ellipses export as flattened SVG assets from
   Figma's local asset server, which was not readable. The colours are the
   design tokens the fills are built from — Lavender/50 `#7f76ec` and
   Indigo/50 `#4069fe` — with alpha and blur tuned against the reference
   renders. Geometry, scale, border, shadow and send-button values are exact.
2. **Chip hover / pressed.** No hovered or pressed instance of the suggestion
   chip exists in the reference frames, and the base Chip component's states are
   not spec'd against this override. `#eeeff5` / `#dee0e9` come from
   `Action/Secondary/Hover` and `/Active` for system consistency.

The Diligent logo and org avatar are hand-drawn approximations; the Figma
originals are image assets that could not be extracted.
