# Liste des changements versions 3.2.0->

## 30/06/2022
- Retrait des plans personnalisés de la liste des modèles disponibles dans la page d'import de plans
- Correction du problème d'attribution du contact du produit de recherche, dans les plans classiques, pouvant provoquer un blocage du plan quand aucun contact n'a été sélectionné


## 22/06/2022
- Annulation de la modification "Retrait des modèles structurés de la liste des modèles personnalisables"
- Correction de l'import de facility avec l'import RDA (issue #398)

## 08/06/2022
- Changements sur la page d'accueil & mise à jour des traductions
- Ajout de l'identifiant cliquable du contributeur dans la liste des contributeurs de l'export PDF
- Les contributeurs sont désormais triés par nom/prénom
- Amélioration de l'export PDF/DOCX
    - Correction de la non prise en compte du mode d'export des produits et des produits sélectionnés
    - Les coûts et contributeurs affichés dépendent désormais des produits sélectionnés

## 07/06/2022
- Mise à jour des traductions et ajout de textes sur la page d'accueil
- Retrait des modèles structurés de la liste des modèles personnalisables
- Retrait du menu "clic droit" de l'éditeur de texte
- Amélioration de l'import RDA
- Correction d'un problème d'attribution du classname des fragments lors de l'import JSON (issue gitbucket 394)
- Les contributeurs sans rôle sont désormais bien transférés lors de la copie de plan (issue gitbucket 390)

## 02/06/2022
- Correction du problème d'affichage des listes de sélection dans les pop up et dans le formulaire principal après fermeture d'une popup
- Les contributeurs sont désormais triés par prénom/nom dans l'export PDF/DOCX et dans l'onglet Contributeurs (issue #217)
- Correction du problème d'export des DMP Publics (issue #218)

## 30/05/2022
- Ajout de la copie pour les plans créés à partir d'un modèle structuré
- Correction du problème d'affichage des listes déroulantes dans les popups (la solution était assez simple, si elle fonctionne je la récupèrerai pour la mettre en production dans la prochaine mise à jour corrective)

## 16/05/2022
- Roadmap V3.1.0 https://github.com/DMPRoadmap/roadmap/releases/tag/v3.1.0
    - Concernant les produits de recherche, on n'utilise pas les nouvelles fonctionnalités Roadmap. Les fonctionnalités sont identiques à ce qui est présent en production
- Roadmap V3.1.1 https://github.com/DMPRoadmap/roadmap/releases/tag/v3.1.1
- Externalisation du code maDMP OPIDoR : toutes les fonctionnalités maDMP sont dans un répertoire séparé du code Roadmap (voir `engines/`). Cela ne devrait avoir aucune conséquence sur le fonctionnement de l'application mais est destiné à permettre une meilleure maintenance de l'application
- Mise à jour de TinyMCE vers la version 5 : l'éditeur du texte a été mis à jour. De nouvelles fonctionnalités sont disponibles comme la possibilité de faire un clic droit pour créer un lien. Le design de l'éditeur est un peu différent.