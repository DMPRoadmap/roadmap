# DMP OPIDoR

## Démarrage rapide

### Requis

- Ruby 2.4.x
- Rails 4.2.x
- NodeJS LTS
- PostgreSQL 9.x

### Installation

Une installation rapide en mode développement de DMP OPIDoR est possible en suivant ces étapes :

1. Récupération du code : `git clone <URL> dmpopidor` puis `cd dmpopidor`
2. Installation des dépendances Ruby et Node : `bundle` et `npm install`
3. Configuration de la base de données :
    - Déplacer *config/database.yml.sample* en *config/database.yml*
    - Configurer *config/database.yml* avec une base de donnée valide
4. Créer la base et executer les migrations :
    - `rake db:create`
    - `rake db:schema:load` **OU** importer un dump existant
    - `rake db:migrate`
5. Enfin, lancer l'application avec : `rails s` ou `rails server`

L'application se lance par défaut en mode développement.

## Développement

### Structure du dépôt Git

Le dépôt git est composé de deux branches principales permanentes :

- *master* qui est la branche dite "stable", elle ne contient une version fonctionnelle et testée sans fonctionnalité en cours de développement.
- *dev* qui est la branche dite "de développement", elle contient une version du code qui n'est pas nécessairement complète ni même fonctionnelle. Cette branche est notamment le point de fusion entre les différentes branches dédiées à des fonctionnalité spécifiques.

En plus de ces deux branches il peut exister des branches dédiées à des développements précis, ces dernières sont préfixées selon leur type, exemples :

- *feature/dynamic_form* serait une branche concernant une nouvelle fonctionnalité de formulaire dynamique
- *fix/dataset* serait une branche apportant une correction à une fonctionnalité de datasets