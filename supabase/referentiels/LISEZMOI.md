# Référentiels douaniers

Données de référence qui alimentent les questionnaires des produits (les codes sont déduits, jamais demandés au client).

| Fichier | Source | Mise à jour |
| --- | --- | --- |
| `mvv_codes_nc_2026.csv` | Douanes, « MVV codes NC », mise à jour du 28/01/2026 | 9 novembre 2026 |

## Questions posées pour retrouver le code NC d'un produit MVV

- Raisin frais (M001) : raisin de cuve (code unique) ; le raisin de table est exclu.
- Jus, moûts, moûts concentrés (M002 à M005) : valeur Brix (≤ 30, de 30 à 67, > 67), valeur en € pour 100 kg, et pour les moûts : partiellement fermenté ou non, masse volumique, TAV acquis.
- Marcs (M006) et lies (M007) : titre alcoométrique total et teneur en matière sèche.
- Vins désalcoolisés (M008, M009) : TAV.

À vérifier : le document source donne 20096959 pour les jus et moûts de raisin, mais 20096951 pour les moûts concentrés (même description). Les deux sont repris tels quels.
