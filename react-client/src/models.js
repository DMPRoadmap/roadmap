import { getValue, setProperty } from './utils.js';
import { DmpApi } from "./api.js";


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
  get name() { this.getData("name"); }
  get role() { this.getData("role.0", ""); }
  get id() { this.getData("contact_id", {}); }
}


export class RoadmapAffiliation extends Model {
  get name() { this.getData("name"); }
  get id() { this.getData("affiliation_id", {}); }
}


export class Contributor extends Model {
  get name() { this.getData("name"); }
  get role() { this.getData("role.0", ""); }
  get id() { this.getData("contributor_id", {}); }
}


export class Funding extends Model {
  get name() { return this.getData("name", ""); }
  get grantId() { return this.getData("grant_id", {}); }
  get funderId() { return this.getData("funder_id", {}); }
  get status() { return this.getData("funding_status", "planned"); }
  get opportunityNumber() { return this.getData("dmproadmap_opportunity_number", ""); }
}


export class Project extends Model {
  funding;

  constructor(data) {
    super(data);
    // TODO:: We should "pop" the "funding" key from the original "data" map.
    this.funding = new Funding(this.getData("funding.0", null));
  }

  get title() { return this.getData("title"); }
  get description() { return this.getData("description", ""); }
  get start() { return this.getData("start"); }
  get end() { return this.getData("end"); }

  commit() {
    this.setData("funding", [this.funding.getData()]);
  }
}


export class DmpModel extends Model {
  project;
  contact;
  contributor;

  constructor(data) {
    super(data);
    this.project = new Project(this.getData("project.0", {}));
    this.contact = new Contact(this.getData("contact.0", {}));
    this.contributor = new Contributor(this.getData("contributor.0", {}));
  }

  get title() { return this.getData("title"); }
  get funding() { return this.project.funding; }
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
    this.setData("contributor", [this.contributor.getData()]);
  }
}


export async function getDraftDmp(dmpId) {
  let api = new DmpApi();

  const resp = await fetch(api.getPath(`/drafts/${dmpId}`));
  api.handleResponse(resp);
  const data = await resp.json();

  return new DmpModel(data.items[0].dmp);
}
