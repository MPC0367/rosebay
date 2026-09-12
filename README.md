# Rosebay Home Cooking & Café — Khao Yai

A four-page website for a real restaurant: a white cottage down a small soi off
Thanarat Road, with an open kitchen in the middle of the room.

> **Unsolicited concept work.** Rosebay is a real, trading restaurant. This was
> not commissioned by them and is not their official site. The photography in
> `img/` is theirs, not ours. **Read [NOTICE.md](NOTICE.md) before making this
> repository public** — it explains what has to change first.

**Run it**

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File serve.ps1
```

Then open <http://localhost:8335/>. Also registered in `NOVA\.claude\launch.json`
as **rosebay** on port **8335**.

Static HTML, CSS and vanilla JS. No build step, no framework, no dependencies
beyond three Google Fonts.

---

## The idea

Khao Yai has more photogenic cafés than it can use. Rosebay is not competing
there. Guests drive down an unmarked soi, queue from nine in the morning, and
write afterwards about the smell of the pan.

So the site is built on one line — **Come home hungry** — and one turn:

> **It looks like a café. We came to cook.**

Everything else hangs off `HOME × PAN × TABLE`.

### What makes it Rosebay and could not be moved to another restaurant

**The name is the story, and it is true.** Two independent Thai sources report
that "Rosebay" joins the owner's former family name — which means *rose* — with
the name of a bay in Australia where she went to learn to cook. Two homes in one
word. That is the `ROSE / BAY` typographic device on the home page and on
`home.html`, with a gloss under each half. No other restaurant can use it.

**The green is theirs, sampled not guessed.** The brief proposed a deep forest
green. Rosebay's actual green — pulled off the awning and the cut-out sign
letters in their own photographs with a canvas — is a **teal**: `#12564C`,
lifting to `#2E8B84` in sunlight. Timber `#8A5A3B` came off their floor. The
accent `#EE7B12` is the colour of the duck-egg yolks in their own food photos.

**The type follows their printed menu.** Their wordmark and menu headings are a
light, widely letterspaced geometric sans, so labels, the wordmark and all
numerals are **Jost**. The voice is **Fraunces** — warm and slightly wonky,
editorial rather than luxury. Thai gets its own art direction and its own type
scale, not a shrunken copy of the English one.

### The signature interaction — from pan to plate

`index.html#kitchen`. A circle holds still while you scroll past it. It starts
small, dark, warm and saturated — a pan in the middle of service — and grows
wide, bright and clean until it is a plate on a table. A teal arc traces the rim
as progress. Four stages, four real photographs, nothing simulated:

1. the pass during service · 2. the open kitchen · 3. the eggs · 4. the plate

The heat is a `sepia() saturate() brightness()` filter interpolated from the same
scroll value that drives the scale, so warmth and size resolve together.

### The gallery — a running ribbon

Section 07 is a feed, so it behaves like one. Twenty of Rosebay's own
photographs travel past on a seamless loop, stop the moment you reach for
them, and open full size when you pick one — with a caption, a counter, and
arrow-key browsing through the whole set.

The track holds two copies of the tiles so `translateX(-50%)` lands exactly on
the start of the original and the seam is invisible; the clones are
`aria-hidden` and out of the tab order, so it is twenty photographs, not
forty. Spacing lives on the tile rather than in `gap`, because a `gap` makes
that -50% land half a gap out and the loop visibly jumps. Tiles are
fixed-height with a declared `aspect-ratio`, so every width is known before
the image loads — a lazy image resolving to `width:auto` later would shift the
track and break the loop. The ribbon shows 760px thumbnails from `img/g/`;
the full file is fetched only when a tile is expanded.

On touch there is no marquee to fight with: it becomes a snap-scrolling strip.
With reduced motion, or with no JavaScript at all, it is a plain scrollable
row of photographs.

### The front door — the loading veil

The first page of a session opens behind a veil in cottage white: Rosebay's own
roofline draws itself, the wordmark arrives beneath it, and the table line fills
— then the veil parts along that line, top half up, bottom half down. The table
line is the site's structural device, so the entrance is made of the same thing
every section heading is made of.

