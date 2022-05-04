# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne. 

## 04/05/2022
- Ajout d'un message concernant les contributeurs lorsque l'on utilise l'import RDA
- Correction du problème de création de ResourceReference présent dans EthicalIssues lors de l'import RDA (issue gitbucket 372)
- Export RDA : `ethical_issues_exist` prend la valeur Oui/Yes lorsqu'au moins un produit de recherche est concerné
- Liste des plans Administrateur : Retrait des plans privé, tous les plans affichés devraient être accessibles (issue gitbucket 362)

## 28/04/2022
- Retrait de la possibilité de création de nouvel organisme depuis le formulaire de création de compte par invitation (issue gitbucket 377)
- La personne contact est désormais bien copiée lors de la copie d'un plan créé à partir d'un modèle classique (issue gitbucket 361)
- Correction d'un problème de sauvegarde du formulaire Meta

## 21/04/2022
- Correction d'un problème d'archivage des utilisateurs (issue gitbucket 376)
- Correction du problème d'ordre des phases dans l'export d'un plan avec plusieurs phases (issue gitbucket 353)
- La date de dernière modification se met désormais bien à jour quand on modifie depuis l'onglet Rédiger (issue gitbucket 348)
- La fusion d'utilisateur transfère désormais les plans en assistance conseil de l'utilisateur fusionné

## 15/04/2022
- Les exports JSON exportent les produits de recherche dans l'ordre d'affichage de l'onglet Produits de Recherche (issue gitbucket 371 & 373)
- L'import RDA récupère désormais les contributeurs (issue gitbucket 373)
- Les boutons radio des formulaires d'import et de téléchargement d'un plan sont désormais cochés quand on clique sur le libellé 
- Il est de nouveau possible de créer des organismes depuis la création de compte et le profil utilisateur, si l'organisme n'est pas dans la liste (issue gitbucket 370)
- Amélioration de l'affichage du nom d'utilisateurs (issue gitbucket 368)
- Suppression du champ de recherche d'organisme dans le formulaire de création d'un nouvel organisme (issue gitbucket 370) => ce champ permet de rechercher l'organisme sur ROR, or cette fonctionnalité n'est pas activée chez nous
- Correction du problème de sauvegarde d'un nouvel organisme (message en rouge) (issue gitbucket 370)


## 08/04/2022
- Correction de problèmes dans  les exports Standard & RDA (issue gitbucket 364)
- La liste des formulaires disponibles est désormais limitées aux propriétés liées au template ResearchOutput, lors de la création/mise à jour d'une question lors de l'édition d'un modèle de DMP
- Suppression de tables et colonnes non utilisées (issue gitbucket 365)
- Suppression de la validation des identifiants financeurs & contributeurs dans l'import RDA
- Ajout du nombre total d'utilisateurs dans la liste Admin/SuperAdmin (issue gitbucket 368)
- Correction du problème de création de nouvelle question dans les Modèles Classiques (issue gitbucket 366)
- Ajout de la validation de présence du contact et de l'email du contact dans l'import Standard
- L'import par API est disponible à l'adresse `api/v1/madmp/plans/import?import_format=rda`. Formats disponibles `standard` et `rda`

## 05/04/2022
- Ajout de l'interface d'import des plans (Standard & RDA)

## 29/03/2022
- Ajout d'une liste de sélection permettant de filtrer les formulaires structurés par type de données, lors de la modification/création d'une question dans un modèle structuré.
- Correction du problème d'affichage des libellés "Plan Details" et "Project Details" dans l'export PDF (issue gitbucket 347)
- Correction du problème d'affichage des plans en visibilité Administrateur dans la liste des plan accessible en tant qu'Admin (issue gitbucket 346)
- Correction du problème d'affichage du message d'alerte "L'élément est déjà présent dans le plan" à la création d'une personne déjà existante (issue gitbucket 316)
- La langue choisie dans le profil utilisateur devrait être correctement appliquée (issue gitbucket 359)

## 28/03/2022
- Correction du problème de copie des plans créés à partir d'un modèle classique (issue gitbucket 354)
- Correction du problème de sélection des recommandations (issue gitbucket 354)
- L'ouverture d'une liste de sélection place désormais le curseur de saisie dans le champ de recherche (issue gitbucket 356)
- Ajout des contributeurs sans rôle dans l'export JSON (issue gitbucket 358)
- Amélioration de l'affichage des valeurs sélectionnées pour les sélecteurs multiples
- Correction du problème d'export des DMP avec plusieurs phases (issue gitbucket 353)
- Correction du problème d'affichage de l'étape du cycle de vie pour les Coûts dans l'export PDF/DOCX (issue gitbucket 351)
- Correction du problème d'ouverture des exports DOCX causé par l'affichage des contributeurs sans rôle
- Mises à jour de la traduction (issue gitbucket 317)

