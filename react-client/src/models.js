import { getValue, setProperty } from './utils.js';
import { DmpApi } from "./api.js";
import moment from 'moment';


class Model {
  #data;

  constructor(data) {
    this.#data = data;
  }

  getData(path, defaultNone) {
    if (typeof path === 'undefined') {
      if (this.commit) this.commit();
      return this.#data;
    }
    return getValue(this.#data, path, defaultNone);
  }

  setData(path, value) {
    this.#data = setProperty(this.#data, path, value);
  }
}


class ModelSet {
  #klass;

  constructor(klass, items = []) {
    this.#klass = klass;
    if (!items) items = [];
    this.items = items.map(i => new klass(i));
  }

  getData() {
    if (!this.items) return [];
    return this.items.map(i => i.getData());
  }

  get(index) {
    return this.items[index];
  }

  update(index, item) {
    if (item instanceof this.#klass) {
      this.items[index] = item;
    } else {
      throw new Error(`Cannot update modelset with ${item}. Modelset may only contain ${this.#klass} objects.`);
    }
  }

  add(item) {
    if (item instanceof this.#klass) {
      this.items.push(item);
    } else {
      throw new Error(`Cannot add ${item} to modelset. Modelset may only contain ${this.#klass} objects.`);
    }
  }

  commit() {
    if (this.items) this.items.forEach(i => i.commit());
  }
}


export class Contact extends Model {
  get name() { return this.getData("name"); }
  set name(val) { this.setData("name", val); }

  get roles() { return this.getData("role", []); }
  set roles(arr) { this.setData("role", arr); }
  get roleDisplays() { return this.roles.map(r => getRoleDisplay(r)); }

  addRole(val) {
    if (this.roleContains(val)) return;
    this.roles = this.roles.push(val);
  }

  removeRole(val) {
    this.roles = this.roles.filter(i => i !== val);
  }

  get id() { return this.getData("contact_id", {}); }
  set id(val) { this.setData("contact_id", val); }
}


export class Contributor extends Model {
  #first_name;
  #last_name;

  constructor(data) {
    super(data);
    this.affiliation = new RoadmapAffiliation(this.getData("dmproadmap_affiliation", {}));
    this.splitNames();
  }

  splitNames() {
    let names = this.name.split(',').map(i => i.trim());
    if (names.length >= 1) this.#first_name = names[0];
    this.#last_name = names.length == 2 ? names[1] : "";
  }

  get name() { return this.getData("name"); }
  set name(val) {
    this.setData("name", val);
    this.splitNames();
  }

