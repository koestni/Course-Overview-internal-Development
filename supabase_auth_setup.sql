-- Supabase DB Setup: globale Kursübersicht + persönlicher Bereich "Mein Studium"

-- 1) Tabellen für benutzerspezifische Daten
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

-- 2) Rechte für angemeldete Nutzer (RLS + Grants)
grant usage on schema public to authenticated;
grant select, insert, update, delete on public.courses to authenticated;
grant select, insert, update, delete on public.user_study_courses to authenticated;
grant select, insert, update, delete on public.user_semesters to authenticated;
grant usage, select on all sequences in schema public to authenticated;

alter table public.courses enable row level security;
alter table public.user_study_courses enable row level security;
alter table public.user_semesters enable row level security;

-- 3) Bestehende Policies ggf. bereinigen (idempotent)
drop policy if exists "courses_select_authenticated" on public.courses;
drop policy if exists "courses_insert_authenticated" on public.courses;
drop policy if exists "courses_update_authenticated" on public.courses;
drop policy if exists "courses_delete_authenticated" on public.courses;

drop policy if exists "study_courses_own_rows" on public.user_study_courses;
drop policy if exists "semesters_own_rows" on public.user_semesters;

-- 4) Policies neu erstellen
-- Globale Kurse: alle angemeldeten Nutzer dürfen lesen/schreiben
create policy "courses_select_authenticated"
on public.courses
for select
to authenticated
using (true);

create policy "courses_insert_authenticated"
on public.courses
for insert
to authenticated
with check (true);

create policy "courses_update_authenticated"
on public.courses
for update
to authenticated
using (true)
with check (true);

create policy "courses_delete_authenticated"
on public.courses
for delete
to authenticated
using (true);

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
