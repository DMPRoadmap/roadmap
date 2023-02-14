import axios from "axios";

// export async function getRegistry(t, token) {
//   try {
//     const response = await axios.get("https://api.publicapis.org/entries", {
//       withCredentials: true,
//       xsrfHeaderName: "X-XSRF-TOKEN",
//       headers: {
//         Bearer: `${token}`,
//       },
//     });
//     const result = require(`../data/registres/${t}.json`);
//     return result[t];
//   } catch (error) {
//     console.error(error);
//   }
// }

export async function getSchema(t, token) {
  try {
    const response = await axios.get("https://api.publicapis.org/entries");
    return require(`../data/templates/${t}-template.json`);
  } catch (error) {
    console.error(error);
  }
}

export async function getRegistryValue(t, token) {
  try {
    const response = await axios.get("https://api.publicapis.org/entries");
    const result = require(`../data/templates/registry_values.json`);
    return result[t];
  } catch (error) {
    console.error(error);
  }
}

export async function getRegistry(t, token) {
  try {
    const response = await axios.get("https://api.publicapis.org/entries");
    const result = require(`../data/registres/${t}.json`);
    return result[t];
  } catch (error) {
    console.error(error);
  }
}

/**
 * It sends a POST request to the server with the jsonObject as the body of the request.
 * </code>
 * @param jsonObject - the data you want to send to the server
 * @returns The response object from the server.
 */
export async function sendData(jsonObject) {
  try {
    const response = await axios.post("api_url", jsonObject, "config");
    console.log(response);
    //toast.success("Congé ajouter");
    return response;
  } catch (error) {
    if (error.response) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx
      //toast.error("error server");
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
      console.log("Error", error.message);
    }
    console.log(error.config);
    return error;
  }
}
