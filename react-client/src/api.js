
export class DmpApi {
  get baseUrl() {
    return `${window.location.origin}/api/v3`;
  }

  getPath(endpoint, queryParams) {
    if (endpoint.charAt(0) !== '/') {
      endpoint = '/' + endpoint;
    }

    if (queryParams) {
      const esc = encodeURIComponent;
      endpoint += (endpoint.indexOf('?') === -1 ? '?' : '&') + Object
        .keys(queryParams)
        .map(k => esc(k) + '=' + esc(queryParams[k]))
        .join('&');
    }

    return new URL(this.baseUrl + endpoint, this.baseUrl);
  }

  getHeaders() {
    // NOTE: This just creates "common" headers required for the API.
    // The returned headers object can be customized further if needed by the
    // caller.
    let headers = new Headers();
    headers.append('Content-Type', "application/json");
    headers.append('Accept', "application/json");
    return headers;
  }

  getOptions(options) {
    // NOTE: Returns common options required for every request. We can
    // still override any of them as required.
    let _headers = this.getHeaders();
    let _options = Object.assign({
      method: 'get',
      mode: 'cors',
      cache: 'no-cache',
      headers: _headers,
    }, options);

    return _options;
  }

  /* Takes a file and returns a promise for the resulting DataURL
   * for the file
   */
  getFileDataURL(fileData) {
    return new Promise((resolve, reject) => {
      if (fileData.size == 0) { resolve(""); }

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
    switch (resp.status) {
      case 400:
      case 404:
        // TODO:: Error handling
        // TODO:: Log and report errors to a logging services
        // TODO:: Message to display to the user?
        console.log('Error fetching from API');
        console.log(resp);
        break;
    }
  }
}
