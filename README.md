# K Mart Flutter App

Flutter grocery-shopping app using Riverpod, GoRouter, and Supabase.

## Requirements

- Flutter 3.47.0 or newer
- Dart 3.13.0 or newer
- A Supabase project configured with the tables and Row Level Security policies used by this app

## Local setup

1. Install Flutter and verify it with `flutter doctor`.
2. Create a local `.env` file from `.env.example` and fill in `SUPABASE_URL` and `SUPABASE_ANON_KEY` using the public client/publishable key only. Never put a service-role key in a Flutter app.
3. Run `flutter pub get`, `dart format lib test`, `flutter analyze`, and `flutter test`.
4. Review `supabase/migrations/20261009_cart_atomic_add.sql` against your live schema, then run it in Supabase SQL Editor. It consolidates duplicate cart rows and installs an atomic cart-add RPC; it does not replace stock validation or checkout-time revalidation.
5. The platform scaffolding in this source package is incomplete. From the project root, run `flutter create . --platforms=android,ios,web` with the required Flutter SDK installed. Review the generated files and re-add the location permissions to `android/app/src/main/AndroidManifest.xml` if the command replaces the manifest.
6. Run on a target device with `flutter run -d <device-id>`.

## Important

- `.env` is a local development file and is ignored by Git. Flutter client keys are public; protect data with Supabase Row Level Security. Do not include a service-role key in the app or in a ZIP.
- Nominatim is suitable only when used in accordance with its usage policy. Do not use it for browser search-as-you-type; this app now searches when the user submits a query. For production, route geocoding through a compliant service/proxy with appropriate caching and rate limits.
- Cart inventory, price, and availability must be revalidated server-side at checkout. Client-side stock checks alone are not a security boundary.

## Verification status

This package has not been compiled or tested in this environment because the Flutter/Dart SDK is unavailable here. Run the commands above locally before treating the app as build-verified.
