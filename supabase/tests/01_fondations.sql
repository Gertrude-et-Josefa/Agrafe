\set ON_ERROR_STOP 0
insert into auth.users (id,email,raw_user_meta_data) values
 ('11111111-1111-1111-1111-111111111111','roxane@test.fr','{"nom":"Roxane"}'),
 ('22222222-2222-2222-2222-222222222222','autre@test.fr','{"nom":"Autre presta"}');
select 'profils créés' t, count(*) from profils;

set role authenticated;
-- Roxane crée son espace
set request.jwt.claim.sub = '11111111-1111-1111-1111-111111111111';
select creer_espace('prestataire','Vinalchimie','viticole') as esp_roxane \gset
-- L'autre crée le sien
set request.jwt.claim.sub = '22222222-2222-2222-2222-222222222222';
select creer_espace('prestataire','Autre cabinet') as esp_autre \gset

-- Test 1 : l'autre ne voit que son espace
select 'T1 autre voit (attendu 1)' t, count(*) from espaces;
-- Test 2 : l'autre ne peut pas modifier l'espace de Roxane
update espaces set nom='piraté' where id = :'esp_roxane';
-- Test 3 : création directe interdite
insert into espaces(type,nom) values ('prestataire','direct');
-- Test 4 : l'autre ne peut pas s'ajouter chez Roxane
insert into membres(espace_id,user_id) values (:'esp_roxane','22222222-2222-2222-2222-222222222222');
-- Test 5 : ne voit pas le profil de Roxane
select 'T5 profils visibles (attendu 1)' t, count(*) from profils;

set request.jwt.claim.sub = '11111111-1111-1111-1111-111111111111';
select 'T6 Roxane voit (attendu 1)' t, count(*) from espaces;
-- Test 7 : corbeille puis restauration
update espaces set deleted_at = now() where id = :'esp_roxane';
reset role;
select 'T7 journal' t, action, table_nom from journal where espace_id = :'esp_roxane' order by id;
-- Test 8 : suppression définitive refusée
set role authenticated; set request.jwt.claim.sub = '22222222-2222-2222-2222-222222222222';
delete from espaces where id = :'esp_autre';
reset role;
select 'T8 espaces restants (attendu 2)' t, count(*) from espaces;
-- Test 9 : anonyme ne voit rien
set role anon; reset request.jwt.claim.sub;
select 'T9 anon (attendu 0)' t, count(*) from espaces;
select creer_espace('prestataire','anon');
reset role; set role authenticated;
set request.jwt.claim.sub = '22222222-2222-2222-2222-222222222222';
select restaurer_espace(:'esp_roxane');
set request.jwt.claim.sub = '11111111-1111-1111-1111-111111111111';
select restaurer_espace(:'esp_roxane');
select 'T10 Roxane revoit son espace (attendu 1)' t, count(*) from espaces;
reset role; select 'T10 journal' t, action from journal where espace_id = :'esp_roxane' order by id;
