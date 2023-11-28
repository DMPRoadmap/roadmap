import {
  getValue,
  setProperty,
  formatBytes,
  convertToBytes,
  stripTags,
} from './utils.js';
import { DmpApi } from "./api.js";
import moment from 'moment';


class Model {
  #data;
  errors = new Map();

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

  validateFields() {
    // sub-classes should use this.errors.set() to set errors
    throw new Error("validateFields not implemented for model");
  }

  isValid() {
    this.errors = new Map();
    this.validateFields();
    if (this.errors.size > 0) { return false; }
    return true;
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

  remove(index) {
    this.items.splice(index, 1);
  }

  commit() {
    if (this.items) this.items.forEach(i => i.commit());
  }
}


export class Contact extends Model {
  constructor(data) {
    super(data);
  }

  get name() { return this.getData("name", ""); }
  set name(val) { this.setData("name", val); }

  get mbox() { return this.getData("mbox", ""); }
  set mbox(val) { this.setData("mbox", val); }

  get id() { return this.getData("contributor_id.identifier"); }
  get idType() { return this.getData("contributor_id.type", "orcid"); }
}


export class Contributor extends Contact {
  constructor(data) {
    super(data);
    this.affiliation = new RoadmapAffiliation(this.getData("dmproadmap_affiliation", {}));
  }

  get roles() { return this.getData("role", []); }
  set roles(arr) { this.setData("role", arr); }
  get roleDisplays() { return this.roles.map(r => getRoleDisplay(r)); }

  addRole(val) {
    if (this.roles.includes(val)) return;
    let roles = this.roles;
    roles.push(val);
    this.roles = roles;
  }

  hasRole(role) {
    return this.roles.includes(role);
  }

  removeRole(val) {
    this.roles = this.roles.filter(i => i !== val);
  }

  get contact() { return this.getData("contact", false); }
  set contact(val) { this.setData("contact", val); }

  validateFields() {
    if (!this.name) {
      this.errors.set("name", "Name is required");
    }

    if (this.contact) {
      if (!this.mbox)
        this.errors.set("mbox", "Primary contact must have an email.");

      if (!this.affiliation.name)
        this.errors.set("affiliation", "Primary contact must have an affiliation.");
    }

    if (this.roles.length === 0) {
      this.errors.set("role", "Please select at least one role.");
    }
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

  get funderId() { return this.getData("funder_id", null); }
  set funderId(val) { this.setData("funder_id", val); }

  get status() { return this.getData("funding_status", "planned"); }
  set status(val) { this.setData("funding_status", val); }

  get grantId() { return this.getData("grant_id", {}); }
  set grantId(val) { this.setData("grant_id", val); }

  get opportunityNumber() { return this.getData("dmproadmap_opportunity_number", ""); }
  set opportunityNumber(val) { this.setData("dmproadmap_opportunity_number", val); }

  get projectNumber() { return this.getData("dmproadmap_project_number", ""); }
  set projectNumber(val) { this.setData("dmproadmap_project_number", val); }

  getStatus() {
    let status = ["notstart", "Not Started"];

    if ((this.name && this.funderId) || this.name === "None")
      status = ["completed", "Completed"];
    return status;
  }
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

  validateFields() {
    if (!this.title)
      this.errors.set("name", "Project name is required")
  }

  getStatus() {
    let status = ["notstart", "Not Started"];
    if (this.title && this.start)
      status = ["completed", "Completed"];
    return status;
  }

  commit() {
    this.setData("funding", [this.funding.getData()]);
  }
}


export class DataObject extends Model {
  constructor(data) {
    super(data);
    this.repository = new DataRepository(this.getData("distribution.0", {}));
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

  validateFields() {
    if (!this.title) this.errors.set("title", "Title is required");
    if (!this.type || this.type.toLowerCase() == "select one")
      this.errors.set("type", "Type is required");

    if (!this.repository.url)
      this.errors.set("repo", "Repository url is required");
  }

  commit() {
    this.setData("distribution.0", this.repository.getData());
  }
}


export class DataRepository extends Model {
  #_size;

