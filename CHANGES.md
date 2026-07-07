# Changes — Bug Fixes

No dev environment was set up for either pass below (no Flutter SDK
installed locally) — all changes were made by reading and editing the Dart
source directly and were not run through `flutter analyze` or `flutter
run`. Recommend a build check before shipping.

# Pass 1 — Admin Console Wiring

Scope: `UrPlug_Flutter_App_v4/urplug_v4/lib/screens/admin/admin_dashboard_screen.dart`,
plus one data bug fix in `lib/data/mock_data.dart`.

## Bug fix

- **`lib/data/mock_data.dart`** — the `div_makindye_s` zone entry was
  passing `'Makindye-Ssabagabo'` as a positional argument to `Zone(...)`,
  but `Zone` only accepts named arguments. This was a hard compile error
  (`Too many positional arguments: 0 allowed, but 1 found`). Fixed by
  adding the missing `name:` label.

## Admin console: buttons that previously did nothing

Before this pass, several admin controls rendered and looked tappable but
had empty `onPressed: () {}` callbacks, or (for the Overview cards) weren't
wrapped in a tappable widget at all. All of the following now actually do
something:

### Overview tab — "Quick Access" cards
- Previously: plain `Container`s with no tap handler.
- Now: each card is wrapped in an `InkWell` and navigates to its matching
  tab (Verification Queue → Verify, Review Moderation → Reviews, User
  Management → Users, Zone Configuration → Zones, Category Management →
  Categories).
- **Platform Analytics** has no corresponding tab yet (there's no
  analytics data source in `MockData`), so tapping it shows a snackbar
  explaining that instead of silently doing nothing.

### Zones tab
- **Edit (pencil icon)** on each zone row now opens a form dialog
  (name, level, parent zone) and updates that zone in place.
- **Add Zone** now opens the same form dialog and appends a new zone to
  the list, with an auto-generated id.
- The parent-zone dropdown is filtered to the correct level automatically
  (a parish's parent must be a division, a division's parent a district,
  etc.), and regions are correctly treated as top-level with no parent.
- Data lives in local widget state for this session (`MockData.zones` is
  copied in, not written back) — same pattern as the rest of the mock-data
  screens. A real backend write happens once Supabase/Firestore is wired
  up per the main README's TODOs.

### Categories tab
- Previously: static instructional text telling *you* to go edit
  `service_category.dart` by hand, with an "Add Category" button that did
  nothing.
- Now: the tab lists all current categories (default ones are marked and
  can't be deleted), and **Add Category** opens a dialog to add a new one
  by label (id is auto-slugified, with a duplicate-id check). Non-default
  categories can be removed with the trash icon.

### Users tab
- Previously: Suspend/Remove showed a snackbar claiming success but never
  changed anything — reopening the tab showed the same list.
- Now: **Remove** actually removes the provider from the list. **Suspend**
  actually toggles a suspended state per provider (shown as a red avatar +
  "Suspended" subtitle, with the menu option flipping to "Reinstate
  account").

### Already working, unchanged
- Verify tab's Approve/Reject.
- Reviews tab's Remove.

## Known limitations / not in scope for this pass

- Everything above is in-memory only (`MockData`/local widget state) — none
  of it persists across app restarts or to a backend. That's consistent
  with the rest of the app, which is intentionally running on mock data
  until Supabase/Firebase is wired in (see the app's own README under
  "What's intentionally stubbed").
- No Flutter toolchain was available to compile/run this locally, so these
  changes have not been verified against the actual widget tree at
  runtime — please build and click through the admin console before
  merging.
- The `RenderFlex overflowed by 7.4 pixels` layout bug reported in the
  admin dashboard (`admin_dashboard_screen.dart:125`, in the original
  file) and the free-text fallback for parish/village/sub-county/district
  entry are still open and were not addressed in this pass.

# Pass 2 — "Fake success" bugs in Provider Dashboard & Job Board

A full read-through audit of the remaining `lib/` tree (models, data,
state, theme, screens, widgets — everything except the admin console,
already covered in Pass 1) turned up five more instances of the same bug
class as Pass 1: an action shows a success message or visually resets, but
never actually writes the change anywhere. All five are fixed below. The
core models/data/state layer (`zone.dart`, `provider_profile.dart`,
`mock_data.dart`'s cross-references, `zone_matching_engine.dart`,
`app_state.dart`) was also audited and found correct — no bugs there.

### `lib/screens/provider/provider_dashboard_screen.dart`

- **"Open for work" switch** — `onChanged` was `(_) => setState(() {})`,
  which discarded the new value entirely, so the switch always snapped
  back to its old position. Now calls
  `app.updateProvider(provider.copyWith(isOpenForWork: v))`.
- **Edit business description sheet** — "Save" just closed the sheet; the
  typed text was discarded. Now saves via
  `provider.copyWith(businessDescription: text)` before closing (and
  ignores an empty/whitespace-only edit rather than blanking the
  description).
- **Post a response (on a review)** — "Post" just closed the sheet; the
  typed response was discarded, so the review kept showing "Post a
  response" afterward. Now rebuilds that `Review` with `providerResponse`
  set and writes it back into `MockData.reviews`.
- **Update service area** — "Save service area" showed a "Service area
  updated" snackbar without ever writing the new zone back, so the old
  zone reappeared on reopen. Now calls
  `onUpdate(provider.copyWith(zone: newZone))` before showing the
  snackbar.
- Supporting change: `ProviderProfile.copyWith()` gained a `zone` param
  (it already had `isOpenForWork` and `businessDescription`, just not
  `zone`) — needed so the service-area fix above has something to call.
  `AppState` gained `updateProvider(ProviderProfile)`, which replaces the
  matching entry in `MockData.providers` by id and calls
  `notifyListeners()`, mirroring the existing `updateConsumer` /
  `completeProviderRegistration` pattern.

### `lib/screens/jobs/job_board_screen.dart`

- **Post job** — "Post job" popped the sheet and showed "Job posted
  successfully!" without ever constructing a `JobPost` or adding it to
  `MockData.jobPosts`, and without validating that a description was
  entered. Now builds a `JobPost` from the selected category, the typed
  description, and the signed-in user's home zone, appends it to
  `MockData.jobPosts`, and rejects an empty description with an inline
  message instead of a false success.

## Known findings not fixed (out of scope: dead code, not "not working")

- `lib/widgets/zone_picker.dart` (`ZonePicker`) is unused/unimported
  anywhere — every screen actually uses `zone_picker_widget.dart`'s
  `ZonePickerWidget`. It's orphaned duplicate code, not a bug (it never
  runs), so left alone.
- `lib/screens/auth/location_setup_screen.dart` is imported by
  `otp_verification_screen.dart` but never navigated to — the real
  post-OTP flow goes to `ConsumerSetupScreen`, which has its own inline
  location step. `LocationSetupScreen` is dead code, also left alone.
