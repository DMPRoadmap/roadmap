# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne.

## 08/03/2024

- Ajout de Redis comme gestionnaire de données de session: cet ajout permet de résoudre le problème d'export des plans avec de nombreux produits de recherche (#10303)
- Correction du problème d'envoie de notifications pour l'ajout d'un nouveau commentaire (#10302)
- Mise à jour du Swagger
- Mise à jour du profil utilisateur pour inclure les liens vers le Swagger
- Ajout d'une table ``guided_tour`` pour spécifier si l'utilisateur a terminé la "visite guidée"
- Mise en place de ``react-joyride`` pour la visite guidée de la partie **Rédiger**
- Création de divers composants pour personnaliser la visite guidée.

## 07/03/2024

- Modification du style par défaut des modales (``InnerModal``) des commentaires, recommendations, ...
- Changement affichage bouton "choix du formulaire personnalisé", il s'affiche comme les commentaires, recommendations, ...
- Correction affichage nombre de commentaire (titre de la modale)
- Retrait des modèles Entité de la liste des modèles proposés lors de l'import de plan
- Correction d'un problème de mise à jour de l'infobox des produits de recherche lors de l'import d'un plan (#10340)
- Ajout de l'identifiant d'affiliation clickable dans la liste des contributeurs de l'onglet Contributeurs et de l'export de Plan (#10295)

## 05/03/2024

- Ajout du support de l'option 'overridable' pour le rôle des contributeurs
- Ajustement de la position du tooltip permissions de l'onglet Partager (#10330)
- Correction d'un problème d'import de plan au format JSON (#10318)
- Changement de l'attribut ``disable`` des ``input`` de type ``text`` pour ``readonly`` ce qui permet de sauvegarder les valeurs **constantes**

## 04/03/2024

- Ajout de la langue choisie dans le filtre des organismes affichées lors de la création de plan & les organismes possédant des modèles publiés mais archivés ne doivent plus apparaitre dans les organimes proposés (#10294)
- Mise à jour des traductions

## 23/02/2024

- Changement de la loupe par un (i) afin d'afficher la description du modèle dans le choix du modèle (création de plan)
- Suppréssion du tooltip par un conteneur qui apparaît au clic de l'icône (i) pour afficher la description
- Modification de la légende des types de modèle de plan (les icônes sont dans le label)
- Ajout du paramètre ``readonly`` dans l'édition des phases
- Corrections/ajouts de traductions
- Changement de la mise en forme de la phrase d'accroche.
- Correction d'un problème d'affichage du type des produits de recherche dans l'infobox après la suppression d'un produit de recherche
- Correction d'un problème de sauvegarde des sous formulaires des référentiels complexes à choix simple (ex: Financeurs)

## 22/02/2024

- Ajout du mail de contact manquant à la signature des notifications de nouveau commentaire.
- Correction d'un problème d'ouverture du formulaire de description du produit de recherche après la mise à jour de l'infobox.
- Ajout d'une option pour afficher l'ensemble des données d'un formulaire lors d'un export PDF/DOCX

## 21/02/2024

- Ajout d'importation externe de données
  - Ajout de ``"externalImports": { "ror": {}, "orcid": {} }`` dans ``PersonStandard``
  - Ajout de ``"externalImports": { "ror": { "affiliationName": "name", "affiliationId": "orgId", "acronyms": "acronym", "affiliationIdType": "idType" } }`` dans ``PartnerStandard``
  - Ajout de ``"externalImports": { "ror": { "affiliationName": "name", "affiliationId": "orgId", "acronyms": "acronym", "affiliationIdType": "idType" } }`` dans ``ResearchEntityStandard``
- Ajout de la logique pour ``externalImports`` dans les composants ``NestedForm``, ``ModalForm`` et ``DynamicForm``.

## 20/02/2024

- Mise à jour de la bannière
- Mise à jour du logo CNRS & Ajout du logo dans le menu principal
- Correction d'un bug du formulaire qui enregistrait les champs "nombre" en tant que chaine de caractère. (#10291)
- Ajout de la gestion d'erreur (ex: unicité du titre et abréviation) lors de l'ajout/mise à jour d'un produit de recherche (#10246)
- Correction d'un problème de génération du titre et abréviation par défaut d'un produit de recherche (#10244, #10247)

## 09/02/2024

- Correction d'un problème de création des fragments à partir d'une modale. L'application pouvaient bloquer la création des fragments avec un champ inclus dans les contraintes d'unicités et dont la valeur est vide (ex: RNSR dans les partenaires).
- Ajout de la possibilité de supprimer le premier produit de recherche
- Amélioration de l'affichage des icônes dans les tableaux de fragments. Certains icônes étaient difficilement cliquables
- Correction d'un problème de sauvegarde d'un fragment dont des champs inclus dans les contraintes d'unicités n'avaient pas été modifiés (ex: ajout d'un identifiant pour une personne sans modification du nom/prénom).
- Ajout de l'URL avant les identifiants ROR et ORCID lors de l'import ROR/ORCID

## 06/02/2024

- Agrandissement de la zone de connexion (sur "Mon Compte")
- Suppression du modèle par défaut dans les autres sélecteurs de modèle.
- Changement de la redirection après connexion, la redirection se fait sur "Tableau de bord"
- Mise à jour des fichiers docker compose.
- Ajout de la mise à jour automatique des informations de l'infobox des Produits de recherche lors de l'enregistrement du formulaire Description d'un produit de recherche
- Ajout de la mise à jour automatique du formulaire Description d'un produit de recherche lors de l'enregistrement de l'infobox d'un produit de recherche
- Correction d'un problème de mise à jour d'une personne après un import Financeur (#9556)

## 30/01/2024

- Correction d'un problème de mise à jour des listes de personnes après la création d'un nouvelle personne. Lorsque le nouveau contributeur était créé à partir de cette personne, la ligne était "vide"
- Correction du problème de mise à jour du titre du plan dans le Tableau de bord après l'import de données Projet
- Ajout de la mise à jour de la liste des personnes après l'import de données Projet
- Correction du problème de captcha lors d'un changement de mot de passe.
- Changement du tooltip du bouton d'ajout d'un contributeur dans l'onglet Produits de Recherche des plans classique. (#9831)
- Correction du problème de mise à jour du titre de produit de recherche dans le formulaire Description après de la mise à jour des informations de l'infobox. (Il est encore nécessaire de recharger la page).
- Changement du nombre de news affichées sur la page d'accueil (13 -> 12)
- Correction du problème d'import RoR dans le formulaire Person
- Correction du problème de recherche dans les listes d'organisme dans la page de création de plan

## 29/01/2024

- Ajout de l'import RoR au niveau des partenaires
- Ajout des modèles recommandés:
  - Lors de la création de plan, un modèle recommandé est proposé selon les critères suivants : contexte, langue, recommandé
  - Ajout d'une nouvelle colonne indiquant qu'un modèle est recommandé dans le tableau des modèles accessible par les administrateurs
  - Dans la liste des modèles, le super administrateur peut cocher une case pour indiquer qu'un modèle **publié** est recommandé.

## 24/01/2024

- L'ajout/mise à jour d'une personne met désormais à jour les listes de contributeurs et les listes de sélection
- Ajout d'un message de confirmation lors de l'ajout/mise à jour des infos d'un produit de recherche
- Ajout du support des valeurs par défaut lors de l'ouverture de sous formulaires ou de modales (ex: Coûts, demandes de ressources...)
- Mise à jour de couleurs et bordures pour correspondre à la nouvelle bannière.

## 23/01/2024

- Amélioration de l'affichage des news
- Amélioration de l'affichage du formulaire de création de compte (#10158)
- Nouvelle image de bannière
- Correction d'un problème d'affichage des sous fragments provoquant le plantage lors de leur ouverture

## 19/01/2024

- Ajout d'un sous formulaire pour les propriétés de type objet non liées à un référentiel (ex Meso@LRServiceRequest) (#10160)
- Les modales ne se ferment désormais plus lorsque l'on clique en dehors. (#10169)
- Ajout d'un bouton Supprimer dans le tableau Valeur Sélectionner des référentiels complexes à choix uniques (Licences/Financeurs)
- Ajustements CSS : recommandations, icône des commentaires
- Correction du problème de sauvegarde des contributeurs (#9556)
- Refonte de la création de plan:
  - Modification des étiquettes des modèles (étape 3)
  - Supprimer l'utilisation du contexte (à l'aide de props)
  - Affichage des choix sous les étiquettes d'étapes

## 15/01/2024

- Correction de l'affichage du modèle sélectionné quand il est dans une liste
- Changement du comportement de étapes de création de plan:
  - Le bouton ``Valider mon choix`` n'est plus présent en étape 1 et 2, le choix ce fait au cli
  - Le bouton ``Valider mon choix`` est présent en dernière étape (3)
- Fusion d'``organisme de financement`` et de ``autres organismes`` en un seul champs
- Ajout d'une légende (modèle structuré, financeur, organisme)
- Ajout d'une taille fixe pour la cellule contenant les boutons d'édition/suppression dans les tableaux des formulaires dynamiques
- Correction d'un problème d'affichage des formulaires lors de la fermeture puis l'ouverture d'un formulaire (#10098)

## 08/01/2024

- Ajout de l'exécution des scripts dans l'onglet Rédiger:
  - Les scripts s'exécutent à partir du `name` et du `owner` présents dans le `run`
  - Si `owner` est absent, le owner "superadmin" est utilisé
- Améliorations diverses dans le choix des recommandations

## 11/12/2023

- Ajout de l'import informations de projets provenant de plusieurs financeurs (#9784)
- Ajout du changement de formulaire (#10040) :
  - Lorsque plusieurs formulaires sont disponibles, une icône s'affiche et permet de faire apparaître le formulaire de changement de formulaire
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
    - Changement de l'icône (ampoule), changement de couleur
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
- Intégration de la bibliothèque react-hook-form  (Carte KB #9587)

## 07/11/2023

- Ajout d'un mode Lecture Seule pour l'onglet Informations Générales
- Ajout des textes "Sélectionnez une valeur" dans les listes de sélection (Carte KB #9555)
- Correction d'un problème d'ouverture des questions sans recommandations
- Plans Classiques : Correction d'un problème d'ajout, mise à jour et suppression des produits de recherche (Carte KB #9831)
- Augmentation de la largeur de l'onglet Informations Générales (Carte KB #9701)

### Contributeurs

- Plans Classiques : Changement de l'icône et du tooltip d'ajout d'un contributeur depuis l'onglet Produits de Recherche (Carte KB #9817)
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
- Amélioration de l'affichage des résultats des recherches RoR/ORCID (ajout d'un icône lien pour ror, ajout d'un icône pour importer, ajout d'un message lorsqu'il n'y a aucune donnée)
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
