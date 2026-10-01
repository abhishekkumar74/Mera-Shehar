# master.md — "Mera Shehar"

> Read this file fully before writing any code. Work ONE phase at a time (see section 11). After each phase: stop, summarise what was built, list anything skipped, and wait for approval. Do not add features, screens or packages that are not in this file. If something is unclear, ask instead of guessing.

---

## 1. Product in one paragraph

Mera Shehar is an Android-first Flutter app for everyday Indian users (18-50, small cities and towns, mid-range phones). The user sets up their **photo and name once**. Every festival (Diwali, Dhanteras, Christmas, New Year, Chhath, Eid, birthdays...) they get beautiful premium cards with **their own photo and name already placed on the card**, and share it in **one tap to WhatsApp Status or groups**. Each shared card carries a small "Mera Shehar" watermark, which is the main organic growth loop. Revenue this year: Google AdMob only.

**North-star behaviours:** (1) open app, (2) card already has my photo and name, (3) one tap to WhatsApp. Everything else is secondary.

### Non-goals for v1 (do NOT build)
Mandi/sone-chandi bhav, news, polls/community, chat, jobs, buy-sell, subscriptions/payments, user accounts with phone/OTP login, server-side photo storage, iOS, web.
(Planned later: village polls, e.g. "match khelna hai, team bulao". Keep code modular so a new feature tab can be added, but build nothing for it now.)

---

## 2. Tech stack (fixed — do not substitute)

**Backend is Firebase only.** No Node/Express server, no Supabase in v1 (not needed: photos stay on device, templates come from Firestore/Remote Config, push is FCM). Repo layout: Flutter app lives in `client/`; paths like `lib/...` in this file mean `client/lib/...`.

| Area | Choice |
|---|---|
| Framework | Flutter (stable), Dart, Android first. minSdk 24 |
| State | `flutter_riverpod` |
| Routing | `go_router` |
| Backend | Firebase: Core, Auth (**anonymous only**), Firestore, Storage, Remote Config, Messaging (FCM), Analytics, Crashlytics |
| Ads | `google_mobile_ads` (AdMob) |
| Photo | `image_picker`, `image_cropper` |
| Photo cut-out (Phase 2 only) | `google_mlkit_selfie_segmentation` |
| Share | `share_plus`, `android_intent_plus` (WhatsApp intent) |
| Files | `path_provider` |
| Images | `cached_network_image` |
| Local storage | `shared_preferences` |
| Install tracking | `play_install_referrer` |
| Links (policy pages, Play Store) | `url_launcher` |

Rules: no other packages without asking. Fonts are **bundled as assets**, not fetched at runtime. APK/AAB target < 25 MB. Must run smoothly on 3 GB RAM phones. Templates must load from the network but have **3 bundled fallback templates** so the app works offline on first launch.

---

## 3. Design system

Source of truth is the Stitch design (light, warm, editorial). Hex values below are read from the screenshots; if Stitch's own design-system export is available, prefer its exact values and tell me about differences.

### 3.1 Colour tokens (light theme only — NO dark mode)

| Token | Hex | Use |
|---|---|---|
| `bg` | `#FDF8F4` | Screen background |
| `surface` | `#F6ECE2` | Input fields, cream tiles |
| `heroPeach` | `#F4E8D8` | Diwali hero card base |
| `chip` | `#EDE6E1` | Inactive chips |
| `border` | `#EBE1D0` | Hairlines (0.5-1px) |
| `ink` | `#2B2623` | Primary text, primary button |
| `muted` | `#7A6F63` | Secondary text |
| `hint` | `#B9AE9F` | Inactive icons, placeholders |
| `gold` | `#8A6212` | Small accent text/icons |
| `goldLine` | `#C9A04A` | Line-art, rings, dashed borders |
| `white` | `#FFFFFF` | Sheets, pills over cards |
| `success` | `#22C55E` | Tiny status dot only |

Template card palettes (pastel, set per template in data, not in UI code): peach `#F6E9DD`, sage `#DFE6D6`, blush `#F4DDD5`, ivory `#F3ECDD`.

