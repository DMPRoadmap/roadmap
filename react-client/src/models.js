import { getValue } from './utils.js';


class Model {
  #data;

  constructor(data) {
    this.#data = data;
  }

  getValue(path, defaultNone) {
    return getValue(this.#data, path, defaultNone);
  }
}


export class Contact extends Model {
  get name() { this.getValue("name"); }
  get role() { this.getValue("role.0", ""); }
  get id() { this.getValue("contact_id", {}); }
}


export class RoadmapAffiliation extends Model {
  get name() { this.getValue("name"); }
  get id() { this.getValue("affiliation_id", {}); }
}


export class Contributor extends Model {
  get name() { this.getValue("name"); }
  get role() { this.getValue("role.0", ""); }
  get id() { this.getValue("contributor_id", {}); }
}


export class Funding extends Model {
  get grantId() { this.getValue("grant_id", {}); }
  get funderId() { this.getValue("funder_id", {}); }
  get status() { this.getValue("funding_status", "planned"); }
  get opportunityNumber() { this.getValue("dmproadmap_opportunity_number", ""); }
}


export class Project extends Model {
  constructor(data) {
    super(data);
    this.funding = new Funding(this.getValue("funding.0", null));
  }

  get title() { return this.getValue("title"); }
  get description() { return this.getValue("description", ""); }
  get start() { return this.getValue("start"); }
  get end() { return this.getValue("end"); }
}


export class DmpModel extends Model {
  constructor(data) {
    super(data);
    this.project = new Project(this.getValue("project.0", null));
  }

  get title() { return this.getValue("title"); }
  get funding() { return this.project.funding; }
}
