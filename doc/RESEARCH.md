# Rosebay Home Cooking & Café — source study

Everything the website says about Rosebay is listed here with where it came from.
Nothing on the site is invented. Where a fact could not be verified it is either
withheld or shown as an attributed third-party claim. Compiled 29 Aug 2026.

---

## 1. Identity

| Fact | Value | Source |
|---|---|---|
| Name | Rosebay Home cooking Café / Rosebay Homecooking Café | Their own FB page name, IG display name, Google listing. Both spellings are in live use by the business itself. |
| Wordmark | `ROSEBAY` in a light, widely letterspaced geometric sans, with `HOME COOKING CAFÉ` letterspaced beneath | Read off their own photo watermark (`_src/wn-17`) and their printed menu header (`_src/gm-04`) |
| Sign on the building | Green cut-out letters `ROSEBAY` on the white siding | `_src/gm-29`, `_src/wn-17`, `_src/gm-07` |
| House logo | A simple gable/house outline containing the name, used on the green A-board and as a faint menu watermark | `_src/gm-01` (OPEN board), `_src/gm-04` (menu) |

### Where the name comes from — VERIFIED, and it is the site's spine

Two independent Thai sources state that "Rosebay" is a place in Australia where
the owner went to learn to cook, and that the owner's former surname is the word
for **rose** (กุหลาบ) — the two halves of the name.

- Sale Here, *รีวิว Rosebay Home cooking Café คาเฟ่เขาใหญ่ ที่สายกะเพราเลิฟเวอร์ต้องแวะ!* —
  "ชื่อ 'Rosebay' มาจากชื่อเมืองในประเทศออสเตรเลีย ซึ่งเป็นจุดเริ่มต้นที่เจ้าของร้านไปเรียนรู้เรื่องการทำอาหาร
  และนามสกุลเดิมของเจ้าของร้านคือคำว่า 'กุหลาบ'"
- Restated independently in the Thai review aggregation for the same venue.

**How the site uses it:** as the "Our Home" story and the `ROSE / BAY` typographic
device. The site says the name joins a bay in Australia where the owner learned to
cook with her own family name. It does **not** name the owner, give a date, or say
which suburb — none of that is verified.

**Not claimed anywhere on the site:** owner's name, year opened, chef biography,
awards, suppliers, coffee origin, seating capacity, reservations.

---

## 2. Contact, address, hours

| Fact | Value | Source |
|---|---|---|
| Address | 339 หมู่ 11 ต.หนองน้ำแดง อ.ปากช่อง จ.นครราชสีมา 30130 | Google listing; Wongnai; RestaurantGuru — three independent listings agree |
| Their own directions | "เขาใหญ่ ถ.ธนะรัชต์ KA. 4 ซอยตรงข้ามโรงเรียนบ้านนา กลับรถ⤵️ตรงหน้าทิวเขา" | **Their own IG caption**, posted 28 Aug 2026 |
| Coordinates | 14.6304824, 101.4045083 | Google Maps place URL |
| Plus code | JCJ3+5R หนองน้ำแดง | Google listing |
| Phone | 064-361-4569 | Their own IG caption + FB page + every listing |
| Email | Rosebayhomecookingcafe@gmail.com | Their own FB page intro panel |
| Instagram | @rosebayhomecookingcafe (3,788 followers) | instagram.com/rosebayhomecookingcafe |
| Facebook | Rosebay Home cooking Café — /rosebaycafe (9.8K followers) | facebook.com/rosebaycafe |
| TikTok | @rosebayhomecookingcafe | search result — listed but not used as a primary channel on the site |

### Hours — the conflict, and how it was resolved

- **Their own Instagram caption, posted 28 Aug 2026**: `💚 Open Every Day` · `🕰 9.00 - 18:00`
- **Their own Instagram bio**: `Open : 7 Day`
- **Their own Facebook post, 29 Aug 2026**: `Open Every Day` · `9.00 - 18:00`
- Wongnai and two Thai blogs say **closed Tuesdays**. Those pages date from 2022–2025.
- RestaurantGuru and Wanderlog say daily; Wanderlog says 09:00–17:00.
- One 2022 Wongnai reviewer noted the kitchen closing at 17:30.

**Published**: `Open every day · 09:00 – 18:00`, sourced to the restaurant's own
channels, with a visible "kitchen winds down before closing — call ahead if you are
arriving late" line and a call-to-confirm on the Visit page. The stale
closed-Tuesday listings are deliberately not repeated. A single `data/site.json`
drives hours everywhere (home, visit, footer, JSON-LD).

**Not claimed**: a specific last-order time. Reported values conflict (17:00 / 17:30)
and none come from the restaurant.

---

## 3. The menu — read off their own printed menu

The prices and dish names on the site come from a photograph of Rosebay's own
printed menu, filed under the Menu category on their Google listing
(`_src/gm-04.jpg`, 1500×2000). The page is headed `HOMECOOKING & CAFÉ` / `- FOODS -`
and closes with their own sign-off, `have a wonderful day!`.

Transcribed verbatim (their English spelling is kept in `doc/`, tidied on the site;
Thai is kept exactly as printed):

