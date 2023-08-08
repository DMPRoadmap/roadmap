import { getValue, setProperty } from './utils.js';
import { DmpApi } from "./api.js";
// import moment from 'moment';


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

  constructor(data) {
    super(data);
    // TODO:: We should "pop" the "funding" key from the original "data" map.
    this.funding = new Funding(this.getData("funding.0", null));
  }

  get title() { return this.getData("title"); }
  set title(val) { this.setData("title", val); }

  get description() { return this.getData("description", ""); }
  set description(val) { this.setData("description", val); }

  // TODO::FIXME:: Work with real date objects
  // To do this we'll use moment.js to parse the objects (and we can use it
  // for other date/time related operatoins)
  // Update the getters and setters for both start and end dates to work
  // with real date types, and save the data in the string format expected
  // by the rails backend.
  get start() {
    return this.getData("start", "");
  }
  set start(dateVal) { this.setData("start", dateVal); }

  get end() { return this.getData("end", ""); }
  set end(dateVal) { this.setData("end", dateVal); }

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
