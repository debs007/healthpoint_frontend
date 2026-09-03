# HealthPoint - Customer App (Flutter)

Built against Flutter 3.44+ / Dart 3.9+. Wired to the real Laravel backend
(`medicine.nebulaqueststudios.com/api` by default - see
`lib/core/constants/app_constants.dart` to change it).

## Setup

```bash
flutter pub get
flutter run
```

To point at a different API URL without editing code:

```bash
flutter run --dart-define=API_BASE_URL=https://your-domain.com/api
```

## Icon assets - read this before sending icon files

Every icon path the app expects is listed in
`lib/core/constants/app_icons.dart`. Name your files **exactly** as listed
there (e.g. `ic_nav_home.svg`, `ic_cart.svg`) and drop them into
`assets/icons/`. Nothing else needs to change - every screen renders
icons through `AppIcon` (`lib/core/widgets/app_icon.dart`), which
currently maps each key to a Material icon fallback. Once your files
exist, swap the relevant line in `AppIcon`'s `_fallbackMap` from
`Icon(Icons.xxx)` to `SvgPicture.asset(AppIcons.xxx)` - one line per icon,
nothing to hunt through across screens.

## Colors

Every color is in `lib/core/constants/app_colors.dart`, extracted by
pixel-sampling the actual screen designs you provided (not eyeballed).
The four brand shades (`primaryDark`, `primary`, `accent`, `surfaceTint`)
are the verified ones. Neutral/status colors are reasonable standard
choices, not sampled from your designs - adjust them directly if the real
spec differs.

## What's real vs not

**Fully wired to the live backend:**
- Login (mobile + OTP), OTP verify
- Home (products, categories derived from product data)
- Categories
- Orders (list, status-filtered)
- Account (profile, order stats)
- Add to cart (cart badge updates live)

**Two things adapted from the 7 designs, not built as-shown:**
- The "Select Your Role: Super Admin / Admin / Staff" login screen doesn't
  fit a customer app - customers don't pick a staff role. Not built.
- The mobile+password+Google/Apple login screen's *visual* language was
  matched, but the *functional* flow is mobile+OTP only, since that's
  what the backend actually supports - no password field or OAuth exists
  for customers on the Laravel side.

**Real backend exists, and now has a real screen too:**
- My Prescriptions (`GET/POST /customer/prescriptions`) - list + camera/gallery
  upload via `image_picker`. Field name confirmed as `file` (not `image`)
  against the actual backend validation rules, not guessed.
- Address Book (`GET/POST/DELETE /customer/addresses`) - list, add (bottom
  sheet form), delete with confirmation. `label` field added to the
  Address model after checking the real backend rules - it was missing
  from the first pass.
- Order Detail (`GET /customer/orders/{id}`) - full item breakdown, status,
  total, delivery date when present.
- **Cart** - view, adjust quantity, remove. Built against the *actual*
  cart response shape (confirmed from the real `CartController`), which
  is flatter than my first guess: `product_name` directly on each item,
  no nested product object, no image. Prices are genuinely nullable -
  they only resolve once the cart has a franchise selected.
- **Checkout** - fulfillment type (delivery/pickup), address selection,
  order summary, places the real order via `POST /customer/orders`.
- **Payment** - Razorpay checkout integration. Field names for both
  `initiate` and `verify` are confirmed against the real
  `PaymentController`, not guessed from Razorpay's generic docs.

**One real, confirmed backend gap this surfaced**: there is no
customer-facing endpoint to list/discover franchises anywhere in the API.
Products browse fine without one (global fallback pricing), but the cart
needs a `franchise_id` before prices resolve, and `POST /customer/orders`
requires one outright. Cart and Checkout both show this honestly rather
than hiding it - a clear banner explaining prices are unresolved and
checkout is blocked until a franchise is selected, with no fake picker
pretending otherwise. **The real fix is a new backend endpoint**
(something like `GET /customer/franchises`, ideally filtered by
delivery area) - not something I invented a workaround for.

**About the payment integration specifically** - this is the one part of
the app I could not verify against real source, because there isn't any
to check: `razorpay_flutter`'s actual on-device behavior can only be
confirmed by running it. The backend-facing parts (exact field names sent
to `initiate`/`verify`) are confirmed correct. The SDK integration itself
- native Android/iOS setup, exact options-map keys, wallet handling - is
unverified. Read the comment at the top of `payment_screen.dart` before
treating this as done; test with Razorpay test-mode keys before it goes
near real money.

**Visually present but honestly marked "Coming soon" - no backend exists
for these at all (no vitals, lab reports, wallet, coupons, payment
methods, reminders, reviews, refer-and-earn, notifications, or offers
endpoints anywhere in the API):**
- Health Records (the whole tab)
- Wallet, Coupons, Payment Methods, Medicine Reminders, Reviews, Refer & Earn
- Notification bell, promo banner CTA

Every one of these shows an honest, specific in-app message when tapped
rather than either doing nothing (looks like a bug) or pretending to work
(worse - looks finished when it isn't).

## Known limitations worth knowing about

- **This code has not been compiled or run.** There's no Flutter SDK in
  the environment this was built in - every file was written and
  statically reviewed (brace/parenthesis balance, import resolution,
  cross-referencing every icon/route constant actually used against what's
  defined) as carefully as that allows, the same rigor applied throughout
  the Laravel build, but static review isn't the same as `flutter run`
  actually succeeding. Test on a real device/emulator before trusting it
  further than that.
- State management is Provider, deliberately - simpler and more
  established than Riverpod, chosen specifically because this code can't
  be iterated on with hot reload here. A reasonable later migration if
  the team prefers Riverpod's compile-time safety, not a dead end.
- No real-time order-status push (Reverb/Pusher) yet - order status is
  whatever the last `loadOrders()` call returned. Pull-to-refresh works;
  live push doesn't exist yet.
- **Highest-value next backend addition**: a customer-facing franchise
  discovery endpoint. Without it, checkout is structurally blocked for
  any cart that doesn't already have a franchise_id somehow set.

