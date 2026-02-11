-- Supabase DB Setup: globale Kursübersicht + persönlicher Bereich "Mein Studium"

-- 0) Admin-Tabelle + Helferfunktion
create table if not exists public.app_admins (
    user_id uuid primary key references auth.users(id) on delete cascade,
    created_at timestamptz not null default now()
);

create or replace function public.is_app_admin(check_user uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
    select exists(
        select 1
        from public.app_admins
        where user_id = check_user
    );
$$;

revoke all on table public.app_admins from anon, authenticated;
grant execute on function public.is_app_admin(uuid) to authenticated;

-- 1) Kurs-Tabelle erweitern (Owner speichern)
alter table public.courses
    add column if not exists created_by_user_id uuid references auth.users(id) on delete set null;

create index if not exists idx_courses_created_by_user_id on public.courses(created_by_user_id);

-- 2) Tabellen für benutzerspezifische Daten
create table if not exists public.user_study_courses (
    user_id uuid not null references auth.users(id) on delete cascade,
    course_id bigint not null references public.courses(id) on delete cascade,
    created_at timestamptz not null default now(),
    primary key (user_id, course_id)
);

create table if not exists public.user_semesters (
    id bigint generated always as identity primary key,
    user_id uuid not null references auth.users(id) on delete cascade,
    name text not null,
    course_ids bigint[] not null default '{}',
    created_at timestamptz not null default now()
);

-- 3) Rechte für angemeldete Nutzer (RLS + Grants)
grant usage on schema public to authenticated;
grant select, insert, update, delete on public.courses to authenticated;
grant select, insert, update, delete on public.user_study_courses to authenticated;
grant select, insert, update, delete on public.user_semesters to authenticated;
grant usage, select on all sequences in schema public to authenticated;

alter table public.courses enable row level security;
alter table public.user_study_courses enable row level security;
alter table public.user_semesters enable row level security;

-- 4) Bestehende Policies bereinigen (idempotent)
drop policy if exists "courses_select_authenticated" on public.courses;
drop policy if exists "courses_insert_authenticated" on public.courses;
drop policy if exists "courses_update_authenticated" on public.courses;
drop policy if exists "courses_delete_authenticated" on public.courses;
drop policy if exists "courses_update_owner_or_admin" on public.courses;
drop policy if exists "courses_delete_owner_or_admin" on public.courses;

drop policy if exists "study_courses_own_rows" on public.user_study_courses;
drop policy if exists "semesters_own_rows" on public.user_semesters;

-- 5) Policies neu erstellen
-- Globale Kurse: alle angemeldeten Nutzer dürfen lesen
create policy "courses_select_authenticated"
on public.courses
for select
to authenticated
using (true);

-- Kurse anlegen: jeder angemeldete Nutzer nur für sich selbst
create policy "courses_insert_authenticated"
on public.courses
for insert
to authenticated
with check (
    created_by_user_id = auth.uid()
);

-- Kurse bearbeiten: nur Owner oder Admin
create policy "courses_update_owner_or_admin"
on public.courses
for update
to authenticated
using (
    created_by_user_id = auth.uid() or public.is_app_admin(auth.uid())
)
with check (
    created_by_user_id = auth.uid() or public.is_app_admin(auth.uid())
);

-- Kurse löschen: nur Owner oder Admin
create policy "courses_delete_owner_or_admin"
on public.courses
for delete
to authenticated
using (
    created_by_user_id = auth.uid() or public.is_app_admin(auth.uid())
);

-- Mein Studium: nur eigene Daten je User
create policy "study_courses_own_rows"
on public.user_study_courses
for all
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "semesters_own_rows"
on public.user_semesters
for all
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
