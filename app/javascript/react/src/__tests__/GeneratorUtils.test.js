import { parsePatern, createMarkup, deleteByIndex, getCheckPatern, checkRequiredForm, isEmptyObject, getLabelName } from "../utils/GeneratorUtils";

describe("parsePattern", () => {
  it("returns a string with keys mapped to their values in the data object", () => {
    const data = {
      costType: "Stockage",
      amount: 320,
      currency: "eur",
    };
    const keys = ["$.costType", " : ", "$.amount", " ", "$.currency"];
    const expectedResult = "Stockage : 320 eur";
    const result = parsePatern(data, keys);
    expect(result).toEqual(expectedResult);
  });

  it("returns a string with keys mapped to their nested values in the data object", () => {
    const data = {
      person: {
        firstName: "brahmi",
        lastName: "amine",
      },
      role: "developer",
    };
    const keys = ["$.person.firstName", " ", "$.person.lastName ", " (", "$.role", ")"];
    const expectedResult = "brahmi amine (developer)";
    const result = parsePatern(data, keys);

    expect(result).toEqual(expectedResult);
  });
});

describe("createMarkup", () => {
  it("returns an object with a sanitized __html property", () => {
    const html = '<p>dmp opidor</p><script>alert("attack!")</script>';
    const expectedResult = {
      __html: "<p>dmp opidor</p>",
    };
    const result = createMarkup(html);

    expect(result).toEqual(expectedResult);
  });
});

describe("deleteByIndex", () => {
  it("returns a new list with the specified index removed", () => {
    const list = [
      {
        label: {
          en_GB: "ABiMS, Plateforme   ABiMS, Analysis   and   Bioinformatics   for   Marine Science.",
          fr_FR: "ABiMS, Plateforme   ABiMS, Analysis   and   Bioinformatics   for   Marine Science.",
        },
        title: "ABiMS",
        technicalResourceId: "https://cat.opidor.fr/index.php/ABiMS",
        idType: "URL",
        serviceContact: "support.abims@sb-roscoff.fr",
      },
      {
        label: {
          en_GB: "Adisp, Archives de Données Issues de la Statistique Publique",
          fr_FR: "Adisp, Archives de Données Issues de la Statistique Publique",
        },
        title: "Adisp",
        technicalResourceId: "https://cat.opidor.fr/index.php/Adisp",
        idType: "URL",
        serviceContact: "http://www.progedo-adisp.fr/contact.php",
      },
      {
        label: {
          en_GB: "Adonis, Acquisition de DONnéeS à l’Inra",
          fr_FR: "Adonis, Acquisition de DONnéeS à l’Inra",
        },
        title: "Adonis",
        technicalResourceId: "https://cat.opidor.fr/index.php/Adonis",
        idType: "URL",
        serviceContact: "adonis@inra.fr",
      },
    ];
    const idx = 2;
    const expectedResult = [
      {
        label: {
          en_GB: "ABiMS, Plateforme   ABiMS, Analysis   and   Bioinformatics   for   Marine Science.",
          fr_FR: "ABiMS, Plateforme   ABiMS, Analysis   and   Bioinformatics   for   Marine Science.",
        },
        title: "ABiMS",
        technicalResourceId: "https://cat.opidor.fr/index.php/ABiMS",
        idType: "URL",
        serviceContact: "support.abims@sb-roscoff.fr",
      },
      {
        label: {
          en_GB: "Adisp, Archives de Données Issues de la Statistique Publique",
          fr_FR: "Adisp, Archives de Données Issues de la Statistique Publique",
        },
        title: "Adisp",
        technicalResourceId: "https://cat.opidor.fr/index.php/Adisp",
        idType: "URL",
        serviceContact: "http://www.progedo-adisp.fr/contact.php",
      },
    ];
    const result = deleteByIndex(list, idx);

    expect(result).toEqual(expectedResult);
  });

  it("returns the original list if the index is out of bounds", () => {
    const list = [
      {
        label: {
          en_GB: "ABiMS, Plateforme   ABiMS, Analysis   and   Bioinformatics   for   Marine Science.",
          fr_FR: "ABiMS, Plateforme   ABiMS, Analysis   and   Bioinformatics   for   Marine Science.",
        },
        title: "ABiMS",
        technicalResourceId: "https://cat.opidor.fr/index.php/ABiMS",
        idType: "URL",
        serviceContact: "support.abims@sb-roscoff.fr",
      },
      {
        label: {
          en_GB: "Adisp, Archives de Données Issues de la Statistique Publique",
          fr_FR: "Adisp, Archives de Données Issues de la Statistique Publique",
        },
        title: "Adisp",
        technicalResourceId: "https://cat.opidor.fr/index.php/Adisp",
        idType: "URL",
        serviceContact: "http://www.progedo-adisp.fr/contact.php",
      },
      {
        label: {
          en_GB: "Adonis, Acquisition de DONnéeS à l’Inra",
          fr_FR: "Adonis, Acquisition de DONnéeS à l’Inra",
        },
        title: "Adonis",
        technicalResourceId: "https://cat.opidor.fr/index.php/Adonis",
        idType: "URL",
        serviceContact: "adonis@inra.fr",
      },
    ];
    const idx = -1;
    const expectedResult = [
      {
        label: {
          en_GB: "ABiMS, Plateforme   ABiMS, Analysis   and   Bioinformatics   for   Marine Science.",
          fr_FR: "ABiMS, Plateforme   ABiMS, Analysis   and   Bioinformatics   for   Marine Science.",
        },
        title: "ABiMS",
        technicalResourceId: "https://cat.opidor.fr/index.php/ABiMS",
        idType: "URL",
        serviceContact: "support.abims@sb-roscoff.fr",
      },
      {
        label: {
          en_GB: "Adisp, Archives de Données Issues de la Statistique Publique",
          fr_FR: "Adisp, Archives de Données Issues de la Statistique Publique",
        },
        title: "Adisp",
        technicalResourceId: "https://cat.opidor.fr/index.php/Adisp",
        idType: "URL",
        serviceContact: "http://www.progedo-adisp.fr/contact.php",
      },
      {
        label: {
          en_GB: "Adonis, Acquisition de DONnéeS à l’Inra",
          fr_FR: "Adonis, Acquisition de DONnéeS à l’Inra",
        },
        title: "Adonis",
        technicalResourceId: "https://cat.opidor.fr/index.php/Adonis",
        idType: "URL",
        serviceContact: "adonis@inra.fr",
      },
    ];
    const result = deleteByIndex(list, idx);

    expect(result).toEqual(expectedResult);
  });
});