Progress is **real**. Each step is an asset actually resolving — `load`,
`document.fonts.ready`, the hero photograph — not a decorative timer. A slow
creep floors the value so the line never looks stuck, but it can only reach the
end when the work is genuinely done, or when the 2.6-second cap fires. A page is
never held hostage by one slow image.

It plays **once per session**. An inline `<head>` script checks `sessionStorage`
and stamps `html.veil-skip` before the body paints, so moving between pages never
replays it and a return visit never flashes it.

Three things keep it from ever becoming a trap:

- The critical styles are inlined **before** the stylesheet links, so the veil
  covers the first painted frame — and so `site.css` can still override them.
- The resting state of the mark and the wordmark is **visible**; the animation
  supplies the hidden start via `backwards`. Done the other way round —
  invisible at rest, revealed by an animation with `forwards` — anywhere
  animations do not run leaves a blank screen. The visible state must never be
  something an animation has to deliver.
- `veil-on` locks scrolling, so a script error clears it, a five-second timer in
  the head clears it regardless, and a CSS failsafe hides the veil on the same
  timer. Without JavaScript the veil is `display: none` and never appears.

`_qa/veil-shot.ps1 -P 0.62` captures the loading state held open at a given
progress.

### The language swipe

Switching language repaints almost every string at once, which reads as a glitch
if it happens in front of you. A band in Rosebay green crosses the screen
carrying the name of the language you are moving to, and the swap happens
underneath it while it has the page covered.

Direction follows the toggle — EN sits left of ไทย, so going to Thai sweeps in
from the right and leaves to the left. The toggle is inert mid-transition, so
hammering it cannot stack transitions or leave the band stranded. Every timing
has a `setTimeout` backstop beside its `transitionend`, because a backgrounded
tab may never fire the event. With reduced motion the band is skipped entirely
and the swap is instant; `window.Rosebay.applyLang()` stays available for the
instant path, which is what the menu renderer uses after it builds its rows.

`_qa/shot.ps1 -Page index -Swipe th` freezes the band mid-sweep.

### The recurring device — the table line

A hairline that behaves like the edge of a table: it runs under every section
label, turns a corner beside a pulled-out sentence (`.tline-corner`), sweeps
across a button on hover, and closes the footer.

---

## Pages

| File | What it is |
|---|---|
| `index.html` | Arrive → the flip → the food → pan to plate → café → the name → pets → social → visit |
| `menu.html` | The real menu, rendered from `data/menu.json`. Sticky category nav, prices aligned, Thai under every dish. |
| `home.html` | The house, the name, the garden beds, the open kitchen, the room |
| `visit.html` | Directions, hours, contact, parking, pet policy, when to come |

Bilingual EN/ไทย throughout. English lives in the DOM; Thai lives in `data-th`
and the English is captured off the DOM on the first switch, so it is never
duplicated in the markup and cannot drift. The choice persists in
`localStorage` under `rosebay.lang`.

---

## Everything here is sourced

`doc/RESEARCH.md` is the ledger: every fact, where it came from, and what was
deliberately withheld. The short version:

- **The menu is theirs.** Dish names, Thai spellings and prices are transcribed
  from a photograph of Rosebay's own printed menu card. Dishes whose price sits
  on a page we could not obtain are listed under *Also on the menu* **without a
  price** rather than guessed.
- **Hours came from the restaurant, not from directories.** Their own Instagram
  and Facebook posts dated 28–29 Aug 2026 say *Open Every Day, 9.00–18.00*.
  Several third-party listings still say closed on Tuesdays; those are years old
  and are not repeated here.
- **The pet policy is first-party.** There is a `PET FRIENDLY` decal with a dog
  and a cat on their own door (`img/door-pet.jpg`), and guests report a dedicated
  outdoor zone. Rules on breeds, carriers and indoor seating are **not** invented
  — the site says to ask on arrival.
- **Nothing is invented**: no founder name, no founding year, no chef biography,
  no awards, no suppliers, no testimonials, no star rating. Google's 4.5/698 is
  real but is not shown as a badge and is deliberately not marked up as
  `aggregateRating`.

Open questions for the restaurant are listed at the end of `doc/RESEARCH.md`.

### Photography

