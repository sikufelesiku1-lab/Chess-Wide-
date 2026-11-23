-- Run this whole file in Supabase Dashboard > SQL Editor.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  rating integer not null default 1200,
  wins integer not null default 0,
  losses integer not null default 0,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);
create table if not exists public.tournaments (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  time_control text not null default '10+5',
  status text not null default 'Registration open',
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);
create table if not exists public.participants (
  tournament_id uuid references public.tournaments(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key(tournament_id,user_id)
);
create table if not exists public.games (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid references public.tournaments(id) on delete cascade,
  white_id uuid references public.profiles(id),
  black_id uuid references public.profiles(id),
  fen text not null,
  pgn text not null default '',
  status text not null default 'waiting',
  result text,
  updated_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
alter table public.tournaments enable row level security;
alter table public.participants enable row level security;
alter table public.games enable row level security;
create policy "profiles readable" on public.profiles for select using (true);
create policy "users update own profile" on public.profiles for update using (auth.uid()=id);
create policy "users insert own profile" on public.profiles for insert with check (auth.uid()=id);
create policy "tournaments readable" on public.tournaments for select using (true);
create policy "admins create tournaments" on public.tournaments for insert with check (exists(select 1 from public.profiles where id=auth.uid() and is_admin));
create policy "admins update tournaments" on public.tournaments for update using (exists(select 1 from public.profiles where id=auth.uid() and is_admin));
create policy "participants readable" on public.participants for select using (true);
create policy "users join as self" on public.participants for insert with check (auth.uid()=user_id);
create policy "admins remove participants" on public.participants for delete using (exists(select 1 from public.profiles where id=auth.uid() and is_admin));
create policy "games readable" on public.games for select using (true);
create policy "players create games" on public.games for insert with check (auth.uid()=white_id or auth.uid()=black_id);
create policy "players update games" on public.games for update using (auth.uid()=white_id or auth.uid()=black_id);
-- Create a profile automatically after sign-up.
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin
  insert into public.profiles(id,username) values(new.id,coalesce(new.raw_user_meta_data->>'username',split_part(new.email,'@',1)));
  return new;
end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
-- IMPORTANT: after registering your own account, run this once with your email:
-- update public.profiles set is_admin=true where id=(select id from auth.users where email='YOUR_EMAIL_HERE');
-- Realtime: in Supabase Dashboard > Database > Replication, enable Realtime for games and participants.
