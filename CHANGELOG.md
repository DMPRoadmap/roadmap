# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne. 


## 03/10/2022
- Export RDA : Correction d'un problème survenant lorsque l'unité de volume de la distribution n'est pas renseigné (issue gitbucket 437)
- Ajout du nombre d'utilisateurs actifs dans la liste des utilisateurs disponible pour les Admin/SuperAdmin

## 29/09/2022
- Export RDA : Amélioration des convertisseurs (issue gitbucket 428)
- Import RDA : Ajout d'un volumeUnit par défaut (issue gitbucket 388)
- Correction d'un problème d'archivage des utilisateurs (issue gitbucket 376)
- Export PDF/DOCX : Les libellés et entêtes des tableaux Produits de Recherche, Contributeurs et Budget sont affichés dans la langue du DMP (issue gitbucket 347)

## 23/09/2022
- Amélioration du message de notification de changement de visibilité (issue gitbucket 420)
- Le lien vers le swagger est désormais dans le pied de page
- Correction d'un problème d'affichage du mail d'assistance dans la signature des emails de notification
- Import RDA
  - Ajout de convertisseurs pour les données provenants de référentiels (issue gitbucket 428)
  - Seule la première valeur est importée pour `security_and_privacy`, `distribution/format`, `license` et `data_quality_assurance`
- Export RDA
  - Ajout d'un convertisseur pour les volumes des fichiers (bytes_size)
- Amélioration du chargement des référentiels
  - Utilisation de la librairie ActiveRecord-Import qui permet d'insérer plusieurs lignes à la fois. Les temps de chargement des référentiels sont gradement réduits.
  - Retrait de la possibilité d'ajout d'une valeur dans un référentiel, le chargement d'un fichier est préférée
  - Remplacement du bouton "Créer valeur" par "Editer Référentiel"

## 09/09/2022
- Swagger : Ajout d'un message indiquant à l'utilisateur de s'authentifier. Les valeurs par défaut de la route /authenticate sont celle de l'autentification utilisateur (auparavant Client)
- Amélioration de l'archivage automatique des utilisateurs après 5 ans. Seuls les utilisateurs actifs sont concernés. Le traitement devrait désormais bien archiver les comptes non connectés depuis plus de 5 ans.
- Import RDA : 
  - distribution/format (tableau) est désormais bien transformé en chaine de caractères (issue gitbucket 423)
  - security_and_privacy ne devrait plus provoquer d'erreur lors de l'import. Les données sont tranformées en chaine de caractères (issue gitbucket 423)
  - data_quality_assurance est désormais importé sans les crochets (issue gitbucket 423)
- Export RDA : 
  - distribution/format renvoit bien un tableau vide lors que le format est absent (issue gitbucket 424)
  - data_quality_assurance renvoit désormais un tableau vide si aucune description n'est forunée dans DocumentationQuality (issue gitbucket 423)
  - Correction d'un problème affectant l'export RDA par API

## 08/08/2022
Ces modifiations pourront faire l'objet d'une mise à jour corrective à mon retour.
- Import RDA : un entrepôt vide n'est plus créé lorsque la donnée n'est pas présente dans le fichier d'import (issue gitbucket 424)
- Reactivation du CATCHA, à valider en VI (issue gitbucket 427)
- Correction du problème d'enregistrement des données organismes causée par un mauvais paramétrage de l'éditeur suite à sa mise à jour. (issue gitbucket 425)

## 07/07/2022
- Correction de l'ordre d'affichage des plans visibilité Organisme dans le tableau de bord (issue gitbucket 417)
- Correction de la langue d'affichage des formulaires de création/edition dans l'onglet Produits de Recherche
- Correction de l'ordre d'affichage des produits de recherche dans l'export PDF/DOCX
- Affichage des questions dans les DMP publics (issue gitbucket 387)
- Import RDA : 
  - Correction du bug se produisant quand `"project": []` (issue gitbucket 416)
  - Correction du mauvais formatage des licences, distribution/format, data_quality_assurance, security_and_privacy (issue gitbucket 407)

## 28/06/2022
- Ajout de la documentation d'API sous forme de Swagger
  - Accessible par l'URL `/api-docs`
  - Accessible par le lien "API Docs" présent dans le bandeau de navigation pour les utilisateurs connectés ayant le droit d'utiliser l'API