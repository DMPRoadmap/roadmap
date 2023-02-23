import React from "react";
import HandleGenerateForms from "../components/Builder/HandleGenerateForms";
import Global from "../components/context/Global";
import { mount } from "enzyme";
import { render, screen } from "@testing-library/react";

import Adapter from "@cfaester/enzyme-adapter-react-18";
import { configure } from "enzyme";
configure({ adapter: new Adapter() });

let shemaObject = {
  $schema: "http://json-schema.org/draft-07/schema#",
  $id: "../Documentation/Implementation/data_model/Json/",
  title: "DataStorageStandard",
  description: "DataStorageStandard template",
  type: "object",
  class: "DataStorageStandard",
  properties: {
    cost: {
      type: "array",
      "table_header@fr_FR": "Type de coût : montant",
      "table_header@en_GB": "Cost type: amount",
      items: {
        type: "object",
        class: "Cost",
        properties: {
          dbid: {
            type: "number",
          },
        },
        template_name: "CostStandard",
        required: ["dbid"],
      },
      description: "Coûts éventuels liés au stockage des données",
      "label@fr_FR": "Coûts",
      "label@en_GB": "Costs",
      "form_label@fr_FR": "Coûts liés au stockage et à la sauvegarde des données",
      "form_label@en_GB": "Data storage and backup associated costs",
    },

    funding: {
      type: "array",
      "table_header@fr_FR": "Financeur : identifiant du financement",
      "table_header@en_GB": "Funder: funding identifier",
      items: {
        type: "object",
        class: "Funding",
        properties: {
          dbid: {
            type: "number",
          },
        },
        template_name: "FundingStandard",
        required: ["dbid"],
      },
      minItems: 1,
      description: "Source(s) de financement d'un projet ou d'une activité de recherche",
      "label@fr_FR": "Sources de financement",
      "label@en_GB": "Funding",
      "form_label@fr_FR": "Indiquer les sources de financement du projet",
      "form_label@en_GB": "Indicate the funding of the project",
    },

    backupPolicy: {
      type: "array",
      table_header: null,
      items: {
        type: "object",
        class: "BackupPolicy",
        properties: {
          dbid: {
            type: "number",
          },
        },
        template_name: "BackupPolicyStandard",
        required: ["dbid"],
      },
      description: "Informations relatives à la politique de sauvegarde",
      "label@fr_FR": "Politique de sauvegarde",
      "label@en_GB": "Backup policy",
      "form_label@fr_FR": "Politique de sauvegarde",
      "form_label@en_GB": "Backup policy",
    },

    principalInvestigator: {
      type: "object",
      class: "Contributor",
      properties: {
        dbid: {
          type: "number",
        },
      },
      template_name: "PrincipalInvestigator",
      required: ["dbid"],
      description: "Coordinateur principal du projet",
      "label@fr_FR": "Coordinateur du projet",
      "label@en_GB": "Project coordinator",
      "tooltip@fr_FR": "Aussi appelé Investigateur principal",
      "tooltip@en_GB": "also called Principal investigator",
      "form_label@fr_FR": "Coordinateur du projet",
      "form_label@en_GB": "Project coordinator",
    },
    contributor: {
      type: "array",
      "table_header@fr_FR": "Nom (rôle)",
      "table_header@en_GB": "Name (role)",
      items: {
        type: "object",
        class: "Contributor",
        properties: {
          dbid: {
            type: "number",
          },
        },
        template_name: "DataStorageManager",
        required: ["dbid"],
      },
      description: "Personne(s) responsable(s) du suivi du stockage des données",
      "label@fr_FR": "Responsables du stockage des données",
      "label@en_GB": "Persons in charge of storage",
      "tooltip@fr_FR": "Le responsable peut être une personne, une équipe, un service",
      "tooltip@en_GB": "Person in charge can be a person, a team, a department",
      "form_label@fr_FR": "Responsables du stockage des données",
      "form_label@en_GB": "Persons in charge of storage",
    },

    volumeUnit: {
      type: "string",
      description: "Unité de volume",
      inputType: "dropdown",
      "label@fr_FR": "Unité",
      "label@en_GB": "Unit",
      registry_name: "VolumeUnit",
      overridable: true,
      "form_label@fr_FR": "Unité",
      "form_label@en_GB": "Unit",
    },

    description: {
      type: "string",
      description: "Description des besoins de stockage",
      inputType: "textarea",
      "label@fr_FR": "Besoins de stockage",
      "label@en_GB": "Storage needs",
      "form_label@fr_FR": "Décrire les besoins de stockage",
      "form_label@en_GB": "Describe storage needs",
    },

    facility: {
      type: "array",
      table_header: null,
      items: {
        type: "object",
        class: "TechnicalResource",
        properties: {
          dbid: {
            type: "number",
          },
        },
        template_name: "TechnicalResourceStandard",
        required: ["dbid"],
      },
      description: "Ressource/équipement utilisée pour le stockage et sauvegarde des données",
      "label@fr_FR": "Equipements, plateaux techniques",
      "label@en_GB": "Equipments, technical platforms",
      inputType: "dropdown",
      registry_name: "StorageServices",
      overridable: true,
      "form_label@fr_FR": "Equipements, plateaux techniques utilisés pour le stockage et sauvegarde des données",
      "form_label@en_GB": "Equipments, technical platforms used for data storage and backup",
    },

    storageType: {
      type: "array",
      items: {
        type: "string",
      },
      description: "Support de stockage des données",
      inputType: "dropdown",
      "label@fr_FR": "Supports de stockage",
      "label@en_GB": "Storage types",
      registry_name: "StorageType",
      overridable: true,
      "form_label@fr_FR": "Supports de stockage",
      "form_label@en_GB": "Storage types",
    },
    uncontrolledKeywords: {
      type: "array",
      items: {
        type: "string",
      },
      description: "Mots clés libres",
      "label@fr_FR": "Mots clés (texte libre)",
      "label@en_GB": "Keywords (free-text)",
      "tooltip@fr_FR": "Un mot clé par ligne. Cliquer sur + pour ajouter un mot-clé. Eviter les acronymes et les mots clés trop génériques",
      "tooltip@en_GB": "One key word per line. Click on + to add a key word. Avoid acronyms and overly generic keywords",
      "form_label@fr_FR": "Mots clés (texte libre)",
      "form_label@en_GB": "Uncontrolled keyword(s) (free-text)",
    },
  },
  required: ["description"],
  to_string: [],
};

