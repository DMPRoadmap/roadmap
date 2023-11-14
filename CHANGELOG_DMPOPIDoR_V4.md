# Liste des changements


**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne.

- Modification du style du menu déroulant "Produits de recherche":
  - Les coins arrondis ont été ajustés correctement
  - Au survol, le style est maintenu avec un changement de couleur de fond
- Modification des libellés de contexte d'un plan (Création du plan)
- Ajout des textes descriptifs des contextes de plan (projet de recherche / entité de recherche)
- Modification de l'abréviation et du titre du premier produit de recherche lors de la création d'un plan
- Augmentation de la largeur des étapes 1 et 2 de la création d'un plan
- Correction d'un problème d'affichage du champ Context lors de l'édition d'un Modèle de DMP (Carte KB #9686)
- Amélioration de l'affichage des tableaux dans l'espace Admin
- Ajout d'une couleur d'activation des boutons Import RoR/ORCID (Carte KB #9636)
- Correction d'un problème de sauvegarde du Type et PID des produits de recherche dans les plans classiques (Carte KB #9831)
- Amélioration du fonctionnement des référentiels multiples & amélioration des messages demandant aux utilisateurs de sélectionner une valeur (Carte KB #9555)


## 07/11/2023
- Ajout d'un mode Lecture Seule pour l'onglet Informations Générales
- Ajout des textes "Selectionnez une valeur" dans les listes de sélection (Carte KB #9555)
- Correction d'un problème d'ouverture des questions sans recommandations
- Plans Classiques : Correction d'un problème d'ajout, mise à jour et suppression des produits de recherche (Carte KB #9831)
- Augmentation de la largeur de l'onglet Informations Générales (Carte KB #9701)

### Contributeurs
- Plans Classiques : Changement de l'icone et du tooltip d'ajout d'un contributeur depuis l'onglet Produits de Recherche (Carte KB #9817)
- Amélioration de la gestion des rôles lors de la suppression d'une personne depuis l'onglet Contributeurs (Carte KB #9851)
- Ajout de l'affichage de l'affiliation et de l'identifiant de la personne dans l'onglet Contributeurs (Carte KB #9832)

## 26/10/2023
- Refonte de l'onglet Contributeurs avec l'ajout de la possibilité d'ajouter une personne dans les plans classiques
- Retrait de la possibilité d'ajouter une personne depuis l'onglet Produits de Recherche
- Améliorations d'affichage dans l'onglet Rédiger (espace de rédaction plus large)

## 26/09/2023
- Correction d'un problème d'affichage (effet accordéon) à l'ouverture de la première question dans l'onglet Rédiger
- Retrait de la vérification du format de l'email (on compte remettre une vérification du format mais elle sera accompagnée de l'intégration d'une nouvelle librairie qui permettra d'améliorer l'affichage et la vérification des formulaires)
- Prise en compte des caractères spéciaux dans la recherche RoR et ORCID
- Amélioration du filtrage sur le pays dans la recherche RoR

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


