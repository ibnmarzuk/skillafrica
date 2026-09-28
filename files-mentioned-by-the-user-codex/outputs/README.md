# SkillAfrica Bootcamp 5.0 Attendance

Responsive Next.js app with a public check-in page, admin dashboard screens, one event QR, projector view, CSV export demo, and Supabase/Postgres schema.

## Run locally

```sh
npm install
cp .env.example .env.local
npm run dev
```

Visit `/` for the admin UI and `/attendance` for attendee check in. The admin screens currently use illustrative demo records and in-memory interactions. The public API becomes active once Supabase environment values and the SQL schema are configured. Do not use demo counts or attendees as real event data.

## Supabase setup

1. Create a Supabase project and run `supabase/schema.sql` in its SQL editor.
2. Set values from `.env.example`. Keep `SUPABASE_SERVICE_ROLE_KEY` server-side only.
3. Create the admin user through Supabase Auth, then add its UUID to `admin_profiles` as shown in the schema comments.
4. Configure event days and settings in the database. The sample dates and default time zone are seeded for the brief.
5. Set `NEXT_PUBLIC_APP_URL` to the deployed origin. The QR page derives the attendance URL from the active origin in this demo; for a production QR, use the configured production origin.

Attendance writes go through `/api/attendance`, which validates names/email, checks active event/date/time using the configured IANA zone and server clock, and relies on the unique `(attendee_id, attendance_date)` database constraint for duplicate protection. The service-role client exists only in a server module. Public Supabase table access is not granted by RLS.

## Production work remaining

Connect the admin UI to Supabase Auth and authenticated server actions, load dashboard data from protected queries, apply authorization to admin routes, and switch demo panels to live data. Add deployment credentials/domain before publishing. Excel export and persistent settings are represented in the product brief but this review build currently exports CSV and keeps settings as a UI demo. Admin screens should not be treated as access-protected until the auth integration is completed.