### 3.2 Typography
- Display / card text: **Playfair Display** (Latin) + **Tiro Devanagari Hindi** (Devanagari fallback). Both bundled.
- UI body: **Plus Jakarta Sans** (Latin) + **Hind** (Devanagari fallback).
- Only weights 400 and 500 (600 for card titles only if the template says so).
- Sizes: title 28, screen heading 22, body 14, small 12, caption 11. Nothing below 11.
- Eyebrow labels (uppercase, letter-spaced 2px, 11px, `gold`) are allowed **only inside template cards**, never in app chrome.
- Sentence case everywhere in the UI.

### 3.3 Shape, spacing, motion
- Radius: hero card 24, tiles 16, buttons 16, chips full pill, bottom sheet top 28.
- No drop shadows. Use 1px `border` hairlines. Only the bottom sheet may have a soft shadow.
- Spacing: 8pt grid. Screen horizontal padding 20. Gap between sections 24.
- Primary button: height 56, `ink` fill, `bg` text, 16 radius. Secondary: transparent, text `ink`, no fill (optionally 1px border).
- **One primary button per screen.**
- Icons: thin outline only, 1.5 stroke (use `lucide_icons` style via built-in `Icons.*_outlined` if no icon package; do not add an icon package without asking).
- Motion: 200-250 ms ease-out. Share button gives a light haptic. Skeleton shimmer for loading images, never a spinner on a blank screen.

### 3.4 Max density rule
Max 3 sections per screen. If a screen feels busy, remove things, do not shrink them.

---

## 4. Screens (final list for v1)

Global: single app bar per screen (never two stacked headers). Bottom nav has 4 tabs: Home, Tyohar, Saved, Profile (outline icon + 11px label, sentence case; active = `ink`, inactive = `hint`). Bottom nav is hidden on Onboarding, Editor and Share-success.

### S1. Onboarding (first launch only, one screen, no login)
Reference: Stitch "Onboarding" screenshot. Layout, top to bottom, centered:
- Logo mark: pin-with-sunrise inside a 56dp circle filled `surface`, top, 24dp from safe area.
- Heading (Playfair 28, `ink`, centered): "Apna card, apne naam se"
- Sub (Plus Jakarta 14, `muted`, centered, max 2 lines): "Ek baar photo aur naam daalo. Baaki roz ka card ready milega."
- Photo picker: 112dp circle, fill `surface`, 1.5px dashed `goldLine` border, camera icon (gold) and label "Photo chunein" (12, gold) inside. Once a photo is chosen, show the cropped photo inside the circle with a small edit badge.
- Caption under picker (12, `muted`, sentence case): "Passport ya profile photo"
- Field: label "Aapka naam" (13, `ink`) above a 52dp input, fill `surface`, radius 16, no border, text 16. Required, max 30 chars, trim whitespace.
- Primary button "Shuru karein" with a right-arrow icon, full width, 56dp.
- Under button, centered, 12 `muted` with clock icon: "Sirf 20 second lagenge"
- At the very bottom (11, `muted`, centered): "Aapka photo sirf aapke phone mein rehta hai." and "Aage badhkar aap Privacy Policy aur Terms se sahmat hote hain." where "Privacy Policy" and "Terms" are tappable links.
Behaviour:
- Tapping photo picker: bottom sheet with "Gallery se chunein" and "Camera se lo", then square crop (1:1). Use the Android photo picker (no storage permission). Camera permission only when Camera is chosen.
- Tapping "Shuru karein" with missing photo or name: do not navigate; show inline error under the missing field in `#B3261E` 12px: "Photo chunein" / "Naam daalo". No snackbars, no disabled button.
- Screen must scroll and keep the button reachable when the keyboard is open (`resizeToAvoidBottomInset` true, wrap in `SingleChildScrollView`).
- On success: save profile locally (`shared_preferences` for name, photo as JPEG 800x800 in app documents dir), then go to Home and replace the route (no back to onboarding).
- The shop-name field from earlier drafts is REMOVED from onboarding. It exists only in Profile (optional).
- **No upload. Nothing leaves the device.**

