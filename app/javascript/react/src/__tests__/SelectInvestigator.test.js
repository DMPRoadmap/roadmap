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
  title: "ProjectStandard",
  description: "ProjectStandard template",
  type: "object",
  class: "ProjectStandard",
  properties: {
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
  },
  required: ["title", "acronym", "description", "funding", "startDate", "endDate", "partner", "principalInvestigator"],
  to_string: [],
  run: [
    {
      script_id: 4,
      name: "Anr_data_fetcher_v2",
      "label@fr_FR": "Importer informations si projet ANR",
      "label@en_GB": "Fill informations if ANR project ",
    },
  ],
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
    expect(wrapper.find("SelectInvestigator").prop("label")).toBe("Coordinateur du projet");
    expect(wrapper.find("SelectInvestigator").prop("name")).toBe("principalInvestigator");
    expect(wrapper.find("SelectInvestigator").prop("tooltip")).toBe("Aussi appelé Investigateur principal");
  });
});
