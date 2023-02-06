# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne. 

## 06/02/2023
- Formulaire dynamique : retravail de la gestion des valeurs par défaut et de l'indicateur de champ constant : 
  - Une propriété est désormais déclarée constante avec l'ajout de l'indicateur `"isConst": true`. ex:

  ```json
    "securityMeasures": {
      "type": "string",
      "label@fr_FR": "Mesures de sécurité",
      "label@en_GB": "Security measures",
      "isConst": true
    }

  ```
  - Les valeurs par défaut sont désormais déclarées dans une propriété appelée `default` située à la racine du schéma. On peut y déclarer une valeur par défaut pour les champs simples, mais également des sous fragments. Ex:

  ```json
    "properties": {...},
    "required": [...],
    "to_string": [],
    "default": {
        "fr_FR": {
            "securityMeasures": "L’offre de service propose la réplication des données,...",
            "facility": [
                {
                    "title": "MESO@LR",
                    "technicalResourceId": "https://cat.opidor.fr/index.php/MESO@LR",
                    "idType": "URL",
                    "serviceContact": "meso-lr@umontpellier.fr"
                }
            ]
        },
        "en_GB": {
            "securityMeasures": "The service offers data replication, ...",
            "facility": [
                {
                    "title": "MESO@LR",
                    "technicalResourceId": "https://cat.opidor.fr/index.php/MESO@LR",
                    "idType": "URL",
                    "serviceContact": "meso-lr@umontpellier.fr"
                }
            ]
        }
    }

  ```
  - Un champ marqué comme constant n'est pas modifiable, dans le cas d'un sous-fragment constant (ex: backupPolicy), le bouton Créer n'apparait pas et un éventuel fragment par défaut est affiché en visionnage seulement.
  - Lors de la **première ouverture** d'un formulaire ou lors du **changement de formulaire**, les valeurs par défaut sont automatiquement importées dans le plan.