### S2. Home
Reference: Stitch "Home" screenshot (apply the fixes in section 4.1).
- App bar (single, only one in the app shell): left = logo mark (36dp, `surface` rounded square, radius 12) + wordmark "Mera Shehar" in Playfair 18 (single line, never wraps); right = user avatar 36dp circle with 1.5px white ring (tap opens Profile). There is NO centered "Home" title.
- Greeting block below app bar (left aligned, no second avatar): "Namaste" (13, `muted`) above "<first name> ji" in Playfair 22.
- Hero card (ratio 4:5, radius 24, fill = template background, soft 1px `border` outline). Content of the default Diwali hero: inner hairline frame (1px `goldLine`, 10dp inset, radius 18), three tiny sparkle marks near the top, a gold line-art diya inside a flat glow circle (flat concentric circles, no blur), serif title "Shubh Deepawali" (Playfair 32), subtitle (Plus Jakarta 14, gold, max 2 lines) "Aapko aur aapke parivaar ko dheron shubhkaamnayein", and the user's photo pill (white, radius full, avatar 36 + name 14/500) at the bottom. Illustration and title must be sized/positioned so there is no large empty gap in the middle of the card.
- The hero card height is capped so the **"Status lagao" button is fully visible without scrolling** on a 360x780 dp screen.
- Primary button "Status lagao" (WhatsApp icon + label), full width, 56dp.
- Small centered text button "Badlo" under the primary button, which opens the Editor.
- Section header row: "Aane wale tyohar" (13, `muted`, sentence case) and a right text link "Sab dekho" (gold) which opens the Tyohar tab.
- Upcoming row: horizontally scrollable tiles (width 112, height 128, radius 16, pastel fill from the template palette). Each tile: date chip at top (e.g. "25 Dec", 12) from `festivalDate`, a 48dp circular icon holder with a line icon, title serif 14 at the bottom. Tapping opens the Editor with that template. Dates are always computed from data and formatted "d MMM". Show the next 3-5 upcoming festivals only.
- Optional single native ad below the upcoming row, flag-controlled.
- Screen scrolls; bottom nav stays fixed. Content gets bottom padding equal to nav height so nothing is hidden behind it.
- States: loading (skeleton for hero and tiles), offline (use bundled/cached templates, small "Offline" chip), no featured (use the next upcoming festival).

### S3. Tyohar (browse)
- App bar: title "Tyohar" only (no logo, no extra header). No subtitle clutter.
- Category chips (horizontal scroll): Sab, Diwali, Christmas, New Year, Chhath, Eid, Birthday (driven by data).
- 2-column grid of tall template cards (radius 16), each already shows the user's photo pill. Small crown icon top-right if `isPremium`. Label under card: template title only.
- Native ad slot every 8th item (flag-controlled).
- Pagination: load 20 at a time.
- Remove from Stitch design: "Handcrafted folios", "6 Collections", eyebrow headers outside cards.

### S4. Editor
- App bar: back arrow, centered serif template title, download icon (saves PNG to gallery).
- Large live card preview (this is the exact widget that gets exported).
- "Photo kahan lage": 4 layout options (bottom-left, bottom-center, bottom-right, no photo). Selected = `ink` border + check.
- Buttons row: **Status** (primary, WhatsApp icon) + **Share** (secondary, share icon).
- Name pill shows user name; tapping the pill lets user edit name for this card only.

### S5. Share success (bottom sheet)
Shown when the user comes back to the app after sharing.
- Check icon, serif "Card tayyar hai"
- Muted: "Status par lagao, dost dekhenge."
- Primary: "Ek aur card banao". Text button: "Home par jao".
- **Never claim the status was posted** (WhatsApp gives no callback). Wording must be "khul gaya / tayyar", not "ho gaya".

### S6. Profile
Edit photo, name, shop name. Privacy Policy and Terms (open via `url_launcher`, URLs in one constants file), "Dost ko bhejo" (referral share, added in Phase 4). App version is added in Phase 5. Nothing else.

