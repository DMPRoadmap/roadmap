class APIResponseError extends Error {
  constructor(msg, resp) {
    super(msg);
    this.name = "API Response Error";
    this.msg = msg;
    this.resp = resp;
  }
}

export class DmpApi {
  get baseUrl() {
    return `${window.location.origin}/api/v3`;
  }

  getPath(endpoint, queryParams) {
    if (endpoint.charAt(0) !== "/") {
      endpoint = "/" + endpoint;
    }

    let url = new URL(this.baseUrl + endpoint, this.baseUrl);

    if (queryParams) {
      let query = new URLSearchParams(queryParams);
      url.search = query.toString();
    }

    return url;
  }

  getFullPath(path, queryParams) {
    let url;
    try {
      url = new URL(path);
    } catch (err) {
      throw new Error(`Invalid url arguments: ${path}`);
    }

    if (queryParams) {
      let query = new URLSearchParams(queryParams);
      url.search = query.toString();
    }
    return url;
  }

  getHeaders() {
    // NOTE: This just creates "common" headers required for the API.
    // The returned headers object can be customized further if needed by the
    // caller.
    var headers = new Headers();
    headers.append("Content-Type", "application/json");
    headers.append("Accept", "application/json");
    return headers;
  }

  getOptions(options) {
    // NOTE: Returns common options required for every request. We can
    // still override any of them as required.
    let _headers = this.getHeaders();
    let _options = Object.assign(
      {
        method: "get",
        mode: "cors",
        cache: "no-cache",
        headers: _headers,
      },
      options
    );

    return _options;
  }

  /* Takes a file and returns a promise for the resulting DataURL
   * for the file
   */
  getFileDataURL(fileData) {
    return new Promise((resolve, reject) => {
      if (fileData.size == 0) {
        resolve("");
      }

      const reader = new FileReader();
      reader.onload = () => {
        resolve(reader.result);
      };
      reader.onerror = reject;
      reader.readAsDataURL(fileData);
    });
  }

  /* Use this method to deal with the API response. We'll mostly
   * use this to handle any required error logging, but we can add some
   * other common code here if needed.
   */
  handleResponse(resp) {
    if (resp.status >= 200 && resp.status < 400) return;
    // TODO:: Error handling
    // TODO:: Log and report errors to a logging services
    // TODO:: Message to display to the user?

    switch (resp.status) {
      case 404:
        throw new APIResponseError("Not Found", resp);
        break;

      default:
        throw new APIResponseError("General API Error", resp);
    }
  }
}