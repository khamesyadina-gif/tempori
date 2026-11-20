# Tempori

Tempori is a Flutter app for tracking items and their expiration dates.

## Supabase setup

Apply [`supabase/migrations/20261030000000_user_dashboard_fields_and_item_photos.sql`](./supabase/migrations/20261030000000_user_dashboard_fields_and_item_photos.sql)
to the Supabase project before opening the user dashboard. It adds the `notes`
and `created_at` columns and configures the public `item-photos` bucket with
upload, update, and delete access restricted to each signed-in user's folder.
Photos are publicly viewable by URL.

Configure the Supabase URL and anon key in `lib/supabase_config.dart`, then
run `flutter pub get` and `flutter run`.

To let users enter the dashboard immediately after registration, open
**Authentication → Sign In / Providers → Email** in the Supabase Dashboard and
turn off **Confirm email**. Existing unconfirmed accounts must be confirmed
once under **Authentication → Users**; changing this setting only affects new
registrations.
