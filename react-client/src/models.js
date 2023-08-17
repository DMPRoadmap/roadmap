import { getValue, setProperty } from './utils.js';
import { DmpApi } from "./api.js";
import moment from 'moment';


class Model {
  #data;

  constructor(data) {
    this.#data = data;
  }

  getData(path, defaultNone) {
    if (typeof path === 'undefined') return this.#data;
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

  get role() { return this.getData("role.0", ""); }
  set role(val) { this.setData("name", val); }

  get id() { return this.getData("contact_id", {}); }
  set id(val) { this.setData("contact_id", val); }
}


export class Contributor extends Model {
  #first_name;
  #last_name;

  constructor(data) {
    super(data);
    this.affiliation = new RoadmapAffiliation(this.getData("dmproadmap_affiliation"));
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

  get roles() { return this.getData("role"); }
  get role() { return this.getData("role.0", ""); }
  get roleDisplay() { return getRoleDisplay(this.role); }

  commit() {
    this.setData("dmproadmap_affiliation", this.affiliation.getData());
  }
}


export class RoadmapAffiliation extends Model {
  get name() { return this.getData("name"); }
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


export class DmpModel extends Model {
  #_contributors;

  constructor(data) {
    super(data);

    this.project = new Project(this.getData("project.0", {}));
    this.funding = this.project.funding;
    this.contact = new Contact(this.getData("contact.0", {}));
    this.contributors = this.getData("contributor", []);
  }

  get title() { return this.getData("title"); }
  set title(val) { this.setData("title", val); }

  get draftId() { return this.getData("draft_id.identifier"); }

  get hasFunder() { return (this.project.funding !== null); }

  get contributors() { return this.#_contributors; }
  set contributors(items) { this.#_contributors = new ModelSet(Contributor, items); }

  /* NOTE
   * Draft data is a special temporary place in the data structure
   * that the backend _wont use_, but that we can use to keep track of
   * state across request, pages and sessions etc.
   *
   * The methods below allows access to the draft data
   **/
  setDraftData(path, data) {
    let dataPath = `draft_data.${path}`;
    this.setData(dataPath, data);
  }

  getDraftData(path) {
    if (typeof path === 'undefined') return this.getData("draft_data", {});
    let dataPath = `draft_data.${path}`;
    return this.getData(dataPath);
  }

  commit() {
    this.project.commit();
    this.contributors.commit();

    this.setData("project", [this.project.getData()]);
    this.setData("contact", [this.contact.getData()]);

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


export async function getContributorRoles() {
  let api = new DmpApi();

  const resp = await fetch(api.getPath("contributor_roles"));
  api.handleResponse(resp);
  const data = await resp.json();

  // Cache this on the document, this way we can refer back to it later.
  // (see "getRoleDisplay" below).
  // This allows us to use this *dynamic list of roles*, without needing to
  // make repeat HTTP fetches.
  document.contributorRoles = data.items;
  return data.items;
}


export function getRoleDisplay(roleVal) {
  if (roleVal === "") return "";
  if (document.contributorRoles) {
    let result = document.contributorRoles.find(r => r.value === roleVal);
    if (result) return result.label;
  } else {
    getContributorRoles().then((roles) => {
      let result = roles.find(r => r.value === roleVal);
      if (result) return result.label;
    });
  }
  throw new Error(`Invalid role, ${roleVal}`);
  return "";
}
