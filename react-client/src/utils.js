export const API_BASE_URL = 'http://localhost:3000/api/v3/'

export function api_path(endpoint, queryParams) {
  if (queryParams) {
    const esc = encodeURIComponent;
    endpoint += (endpoint.indexOf('?') === -1 ? '?' : '&') + Object
      .keys(queryParams)
      .map(k => esc(k) + '=' + esc(queryParams[k]))
      .join('&');
  }
  return new URL(endpoint, API_BASE_URL);
}

export function api_headers(extra_headers) {
  // NOTE: This just creates "common" headers required for the API.
  // The returned headers object can be customized further if needed by the
  // caller.
  let headers = new Headers();
  headers.append('Content-Type', "application/x-www-form-urlencoded");
  headers.append('Accept', "application/json");
  return headers;
}

export function api_options(options) {
  let _options = Object.assign({
    method: 'get',
    mode: 'cors',
    cache: 'no-cache',
  }, options);

  return _options;
}


// Quick API function calls
