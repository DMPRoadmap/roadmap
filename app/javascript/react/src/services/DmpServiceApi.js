import axios from 'axios';
import toast from 'react-hot-toast';

function createHeaders(csrf = null) {
  if (csrf) {
    return {
      headers: {
        'X-CSRF-Token': csrf,
        'Content-Type': 'application/json',
      },
    };
  }

  return {
    headers: {
      'Content-Type': 'application/json',
    },
  };
}

export async function getFragment(id) {
  let response;
  try {
    response = await axios.get(`/madmp_fragments/${id}`, createHeaders());
  } catch (error) {
    console.error(error);
    return error;
  }
  return response;
}

export async function getSchema(id) {
  let response;
  try {
    response = await axios.get(`/madmp_schemas/${id}`, createHeaders());
  } catch (error) {
    console.error(error);
    return error;
  }
  return response;
}

export async function getRegistry(id) {
  let response;
  try {
    response = await axios.get(`/registries/${id}`, createHeaders());
  } catch (error) {
    console.error(error);
    return error;
  }
  return response;
}

export async function getContributors(dmpId, templateId) {
  let response;
  try {
    response = await axios.get(`/madmp_fragments/load_fragments?dmp_id=${dmpId}&schema_id=${templateId}`, createHeaders());
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
export async function saveForm(id, jsonObject) {
  let response;
  const csrf = document.querySelector('meta[name="csrf-token"]').content;
  try {
    response = await axios.post(`/madmp_fragments/update_json/${id}`, jsonObject, createHeaders(csrf));
  } catch (error) {
    if (error.response) {
      toast.error(error.response.message);
    } else if (error.request) {
      toast.error(error.request);
    } else {
      toast.error(error.message);
    }
  }
  return response;
}
