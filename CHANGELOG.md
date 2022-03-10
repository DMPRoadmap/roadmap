# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne. 

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