45 photographs, all Rosebay's own or from their listings — their Instagram
(1440×1920 originals), their Wongnai gallery, their Google Business listing.
`_qa/*-manifest.json` plus `_qa/fetch-manifest.ps1` reproduce the harvest;
`_qa/build-images.ps1` crops and resizes into `img/`.

Two things that matter:

- Their Wongnai photographs carry a **burnt-in dish caption and wordmark** across
  the lower quarter of the frame. Those duplicate the site's own typography and
  read as artifacts, so `build-images.ps1` crops the band away (`cb` in the
  plan). Their captions were, however, the most reliable label available — that
  is how each kaprao photograph is correctly matched to its dish.
- Google's photo strip leaks neighbouring venues into the results. Anything that
  could not be tied to Rosebay (a whole other café, Toplofty) is excluded.

---

## Making changes without touching components

| Change | Edit |
|---|---|
| Hours, phone, address, coordinates, social links | `data/site.json` |
| Menu items, prices, categories, featured dishes | `data/menu.json` |
| Turn the pet module off | `data/site.json` → `pet.enabled` |
| Show an announcement banner | `data/site.json` → `announcement` |

`menu.html` renders entirely from `data/menu.json` at runtime. `data/site.json`
is the declared single source for the facts that appear in more than one place;
the static pages currently carry those values inline, so update both if you edit
hours or the phone number — or wire the pages to the JSON, which is the intended
next step.

---

## Engineering notes worth keeping

**Reveals are measured, never observed.** `IntersectionObserver` delivers its
callbacks as part of the rendering lifecycle, so any host that is not painting
normally — an embedded viewer, a backgrounded frame — can deliver *nothing*, and
everything gated on it stays at `opacity: 0` forever. `js/app.js` measures with
`getBoundingClientRect()` on a rAF-throttled sweep, hooked to scroll, wheel,
touchmove, resize, load and `fonts.ready`, with a 2.5s backstop that opens
everything if no scroll signal ever arrives.

**No layout depends on `svh`.** In a host that reports a zero-height viewport,
`svh` resolves to `0px` — and a section sized purely in `svh` collapses to
nothing, taking the signature interaction with it. Heights come from `--vhpx`,
which has a static CSS fallback and is refined by JS only when the measurement is
plausible.

**A script error cannot blank the page.** Reveals start hidden and are opened by
JS, so the inline head script drops the `.js` flag on any script error and the
`html:not(.js)` rules show everything. Verified with JS fully disabled: the hero
renders, the headline is visible, and the pan section becomes a readable stack
instead of a 3,700px dead zone.

**Masking must clear the glyphs, not the line box.** The line-mask reveal
clips each line so it can wipe in. At `line-height: .92` a descender — g, y, p,
or a Thai below-vowel — sits about .13em below the line box, so the clip has to
grow. Padding the element *inside* the mask with a matching negative margin
leaves the clip box exactly the same height and silently does nothing; that is
what sliced the tail off "along." The padding belongs on the masking span, the
negative margin keeps the rhythm, and the start position has to clear the taller
box. `_qa/headings.html` pulls every masked heading out of all four pages, in
both languages, and lays them over a magenta bar — any glyph the mask is cutting
shows a bite taken out of it.

**Captioned figures.** `.rv-img` clips its own overflow so the reveal wipe stays
in frame — which also clipped away any `<figcaption>`. Figures with captions
carry `.cap`, which moves the aspect ratio onto the image, stops the figure
clipping, and drops the 1.06 entrance scale so nothing spills.

**Per-ground colour tokens.** `--fg`, `--fg-2`, `--fg-3`, `--rule` and `--accent`
are redefined by `.ground-kitchen`, `.ground-tint` and `.ground-green` and cascade,
so a light block nested in a dark section always resolves correctly.

---

## QA

```powershell
cd _qa
.\shot.ps1 -Page index                      # desktop, 1440 viewport
.\shot.ps1 -Page index -To '%23kitchen'     # land on a section
.\shot.ps1 -Page menu -Mobile               # true 390x844 via an iframe wrapper
.\shot.ps1 -Page index -Lang th             # Thai
.\shot.ps1 -Page index -Probe               # overflow + contrast report
.\shot.ps1 -Page index -Swipe th            # the language band, mid-sweep
.\veil-shot.ps1 -P 0.62                     # the loading veil, held at 62%
.\build-thumbs.ps1                          # rebuild the gallery thumbnails
```

