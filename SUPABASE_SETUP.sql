-- NEXUS: table de sauvegardes joueur pour Supabase
-- A executer une seule fois dans Supabase > SQL Editor.

create table if not exists public.player_saves (
  user_id uuid primary key references auth.users(id) on delete cascade,
  save_data jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.player_saves enable row level security;

drop policy if exists "Players can read their own save" on public.player_saves;
create policy "Players can read their own save"
on public.player_saves for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "Players can insert their own save" on public.player_saves;
create policy "Players can insert their own save"
on public.player_saves for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Players can update their own save" on public.player_saves;
create policy "Players can update their own save"
on public.player_saves for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Ne jamais activer de policy publique (anon) donnant acces aux sauvegardes.
-- Les utilisateurs anonymes Supabase sont authentifies et passent par ces policies.
