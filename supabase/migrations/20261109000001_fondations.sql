-- =====================================================================
-- Agrafe : migration 1, les fondations
-- Profils, espaces (prestataire ou entreprise), membres, journal.
-- Principe : chaque ligne appartient à un espace ; seuls ses membres
-- la voient (règles d'accès RLS). Rien n'est effacé directement :
-- une suppression renseigne deleted_at (corbeille 30 jours).
-- =====================================================================

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------
-- Profils : un par utilisateur Supabase
-- ---------------------------------------------------------------------
create table public.profils (
  id          uuid primary key references auth.users (id) on delete cascade,
  nom         text,
  email       text not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Création automatique du profil à l'inscription
create or replace function public.creer_profil()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profils (id, email, nom)
  values (new.id, new.email, coalesce(new.raw_user_meta_data ->> 'nom', ''));
  return new;
end;
$$;

create trigger a_l_inscription
  after insert on auth.users
  for each row execute function public.creer_profil();

-- ---------------------------------------------------------------------
-- Espaces
-- ---------------------------------------------------------------------
create table public.espaces (
  id          uuid primary key default gen_random_uuid(),
  type        text not null check (type in ('prestataire', 'entreprise')),
  nom         text not null check (length(trim(nom)) > 0),
  pack        text,                       -- ex. 'viticole'
  created_by  uuid references auth.users (id),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz                 -- corbeille
);

-- ---------------------------------------------------------------------
-- Membres d'un espace
-- ---------------------------------------------------------------------
create table public.membres (
  espace_id   uuid not null references public.espaces (id) on delete cascade,
  user_id     uuid not null references auth.users (id) on delete cascade,
  role        text not null default 'membre' check (role in ('admin', 'membre')),
  created_at  timestamptz not null default now(),
  primary key (espace_id, user_id)
);

create index membres_par_utilisateur on public.membres (user_id);

-- ---------------------------------------------------------------------
-- Journal : trace des actions (qui, quoi, quand)
-- ---------------------------------------------------------------------
create table public.journal (
  id          bigint generated always as identity primary key,
  espace_id   uuid,                       -- sans clé étrangère : le journal survit à tout
  user_id     uuid,
  action      text not null,              -- insert, update, delete, restore…
  table_nom   text not null,
  ligne_id    text,
  details     jsonb,
  created_at  timestamptz not null default now()
);

create index journal_par_espace on public.journal (espace_id, created_at desc);

-- ---------------------------------------------------------------------
-- Fonctions d'aide aux règles d'accès
-- (security definer : elles lisent membres sans repasser par RLS)
-- ---------------------------------------------------------------------
create or replace function public.est_membre(p_espace uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.membres m
    join public.espaces e on e.id = m.espace_id
    where m.espace_id = p_espace
      and m.user_id = auth.uid()
      and e.deleted_at is null
  );
$$;

create or replace function public.est_admin(p_espace uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.membres m
    join public.espaces e on e.id = m.espace_id
    where m.espace_id = p_espace
      and m.user_id = auth.uid()
      and m.role = 'admin'
      and e.deleted_at is null
  );
$$;

-- ---------------------------------------------------------------------
-- Journalisation générique (à brancher sur chaque table métier)
-- La table doit avoir une colonne espace_id ; pour espaces, c'est id.
-- ---------------------------------------------------------------------
create or replace function public.journaliser()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_ligne   jsonb := to_jsonb(coalesce(new, old));
  v_espace  uuid  := coalesce((v_ligne ->> 'espace_id')::uuid,
                              case when tg_table_name = 'espaces' then (v_ligne ->> 'id')::uuid end);
  v_action  text  := lower(tg_op);
begin
  if tg_op = 'UPDATE' then
    if old is distinct from new and (to_jsonb(old) ->> 'deleted_at') is null
       and (to_jsonb(new) ->> 'deleted_at') is not null then
      v_action := 'corbeille';
    elsif (to_jsonb(old) ->> 'deleted_at') is not null
       and (to_jsonb(new) ->> 'deleted_at') is null then
      v_action := 'restauration';
    end if;
  end if;

  insert into public.journal (espace_id, user_id, action, table_nom, ligne_id, details)
  values (
    v_espace,
    auth.uid(),
    v_action,
    tg_table_name,
    v_ligne ->> 'id',
    case when tg_op = 'UPDATE'
         then jsonb_build_object('avant', to_jsonb(old), 'apres', to_jsonb(new))
         else v_ligne end
  );
  return coalesce(new, old);
end;
$$;

-- Mise à jour automatique de updated_at
create or replace function public.maj_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger maj_updated_at before update on public.profils
  for each row execute function public.maj_updated_at();
create trigger maj_updated_at before update on public.espaces
  for each row execute function public.maj_updated_at();

create trigger journal_espaces after insert or update or delete on public.espaces
  for each row execute function public.journaliser();
create trigger journal_membres after insert or update or delete on public.membres
  for each row execute function public.journaliser();

-- ---------------------------------------------------------------------
-- Création d'un espace : l'utilisateur en devient administrateur
-- (seule porte d'entrée pour créer un espace)
-- ---------------------------------------------------------------------
create or replace function public.creer_espace(p_type text, p_nom text, p_pack text default null)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Connexion requise';
  end if;

  insert into public.espaces (type, nom, pack, created_by)
  values (p_type, p_nom, p_pack, auth.uid())
  returning id into v_id;

  insert into public.membres (espace_id, user_id, role)
  values (v_id, auth.uid(), 'admin');

  return v_id;
end;
$$;

revoke all on function public.creer_espace(text, text, text) from public, anon;
grant execute on function public.creer_espace(text, text, text) to authenticated;

-- ---------------------------------------------------------------------
-- Règles d'accès (RLS)
-- ---------------------------------------------------------------------
alter table public.profils  enable row level security;
alter table public.espaces  enable row level security;
alter table public.membres  enable row level security;
alter table public.journal  enable row level security;

-- Profils : chacun voit et modifie le sien, et voit ceux de ses co-membres
create policy profils_lecture on public.profils for select to authenticated
  using (
    id = auth.uid()
    or exists (
      select 1 from public.membres moi
      join public.membres autre on autre.espace_id = moi.espace_id
      where moi.user_id = auth.uid() and autre.user_id = profils.id
    )
  );
create policy profils_modif on public.profils for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

-- Espaces : lecture par les membres ; modification (dont corbeille) par les admins
-- Pas de création directe (passer par creer_espace) ni d'effacement définitif.
create policy espaces_lecture on public.espaces for select to authenticated
  using (public.est_membre(id));
create policy espaces_modif on public.espaces for update to authenticated
  using (public.est_admin(id)) with check (public.est_admin(id));

-- Membres : lecture par les membres ; gestion par les admins
create policy membres_lecture on public.membres for select to authenticated
  using (public.est_membre(espace_id));
create policy membres_ajout on public.membres for insert to authenticated
  with check (public.est_admin(espace_id));
create policy membres_modif on public.membres for update to authenticated
  using (public.est_admin(espace_id)) with check (public.est_admin(espace_id));
create policy membres_retrait on public.membres for delete to authenticated
  using (public.est_admin(espace_id));

-- Journal : lecture seule pour les membres de l'espace
create policy journal_lecture on public.journal for select to authenticated
  using (public.est_membre(espace_id));

-- ---------------------------------------------------------------------
-- Restauration d'un espace mis en corbeille (dans les 30 jours)
-- Un espace en corbeille n'est plus visible : seul un de ses admins
-- peut le restaurer, par cette fonction.
-- ---------------------------------------------------------------------
create or replace function public.restaurer_espace(p_espace uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (
    select 1 from public.membres
    where espace_id = p_espace and user_id = auth.uid() and role = 'admin'
  ) then
    raise exception 'Seul un administrateur de cet espace peut le restaurer';
  end if;

  update public.espaces
     set deleted_at = null
   where id = p_espace
     and deleted_at > now() - interval '30 days';

  if not found then
    raise exception 'Espace introuvable ou corbeille expirée';
  end if;
end;
$$;

revoke all on function public.restaurer_espace(uuid) from public, anon;
grant execute on function public.restaurer_espace(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- Autorisations explicites (les nouvelles tables ne sont pas exposées
-- automatiquement) : les règles RLS ci-dessus filtrent ensuite les lignes.
-- ---------------------------------------------------------------------
grant usage on schema public to anon, authenticated;
grant select, update            on public.profils to authenticated;
grant select, update            on public.espaces to authenticated;
grant select, insert, update, delete on public.membres to authenticated;
grant select                    on public.journal to authenticated;
revoke all on public.profils, public.espaces, public.membres, public.journal from anon;
