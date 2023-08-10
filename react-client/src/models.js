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


export class Contact extends Model {
  get name() { return this.getData("name"); }
  set name(val) { this.setData("name", val); }

  get role() { return this.getData("role.0", ""); }
  set role(val) { this.setData("name", val); }

  get id() { return this.getData("contact_id", {}); }
  set id(val) { this.setData("contact_id", val); }
}


export class RoadmapAffiliation extends Model {
  get name() { return this.getData("name"); }
  set name(val) { this.setData("name", val); }

  get id() { return this.getData("affiliation_id", {}); }
  set id(val) { this.setData("affiliation_id", val); }
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
  project;
  contact;

  constructor(data) {
    super(data);

    this.project = new Project(this.getData("project.0", {}));
    this.funding = this.project.funding;
    this.contact = new Contact(this.getData("contact.0", {}));
  }

  get title() { return this.getData("title"); }
  set title(val) { this.setData("title", val); }

  get draftId() { return this.getData("draft_id.identifier"); }

  get conrtibutors() { return this.getData("contributor"); }
  set contributors(val) { this.setData("contributor"); }

  get hasFunder() { return (this.project.funding !== null); }

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
    this.setData("project", [this.project.getData()]);
    this.setData("contact", [this.contact.getData()]);
  }
}


export async function getDraftDmp(dmpId) {
  let api = new DmpApi();

  const resp = await fetch(api.getPath(`/drafts/${dmpId}`));
  api.handleResponse(resp);
  const data = await resp.json();

  return new DmpModel(data.items[0].dmp);
}