## 14/03/2022
- Correction du problème de mise à jour de lastModifiedDate dans les fragments Meta (issue gitbucket 336)
- Correction du problème d'affichage de la liste des plans en visibilité Organisme (issue gitbucket 326)
- Mise à jour des traductions (issue gitbucket 317)
- Ajout de la possibilité d'afficher des Costs non rattachés à un produit de recherche (import RDA)

## 10/03/2022
- Correction du problème de suppression des contributeurs (issue gitbucket 343)
- Correction du problème d'affichage des formulaires structurés pour les nouvelles questions  (issue gitbucket 341)
- Correction du problème d'attribution du type de personne à la création du plan (issue gitbucket 340)
- Correction du problème d'affichage du message "select a value or enter a new one" pour la liste des financeurs (issue gitbucket 313)
- Correction d'un problème de traduction des formulaires dans Informations Générales
- Correction d'un problème d'envoi de la notification de nouveau commentaire (issue gitbucket 322)


## 04/03/2022
- Correction du problème d'affichage des libellés dans l'export PDF (issue gitbucket 333)
- Correction du problème de cloture de l'assistance conseil  (issue gitbucket 339)
- Correction du problème d'nvoi de notification aux personnes invitées  (issue gitbucket 331)
- Retrait du message du bug de changement de mail dans le profil utilisateur
- Les champs de saisie multiple ne font plus apparaitre un champ de saisie vide, après une sauvegarde du formulaire structuré
- Correction du problème de sauvegarde des valeurs de référentiels
- L'indicateur de dernière sauvegarde est mis à jour même si la sauvegarde a été faite par le même utilisateur (issue gitbucket 320)
- Correction du problème de changement de visibilité des plans (issue gitbucket 326)
- Correction d'un problème de recherche dans la liste des formulaires structurés
- Correction d'un problème qui empêchait d'accéder au champ de recherche/saisie dans les référentiels situés dans une popup (issue gitbucket 334)
- Correction d'un bug survenant lorsqu'un référentiel contient une valeur vide
- Correction du bug d'affichage des types de produits pour les plans non structurés  (issue gitbucket 338)

### Ajout du type de Modèle
- L'administrateur peut définir le type de modèle : Classique ou Structuré
- Les modèles classiques ne peuvent pas avoir de question reliées à un formulaire structuré
- Les modèles structurés n'ont accès qu'aux formulaires structurés, l'administrateur ne peut pas créer de question structurelles.

#### Modification à venir
- Retrait du type 'Structuré' des formats de réponse pour les modèles classiques
- Ajout d'un champ permettant de sélectionner le type de formulaire (classname) afin d'affiner la liste des formulaires proposés

## 28/02/2022
- Intégration de DMPRoadmap V3.0.5 (https://github.com/DMPRoadmap/roadmap/releases/tag/v3.0.5)
- L'identifiant du plan n'est plus rempli automatiquement (issue gitbucket 318)
- Amélioration des champs texte multiples (ex: mots clés non controllés) (issue gitbucket 319)
- La date d'enregistrement d'une question structurée s'affiche désormais correctement (issue gitbucket 320)
- Correction de l'affichage de l'étape du cycle de vie dans la synthèse des coûts (issue gitbucket 321)
- Correction du bug provoqué par l'ajout d'un commentaire qui bloquait l'onglet Rédiger (issue gitbucket 322)
- Le bouton Suivant est de nouveau fonctionnel dans le formulaire de création de plan (issue gitbucket 323)
- Correction d'affichage des libellés dans les fenêtres d'ajout/modification des contributeurs (issue gitbucket 324)
- Correction de l'affichage des boutons Déplacer et Supprimer dans l'onglet Produits de Recherche (issue gitbucket 325)
- La visibilité est de nouveau modifiable quelque soit le taux de remplissage d'un plan (issue gitbucket 326)
- Le message personnalisé d'un organisme est de nouveau modifiable (issue gitbucket 327)
- Les demandes d'assistance sont désormais triées par date de demande décroissante (issue gitbucket 328)
- La mise à jour des templates est de nouveau possible (issue gitbucket 330)
- Ajout de la Gem rack-attack (issue gitbucket 337)
