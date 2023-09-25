# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne. 


## 25/09/2023
- Les recommandations sont désormais correctement triées dans le Choix des Recommandations
- Les formulaires Project/Meta se rechargement correctement après l'utilisation de l'import ANR
- Le choix du produit de recherche affiché dans l'onglet Rédiger est conservé lors d'un rechargement de la page
- Le produit de recherche par défaut est désormais créé avec `containsPersonalData` à Non
- Correction de l'attribution du rôle d'un contributeur
- Correction d'un problème de suppression des contributeurs
- Affichage d'un entête des tableaux de fragments lorsque `table_header` n'est pas renseigné
- Amélioration de l'affichage des résultats des recherches RoR/ORCID (ajout d'un icone lien pour ror, ajout d'un icone pour importer, ajout d'un message lorsqu'il n'y a aucune donnée)
- Correction du filtre sur les pays dans l'import RoR
- Ajout de l'affichage du numéro de section dans les questions


## 22/06/2023
- Correction d'un problème d'affichage des libellés lorsque form_label est absent et ajout d'une valeur par défaut lorsque qu'aucun libellé n'est déclaré.
- Ajout du support des plans pour les structures de recherche
  - Suppression de l'import ANR
  - Ajout d'un libellé différencié pour les formulaires Projet/Structure

## 19/06/2023
- Intégration de l'onglet Informations Générales
  - L'import financeur est pour le moment limité aux données ANR. La liste des financeurs n'est affichée que lorsque qu'il existe plusieurs financeurs disponibles.
  - Absence du choix de recommandations, déplacé dans l'onglet Rédiger (intégration en cours).
Problèmes connus : 
- Présence de texte fictif pour décrire le choix d'un modèle Structure ou Projet
- Présente d'un problème de police d'écriture. Les polices utilisées dans l'onglet refondu ne sont pas correctement chargées.
- L'import ANR pointant sur la VI, il est possible que certains projets soient manquants dans la liste proposée.


## 30/05/2023
La charte graphique est encore en cours de travail, cette version intègre le nouveau formulaire de création de plan. Le menu principal a été changé pour ne proposer que l'option "Créer un plan".
L'intégration des onglets Rédiger et Informations générales n'a pas encore été faite. Le code utilisé est identique à la version de production.
Problèmes connus : 
- Présence de texte fictif pour décrire le choix d'un modèle Structure ou Projet
- Absence de bouton "Retour" pour revenir au choix Projet/Structure
- Absence de texte indiquant l'absence de modèle à sélectionner pour Mon organisme/Autre Organisme/Financeur.