  set host(hostData) {
    // NOTE:: The lookup data returns the repository name as "name",
    // but the DMP saves the repo name as "title". So we do some manual
    // work here
    if (hostData.hasOwnProperty('name')) {
      hostData['title'] = hostData['name'];
      delete hostData['name'];
    }
    this.setData("host", hostData);
  }

  get title() { return this.getData("host.title", ""); }
  set title(val) { this.setData("host.title", val); }

  get url() { return this.getData("host.url", ""); }
  set url(val) { this.setData("host.url", val); }

  get description() { return this.getData("host.description", ""); }
  set description(val) { this.setData("host.description", val); }

  get repoId() { return this.getData("host.dmproadmap_host_id.identifier", ""); }

  /* Returns a map containing the value and unit */
  get size() {
    if (!this.#_size) {
      let val = this.getData("byte_size", 0);
      if (typeof val === "string") {
        val = Math.floor(parseFloat(val));
      }
      this.#_size = formatBytes(val, 2);
    }
    return this.#_size;
  }

  setSize(value, unit) {
    if (typeof unit === "undefined") {
      throw Error("Cannot call setSize with undefined units");
    }
    this.setData("byte_size", convertToBytes(value, unit));
  }

  get isLocked() {
    if (this.repoId === "") {
      return false;
    } else {
      return true;
    }
  }
}


export class RelatedWork extends Model {
  #_modRun;  // This is a reference to the modification run object.

