# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne.

## 15/01/2024

- Changement du comportement de étapes de création de plan:
  - Le bouton ``Valider mon choix`` n'est plus présent en étape 1 et 2, le choix ce fait au cli
  - Le bouton ``Valider mon choix`` est présent en dernière étape (3)
- Fusion d'``organisme de financement`` et de ``autres organismes`` en un seul champs
- Ajout d'une légende (modèle structuré, financeur, organisme)
- Ajout d'une taille fixe pour la cellule contenant les boutons d'édition/suppression dans les tableaux des formulaires dynamiques
- Correction d'un problème d'affichage des formulaires lors de la fermeture puis l'ouverture d'un formulaire (#10098)

## 08/01/2024

- Ajout de l'exécution des scripts dans l'onglet Rédiger:
  - Les scripts s'éxécutent à partir du `name` et du `owner` présents dans le `run`
  - Si `owner` est absent, le owner "superadmin" est utilisé
- Améliorations diverses dans le choix des recommandations

## 11/12/2023

- Ajout de l'import informations de projets provenant de plusieurs financeurs (#9784)
- Ajout du changement de formulaire (#10040) :
  - Lorsque plusieurs formulaires sont disponibles, une icone s'affiche et permet de faire apparaitre le formulaire de changement de formulaire
- Correction des conditions d'affichage des Contributeurs multiples (devrait corriger le problème d'affichage des contributeurs dans le formulaire ResearchEntityStandard)
- Correction d'un problème de sélection du rôle des contributeurs.

## 07/12/2023

- Correction du titre de la fenêtre d'édition lors de l'ajout d'une personne (#9849)
- Correction du problème de sauvegarde du type dans la fenêtre d'ajout/modification d'un produit de recherche (#10036)
- Création de plan :
  - L'étape 2 permet désormais de choisir la langue du modèle
  - Lors du choix du modèle, une icône s'affichage lorsque d'un modèle est structuré.

## 01/12/2023

- Noël !
- Changement du message par défaut dans les listes de sélections lorsqu'aucun élément n'est trouvé
- Amélioration du CSS des tableaux
- Modification de l'entête des pop ups pour refléter l'objet en cours de modification/ajout.

## 29/11/2023

- Amélioration de la consistance du CSS des tableaux (bordures).
- Amélioration du CSS des boutons du formulaire de création de produit de recherche (onglet Rédiger)
- Amélioration CSS diverses (#9913)
- Correction d'un problème de sauvegarde des fragments lors de la création puis de l'édition d'un fragment (sans au préalable sauvegarder le formulaire principal)
- Correction d'un problème de réinitialisation du formulaire des pop-ups après leur fermeture (#9587)
- Correction d'un bug se produisant lors de l'export PDF et l'accès à l'onglet Budget (du code utilisé par ces fonctionnalités avait été supprimées et provoquaient un plantage).

## 21/11/2023

- Ajout du support de l'option overridable aux nouveaux formulaires, le comportement est identique à celui en production excepté les référentiels complexes à choix unique (Licences, Financeurs):
  - Ajout d'un sous formulaire pour Editer/Ajouter une valeur d'un référentiel.
- Ajustement du CSS des boutons secondaires (boutons Annuler, Fermer) & des tableaux

## 17/11/2023

- Modification des étapes de création de plan:
  - Correction et ajout des textes
  - Ajout de [react-form-stepper](https://github.com/M0kY/react-form-stepper)
  - Ajout d'une étape du choix du type de plan (structuré, simplifié)
- Mise à jour onglet "Rédiger":
  - Ajout d'une ligne d'information du plan (modèle, organisme, version, date de publication)
  - Mise à jour du titre de choix de recommendations:
    - Changement de l'icone (ampoule), changement de couleur
- Correction d'un problème d'import Financeur (c'était le projet PHYTOCLIM qui était importé quelque soit le choix, du code utilisé en local pour tester l'import avait été déployé sur le serveur)

## 14/11/2023

- Modification du style du menu déroulant "Produits de recherche":
  - Les coins arrondis ont été ajustés correctement
  - Au survol, le style est maintenu avec un changement de couleur de fond
- Modification des libellés de contexte d'un plan (Création du plan)
- Ajout des textes descriptifs des contextes de plan (projet de recherche / entité de recherche)
- Modification de l'abréviation et du titre du premier produit de recherche lors de la création d'un plan
- Augmentation de la largeur des étapes 1 et 2 de la création d'un plan
- Augmentation de la largeur des étapes 1 et 2 de la création d'un plan
- Correction d'un problème d'affichage du champ Context lors de l'édition d'un Modèle de DMP (Carte KB #9686)
- Amélioration de l'affichage des tableaux dans l'espace Admin
- Ajout d'une couleur d'activation des boutons Import RoR/ORCID (Carte KB #9636)
- Correction d'un problème de sauvegarde du Type et PID des produits de recherche dans les plans classiques (Carte KB #9831)
- Amélioration du fonctionnement des référentiels multiples & amélioration des messages demandant aux utilisateurs de sélectionner une valeur (Carte KB #9555)
- Amélioration de la création de plan (Carte KB #9876)
- Intégration de la librarie react-hook-form  (Carte KB #9587)

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
