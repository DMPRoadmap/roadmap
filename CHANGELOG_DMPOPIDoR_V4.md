# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne. 

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


