import React from "react";
import HandleGenerateForms from "../components/Builder/HandleGenerateForms";
import Global from "../components/context/Global";
import { mount } from "enzyme";

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
    expect(wrapper.find("SelectContributor").prop("label")).toBe("Responsables du stockage des données");
    expect(wrapper.find("SelectContributor").prop("name")).toBe("contributor");
  });
});