  get modrun() { return this.#_modRun; }
  set modrun(modInstance) {
    if (modInstance instanceof Modification) {
      this.#_modRun = modInstance;
    } else {
      throw new Error("Invalid instance for related works modifier run");
    }
  }

  get dateFound() {
    if (this.#_modRun && this.#_modRun instanceof Modification)
      return this.#_modRun.dateFound;
    return null;
  }

  get provenance() {
    if (this.#_modRun && this.#_modRun instanceof Modification)
      return this.#_modRun.provenance;
    return null;
  }

  get doi() { return this.getData("identifier", ""); }

  get citation() { return stripTags(this.getData("citation", "")); }

  get confidence() { return this.getData("confidence", ""); }

  get descriptor() { return this.getData("descriptor", ""); }

  get notes() { return this.getData("notes", []); }

  get confidenceReason() { return this.notes.join(', '); }

  get score() { return this.getData("score", 0); }

  get status() { return this.getData("status", "pending"); }
  set status(val) { this.setData("status", val); }
  // pending, approved, rejected

  get type() { return this.getData("type", ""); }

  get workType() { return this.getData("work_type", ""); }
}


export class Modification extends Model {
  #_relatedWorks;

  constructor(data) {
    super(data);
    this.relatedWorks = this.getData("dmproadmap_related_identifiers", []);
  }

  get dateFound() {
    let date = moment(this.getData("timestamp"));
    if (!date.isValid()) return false;
    return moment(this.getData("timestamp")).format('MM-DD-YYYY');
  }

  get relatedWorks() { return this.#_relatedWorks; }
  set relatedWorks(items) {
    this.#_relatedWorks = new ModelSet(RelatedWork, items);

    // Also add a reference to the modification object so that every related
    // work have access to fields like provenance, dateFound etc.
    this.#_relatedWorks.items.forEach(rw => rw.modrun = this);
  }

  get provenance() { return this.getData("provenance", null); }

  hasRelatedWorks() {
    return (this.relatedWorks.items.length > 0);
  }

  commit() {
    this.setData("dmproadmap_related_identifiers", this.relatedWorks.getData());
  }
}


export class DmpModel extends Model {
  #_contributors;
  #_dataset;
  #_modifications;
  #_relatedWorks;

  constructor(data) {
    super(data);

    this.project = new Project(this.getData("project.0", {}));
    this.funding = this.project.funding;
    this.contact = new Contact(this.getData("contact.0", {}));
    this.contributors = this.getData("contributor", []);
    this.dataset = this.getData("dataset", []);
    this.modifications = this.getData("dmphub_modifications", []);

    // Not to be confused with the same field inside the Modifiers.
    // This one here is for the related works that were accepted as related,
    // and added to the DMP directly
    this.relatedWorks = this.getData("dmproadmap_related_identifiers", []);
  }

  get title() { return this.getData("title"); }
  set title(val) { this.setData("title", val); }

  get modified() {
    let date = moment(this.getData("modified"))
    if (!date.isValid()) {
      return false;
    }
    return moment(this.getData("modified")).format('MM-DD-YYYY');
  }
  set modified(val) { this.setData("modified", val); }

  get created() {
    let date = moment(this.getData("created"))
    if (!date.isValid()) {
      return false;
    }
    return moment(this.getData("created")).format('MM-DD-YYYY');
  }
  set created(val) { this.setData("created", val); }


  get draftId() { return this.getData("draft_id.identifier", null); }
  get id() {
    if (this.draftId) return this.draftId;

    let uri = this.getData("dmp_id.identifier", null);
    if (!uri) return null;

    // return encodeURIComponent(idpath.hostname + idpath.pathname);
    // NOTE: We will use a custom URI encoder for the ID here. Reason? If we use
    // encodeURIComponent then the browser and other third partly libraries
    // makes too many assumptions about what we use this for. In some cases
    // third party libs will try to decode the URI when it shouldn't
    // By using our own, we avoid debugging cases like this.
    let idpath = new URL(uri);
    let idStr = idpath.hostname + idpath.pathname;
    return idStr.replace(/\//g, "_");
  }

  get hasFunder() {
    if (this.project.funding.name === "None") return false;
    if (this.project.funding.name && this.funding.funderId) return true;
    return false;
  }

  get funderApi() {
    return this.getDraftData("funder.funder_api", null);
  }

  // Modelsets
  get contributors() { return this.#_contributors; }
  set contributors(items) { this.#_contributors = new ModelSet(Contributor, items); }

  get dataset() { return this.#_dataset; }
  set dataset(items) { this.#_dataset = new ModelSet(DataObject, items); }

  get modifications() { return this.#_modifications; }
  set modifications(items) { this.#_modifications = new ModelSet(Modification, items); }

  hasRelatedWorks() {
    return this.modifications.items.some(i => i.hasRelatedWorks());
  }

  get relatedWorks() { return this.#_relatedWorks; }
  set relatedWorks(items) { this.#_relatedWorks = new ModelSet(RelatedWork, items); }

  get stepStatus() {
    let setupStatus = ["notstart", "Not Started"];
    if (this.title) setupStatus = ["completed", "Completed"];

    let contributorStatus = ["recommended", "Recommended"];
    if (this.contributors.items.length > 0) {
      let contributorStatus = ["completed", "Recommended"];
      /*
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
      */
    }

    let outputsStatus = ["recommended", "Recommended"];
    if (this.dataset.items.length > 0) {
      let outputsStatus = ["completed", "Recommended"];
      /*
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
      */
    }

    let relatedStatus;
    let relatedCount = 0;
    this.modifications.items.forEach((mod) => {
      let pending = mod.relatedWorks.items.filter((rw) => rw.status === "pending");
      relatedCount += pending.length;
    });
    if (relatedCount === 0) {
      relatedStatus = ["completed", `${relatedCount} Items Pending`];
    } else {
      relatedStatus = ["recommended", `${relatedCount} Items Pending`];
    }

    return {
      setup: setupStatus,
      funders: this.funding.getStatus(),
      project: this.project.getStatus(),
      contributors: contributorStatus,
      outputs: outputsStatus,
      related: relatedStatus,
    };
  }

  get status() {
    if (this.isRegistered) return ["registered", "Registered"];
    return ["incomplete", "Incomplete"];
  }

  get privacy() { return this.getData("dmproadmap_privacy", "private"); }
  set privacy(val) { return this.setData("dmproadmap_privacy", val); }

  get isPrivate() { return (this.privacy === "private"); }

  get isRegistered() {
    if (!this.draftId) return true;
    return false
  }

  get narrative() {
    if (this.isRegistered) {
      let rel = this.getData("dmproadmap_related_identifiers", []);
      if (rel.length == 0) return null;

      let pdf = rel.find(i => {
        if (!(i.work_type || i.descriptor)) return false;
        return (
          i.work_type == "output_management_plan" &&
          i.descriptor == "is_metadata_for"
        );
      });
      pdf.file_name = pdf.identifier.split('/').pop();
      return pdf;
    } else {
      return this.getDraftData("narrative", null);
    }
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

  validateFields() {
    let contact = this.contributors.items.find(c => c.contact);
    if (contact) {
      if (!contact.isValid()) {
        contact.errors.forEach((v, k) => {
          this.errors.set("contributors", v);
        });
      }
    } else {
      this.errors.set(
        "contributors",
        "You must have a primary contact in your contributors. Please select one before registering your DMP"
      );
    }

    if (!this.project.title)
      this.errors.set("project", "Project name is required");
  }

  commit() {
    this.setData("project", [this.project.getData()]);
    this.setData("dataset", this.dataset.getData());

    // NOTE: Even though the data for this can be many contributors, the key
    // in the backend data just reads as singular "contributor"
    this.setData("contributor", this.contributors.getData());

    this.setData("dmphub_modifications", this.modifications.getData());
    this.setData("dmproadmap_related_identifiers", this.relatedWorks.getData());
  }
}

export function decodeId(id) {
  return id.replace(/_/g, "/");
}

export async function getDmp(dmpId) {
  let api = new DmpApi();

  let prefix = "drafts";
  let id = decodeId(dmpId);
  if (id !== dmpId) {
    prefix = "dmps";
  }

  const resp = await fetch(api.getPath(`/${prefix}/${id}`));
  api.handleResponse(resp);
  const data = await resp.json();

  if (data.items.length == 0)
    throw Error("DMP Not Found");
  return new DmpModel(data.items[0].dmp);
}


export async function saveDmp(dmp) {
  // Ensure nested dmp data was comitted before continuing
  dmp.commit();

  let api = new DmpApi();
  let options = api.getOptions({
    method: "put",
    body: JSON.stringify({ dmp: dmp.getData() }),
  });

  let prefix = "drafts";
  let id = decodeId(dmp.id);
  if (id !== dmp.id) {
    prefix = "dmps";
  }

  const resp = await fetch(api.getPath(`/${prefix}/${encodeURIComponent(id)}`), options);
  api.handleResponse(resp);
  const data = await resp.json();

  return new DmpModel(data.items[0].dmp);
}


export async function registerDmp(dmp) {
  if (dmp.isRegistered) {
    throw new Error("DMP already registered");
  }

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
  if (document._outputTypes && typeVal !== "")
    return document._outputTypes[typeVal];
  return "";
}


export async function getRelatedWorkTypes(forceUpdate) {
  // We Cache the results on the document to reduce traffic, but allow for
  // a forced update if needed.
  if (!document._relatedWorkTypes || forceUpdate) {
    let api = new DmpApi();
    const resp = await fetch(api.getPath("related_work_types"));
    api.handleResponse(resp);
    const data = await resp.json();

    document._relatedWorkTypes = {};
    if (data.items) {
      data.items.forEach(item => {
        document._relatedWorkTypes[item.value] = item.label;
      })
    }
  }

  return document._relatedWorkTypes;
}


export function getRelatedWorkTypeDisplay(val) {
  if (document._relatedWorkTypes && val !== "")
    return document._relatedWorkTypes[val];
  return "";
}
