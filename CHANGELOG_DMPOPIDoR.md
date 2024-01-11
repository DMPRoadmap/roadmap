# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne. 

## 11/01/2024
- Correction d'un problème d'export des plans entités au format JSON
- Correction du problème d'affichage des listes d'organismes dans la création de plan, causé par l'absence de financeur.

## 10/01/2024
- Correction du comportement des boutons dans les formulaires
- Correction du problème d'export des plans pour les entités de recherche
- Retrait du format d'export JSON RDA pour les plans pour les entités de recherche
- Création de plan : la liste des financeurs prend désormais en compte le contexte

## 17/11/2023
- Correction de l'affichage du choix des recommandations (Carte KB #9917)
- La recherche d'organisme n'est plus sensible aux accents (Carte KB #9844)
- Mise à jour vers Ruby 3.2 & Rails 7.1

## 29/09/2023
- Correction du problème de bande blanche sous le pied de page (ce problème venait d'une image ajoutée dans par le code Matomo, a voir si retirer cette image a une conséquence sur l'habilité de Matomo suivre les utilsateurs)
- La recherche d'organisme lors de la création de compte ou dans le profil utilisateur peut désormas se faire sans accent.
- Correction de l'adresse mail d'envoi du formulaire de contact.
- Correction du titre par défaut des plans (présence de 's à la fin du titre)

## 29/08/2023
- Correction d'un problème de fusion des comptes utilisateurs (issue gitbucket 514)
- Correction d'un problème de génération des statistiques d'utilisation (ajout de la gem ruby-progressbar)

## 24/07/2023
- Correction d'un problème de copier/coller du formatage dans les éditeurs TinyMCE (issue gitbucket 510)

## 18/07/2023
- Mise à jour de FontAwesome (librairie d'icônes) vers la version 6
- Amélioration du support des plans pour les entités de recherche
  - Renommage des fichiers de "research structure" vers "research entity"
  - Utilisation d'un template DMPResearchEntity pointant sur ResearchEntityStandard à la place de ProjectStandard

## 30/06/2023
- Changement des textes référençant "Structure de recherche/Research Structure" en "Entité de Recherche/Research Entity"
- Ajout du Domaine de Recherche dans le tableau des DMPs Publics
- Désactivation des UUID des produits de recherche par défaut (changement visible lors de la mise en production)
- Correction d'un problème de fermeture de la bannière contenant le message des cookies
- Correction d'un problème d'accès des plans présents dans l'interface administrateur par les administrateurs d'organisme (issue gitbucket 489)

## 23/06/2023
- Mise à jour de la configuration de l'éditeur des Pages Statiques (le bouton Upgrade n'est plus affiché)
- Mise à jour du texte des liens dans le pied de page
- Mise à jour vers Rails 7 et Ruby 3.1 : Rien à tester, il faut seulement surveiller d'éventuels bugs inhabituels.
