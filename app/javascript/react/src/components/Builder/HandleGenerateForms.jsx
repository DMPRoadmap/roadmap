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
    for (const [key, value] of Object.entries(properties)) {
      const label = value[`form_label@${locale}`];
      const tooltip = value[`tooltip@${locale}`];
      const isConst = Object.prototype.hasOwnProperty.call(value, `const@${locale}`) ? value[`const@${locale}`] : false;
      // condition 1
      if (value.type === 'string' || value.type === 'number') {
        // Condition 1.1
        // si inputType === textarea

        if (value.inputType === 'textarea') {
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
          value.inputType === 'dropdown'
          && Object.prototype.hasOwnProperty.call(value, 'registry_id')
        ) {
          data.push(
            <SelectSingleList
              key={key}
              label={label}
              propName={key}
              registryId={value.registry_id}
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

        if (!Object.prototype.hasOwnProperty.call(value, 'inputType')) {
          data.push(
            <InputText
              key={key}
              label={label}
              type={value.format ? value.format : value.type}
              placeholder={''}
              isSmall={false}
              smallText={''}
              propName={key}
              changeValue={changeValue}
              hidden={value.hidden ? true : false}
              tooltip={tooltip}
              isConst={isConst}
              fragmentId={fragmentId}
            ></InputText>,
          );
        }
      }
      // condition 2
      if (value.type === 'array') {
        // condition 2.1
        // si inputType === dropdown et on n'a pas de registry_name
        if (
          value.inputType === 'dropdown'
          && Object.prototype.hasOwnProperty.call(value, 'registry_id')
        ) {
          if (value.items.schema_id) {
            data.push(
              <SelectWithCreate
                key={key}
                label={label}
                propName={key}
                registryId={value.registry_id}
                changeValue={changeValue}
                templateId={value.items.schema_id}
                level={level}
                header={value[`table_header@${locale}`]}
                fragmentId={fragmentId}
              ></SelectWithCreate>,
            );
          } else {
            data.push(
              <SelectMultipleList
                key={key}
                label={label}
                propName={key}
                registryId={value.registry_id}
                changeValue={changeValue}
                tooltip={tooltip}
                level={level}
                fragmentId={fragmentId}
              ></SelectMultipleList>,
            );
          }
        } else {
          // si on a type === array et items.type === object
          if (value.items.type === 'object') {
            if (key === 'contributor' && value.items.class === 'Contributor') {
              data.push(
                <SelectContributor
                  key={key}
                  label={label}
                  propName={key}
                  changeValue={changeValue}
                  templateId={value.items.schema_id}
                  level={level}
                  tooltip={tooltip}
                  header={value[`table_header@${locale}`]}
                  fragmentId={fragmentId}
                ></SelectContributor>,
              );
            } else {
              data.push(
                <ModalTemplate
                  key={key}
                  propName={key}
                  tooltip={tooltip}
                  value={value}
                  templateId={value.items.schema_id}
                  level={level}
                  header={value[`table_header@${locale}`]}
                  fragmentId={fragmentId}
                ></ModalTemplate>,
              );
            }
          }
          if (value.items.type === 'string') {
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
      if (value.type === 'object') {
        // condition 3.1

        if (Object.prototype.hasOwnProperty.call(value, 'schema_id')) {
          // console.log(" Sous fragment unique (sous formulaire)");
          if (value.inputType === 'pickOrCreate') {
            data.push(
              <ModalTemplate
                key={key}
                propName={key}
                tooltip={tooltip}
                value={value}
                templateId={value.schema_id}
                level={level}
                fragmentId={fragmentId}
              ></ModalTemplate>,
            );
          }

          if (value.class === 'Contributor') {
            // console.log("TODO : condition funder à voir");
            data.push(
              <SelectInvestigator
                key={key}
                label={label}
                propName={key}
                changeValue={changeValue}
                dmpId={dmpId}
                templateId={value.schema_id}
                level={level}
                tooltip={tooltip}
                fragmentId={fragmentId}
              ></SelectInvestigator>,
            );
          }
        }
        // codition 3.2
        if (value.inputType === 'dropdown') {
          if (Object.prototype.hasOwnProperty.call(value, 'registry_id')) {
            data.push(
              <SelectSingleList
                key={key}
                registryId={value.registry_id}
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
