# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne. 

## 21/01/2022
- Résolution d'un bug survenant la vérification de l'existance d'un contributeur, à la création d'un nouveau contributeur.

## 20/01/2022
- Ajout de l'affiliation dans le tableau des contributeurs présent lors de l'export (issue gitbucket 311)
- Résolution d'un bug survenant lorsque 'params' est absent de la propriété 'run' d'un template
- L'organisme sélectionné est désormais bien pris en compte lors de la création d'un compte suite à un partage de plan (issue gitbucket 312)

## 13/01/2022
- Changement du message pour les organismes "unmanaged" affiché lors de la création de plan
- Ajout d'un message indiquant que le changement d'email n'est pas fonctionnel
- Résolution d'un bug se produisant lors de l'accès à un profil utilisateur en tant que super admin, quand un plan n'a pas de propriétaire.
- Les organismes "unmanaged" ne sont plus présent dans la liste des organismes du formulaire de création de plan.

## 11/01/2022
- Le changement d'email depuis le profil est de nouveau fonctionnel
- Les tooltips s'affichent désormais sur les boutons "Runs"

## 10/01/2022
- Les organismes "unmanaged" n'apparaissent plus dans le sélecteur d'organimes. Il est cependant toujours possible d'en créer un nouveau
- Ajout d'un message dans le formulaire de création de plan pour les utilisateurs liés à un organisme "unmanaged"
- (A tester en VI) Fix pour les problèmes d'encodage des informations provenant de la fédération d'identité. Ce problème empếche les utilisateurs de lier leur compte à la fédé et de se connecter par la fédé.
- Mise à jour de l'URL de la codebase.

## 16/12/2021
- Ajout de l'indication des valeurs minimum et maximum sur les champs nombre
- Correction d'un problème empêchant la saisie d'une valeur dans les champs nombre lorsque le minimum était supérieur à 0
- Corrrection d'un problème d'affichage des noms des personnes dans les mails de notification (problème du mail d'assistance conseil)
- Ajout de l'éditeur du texte de banière dans l'édition d'un organisme
- Joyeuses fêtes !

## 10/12/2021
- Amélioration de l'affichage des valeurs sélectionnées pour les référentiels multiples
- Changement du formatage des informations provenant de l'API des référentiels
- Le bouton d'ajout de lien des éditeurs présent dans une fenêtre "pop up" est de nouveau fonctionnel
- Le formatage HTML est affiché correctement lors de l'export, pour les listes de sous fragments (ex: Politique de Données)
- Amélioration de l'affichage des champs `number` avec l'ajout d'un espace de séparation des milliers

## 06/12/2021
- Ajout du support des paramètres dans les propriétés `run` présentes dans les templates
- Les tooltips devraient s'afficher correctement suite à une sauvegarde ou à l'ouverture d'une question  (Issue Gitbucket 103)
- Amélioration des sélecteurs multiples : 
  - Référentiels complexes (ex : Partners) ou Contributeurs : Ajout d'une icone indiquant que les éléments seront ajoutés sous la liste
  - Référentiels simples (ex: StorageType) : refonte graphique qui devraient rendre plus clair l'ajout et la suppression d'éléments.
- Ajout d'une API d'interrogation des référentiels 
  - Liste : `/api/v1/madmp/registries`
  - Accès à un référentiel et ses valeurs : `/api/v1/madmp/registries/:name` (ex: `/api/v1/madmp/registries/AgentIdSystem`)

## 02/12/2021

- Seuls les systèmes d'identification marqués comme actif sont affichés dans le profil utilisateur (ORCID n'apparaitra plus malgré la désactivation)
- Les tableaux de fragments affichent désormais le formatage HTML (liens, gras, italique)
- Les référentiels simples affichent désormais le formatage HTML de la valeur sélectionnée (ex: Description d'un Standard de métadonnées)
- Les éditeurs des fenêtres "pop up" ont désormais les mêmes options que les autres éditeurs de l'application.
- Le mail partage d'un partage d'un plan à un utilisateur qui n'a pas de compte affiche le nom de la personne ayant partagé le plan.
- L'onglet "Runs" dans le volet *Commentaires et Recommandations* est affiché seulement quand le formulaire choisi possède des traitements. (Issue Gitbucket 192)
- Amélioration de l'affichage des liens dans le texte des questions
- Amélioration de l'affichage des valeurs numériques dans les `to_string`
- Ajout du support d'une valeur maximum et mininum pour les champs de type `number`
ex : 
```json
"amount": {
    "type": "number",
    "minimum": 0,
    "maximum": 20000,
    "description": "Valeur numérique du montant",
    "label@fr_FR": "Montant",
    "label@en_GB": "Amount",
    "tooltip@fr_FR": "Saisir le montant",
    "tooltip@en_GB": "Enter the amount",
    "form_label@fr_FR": "Montant",
    "form_label@en_GB": "Amount"
}
```

### Produits de recherche
- Pour les plans avec un seul produit de recherche, le nom du produit de recherche est affiché dans les mails de notification d'un nouveau commentaire
- Les champs Abbréviation et Nom complet sont obligatoires (Issue Gitbucket 55)
