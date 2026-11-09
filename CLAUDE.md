# Règles du projet Agrafe

- Interface et textes en français. Jamais de grand tiret (—) dans les textes : virgule, deux-points ou reformulation.
- Aucune mention de Vinalchimie (ni d'aucun client réel) dans l'interface, les exemples, les textes d'aide ou les données de démonstration. Agrafe est un produit générique pour tout prestataire externalisé.
- L'identité visuelle (logos, pictogrammes, couleurs, typographies, réglages) est fournie par Roxane. Le CSS se limite à la mise en page ; les couleurs, tailles et formes viennent du fichier de réglages visuels.
- Aucun mot de passe ni clé secrète dans le dépôt. Seule la clé Supabase « publishable » est utilisée côté application.
- Toute modification de la base passe par une nouvelle migration dans `supabase/migrations`, testée (règles d'accès comprises) avant publication.
- On travaille sur la branche `test` ; `main` (production) ne reçoit que ce qui a été essayé.
- Rien n'est effacé directement : corbeille de 30 jours (`deleted_at`), et chaque action sensible est inscrite au journal.
- Cahier des charges de référence : document « Cahier des charges : Agrafe ».
