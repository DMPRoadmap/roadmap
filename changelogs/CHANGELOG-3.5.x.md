# Liste des changements versions 3.5.0->3.5.6

## 15/01/2024
- Correction du problème engendrant la création de plusieurs contributeurs lors de l'ajout d'une personne dans un formulaire contenant plusieurs listes de contributeurs différentes (plans entité)
- Correction d'un problème faisant disparaître la liste des contributeurs après la mise à jour d'un contributeur.

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

## 12/05/2023
- Mise à jour du CAPTCHA vers Recaptcha V3 : 
  - La validation est transparente basée sur un score calculé par Google
  - Si la validation échoue, le site propose le test "Je ne suis pas un robot"

## 28/04/2023
- Correction du problème de pagination de la liste des contributeurs dans l'onglet Contributeurs (issue gitbucket 482) & retrait du champ de recherche
- Correction du problème d'affichage des boutons
- Correction du problème d'affichage du message indiquant qu'un élément est déjà présent dans le plan, lors de la sauvegarde dans une popup.

## 05/04/2023
- Amélioration des fenetres de confirmation pour le partage d'un plan public, l'import ANR, l'envoi d'une notification et la suppression d'un sous fragment dans une liste de sous fragment. (Installation de la librarie Sweetalert2)
- Correction d'un problème d'affichage des logos Twitter et Github dans le pied de page

## 31/03/2023
- Correction de problèmes CSS divers (Taille de certains textes, onglets Recommendations/Commentaires)
- Ajout d'une fenêtre de validation lorsqu'un plan est passé en public.

## 14/03/2023
- Correction d'un problème provoquant un message d'erreur lors de l'import ANR.
- Ruby 3.0 & Migration Webpacker => fusion des derniers changements présents sur la branche development de Roadmap (en prévision de la prochaine release). En théorie les changements sont invisibles pour les utilisateurs mais l'importance des changements dans le code peut potentiellement avoir créé des bugs. 

## 09/03/2023
- Ajout de la prise en compte de l'UUID lors d'un appel à la Codebase (notification, calcul ...)


- Refonte de la gestion des valeurs par défaut dans les formulaires dynamiques.
