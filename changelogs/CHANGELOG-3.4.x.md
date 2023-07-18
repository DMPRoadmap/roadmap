# Liste des changements versions 3.4.0->3.4.4


## 16/02/2023
- DMPRoadmap V4.0.2 : https://github.com/DMPRoadmap/roadmap/releases/tag/v4.0.2
- Correction du problème d'affichage des valeurs par défaut dans les champs "number" (issue gitbucket 467)
- La liste des formulaires personnalisés n'est plus proposée lorsqu'un seul formulaire est disponible (issue gitbucket 468) => Sera déployé dans une version corrective prochainement
- Amélioration de l'affichage des groupes de recommandations lorsque le groupe a le même nom que l'organisme associé (issue gitbucket 469)

## 02/02/2023
- Retrait des modèles structurés de la liste des modèles personnalisables (issue gitbucket 463)
- Amélioration du message de confirmation d'envoi d'une notification depuis l'onglet Runs, lors de la rédaction du plan.

## 05/12/2022
- DMPRoadmap V4.0.1 : https://github.com/DMPRoadmap/roadmap/releases/tag/v4.0.1 
- Amélioration de l'accessibilité des formulaires dynamiques
- Export RDA : Ajout du convertisseur pour 'Crossref Funder ID' ver 'fundref' (issue gitbucket 449)
- Le volet Recommandations est bien ouvert par défaut, dans le cas où il existe des recommandations (issue gitbucket 457)
- Ajout d'une signature "light" au mail de notification de création/mise à jourd d'un client API (issue gitbucket 448)

## 24/11/2022
- Le mail d'ajout de commentaires s'adresse désormais bien au contributeurs du plan et plus au propriétaire (issue gitbucket 448)
- Correction du problème affectat l'adresse mail d'envoi du mail de complétion d'assistance/conseil. Auparavant l'application essayait d'envoyer le message avec l'adresse de contact de l'organisme, provocant des rejets du serveur mail hébergeant l'adresse.
-  Amélioration de l'affichage du formulaire de choix des recommandations, pour les organismes n'ayant qu'un groupe de recommandations.

## 22/11/2022
- Ajout d'une ligne blanche lors de la sélection du Client API lié à un MadmpSchema, permettant de retirer le client lié au schéma (issue gitbucket 450)
- La création d'un plan Structure ne crée plus de PrincipalInvestigator (issue gitbucket 454)

## 21/11/2022
- Export RDA : correction d'un problème de conversion de la certification (issue gitbucket 446)
- Correction d'un problème de rafraichissement des listes de contributeurs pour les formulaires contenant plusieurs listes de contributeurs
- Le mail d'ajout de commentaires s'envoit désormais à tous les contributeurs du plan (issue gitbucket 448)
- Client API :
  - Il n'est désormais plus possible de supprimer un client rattaché à un formulaire (issue gitbucket 450) 
  - Amélioration du mail de création/modification d'un client  (issue gitbucket 451)

## 10/11/2022
- Remplacement du logo de l'application par sa version vectorisée
- Suppression du titre à la création d'un plan

## Plan de Structure
- Ajout de champ `context`à la table 'templates`
- Ajout du choix du contexte (Research project ou Research Structure) au Modèle de DMP
- Pour les plans créés à partir d'un modèle "Research Structure", le formulaire Projet est remplacé par le formulaire Structure
- Par défaut un Modèle concerne un Projet de Recherche
- Modification du menu de création de plan pour ajouter le choix du Plan Structure de Recherche

Bugs connus et améliorations à venir : 
- Bug : Création d'un PrincipalInvestigator pour les plans Structure de Recherche
- Bug : Problème d'affichage des listes de StructureManager & DataSteward lors de l'ajout d'un nouveau contributeur dans l'une de ces listes. C'est un problème visuel, il disparait au rechargement de la page
- A améliorer : Déplacer le choix entre Plan Projet et Structure dans le formulaire de création de plan.


## 04/11/2022
- Correction d'un problème de récupération des paramètres des boutons Runs dans les schemas, provocant un plantage lors de l'utilisation des boutons
- Ajout de l'affichage du champ `uuid` dans l'onglet Produit de Recherche, avec un bouton permettant de copier la valeur du champ.
- API Plans: 
  - Suppression de l'option `research_outputs=` de la route `/api/v1/plans/:id`, on ne peut désormais qu'un (voir point suivant) ou tous les produits de recherche du plan.
  - Ajout de la route `/api/v1/plans/research_outputs/:uuid` permettant de recupérer un plan limité au contenu du produit de recherche associé à l'UUID passé en paramètre.
  - Lorsqu'un ClientAPI interroge la route `/api/v1/plans/research_outputs/:uuid`, un droit en lecture lui est automatiquement attribué sur le plan.
  - Mise à jour de la documentation Swagger

## 27/10/2022
- DMPRoadmap V4.0.0 : https://github.com/DMPRoadmap/roadmap/releases/tag/v4.0.0
- Correction d'un problème empéchant le téléchargement des plans et l'accès à l'onglet Contributeurs
- Import/Export RDA : 
  - Correction d'un problème d'import de la certification du Host 
  - Correction d'un problème d'export de la propriété `docIdentifier`présente dans `EthicalResources/ResourceReference`

## 25/10/2022
- Correction d'un bug affectant le champ `visibility` des Plans et Modèles de Plans
- Import/Export RDA : Amélioration de l'import/export de `metadataLanguage`
- Amélioration des notifications d'archivage des comptes non connecté depuis 5 ans

## 14/10/2022
- Ajout du champ `uuid` aux produits de recherche. Ce champ est généré automatiquement et sert d'identifiant unique au produit de recherche.

### Gestion des droits d'accès aux plans pour les clients API

- Ajout d'un sélecteur du client API dans le formulaire de création/modification des Schémas. Il permet d'indiquer qu'un formulaire appartient à un client
- Ajout d'une interface de gestion des accès au plan par les clients dans l'onglet Partager (Gestion des Applications tierces). L'utilisateur peut ajouter au retirer l'accès au plan à un client (en lecture seulement pour le moment). Par défaut l'interface est cachée, à la manière des questions.
- Lorsqu'un formulaire est lié à un client et que l'utilisateur clique sur un bouton Notification, un droit d'accès en lecture est attribué, sur le plan, au client lié au formulaire.
- Lorsqu'un client interroge l'API Plans avec l'`uuid` d'un produit de recherche (voir ci-dessous), un droit d'accès en lecture lui est automatiquement attribué. On considère qu'en partageant l'UUID de son produit, le client a donné un accord implicite de lecture de son plan.

### API Plans
- Suppression de la route `/api/v1/madmp/plans/:id/rda_export`, désormais remplacée par une option `export_format`

### Mise à jour roadmap
- Mise à jour vers Ruby 2.7 et Rails 6 depuis la branche `development`du dépot Roadmap.
