-- NEXUS: table de sauvegardes joueur pour Supabase
-- A executer dans Supabase > SQL Editor. Le script est re-executable.

create table if not exists public.player_saves (
  user_id uuid primary key references auth.users(id) on delete cascade,
  save_data jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.player_saves enable row level security;

-- Defense en profondeur : aucune lecture/ecriture publique ou via le role anon.
revoke all on table public.player_saves from public;
revoke all on table public.player_saves from anon;
grant select, insert, update on table public.player_saves to authenticated;

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

-- Les comptes invités Supabase sont des utilisateurs authentifies :
-- ils utilisent donc ces policies, avec auth.uid() limite a leur propre ligne.