`_qa/headings.html` is the type check: it pulls every masked heading out of all
four pages, renders each in both languages, and lays them over a magenta bar, so
a glyph the mask is clipping shows a bite taken out of it.

`?shot=1` is a settle mode: it kills transitions, opens every reveal, and
positions the page by `&y=` or `&to=`. It re-applies on `resize` because headless
Edge lays out at a shorter viewport during load and then resizes before
rasterising — without that the shift lands hundreds of pixels short. `&probe=1`
renders a layout report over the page: horizontal overflow offenders and every
text/ground pair below WCAG AA.

Current state at 1440 and at 390: **no horizontal overflow on any page**, and no
contrast failures except the nav while it is still over the hero photograph,
where a static ratio cannot judge — that case is handled with the hero's top
scrim plus a text shadow, both removed the moment the nav goes solid.

The in-app Browser pane reports a **zero-size viewport whenever it is hidden**,
which makes every JS measurement there useless and lazy images look broken.
Screenshots still composite correctly. Use headless Edge for anything
measurement-shaped, and confirm fixes by inspecting *class names*, which stay
truthful, rather than computed values, which do not.

---

---

## Shareable single-file build

<https://claude.ai/code/artifact/90bb258a-06e9-44f7-801f-e927eef7de9a>

```powershell
cd _qa
.\build-artifact-img.ps1     # re-encode the 46 referenced photographs to artifact sizes
.\build-artifact.ps1         # fold the four pages into one file
```

`_qa/build-artifact.ps1` folds the site into `_qa/rosebay-artifact.html` — 6.4 MB
against a 16 MB ceiling. Chrome comes from `index.html`; the other three pages
become hash routes (`#menu`, `#our-home`, `#visit`, plus `#pet-friendly` which
means "the visit route, then its pet section"). One page is in the document flow
at a time, so each starts at its own top and the nav goes solid off the home
route.

What the build has to handle:

- **Each image is base64'd exactly once** into `window.RB_IMG`, keyed by its
  original path; the markup carries `data-img-src` and a 1×1 placeholder that a
  hydrate pass fills before `app.js` runs. Pasting the data URI at every `<img
  src>` multiplies anything that appears on more than one page. `window.RB_SRC()`
  resolves a path through the map or returns it unchanged, so `menu.js` and
  `gallery.js` run identically as four pages or as one file — same for
  `window.RB_MENU`, which stands in for the `data/menu.json` fetch.
- **Blocks are extracted by counting nested tags, not by lazy regex.** A
  `.*?</div>\s*</div>` stopped one close short of the three-deep veil markup, and
  the resulting unclosed `<div>` adopted the entire rest of the document — which
  the veil controller then removed, publishing a blank page. The build now
  asserts every extracted block closes every `<div>` it opens.
- **The viewer's CSP admits no third-party frames**, so the OpenStreetMap embeds
  would render as empty boxes on the one section whose job is directions. They
  become a real card: the gable mark, the address, coordinates and plus code, and
  the button that matters. The duplicate controls that sat beside the live map
  are dropped.
- `scroll-behavior: smooth` is forced back to `auto` — across a document this
  tall a section jump becomes an interminable crawl.
- Ids that collide once the pages share a document are renamed: index's `#visit`
  section becomes `#find-us`, visit's `#pet` becomes `#v-pet`.

**Keep the build script saved as UTF-8 with a BOM.** PowerShell 5.1 parses a
BOM-less `.ps1` as ANSI, which silently mangles every non-ASCII literal in it —
the first build shipped a mojibake `<title>` and a broken Thai skip link.

`_qa/art-shot.ps1 -Hash visit -Y 620` screenshots the built artifact.

## Not done / would do next

- Wire the static pages to `data/site.json` so hours and phone have exactly one home.
- Get the remaining menu pages from Rosebay (drinks, desserts, sides, beef-fat
  fried rice) so no price on the site comes from a photograph.
- Confirm the pet rules and the canonical address spelling with the restaurant.
- `img/` is ~15 MB of JPEG/WebP (including the gallery thumbnails in `img/g/`). AVIF plus `srcset` would cut the hero
  meaningfully; no build step exists here to generate them.