**KHAO KAPRAO DISHES**

| EN (as printed) | TH (as printed) | ฿ |
|---|---|---|
| KAPRAO FRIED RICE MINCED PORK WITH CRACKLING PORK AND FRIED EGG | ข้าวผัดกะเพราคลุกหมูสับกากหมูไข่ดาว | 150 |
| KHAO KAPRAO MINCED PORK WITH CRACKLING PORK AND FRIED EGG | ข้าวกะเพราหมูสับกากหมูไข่ดาว | 150 |
| KHAO KAPRAO BEEF TENDERLOIN WITH FRIED EGG/OMELETTE ★ | ข้าวกะเพราเนื้อสันในไข่ดาว/ไข่เจียว | 160 |
| KHAO KAPRAO CRAB WITH FRIED EGG/OMELEETTE ★ | ข้าวกะเพราปูไข่ดาว/ไข่เจียว | 290 |
| KHAO KAPRAO CRAYFISH WITH FRIED EGGS/OMELEETTE | ข้าวกะเพรากั้งไข่ดาว/ไข่เจียว | 290 |
| KHAO KAPRAO SCALLOP WITH FRIED EGGS/OMELEETTE | ข้าวกะเพราหอยเชลล์ไข่ดาว/ไข่เจียว | 290 |

**FRIED RICE DISHES**

| EN (as printed) | TH (as printed) | ฿ |
|---|---|---|
| RICE FRIED OMLETTE | ข้าวไข่เจียว | 120 |
| CHINESES SAUSAGE FRIED RICE | ข้าวผัดกุนเชียง | 120 |
| CRAB FRIED RICE | ข้าวผัดปู | 290 |
| CRAYFISH GARLIC FRIED WITH FRIED EGG ★ | ข้าวกั้งผัดกระเทียมไข่ดาว | 290 |
| SCALLOP GARLIC FRIED WITH CREAMY OMELETTE | ข้าวหอยเชลล์ผัดกระเทียมไข่ข้น | 290 |

**ADD-ON** (printed in a dashed box)

| EN | TH | ฿ |
|---|---|---|
| FRIED EGG | ไข่ดาว | 20 |
| CRACKLING PORK | กากหมู | 50 |

★ = marked with a "recommended" hand icon on their printed menu.

### Dishes that are real but whose current price is NOT on that page

These appear repeatedly in guest reviews and photographs but are on menu pages that
were not obtainable. They are shown on the site **without a price**, in a clearly
labelled "also on the menu" list, rather than guessing.

ข้าวผัดมันเนื้อ (beef-fat fried rice) · ข้าวผัดเนื้อเค็ม (salted-beef fried rice) ·
ข้าวเนื้อสันในผัดกระเทียมไข่ข้น (beef tenderloin, garlic, creamy omelette) ·
ข้าวหมูกรอบ (crispy pork) · ข้าวผัดรถไฟ (railway fried rice) · ผัดซีอิ๊ว (pad see ew) ·
มันหวานฟรายส์ (sweet potato fries) · มันฝรั่งฟรายส์ (fries) · กุนเชียงทอด (fried Chinese sausage) ·
ข้าวกะเพรามังสวิรัติ / กะเพราเจ plant-based · ขนมเปี๊ยะถั่วไข่เค็ม (mung-bean & salted-egg pastry) ·
coffee, matcha, lemongrass and mangosteen juice, cakes.

Sources: Wongnai reviews (2022–2026), Google reviews (2026), Pantip, Thaifootprint,
Sale Here, Preawpak, HappyCow (which lists the vegetarian/plant-based kaprao).

**Deliberately not published**: older prices found in 2022 reviews (135/150/90/95/80/50).
They are years out of date and contradict the current printed menu in places.

---

## 4. The food, in guests' own words

Quoted on the site only where attributed, and never as a fabricated testimonial.

- "ข้าวผัดหอมกลิ่นกระทะไหม้ๆแห้งๆเป็นเอกลักษณ์เฉพาะของร้าน ผัดกระเพราอร่อยทุกเมนู" — Google review
- "กะเพราอร่อยมาก ไข่เป็ดดาวดีเลิศ ปริมาณอาหารคุ้มราคา" — Google review
- "ข้าวกระเพราอร่อยดีครับผัดมาแห้งกำลังดีข้าวเรียงเม็ด … มีโซน pet-friendly โดยเฉพาะดีมาก" — Google review, ~Jul 2026
- "กะเพราปูให้เนื้อปูสะใจ … หอยเชลตัวใหญ่สวยๆ" — Google review
- "เข้ามาในซอยเล็กๆถ้าไม่มี GPS คงหลง" — Google review (this is why Get Directions is the primary action)
- "เข้ามาในร้านเป็นครัวเปิด ครัวจริงจังมาก" — Wongnai review
- Duck eggs, not chicken: "ไข่เป็ด" appears across Wongnai, Pantip and Google reviews.

Mixed views exist and are not hidden in the research: two 2026 Google reviewers found
the kaprao milder than they expected, and one found the air-conditioning weak. The site
makes no rating claim of its own.

