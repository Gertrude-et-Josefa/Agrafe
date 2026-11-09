# Agrafe

Application web qui relie des entreprises à leurs prestataires externalisés.
Éditée par Gertrude & Josefa. Le cahier des charges complet est dans le document « Cahier des charges : Agrafe ».

## Technique

- **SvelteKit** (application monopage, publiée en fichiers statiques)
- **Supabase** : base de données, connexion, fichiers
- **Cloudflare Pages** : hébergement
- Deux environnements : **test** (branche `test`) et **production** (branche `main`)

## Organisation des dossiers

| Dossier | Contenu |
| --- | --- |
| `src/routes` | Les pages de l'application |
| `src/lib` | Le code partagé (connexion à Supabase, composants) |
| `supabase/migrations` | La structure de la base, une migration par étape, dans l'ordre |
| `supabase/tests` | Les tests des règles d'accès |

## Démarrer en local

1. Copier `.env.example` en `.env` et y mettre l'adresse et la clé publique du projet Supabase de **test**.
2. `npm install`
3. `npm run dev`

## Règles du projet

- Ne jamais mettre de mot de passe ni de clé secrète dans Git (le fichier `.env` est exclu).
- Toute modification de la base passe par une nouvelle migration, jamais à la main dans Supabase.
- Toute mise à jour est essayée sur l'environnement de test avant la production.
- Rien n'est effacé directement : une suppression envoie en corbeille pendant 30 jours.

## Étapes de construction

1. Fondations : connexion, espaces, membres, journal, règles d'accès ← **en cours**
2. Contacts, entreprises, libellés
3. Tâches, récurrences, agenda, justificatifs
4. Notes @ # /, projets, choses à faire
5. Chrono, temps, rapports et exports
6. Côté client : invitation, commande, fil d'échange, pièces jointes, notifications
7. Pack viticole
8. Module DAE (version 2)
