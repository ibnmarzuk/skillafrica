create extension if not exists pgcrypto;
create table if not exists public.event_settings (
 id uuid primary key default gen_random_uuid(), singleton boolean not null default true unique check(singleton), event_name text not null default 'SkillAfrica Bootcamp 5.0',
 start_date date not null default '2026-09-24', end_date date not null default '2026-09-28',
 opening_time time not null default '14:00', closing_time time not null default '18:00',
 timezone text not null default 'Africa/Lagos', is_active boolean not null default true,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 constraint valid_window check(opening_time < closing_time), constraint valid_dates check(start_date <= end_date));
create table if not exists public.event_days (
 attendance_date date primary key, enabled boolean not null default true,
 created_at timestamptz not null default now());
insert into public.event_settings default values on conflict do nothing;
insert into public.event_days(attendance_date,enabled) values
 ('2026-09-24',true),('2026-09-25',true),('2026-09-26',true),('2026-09-27',true),('2026-09-28',true)
on conflict(attendance_date) do nothing;
create table if not exists public.attendees (
 id uuid primary key default gen_random_uuid(), full_name text not null, registered_name text not null,
 email text not null, email_normalized text generated always as (lower(trim(email))) stored,
 created_at timestamptz not null default now(), constraint attendees_email_normalized_unique unique(email_normalized));
create index if not exists attendees_email_idx on public.attendees(email_normalized);
create table if not exists public.attendance (
 id uuid primary key default gen_random_uuid(), attendee_id uuid not null references public.attendees(id) on delete cascade,
 attendance_date date not null references public.event_days(attendance_date), check_in_time timestamptz not null default now(),
 status text not null default 'present' check(status in ('present')), created_at timestamptz not null default now(),
 constraint one_checkin_per_day unique(attendee_id,attendance_date));
create index if not exists attendance_date_idx on public.attendance(attendance_date);
create index if not exists attendance_attendee_idx on public.attendance(attendee_id);
create table if not exists public.admin_profiles (
 id uuid primary key references auth.users(id) on delete cascade, display_name text,
 role text not null default 'admin' check(role in ('admin')), created_at timestamptz not null default now());
alter table public.event_settings enable row level security;
alter table public.event_days enable row level security;
alter table public.attendees enable row level security;
alter table public.attendance enable row level security;
alter table public.admin_profiles enable row level security;
create policy "admins manage settings" on public.event_settings for all to authenticated using(exists(select 1 from public.admin_profiles p where p.id=auth.uid())) with check(exists(select 1 from public.admin_profiles p where p.id=auth.uid()));
create policy "admins manage days" on public.event_days for all to authenticated using(exists(select 1 from public.admin_profiles p where p.id=auth.uid())) with check(exists(select 1 from public.admin_profiles p where p.id=auth.uid()));
create policy "admins read attendees" on public.attendees for select to authenticated using(exists(select 1 from public.admin_profiles p where p.id=auth.uid()));
create policy "admins read attendance" on public.attendance for select to authenticated using(exists(select 1 from public.admin_profiles p where p.id=auth.uid()));
create policy "admins read own profile" on public.admin_profiles for select to authenticated using(id=auth.uid());
-- Grant the authenticated role read-only access to realtime attendance events.
alter publication supabase_realtime add table public.attendance;
-- Admins are provisioned by the project owner after creating their Supabase Auth user:
-- insert into public.admin_profiles(id,display_name) values ('AUTH_USER_UUID','Event Admin');
