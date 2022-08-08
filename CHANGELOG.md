# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne. 


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