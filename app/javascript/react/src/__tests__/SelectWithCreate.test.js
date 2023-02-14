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
    expect(wrapper.find("SelectWithCreate").prop("label")).toBe(
      "Equipements, plateaux techniques utilisés pour le stockage et sauvegarde des données"
    );
    expect(wrapper.find("SelectWithCreate").prop("name")).toBe("facility");
  });
});