### S7. Saved
Grid of cards the user saved (local list of template IDs + chosen layout). Empty state: "Abhi koi card save nahi kiya" with button "Tyohar dekho".

---

## 4.1 Stitch reference screens: what to copy and what to fix

Five Stitch screens exist (Onboarding, Home, Tyohar, Editor, Share success). They are visual references, not code. Copy the look, never copy the mistakes below. The phone frame and fake status bar in the Stitch screenshots are NOT part of the app.

**Copy:** warm off-white background, Playfair headings, thin gold line-art, pastel cards, inner hairline frame on cards, white photo pill, rounded dark primary button, dashed gold photo picker.

**Mandatory fixes (these override the screenshots):**
1. One app bar per screen. Stitch shows two stacked headers on Editor and Tyohar and two avatars on Home. Home has exactly one avatar (app bar).
2. Remove the grey gradient strip under the Home app bar (rendering artifact).
3. No centered "Home" / "Cards Tyohar" / "Card Customizer" / "Send Gilded Wish" titles in app bars. Only: Home = logo + Mera Shehar; Tyohar = "Tyohar"; Editor = template title; Share sheet = no title.
4. Remove English filler: "Handcrafted folios", "6 Collections", "Winter solstice", "Season of grace" as UI text. (Eyebrow text like this may exist only inside template artwork if the template data says so.)
5. UI labels are sentence case. Bottom nav labels: "Home", "Tyohar", "Saved", "Profile" (11dp, not uppercase). Section headers like "Aane wale tyohar" are sentence case, 13dp, `muted`. The uppercase letter-spaced style exists only inside template cards.
6. Dates are never hardcoded. Stitch's "10 Nov" for Dhanteras is a placeholder. All dates come from `festivalDate` in template data (verify real dates when entering data).
7. All dark buttons use `ink` `#2B2623` (Stitch mixes two browns).
8. Success sheet wording: "Card tayyar hai", never "share ho gaya" (WhatsApp gives no callback).
9. Hindi font fallback must work: any Devanagari text uses Tiro Devanagari Hindi (headings) or Hind (body).
10. Onboarding: add the missing privacy/consent lines and keep the keyboard behaviour described in S1.

## 5. Card engine (the heart of the app — build with most care)

- A template is rendered by a single `CardRenderer` widget that takes `Template + UserProfile + Layout`. The same widget is used in Home, Tyohar thumbnails, Editor and export. No separate export UI.
- Export: wrap in `RepaintBoundary`, `toImage(pixelRatio)` to a **1080x1350 PNG (4:5)**, write to cache dir, then share. Export must complete in < 1.5 s on a low-end phone.
- Watermark: small "Mera Shehar" mark bottom-right, 40% opacity, inside the PNG. Always on in v1. Position must not collide with the photo pill in any layout.
- Photo layouts (v1): `bottomLeft`, `bottomCenter`, `bottomRight`, `none` (pill with photo + name). Phase 2 adds `cutoutLarge` (background-removed photo placed large on the card, using ML Kit selfie segmentation). Segmentation runs once at onboarding and the result is cached as a transparent PNG.
- Text on cards supports Hindi + English. Never clip: use auto-fit with a min font size, then wrap.

### 5.1 Template data model (Firestore `templates/{id}` and bundled JSON fallback)
```json
{
  "id": "xmas_pine_01",
  "category": "christmas",
  "title": "Minimal Pine",
  "festivalDate": "2026-12-25",
  "isPremium": false,
  "isActive": true,
  "sortOrder": 10,
  "canvas": { "ratio": "4:5", "bgColor": "#DFE6D6" },
  "backgroundUrl": "templates/xmas_pine_01/bg.webp",
  "thumbUrl": "templates/xmas_pine_01/thumb.webp",
  "texts": [
    { "text": "SEASON OF GRACE", "style": "eyebrow", "x": 0.5, "y": 0.12 },
    { "text": "Merry Christmas", "style": "display", "x": 0.5, "y": 0.2 },
    { "text": "Peace, warmth & joyful light", "style": "italic", "x": 0.5, "y": 0.78 }
  ],
  "photoLayouts": ["bottomLeft", "bottomCenter", "bottomRight", "none"],
  "defaultLayout": "bottomLeft"
}
```
Backgrounds are WebP (max ~150 KB each). Text positions are normalised 0-1 so the card scales to any size. New templates must be addable from Firestore with **no app update**.

