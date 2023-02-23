import axios from 'axios';

const xsrfConfig = (xsrf) => ({
  withCredentials: true,
  xsrfHeaderName: 'X-XSRF-TOKEN',
  headers: {
    Authorization: xsrf,
  },
});

export async function getFragment(id, xsrf) {
  let response;
  try {
    response = await axios.get(`/madmp_fragments/${id}`, xsrfConfig(xsrf));
  } catch (error) {
    console.error(error);
    return error;
  }
  return response;
}

export async function getSchema(id, xsrf) {
  let response;
  try {
    response = await axios.get(`/madmp_schemas/${id}`, xsrfConfig(xsrf));
  } catch (error) {
    console.error(error);
    return error;
  }
  return response;
}

export async function getRegistryValue(t, xsrf) {
  try {
    const response = await axios.get('https://api.publicapis.org/entries', xsrfConfig(xsrf));
    const result = require('../data/templates/registry_values.json');
    return result[t];
  } catch (error) {
    console.error(error);
    return error;
  }
}

export async function getRegistry(id, xsrf) {
  let response;
  try {
    response = await axios.get(`/registries/${id}`, xsrfConfig(xsrf));
  } catch (error) {
    console.error(error);
    return error;
  }
  return response;
}

export async function getContributors(dmpId, templateId, xsrf) {
  let response;
  try {
    response = await axios.get(`/madmp_fragments/load_fragments?dmp_id=${dmpId}&schema_id=${templateId}`, xsrfConfig(xsrf));
  } catch (error) {
    console.error(error);
    return error;
  }
  return response;
}

/**
 * It sends a POST request to the server with the jsonObject as the body of the request.
 * </code>
 * @param jsonObject - the data you want to send to the server
 * @returns The response object from the server.
 */
export async function sendData(jsonObject) {
  try {
    const response = await axios.post('api_url', jsonObject, 'config');
    // toast.success("Congé ajouter");
    return response;
  } catch (error) {
    if (error.response) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx
      // toast.error("error server");
      console.log(error.response.data);
      console.log(error.response.message);
      console.log(error.response.status);
      console.log(error.response.headers);
    } else if (error.request) {
      // The request was made but no response was received
      // `error.request` is an instance of XMLHttpRequest in the
      // browser and an instance of
      // http.ClientRequest in node.js
      // toast.error("error request");
      console.log(error.request);
    } else {
      // Something happened in setting up the request that triggered an Error
      console.log('Error', error.message);
    }
    console.log(error.config);
    return error;
  }
}