describe("HandleGenerateForms component", () => {
  it("should render input elements correctly", () => {
    const level = 1;
    const lng = "fr";
    const changeValue = jest.fn();
    const wrapper = mount(
      <Global>
        <HandleGenerateForms shemaObject={shemaObject} level={level} lng={lng} changeValue={changeValue} />
      </Global>
    );
    render(
      <Global>
        <HandleGenerateForms shemaObject={shemaObject} level={level} lng={lng} changeValue={changeValue} />
      </Global>
    );

    // modal template
    expect(screen.getByText("Coûts liés au stockage et à la sauvegarde des données")).toBeInTheDocument();
    expect(screen.getByText("Indiquer les sources de financement du projet")).toBeInTheDocument();
    expect(screen.getByText("Politique de sauvegarde")).toBeInTheDocument();
    //principalInvestigator (select investigator)
    expect(wrapper.find("SelectInvestigator").prop("label")).toBe("Coordinateur du projet");
    expect(wrapper.find("SelectInvestigator").prop("name")).toBe("principalInvestigator");
    expect(wrapper.find("SelectInvestigator").prop("tooltip")).toBe("Aussi appelé Investigateur principal");

    //contributor (Select contributor)
    expect(wrapper.find("SelectContributor").prop("label")).toBe("Responsables du stockage des données");
    expect(wrapper.find("SelectContributor").prop("name")).toBe("contributor");

    //volumeUnit  (Select single)
    expect(wrapper.find("SelectSingleList").prop("label")).toBe("Unité");
    expect(wrapper.find("SelectSingleList").prop("name")).toBe("volumeUnit");

    //text area
    expect(screen.getByText("Décrire les besoins de stockage")).toBeInTheDocument();

    //facility (select with create)
    expect(wrapper.find("SelectWithCreate").prop("label")).toBe(
      "Equipements, plateaux techniques utilisés pour le stockage et sauvegarde des données"
    );
    expect(wrapper.find("SelectWithCreate").prop("name")).toBe("facility");

    //storageType (select multiple)
    expect(wrapper.find("SelectMultipleList").prop("label")).toBe("Supports de stockage");
    expect(wrapper.find("SelectMultipleList").prop("name")).toBe("storageType");

    //uncontrolledKeywords (String add/delete)
    expect(wrapper.find("InputTextDynamicaly").prop("label")).toBe("Mots clés (texte libre)");
    expect(wrapper.find("InputTextDynamicaly").prop("name")).toBe("uncontrolledKeywords");
  });
});
