# FlashStruct redesign handoff

Updated 2026-09-22. Read this on continuation; do not restart the design interview.

## User requests and approvals

- Original request: `$impeccable init`, then relayout and redesign entire UI using impeccable.
- Confirmed product and scope: Indonesian university students; Array/Struct/Pointer; Pahami → Hafalkan → Buktikan; no accounts, local browser progress; all Home, Dashboard, Materi, Video, Flashcard, Quiz; desktop/mobile equally complete. Preserve business behavior and factual content.
- Explicit constraint: “pastikan tidak ai slop”. User selected familiar learning-app convention deliberately; execute that convention well, not a new unusual metaphor.
- Direction page key `3c0fe4ab`: canon selected, comp-first, toggle NOT flipped. Result saved in `.impeccable/direction-choice.json`. Do not ask again or record comp as a permanent workflow preference; no standing buildPath was answered.
- User delegated selection of quality reference products. Selected Exercism (unlocking exercises), GitBook (reading/navigation), Khan Academy (progress orientation). Official source URLs and rationale: `.impeccable/reference-quality.md` and direction-choice.json.
- Composition page key `86d02a41`: option `a` confirmed by tool and user saying “sudah saya pilih a”. This is final composition approval. Do NOT generate more comps or ask another design approval.
- Approved comp: `.impeccable/mocks/komposisi-a.png` (1505×1045). Sidecar `.png.json` has approved=true; `.json` duplicate also true. B/C are unapproved alternatives.
- Most recent user request: “catat record sebelum limit”. This file fulfills that request; continue implementation afterward.

## Current state

Product record created: `PRODUCT.md`. No application source edits yet. Git status before implementation showed only untracked `PRODUCT.md` and `.impeccable/`; earlier unrelated source changes were committed/cleared by user before this turn. Check current status before edits.

Context launcher already ran ONCE this session; do not rerun. Skill base `.agents/skills/impeccable`. Loaded init, new-work, visualize, craft-floor, live-setup. Native imagegen used for all comps (no API fallback). Browser CUA reported no browsers and unavailable iab; headless Playwright works and app is already running at http://localhost:5173. Do not start duplicate server.

`.impeccable/live/config.json`: index.html, before body, html comment, cspChecked=true. detect-csp returned null. No CSP modifications or live injection performed.

## Mandatory build workflow progress

`.impeccable/build/state.json`: started via `build-phase start --direction dfe3ca3d --kind canon`. Current phase **hero**. Comps, spec, plates PASSED. No raster plates needed (26 semantic regions). Scaffold generated successfully.

Tools use `.agents/skills/impeccable/scripts/impeccable <verb>`.

- `comp-spec --comp .impeccable/mocks/komposisi-a.png --regions .impeccable/build/regions.json` created `.impeccable/build/spec.json`.
- Explicit `box` uses NORMALIZED 0..1 ratios, not pixels. Region source saved; full grid `.impeccable/build/comp-grid.png` inspected.
- All 11 text regions measured. Lead `heading` ranked by font-match: **Encode Sans 700, 37px** for measured 28.9px cap height. Proof `.impeccable/build/font-match/heading.png` inspected; script selected and recorded it. Need obtain/self-host font for implementation.
- `.impeccable/build/scaffold/layout.css` provides measured positions/sizes and `.impeccable/build/scaffold/hero-reference.html` reference. Bind dimensions into responsive semantic structure, not absolute positioning of entire app.
- Next: build dashboard first viewport plus shared tokens/header. Then capture at comp dimensions to `.impeccable/review/hero-repro.png`; `build-phase advance` validates against comp. Since no plates, no blank plate-only capture needed. Do not skip failed gates or use force.
- Remaining phases: hero → sections (other pages/full dashboard) → motion → responsive → review. Read current tool outputs and new-work section 6 for required records and screenshots. Never silently bypass gate. Runtime data differs legitimately from illustrative comp; preserve real curriculum/counts and explain replacement.

## Design contract and preservation

Surface brief `.impeccable/surfaces/src-pages-dashboardpage-tsx.md` (verified after write); source `.impeccable/brief-body.md`. Approved direction: white ground, dark navy readable text, restrained blue primary controls, fine cool borders, modest radii. Desktop header horizontal with theme control. Dashboard heading; wide split recommendation (lesson+action left, module progress+3 stage cells right); 3-column progress strip; filterable module rows with topic, progress, stage states, arrow. Shared style must extend to all UI with page-specific compositions, full dark theme, focus/reduced-motion/error/loading/empty/completed states.

