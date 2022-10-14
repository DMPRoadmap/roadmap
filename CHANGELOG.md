# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne. 


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