---

## 6. Architecture

Feature-first structure:
```
lib/
  main.dart
  app/            (router, theme, constants)
  core/           (tokens, widgets, utils, services)
  features/
    onboarding/
    home/
    tyohar/
    editor/
    share/
    saved/
    profile/
    templates/    (model, repository, CardRenderer)
```
- Repository pattern: `TemplateRepository` (Firestore + cache + bundled fallback), `ProfileRepository` (local only), `ShareService`, `AdService`, `AnalyticsService`.
- Firestore offline persistence on. Cache template images with `cached_network_image`.
- Remote Config keys: `featured_template_id`, `ads_enabled`, `native_ad_every_n`, `interstitial_every_n_shares`, `min_app_version`.
- Keep UI widgets stateless where possible; no business logic in widgets.

---

## 7. Sharing and growth

- **Status button:** export PNG, then open WhatsApp share via intent (`com.whatsapp`, fallback `com.whatsapp.w4b`, fallback system share sheet). Be aware: there is no official API to post straight to Status. The WhatsApp picker shows "My status" at the top; the UX copy should say "Status lagao" and the user taps "My status" there.
- **Share button:** system share sheet with the PNG and a short caption: "Mera Shehar se banaya. Aap bhi banao: <play store link>".
- **Referral:** Play Store link carries `referrer=utm_source%3Dshare%26utm_campaign%3D<userCode>`. On first launch read it via Play Install Referrer and log an `install_referred` analytics event. Do **not** use Firebase Dynamic Links (shut down).
- "Dost ko bhejo" in Profile shares the app link with the same referrer.
- Ambassador codes: `utm_campaign=amb_<code>` — just log them, no payout logic in the app.

---

## 8. Ads (AdMob, this year's only revenue)

- Use Google test ad unit IDs in debug builds. Real IDs only via build config, never committed.
- Allowed: one native ad on Home, native ad every Nth grid item on Tyohar, one interstitial **after a completed share**, not in the first session, max 1 per `interstitial_every_n_shares` (default 3). Never block the Editor with an ad before export.
- Not allowed: banners on Editor, ads that cover the card, any prompt asking users to tap ads, auto-redirect ads.
- All ad behaviour is controlled by Remote Config, with a kill switch `ads_enabled`.
- Consent: show Google UMP consent form where required.

---

## 9. Notifications and analytics

- FCM topic `daily`. Ask for notification permission (Android 13+) only after the user's **first successful share**, with the line: "Har subah card ready milega. Allow karein?"
- Notification copy example: "Aaj ka card ready hai. Status par lagao."
- Analytics events: `onboarding_done`, `template_view`, `editor_open`, `layout_change`, `share_status_tap`, `share_generic_tap`, `export_done`, `install_referred`, `notif_open`, `ad_impression`. Always log `template_id`.
- Core metrics to watch: D1/D7 retention, share rate (shares per DAU), template-level share rate.
- Crashlytics on, with non-fatal logging around export and share.

---

## 10. Privacy, policy, quality

- Photo and name stay on device. No photo upload in v1. Say so in the Privacy Policy and Play Data Safety form.
- Privacy Policy and Terms are in-app links and live URLs (Play Store requirement). Include DPDP Act 2023 consent line on onboarding.
- Templates must use only licensed or original artwork. No copyrighted characters, no copied Google images, no real-person likenesses.
- Accessibility: tap targets >= 48 dp, text contrast AA on `bg`, `semanticsLabel` on icon buttons.
- Language: UI copy is Hinglish (Roman). Card text can be Hindi (Devanagari) or English per template. Architecture must allow adding UI languages later (use `intl`-ready string layer, even if only Hinglish ships).