Generated comp defects explicitly explained before approval: avatar is not a feature (replace with existing theme control); example count 4 replaced by actual 10 modules; fake labels/numbers replaced by real data. Existing factual copy remains. Keep all actual capabilities including progress stats, streak, topic breakdown, export/import/reset (may move below module list; do not remove). Existing app has no accounts, but does have streak statistic. No invented claims/features.

Craft-floor read immediately before upcoming edit; it may be reread after continuation. Source components should keep business behavior. No DB changes needed.

## Existing source details

- React/TS/Vite/Tailwind; `src/styles/tokens.css` old cream/purple/brown palette in light and brown dark. `global.css` maps tokens via @theme, container and prose rules.
- Old fonts index.html Google Fonts Inter, Space Grotesk, JetBrains Mono. Replace display with measured Encode Sans, keep readable body/mono as appropriate, self-host fonts.
- `src/components/layout/{Header,BottomNav,RootLayout}.tsx`: theme cycle, five nav links, mobile bottom nav, skip link, route focus/restoration. Preserve behavior.
- `src/pages/DashboardPage.tsx`: queries live curriculum; `useProgres`; computes recommendation, topic progress, weakest module, sorted module list, filter; current order recommendation, 4 stat cards, topic breakdown, module cards, settings. Needs substantial layout replacement following A.
- `src/features/dashboard/KartuDashboard.tsx`: recommendation uses a single stage/icon currently. Exported components `KartuRekomendasi`, `KartuSemuaSelesai`, `SaranMemperkuat`, `BarisTopik`, `StatCard`.
- `src/components/ui/Card.tsx`: Card has border+shadow (remove redundant shadow), Badge uppercase (refine), PageHeader.
- `src/pages/MateriPage.tsx`: topic-grouped 3-col cards. Other pages not fully inspected yet.
- Progress and unlocking: `src/features/progres/aturan.ts`; API/data queries should remain untouched.

## Evidence and checks

Before screenshots captured AND inspected:
- `.impeccable/review/before-desktop.png` (1505×1045 viewport, full page)
- `.impeccable/review/before-mobile.png` (390×844 viewport, full page)

Headless Playwright via node `import {chromium} from 'playwright'; chromium.launch({headless:true})` works. Database content actually loads. Dashboard first lesson Dasar Array & Indeks, reason 12 minutes. Actual 10 modules, 206 cards; new browser all stages unstarted. Capture should wait networkidle/fonts and verify actual data visible. No mocks used for baseline.

Existing tests: npm run typecheck, lint, test, build; playwright.config.ts Chromium/Firefox/mobile Chromium with reused localhost:5173 server. `e2e/aksesibilitas.spec.ts` checks 5 pages and module in both themes, keyboard. Other E2E tests cover read, flashcards, quiz, persistence, stage locking. Run relevant checks after changes, not repeated blindly.

## Required finish handoffs

Per invoked skill, subagents explicitly authorized for shipped finish reviewer/documenter. Do not delegate arbitrary UI implementation (no user blanket multiagent request).
- After implementation and bounded desktop/mobile visual verification, run detector once on changed targets, correct mechanical issues.
- Spawn fresh finish reviewer with fork_turns="none" and concrete packet: original request, approvals, PRODUCT, surface contract, comp, build state, spec, screenshot paths, comp-diff folders, craft-floor. Tool has no custom agent-type parameter; specify role in task/message, do not read shipped agent definition files before spawning. Reviewer cannot browse, needs valid screenshots. Disclose adaptation only if needed.
- Fix according to reviewer disposition and return evidence for verdict.
- Spawn documenter after final corrections with write scope `DESIGN.md`, `.impeccable/design.json`; must document actual built tokens/system. Read document.md workflow as needed. Both artifacts required at finish.
- Final report concise Indonesian, explain changes/tests/material limitations. Do not claim completion until app redesign and review/documentation done.

## Tool sessions

Earlier question polling sessions 94773/91058/26201 are expired; both questions have been answered and consumed. No further polling needed.
Font rank session 8630 completed. Baseline capture session 51594 completed. No running relevant shell job at time of this record.

## Artifact handling

All generated comps under `.impeccable/mocks/`, prompts embedded in PNG and JSON sidecars. Gate wants `<image>.png.json`, not just basename `.json`; fixed for A/B/C. All images are development references, not shipping UI. Do not ship a rasterized dashboard. No design images needed in runtime for this clean UI direction.
