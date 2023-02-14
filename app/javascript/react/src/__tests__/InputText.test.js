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
    estimatedVolume: {
      type: "number",
      description: "Volume estimé des données",
      "label@fr_FR": "Volume estimé des données",
      "label@en_GB": "Estimated volume of data",
      "form_label@fr_FR": "Volume estimé des données",
      "form_label@en_GB": "Estimated volume of data",
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

    expect(wrapper.find("InputText").prop("label")).toBe("Volume estimé des données");
    expect(wrapper.find("InputText").prop("name")).toBe("estimatedVolume");
  });
});