### Copy deck (use exactly)
- Onboarding: "Apna card, apne naam se" / "Shuru karein"
- Home: "Namaste" / "Status lagao" / "Badlo" / "Aane wale tyohar"
- Editor: "Photo kahan lage" / "Status" / "Share"
- Success: "Card tayyar hai" / "Ek aur card banao" / "Home par jao"
- Errors (one sentence, what happened + what to do): "Internet nahi hai. Card phir bhi ban sakta hai." / "Card nahi ban paaya. Dobara try karo."
- Banned words: "successfully", "please", "unlock", "premium experience", shuddh Hindi like "lautien".

---

## 11. Phases (one at a time; each ends with a demo build and a short report)

### Phase 0 — Foundation
Flutter project, folder structure, theme from section 3 (tokens as a single `AppTokens` file), bundled fonts, Firebase setup, go_router skeleton with empty screens and the bottom nav.
**Done when:** app opens in the warm light theme, tabs navigate, fonts render Hindi + English correctly, a debug-only design preview screen matches section 3. Detailed instructions: `docs/prompts/phase-0.md`.

### Phase 1 — Onboarding and profile
S1 and S6 (profile edit). Photo pick + crop, local save, "profile exists" gate at launch.
**Done when:** a new user gets from install to Home in under 30 s, and data survives app restart. Detailed instructions: `docs/prompts/phase-1.md`.

### Phase 2 — Card engine
`CardRenderer`, 3 bundled templates (Diwali, Christmas, New Year), layouts, export PNG, WhatsApp intent, system share, S4, S5. Then add ML Kit cut-out layout `cutoutLarge`.
**Done when:** one tap exports a clean 1080x1350 PNG with correct photo + name and opens WhatsApp; works offline.

### Phase 3 — Template system and browse
Firestore templates, caching, S2 (Home) with featured logic, S3 (Tyohar) with chips and pagination, S7 (Saved), Remote Config, crown flag on premium cards (all still free).
**Done when:** a new template added in Firestore appears in the app without an update.

### Phase 4 — Growth and revenue
FCM daily topic and permission flow, AdMob (native + share-triggered interstitial, frequency capped), referral link and Install Referrer logging, analytics events.
**Done when:** test ads show, events appear in Firebase DebugView, referral param is read on first launch.

### Phase 5 — Polish and release
Animations, skeleton loaders, empty/error states, low-end device test, app size check, Play Console assets (icon, screenshots, Data Safety), closed testing, production release.
**Done when:** passes a 12-tester, 14-day closed test (if personal account), crash-free > 99%, app size < 25 MB.

---

## 12. Working rules for the agent

1. Follow section 3 exactly. If a screen looks busy, delete elements, never shrink fonts below 11.
2. One phase at a time. Report after each phase.
3. No extra packages, features or screens beyond this file.
4. Keep files small and readable. No dead code, no TODO comments left behind.
5. Every user-facing string comes from one strings file.
6. Never hardcode ad IDs, API keys or secrets.
7. When a design decision is missing, propose 2 options with a recommendation and wait.

## 13. Open decisions (D4 and D5 before Phase 0, the rest before Phase 2)
- **D1. Export ratio:** v1 exports 4:5 (1080x1350). WhatsApp Status is 9:16, so the card appears centered with side/top bars. Acceptable for v1; evaluate 9:16 templates in a later phase.
- **D2. App name is "Mera Shehar".** Check Play Store availability before Phase 5. Note: the name suggests one city while the product is festival cards for everyone; revisit only if growth data says so.
- **D4. applicationId** (currently `com.merashehar.app`) must be chosen before Phase 0 and can never change after the first Play Store upload.
- **D5. Firebase project** is created by the owner (manual) before Phase 0; the agent only wires it in.
- **D3. First 3 festivals to design in full:** Dhanteras/Diwali, Christmas, New Year (8-10 styles each).