  get first_name() { return this.#first_name; }
  get last_name() { return this.#last_name; }

  get mbox() { return this.getData("mbox", ""); }
  set mbox(val) { this.setData("mbox", val); }

  get id() { return this.getData("contributor_id.identifier"); }
  get idType() { return this.getData("contributor_id.type"); }

  get roles() { return this.getData("role", []); }
  set roles(arr) { this.setData("role", arr); }

  getRoleDisplays() { return this.roles.map(r => getRoleDisplay(r)); }

  addRole(val) {
    if (this.roles.includes(val)) return;
    this.roles.push(val);
  }

  removeRole(val) {
    this.roles = this.roles.filter(i => i !== val);
  }

  commit() {
    let affiliationData = this.affiliation.getData();
    if (affiliationData) {
      this.setData("dmproadmap_affiliation", affiliationData);
    }
  }
}


export class RoadmapAffiliation extends Model {
  get name() { return this.getData("name", ""); }
  set name(val) { this.setData("name", val); }

  get acronym() { return this.getData("acronym"); }

  get id() { return this.getData("affiliation_id.identifier"); }
  get idType() { return this.getData("affiliation_id.type"); }
}


export class Funding extends Model {
  get name() { return this.getData("name", ""); }
  set name(val) { this.setData("name", val); }

  get funderId() { return this.getData("funder_id", {}); }
  set funderId(val) { this.setData("funder_id", val); }

  get status() { return this.getData("funding_status", "planned"); }
  set status(val) { this.setData("funding_status", val); }

  get grantId() { return this.getData("grant_id", {}); }
  set grantId(val) { this.setData("grant_id", val); }

  get opportunityNumber() { return this.getData("dmproadmap_opportunity_number", ""); }
  set opportunityNumber(val) { this.setData("dmproadmap_opportunity_number", val); }

  get projectNumber() { return this.getData("dmproadmap_project_number", ""); }
  set projectNumber(val) { this.setData("dmproadmap_project_number", val); }
}


export class Project extends Model {
  funding;
  #startDate;
  #endDate;

  constructor(data) {
    super(data);

    this.funding = new Funding(this.getData("funding.0", null));
    this.setStart(this.getData("start", null));
    this.setEnd(this.getData("end", null));
  }

  get title() { return this.getData("title"); }
  set title(val) { this.setData("title", val); }

  get description() { return this.getData("description", ""); }
  set description(val) { this.setData("description", val); }

  get start() { return this.#startDate; }
  get end() { return this.#endDate; }

  setStart(dateStr, formatStr) {
    if (!dateStr) dateStr = "";

    if (formatStr) {
      this.#startDate = moment(dateStr, formatStr);
    } else {
      this.#startDate = moment(dateStr);
    }

    if (this.#startDate.isValid()) {
      this.setData("start", this.#startDate.format());
    } else {
      this.setData("start", "");
    }
  }

  setEnd(dateStr, formatStr) {
    if (!dateStr) dateStr = "";

    if (formatStr) {
      this.#endDate = moment(dateStr, formatStr);
    } else {
      this.#endDate = moment(dateStr);
    }

    if (this.#endDate.isValid()) {
      this.setData("end", this.#endDate.format());
    } else {
      this.setData("end", "")
    }
  }

  commit() {
    this.setData("funding", [this.funding.getData()]);
  }
}


export class DataObject extends Model {
  constructor(data) {
    super(data);

    this.repository = new DataRepository(this.getData("distribution.0.host", {}));
  }

  get title() { return this.getData("title", ""); }
  set title(val) { this.setData("title", val); }

  get type() { return this.getData("type", ""); }
  set type(val) { this.setData("type", val); }
  get typeDisplay() { return getOutputTypeDisplay(this.type); }

  get personal() { return this.getData("personal_data", "no"); }
  set personal(val) { this.setData("personal_data", val); }
  get isPersonal() { return (this.personal === "yes"); }

  get sensitive() { return this.getData("sensitive_data", "no"); }
  set sensitive(val) { this.setData("sensitive_data", val); }
  get isSensitive() { return (this.sensitive === "yes"); }

  commit() {
    this.setData("distribution", [{host: this.repository.getData()}]);
  }
}


export class DataRepository extends Model {
  get title() { return this.getData("title", ""); }
  set title(val) { this.setData("title", val); }

  get url() { return this.getData("url", ""); }
  set url(val) { this.setData("url", val); }

  get description() { return this.getData("description", ""); }
  set description(val) { this.setData("description", val); }

  get isLocked() {
    if (this.getData("dmproadmap_host_id.identifier", "") === "") {
      return false;
    } else {
      return true;
    }
  }
}


export class DmpModel extends Model {
  #_contributors;
  #_dataset;

  constructor(data) {
    super(data);

    this.project = new Project(this.getData("project.0", {}));
    this.funding = this.project.funding;
    this.contact = new Contact(this.getData("contact.0", {}));
    this.contributors = this.getData("contributor", []);
    this.dataset = this.getData("dataset", []);
  }

  get title() { return this.getData("title"); }
  set title(val) { this.setData("title", val); }

  get draftId() { return this.getData("draft_id.identifier"); }

  get hasFunder() {
    if (this.project.funding.name && this.project.funding.funderId) return true;
    return false;
  }

  // Modelsets
  get contributors() { return this.#_contributors; }
  set contributors(items) { this.#_contributors = new ModelSet(Contributor, items); }

  get dataset() { return this.#_dataset; }
  set dataset(items) { this.#_dataset = new ModelSet(DataObject, items); }

  get stepStatus() {
    let contributorStatus = ["recommended", "Recommended"];
    if (this.contributors.items.length > 0) {
      if (this.contributors.items.length == 1) {
        contributorStatus = [
          "completed",
          "1 Contributor"
        ];
      } else {
        contributorStatus = [
          "completed",
          this.contributors.items.length + " Contributors"
        ];
      }
    }

    let outputsStatus = ["recommended", "Recommended"];
    if (this.dataset.items.length > 0) {
      if (this.dataset.items.length == 1) {
        outputsStatus = [
          "completed",
          "1 Research Output",
        ];
      } else {
        outputsStatus = [
          "completed",
          this.dataset.items.length + " Research Outputs"
        ]
      }
    }

    return {
      setup: ["completed", "Completed"],
      funders: ["notstart", "Not Started"],
      project: ["notstart", "Not Started"],
      contributors: contributorStatus,
      outputs: outputsStatus,
    };
  }

  get status() {
    return ["incomplete", "Incomplete"];
  }

  get isPrivate() {
    // TODO:: Where to store this in the  DMP? I didn'e see it in the dummy data
    // For the time being we will store this in the draftdata
    return this.getDraftData("is_private", true);
  }

  /* NOTE
   * Draft data is a special temporary place in the data structure
   * that the backend _wont use_, but that we can use to keep track of
   * state across request, pages and sessions etc.
   *
   * The methods below allows access to the draft data
   **/
  setDraftData(path, data) {
    this.setData(`draft_data.${path}`, data);
  }

  getDraftData(path, defaultNone) {
    if (typeof path === 'undefined') return this.getData("draft_data", {});
    return this.getData(`draft_data.${path}`, defaultNone);
  }

  commit() {
    this.setData("project", [this.project.getData()]);
    this.setData("contact", [this.contact.getData()]);
    this.setData("dataset", this.dataset.getData());

    // NOTE: Even though the data for this can be many contributors, the key
    // in the backend data just reads as singular "contributor"
    this.setData("contributor", this.contributors.getData());
  }
}


export async function getDraftDmp(dmpId) {
  let api = new DmpApi();

  const resp = await fetch(api.getPath(`/drafts/${dmpId}`));
  api.handleResponse(resp);
  const data = await resp.json();

  return new DmpModel(data.items[0].dmp);
}


export async function saveDraftDmp(dmp) {
  // Ensure nested dmp data was comitted before continuing
  dmp.commit();

  let api = new DmpApi();
  let options = api.getOptions({
    method: "put",
    body: JSON.stringify({ dmp: dmp.getData() }),
  });

  const resp = await fetch(api.getPath(`/drafts/${dmp.draftId}`), options);
  api.handleResponse(resp);
  const data = await resp.json();

  return new DmpModel(data.items[0].dmp);
}


export async function registerDraftDmp(dmp) {
  console.log('DMP ID?');
  console.log(dmp.draftId);

  let api = new DmpApi();
  let options = api.getOptions({
    method: "post",
    body: JSON.stringify({ dmp: dmp.getData() }),
  });
  const resp = await fetch(api.getPath(`/dmps/`), options);
  api.handleResponse(resp);
  const data = await resp.json();

  return data;
}


export async function getOutputTypes(forceUpdate) {
  // We Cache the results on the document to reduce traffic, but allow for
  // a forced update if needed.
  if (!document._outputTypes || forceUpdate) {
    let api = new DmpApi();
    const resp = await fetch(api.getPath("output_types"));
    api.handleResponse(resp);
    const data = await resp.json();

    document._outputTypes = {};
    if (data.items) {
      data.items.forEach(item => {
        document._outputTypes[item.value] = item.label;
      })
    }
  }
  return document._outputTypes;
}


export function getOutputTypeDisplay(typeVal) {
  // Note make sure outputTypes is cached on the document before calling
  // this function.
  if (typeVal === "") return "";
  if (!document._outputTypes) return "";
  return document._outputTypes[typeVal] || "";
}


export async function getContributorRoles(forceUpdate) {
  // We Cache the results on the document to reduce traffic, but allow for
  // a forced update if needed.
  if (!document._contributorRoles || forceUpdate) {
    let api = new DmpApi();
    const resp = await fetch(api.getPath("contributor_roles"));
    api.handleResponse(resp);
    const data = await resp.json();

    document._contributorRoles = {};
    if (data.items) {
      document._contributorRoles = data.items;
    }
  }
  return document._contributorRoles;
}


export function getRoleDisplay(roleVal) {
  if (roleVal === "") return "";
  if (document._contributorRoles) {
    let result = document._contributorRoles.find(r => r.value === roleVal);
    if (result) return result.label;
  }
  return "";
}
