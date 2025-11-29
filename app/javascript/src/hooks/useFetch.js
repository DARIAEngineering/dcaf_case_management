const GET = "GET";
const POST = "POST";
const PUT = "PUT";
const PATCH = "PATCH";
const DEL = "DELETE";

const defaultHeaders = {
  "Content-Type": "application/json",
  Accept: "application/json",
};

async function fetchData({
  path,
  method,
  data,
  headers,
  onUnauthorized,
  onError,
}) {
  const response = await fetch(path, {
    method: method,
    body: !!data ? JSON.stringify(data) : null,
    headers: !!headers ? headers : defaultHeaders,
  }).then((response) => {
    if (response.status === 204) {
      return {};
    } else if (response.status === 401 && !!onUnauthorized) {
      return onUnauthorized(response);
    } else if (response.status >= 500 && !!onError) {
      return onError(response);
    } else {
      return response.json();
    }
  });

  return response;
}

export function useFetch(onUnauthorized, onError) {
  return {
    get: (path, headers) =>
      fetchData({
        path: path,
        method: GET,
        data: null,
        headers: headers,
        onUnauthorized: onUnauthorized,
        onError: onError,
      }),
    post: (path, data, headers) =>
      fetchData({
        path: path,
        method: POST,
        data: data,
        headers: headers,
        onUnauthorized: onUnauthorized,
        onError: onError,
      }),
    put: (path, data, headers) =>
      fetchData({
        path: path,
        method: PUT,
        data: data,
        headers: headers,
        onUnauthorized: onUnauthorized,
        onError: onError,
      }),
    patch: (path, data, headers) =>
      fetchData({
        path: path,
        method: PATCH,
        data: data,
        headers: headers,
        onUnauthorized: onUnauthorized,
        onError: onError,
      }),
    del: (path, headers) =>
      fetchData({
        path: path,
        method: DEL,
        data: null,
        headers: headers,
        onUnauthorized: onUnauthorized,
        onError: onError,
      }),
  };
}

export default useFetch;