**Ratings** (real, but deliberately NOT marked up as `aggregateRating` and not used as
a badge): Google 4.5 from 698 reviews; Wongnai 4.1 from 31 ratings; Facebook 98%
recommend from 54 reviews. Google price band ฿200–400 per person, reported by 187 users.

---

## 5. The place

- White board-and-batten cottage, gable end with three square vents, **teal-green
  awning and matching green sign letters**, timber porch and timber double doors with
  glazing. `_src/gm-29`, `_src/wn-17`, `_src/gm-01`
- Raised timber beds of herbs and vegetables directly in front of the building; the
  restaurant grows produce it cooks with. `_src/gm-29`; stated in Sale Here and Thaifootprint.
- Open kitchen in the middle of the room, white tiled counter, pendant lights, cooks
  working in front of guests. `_src/wn-09`, `_src/wn-10`, `_src/wn-21`
- Interior: white walls, dark timber tables and chairs, pitched ceiling, garden windows.
  `_src/gm-26`, `_src/gm-02`, `_src/wn-11`
- Coffee counter, espresso machine, dessert cabinet with cakes. `_src/wn-19`, `_src/gm-31`
- Down a small soi opposite Ban Na School, off Thanarat Road around the KA. 4 marker.
- Butterflies at the entrance are mentioned by a 2026 Google reviewer — charming, but
  not published as a promise.

### Brand colour, sampled not guessed

Sampled with a canvas from `_src/wn-17` (awning) and cross-checked against `_src/gm-07`,
`_src/wn-08` and `_src/wn-19`:

| Token | Hex | Sampled from |
|---|---|---|
| Rosebay green | `#12564C` | awning in shadow `#216C70`, sign board `#0A5C4E` |
| Lit green | `#2E8B84` | awning in sun `#358786` / `#4B9D94` |
| Timber | `#8A5A3B` | interior floor and furniture `#925C39` / `#7C5B4A` |
| Yolk | `#EE7B12` | the actual duck-egg yolk in their food photography `#FE7F02` |

The brief's provisional "deep forest green #23402F" was replaced: Rosebay's real
green is a **teal**, not a forest green.

---

## 6. Pet policy — verified first-party

- **Their own window decal**: a circular white sticker on the timber door showing a dog
  and a cat with the words `PET FRIENDLY`. `_src/gm-27` (zoomed and confirmed).
- A Google reviewer, ~Jul 2026: "มีโซน pet-friendly โดยเฉพาะดีมาก" — a dedicated
  pet-friendly zone.
- A Wongnai reviewer describes an outdoor pet-friendly patio with fans and shade.
- Wanderlog: pets allowed in the outdoor area.

**Published**: that Rosebay welcomes pets, in an outdoor zone, sourced to their own
door decal and guest reports. **Not published**: breed rules, leash or carrier rules,
indoor permission, or any charge — none of that is stated anywhere by the restaurant.
The site asks visitors to check on arrival, and the whole module can be switched off
from `data/site.json` (`pet.enabled`).

---

## 7. Photography provenance

45 images harvested. Where each came from:

| Set | Count | Source | How |
|---|---|---|---|
| `ig-*` | 10 | Their own Instagram, posts dated 18–28 Aug 2026 | Post permalinks render logged-out; the DOM carries the full 1440×1920 original |
| `wn-*` | 25 | Their Wongnai listing gallery | `img.wongnai.com/p/1920x0/<path>` fetches directly. The 2025-12-17 batch carries **their own** `ROSEBAY / HOME COOKING CAFÉ` watermark, so those are restaurant-supplied |
| `gm-*` | 31 | Their Google Business listing | `lh3.googleusercontent.com/...=w2000-h2000` |

**Excluded on purpose**: `gm-12` (TOPLOFTY KHAO YAI), `gm-13`, `gm-14`, `gm-15`, `gm-16`,
`gm-17` — Google's panel leaked photos of neighbouring venues into the strip. Nothing
that could not be tied to Rosebay is used.

Seasonal note: several strong exteriors (`wn-17`, `gm-01`, `wn-15`) carry Christmas
decorations. They are used sparingly and never as the hero, so the site does not look
permanently festive. The hero (`gm-29`) is undecorated daylight.

Reproduce any of it with `_qa/fetch-manifest.ps1 -Manifest _qa/<set>-manifest.json`.
The Instagram and Google URLs are signed and expire — re-harvest rather than editing them.

---

## 8. Open questions for Rosebay

Flagged rather than guessed:

1. Confirm the canonical address and whether "หนองน้ำแดง" or "หมูสี" is correct — listings differ.
2. Confirm hours and whether there is a last-order time.
3. Supply the remaining menu pages (drinks, desserts, sides, the beef-fat fried rice page)
   so prices stop coming from a photograph.
4. Confirm the pet rules you would like published.
5. Confirm whether reservations are taken. The site currently assumes not, and leads with
   directions instead.
6. Confirm the correct spelling of the name in English — the business uses both
   "Rosebay Home cooking Café" and "Rosebay Homecooking Café".
