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
  title: "BackupPolicyStandard",
  description: "BackupPolicyStandard template",
  type: "object",
  class: "BackupPolicyStandard",
  properties: {
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
  },
  required: ["description"],
  to_string: ["$.description"],
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
    expect(wrapper.find("SelectMultipleList").prop("label")).toBe("Supports de stockage");
    expect(wrapper.find("SelectMultipleList").prop("name")).toBe("storageType");
  });
});
