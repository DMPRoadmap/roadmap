# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne. 

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
