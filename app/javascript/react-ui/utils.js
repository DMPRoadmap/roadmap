import {TEST_TOKEN_2} from './tmp.js';

export const API_BASE_URL = "https://api.dmphub-dev.cdlib.org";


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
  headers.append('Content-Type', "x-www-form-urlencoded");
  headers.append('Accept', "application/json");
  // headers.append('Credentials', 'omit');

  // TODO::FIXME:: We are hard-coding this token for now. The token
  // authentication mighth change for this app, so for the time being the
  // hard-coded token is just used for quick testing.
  headers.append('Authorization', `Bearer ${TEST_TOKEN_2}`);

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
