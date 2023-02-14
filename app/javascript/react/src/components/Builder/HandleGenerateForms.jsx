import React, { useEffect, useState } from "react";
import { getRegistryList } from "../../utils/GeneratorUtils";
import TextArea from "../Forms/TextArea";
import InputText from "../Forms/InputText";
import InputTextDynamicaly from "../Forms/InputTextDynamicaly";
import ModalTemplate from "../Forms/ModalTemplate";
import SelectContributor from "../Forms/SelectContributor";
import SelectMultipleList from "../Forms/SelectMultipleList";
import SelectSingleList from "../Forms/SelectSingleList";
import SelectWithCreate from "../Forms/SelectWithCreate";
import listContributor from "../../data/contributor.json";

function HandleGenerateForms({ shemaObject, level, lng, changeValue }) {
  const objectProp = shemaObject.properties;
  let data = [];
  // si type shema is an object
  //retun est code html
  if (shemaObject.type === "object") {
    for (const [key, value] of Object.entries(objectProp)) {
      const label = lng === "fr" ? value["form_label@fr_FR"] : value["form_label@en_GB"];
      const tooltip = lng === "fr" ? value["tooltip@fr_FR"] : value["tooltip@en_GB"];
      const isConst = value.hasOwnProperty("const@fr_FR") ? (lng === "fr" ? value["const@fr_FR"] : value["const@en_GB"]) : false;

      // condition 1
      if (value.type === "string" || value.type === "number") {
        // Condition 1.1
        // si inputType === textarea

        if (value.inputType === "textarea") {
          data.push(<TextArea key={key} label={label} name={key} changeValue={changeValue} tooltip={tooltip}></TextArea>);
          //sethtmlGenerator(data);
        }
        // Condition 1.2
        // si inputType === dropdown
        if (value.inputType === "dropdown" && value.hasOwnProperty("registry_name")) {
          const registerList = getRegistryList(value.registry_name);
          data.push(
            <SelectSingleList
              label={label}
              name={key}
              key={key}
              arrayList={registerList}
              changeValue={changeValue}
              tooltip={tooltip}
              level={level}
            ></SelectSingleList>
          );
        }
        // Condition 1.3
        // si on pas inputType propriete

        if (!value.hasOwnProperty("inputType")) {
          data.push(
            <InputText
              key={key}
              label={label}
              type={value.format ? value.format : value.type}
              placeholder={""}
              isSmall={false}
              smallText={""}
              name={key}
              changeValue={changeValue}
              hidden={value.hidden ? true : false}
              tooltip={tooltip}
              isConst={isConst}
            ></InputText>
          );
        }
      }
      // condition 2
      if (value.type === "array") {
        // condition 2.1
        // si inputType === dropdown et on n'a pas de registry_name
        if (value.inputType === "dropdown" && value.hasOwnProperty("registry_name")) {
          if (value.items.template_name) {
            const registerList = getRegistryList(value.registry_name);

            data.push(
              <SelectWithCreate
                label={label}
                name={key}
                key={key}
                arrayList={registerList}
                changeValue={changeValue}
                template={value.items.template_name}
                level={level}
                keyValue={key}
              ></SelectWithCreate>
            );
          } else {
            const registerList = getRegistryList(value.registry_name);
            data.push(
              <SelectMultipleList
                label={label}
                name={key}
                key={key}
                arrayList={registerList}
                changeValue={changeValue}
                tooltip={tooltip}
                level={level}
              ></SelectMultipleList>
            );
          }
        } else {
          // si on a type === array et items.type === object
          if (value.items.type === "object") {
            if (key === "contributor" && value.items.class === "Contributor") {
              //console.log("TODO : condition contributor à voir");
              data.push(
                <SelectContributor
                  label={label}
                  name={key}
                  key={key}
                  arrayList={listContributor}
                  changeValue={changeValue}
                  template={"PersonStandard"}
                  keyValue={key}
                  level={level}
                  tooltip={tooltip}
                ></SelectContributor>
              );
            } else {
              data.push(
                <ModalTemplate
                  key={key}
                  tooltip={tooltip}
                  value={value}
                  template={value.items.template_name}
                  keyValue={key}
                  level={level}
                ></ModalTemplate>
              );
            }
          }
          if (value.items.type === "string") {
            data.push(<InputTextDynamicaly key={key} label={label} name={key} tooltip={tooltip}></InputTextDynamicaly>);
          }
        }

        if (value.items.type !== "object") {
          //Description des données et collecte ou réutilisation de données existantes
          //console.log("Champs simples avec bouton Add/Delete : type=array + items.type=(tout sauf object)");
        }
      }
      // condition 3
      if (value.type === "object") {
        // condition 3.1

        if (value.hasOwnProperty("template_name")) {
          //console.log(" Sous fragment unique (sous formulaire)");
          if (value.inputType === "pickOrCreate") {
            data.push(
              <ModalTemplate
                key={key}
                tooltip={tooltip}
                value={value}
                lng={lng}
                template={value.template_name}
                keyValue={key}
                level={level}
              ></ModalTemplate>
            );
          }
        }
        // codition 3.2
        if (value.inputType === "dropdown") {
          if (value.hasOwnProperty("registry_name")) {
            const registerList = getRegistryList(value.registry_name);
            //console.log("TODO : à régler : pas encore trouvé");
            data.push(
              <SelectSingleList
                label={label}
                name={key}
                arrayList={registerList}
                changeValue={changeValue}
                tooltip={tooltip}
                level={level}
              ></SelectSingleList>
            );
          }
        }
      }
    }
  }
  return data;
}

export default HandleGenerateForms;
