# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne. 

## 30/05/2022
- Ajout de la copie pour les plans créés à partir d'un modèle structuré
- Correction du problème d'affichage des listes déroulantes dans les popups (la solution était assez simple, si elle fonctionne je la récupèrerai pour la mettre en production dans la prochaine mise à jour corrective)

## 16/05/2022
- Roadmap V3.1.0 https://github.com/DMPRoadmap/roadmap/releases/tag/v3.1.0
    - Concernant les produits de recherche, on n'utilise pas les nouvelles fonctionnalités Roadmap. Les fonctionnalités sont identiques à ce qui est présent en production
- Roadmap V3.1.1 https://github.com/DMPRoadmap/roadmap/releases/tag/v3.1.1
- Externalisation du code maDMP OPIDoR : toutes les fonctionnalités maDMP sont dans un répertoire séparé du code Roadmap (voir `engines/`). Cela ne devrait avoir aucune conséquence sur le fonctionnement de l'application mais est destiné à permettre une meilleure maintenance de l'application
- Mise à jour de TinyMCE vers la version 5 : l'éditeur du texte a été mis à jour. De nouvelles fonctionnalités sont disponibles comme la possibilité de faire un clic droit pour créer un lien. Le design de l'éditeur est un peu différent.