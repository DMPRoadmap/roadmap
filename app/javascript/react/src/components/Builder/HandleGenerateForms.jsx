/* eslint-disable no-restricted-syntax */
import React, { useContext } from 'react';
import PropTypes from 'prop-types';

import { GlobalContext } from '../context/Global.jsx';
import InputText from '../Forms/InputText';
import InputTextDynamicaly from '../Forms/InputTextDynamicaly';
import ModalTemplate from '../Forms/ModalTemplate';
import SelectContributor from '../Forms/SelectContributor';
import SelectMultipleList from '../Forms/SelectMultipleList';
import SelectSingleList from '../Forms/SelectSingleList';
import SelectWithCreate from '../Forms/SelectWithCreate';
import TinyArea from '../Forms/TinyArea';
import SelectInvestigator from '../Forms/SelectInvestigator';

function HandleGenerateForms({
  shemaObject, level, changeValue, fragmentId,
}) {
  const { locale, dmpId } = useContext(GlobalContext);
  if (!shemaObject) return false;
  const properties = shemaObject.properties;
  const data = [];
  // si type shema is an object
  // retun est code html
  if (shemaObject.type === 'object') {
    for (const [key, prop] of Object.entries(properties)) {
      const label = prop[`form_label@${locale}`];
      const tooltip = prop[`tooltip@${locale}`];
      const isConst = Object.prototype.hasOwnProperty.call(prop, `const@${locale}`) ? prop[`const@${locale}`] : false;
      // condition 1
      if (prop.type === 'string' || prop.type === 'number') {
        // Condition 1.1
        // si inputType === textarea

        if (prop.inputType === 'textarea') {
          data.push(
            <TinyArea
              key={key}
              level={level}
              label={label}
              propName={key}
              changeValue={changeValue}
              tooltip={tooltip}
              fragmentId={fragmentId}
            ></TinyArea>,
          );
          // sethtmlGenerator(data);
        }
        // Condition 1.2
        // si inputType === dropdown
        if (
          prop.inputType === 'dropdown'
          && Object.prototype.hasOwnProperty.call(prop, 'registry_id')
        ) {
          data.push(
            <SelectSingleList
              key={key}
              label={label}
              propName={key}
              registryId={prop.registry_id}
              changeValue={changeValue}
              tooltip={tooltip}
              level={level}
              fragmentId={fragmentId}
              registryType="simple"
            ></SelectSingleList>,
          );
        }
        // Condition 1.3
        // si on pas inputType propriete

        if (!Object.prototype.hasOwnProperty.call(prop, 'inputType')) {
          data.push(
            <InputText
              key={key}
              label={label}
              type={prop.format ? prop.format : prop.type}
              placeholder={''}
              isSmall={false}
              smallText={''}
              propName={key}
              changeValue={changeValue}
              hidden={prop.hidden ? true : false}
              tooltip={tooltip}
              isConst={isConst}
              fragmentId={fragmentId}
            ></InputText>,
          );
        }
      }
      // condition 2
      if (prop.type === 'array') {
        // condition 2.1
        // si inputType === dropdown et on n'a pas de registry_name
        if (
          prop.inputType === 'dropdown'
          && Object.prototype.hasOwnProperty.call(prop, 'registry_id')
        ) {
          if (prop.items.schema_id) {
            data.push(
              <SelectWithCreate
                key={key}
                label={label}
                propName={key}
                registryId={prop.registry_id}
                changeValue={changeValue}
                templateId={prop.items.schema_id}
                level={level}
                header={prop[`table_header@${locale}`]}
                fragmentId={fragmentId}
              ></SelectWithCreate>,
            );
          } else {
            data.push(
              <SelectMultipleList
                key={key}
                label={label}
                propName={key}
                registryId={prop.registry_id}
                changeValue={changeValue}
                tooltip={tooltip}
                level={level}
                fragmentId={fragmentId}
              ></SelectMultipleList>,
            );
          }
        } else {
          // si on a type === array et items.type === object
          if (prop.items.type === 'object') {
            if (key === 'contributor' && prop.items.class === 'Contributor') {
              data.push(
                <SelectContributor
                  key={key}
                  label={label}
                  propName={key}
                  changeValue={changeValue}
                  templateId={prop.items.schema_id}
                  level={level}
                  tooltip={tooltip}
                  header={prop[`table_header@${locale}`]}
                  fragmentId={fragmentId}
                ></SelectContributor>,
              );
            } else {
              data.push(
                <ModalTemplate
                  key={key}
                  propName={key}
                  tooltip={tooltip}
                  value={prop}
                  templateId={prop.items.schema_id}
                  level={level}
                  header={prop[`table_header@${locale}`]}
                  fragmentId={fragmentId}
                ></ModalTemplate>,
              );
            }
          }
          if (prop.items.type === 'string') {
            data.push(
              <InputTextDynamicaly
                key={key}
                label={label}
                propName={key}
                tooltip={tooltip}
                fragmentId={fragmentId}
              ></InputTextDynamicaly>,
            );
          }
        }
      }
      // condition 3
      if (prop.type === 'object') {
        // condition 3.1

        if (Object.prototype.hasOwnProperty.call(prop, 'schema_id')) {
          // console.log(" Sous fragment unique (sous formulaire)");
          if (prop.inputType === 'pickOrCreate') {
            data.push(
              <ModalTemplate
                key={key}
                propName={key}
                tooltip={tooltip}
                value={prop}
                templateId={prop.schema_id}
                level={level}
                fragmentId={fragmentId}
              ></ModalTemplate>,
            );
          }

          if (prop.class === 'Contributor') {
            // console.log("TODO : condition funder à voir");
            data.push(
              <SelectInvestigator
                key={key}
                label={label}
                propName={key}
                changeValue={changeValue}
                dmpId={dmpId}
                templateId={prop.schema_id}
                level={level}
                tooltip={tooltip}
                fragmentId={fragmentId}
              ></SelectInvestigator>,
            );
          }
        }
        // codition 3.2
        if (prop.inputType === 'dropdown') {
          if (Object.prototype.hasOwnProperty.call(prop, 'registry_id')) {
            data.push(
              <SelectSingleList
                key={key}
                registryId={prop.registry_id}
                label={label}
                propName={key}
                changeValue={changeValue}
                tooltip={tooltip}
                level={level}
                fragmentId={fragmentId}
                registryType="complex"
              ></SelectSingleList>,
            );
          }
        }
      }
    }
  }
  return data;
}

HandleGenerateForms.propTypes = {
  level: PropTypes.number,
  shemaObject: PropTypes.object,
  changeValue: PropTypes.func,
  fragmentId: PropTypes.number,
};

export default HandleGenerateForms;