describe("getCheckPattern", () => {
  test("returns true for valid email address", () => {
    const type = "email";
    const value = "test@example.com";
    expect(getCheckPatern(type, value)).toBe(true);
  });

  test("returns false for invalid email address", () => {
    const type = "email";
    const value = "testexample.com";
    expect(getCheckPatern(type, value)).toBe(false);
  });

  test("returns true for valid URI", () => {
    const type = "uri";
    const value = "https://www.example.com";
    expect(getCheckPatern(type, value)).toBe(true);
  });

  test("returns false for invalid URI", () => {
    const type = "uri";
    const value = "httwww.example.";
    expect(getCheckPatern(type, value)).toBe(false);
  });

  test("returns true for any other type", () => {
    const type = "string";
    const value = "anyValue";
    expect(getCheckPatern(type, value)).toBe(true);
  });
});

// describe("checkRequiredForm", () => {
//   it("returns undefined if form is falsy", () => {
//     const standardTemplate = { required: ["field1", "field2"] };
//     const form = null;
//     const result = checkRequiredForm(standardTemplate, form);
//     expect(result).toBe(undefined);
//   });

//   it("returns the first required field that is empty or has the default value", () => {
//     const standardTemplate = { required: ["field1", "field2"] };
//     const form = {
//       field1: "",
//       field2: "<p></p>",
//       field3: "some value",
//     };
//     const result = checkRequiredForm(standardTemplate, form);
//     expect(result).toBe("field1");
//   });

//   it("returns an empty string if all required fields have a value", () => {
//     const standardTemplate = { required: ["field1", "field2"] };
//     const form = {
//       field1: "some value",
//       field2: "some other value",
//     };
//     const result = checkRequiredForm(standardTemplate, form);
//     expect(result).toBe("");
//   });
// });

describe("isEmptyObject", () => {
  it("returns true for an empty object", () => {
    const obj = {};
    expect(isEmptyObject(obj)).toBe(true);
  });

  it("returns false for a non-empty object", () => {
    const obj = { key: "value" };
    expect(isEmptyObject(obj)).toBe(false);
  });

  it("returns true for an empty array", () => {
    const obj = [];
    expect(isEmptyObject(obj)).toBe(false);
  });

  it("returns false for a non-empty array", () => {
    const obj = [1, 2, 3];
    expect(isEmptyObject(obj)).toBe(false);
  });

  it("returns true for an object without any own properties", () => {
    const obj = Object.create(null);
    expect(isEmptyObject(obj)).toBe(true);
  });
});

describe("getLabelName", () => {
  it("returns the correct label name for a given value", () => {
    const value = "description";
    const object = {
      properties: {
        description: {
          type: "string",
          description: "Description de la politique de sauvegarde appliquée",
          inputType: "textarea",
          "label@fr_FR": "nom et description de la politique de stockage et sauvegarde",
          "label@en_GB": "Storage and backup policy name and description",
          "form_label@fr_FR": "Politique de stockage et sauvegarde",
          "form_label@en_GB": "Storage and backup policy",
        },
      },
    };

    expect(getLabelName(value, object)).toBe("Politique de stockage et sauvegarde");
  });

  it("returns the fallback label name if form_label is not available", () => {
    const value = "description";
    const object = {
      properties: {
        description: {
          type: "string",
          description: "Description de la politique de sauvegarde appliquée",
          inputType: "textarea",
          "label@fr_FR": "nom et description de la politique de stockage et sauvegarde",
          "label@en_GB": "Storage and backup policy name and description",
        },
      },
    };

    expect(getLabelName(value, object)).toBe("nom et description de la politique de stockage et sauvegarde");
  });
});
