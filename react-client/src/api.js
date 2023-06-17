
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

  getHeaders(extra_headers) {
    // NOTE: This just creates "common" headers required for the API.
    // The returned headers object can be customized further if needed by the
    // caller.
    let headers = new Headers();
    headers.append('Content-Type', "application/x-www-form-urlencoded");
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
}
