import useFetch from "../useFetch";

let defaultHeaders = {
  "Content-Type": "application/json",
  Accept: "application/json",
};

let customHeaders = {
  "Content-Language": "de-DE",
  Date: "Wed, 21 Oct 2015 07:28:00 GMT",
};

let url;
let data;
let status;
let ok;
let mockResponse = { data: "here" };
let mockJsonPromise = Promise.resolve(mockResponse);
let mockFetchPromise;

afterAll(() => {
  delete global.fetch;
});

describe("useFetch", () => {
  describe("get", () => {
    beforeEach(() => {
      url = "https://jsonplaceholder.typicode.com/todos/1";
      status = 200;
      ok = true;
      mockFetchPromise = Promise.resolve({
        status: status,
        ok: ok,
        json: () => mockJsonPromise,
      });

      global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
    });

    it("returns the expected response", () => {
      const { get } = useFetch();
      expect(get(url)).resolves.toEqual(mockResponse);
    });

    it("calls fetch with the expected parameters", async () => {
      const { get } = useFetch();
      await get(url);
      expect(global.fetch).toHaveBeenCalledWith(
        url,
        expect.objectContaining({
          method: "GET",
          body: null,
          headers: defaultHeaders,
        })
      );

      process.nextTick(() => {
        global.fetch.mockClear();
      });
    });

    it("calls fetch with the custom headers", async () => {
      const { get } = useFetch();
      await get(url, customHeaders);
      expect(global.fetch).toHaveBeenCalledWith(
        url,
        expect.objectContaining({
          method: "GET",
          body: null,
          headers: customHeaders,
        })
      );

      process.nextTick(() => {
        global.fetch.mockClear();
      });
    });

    describe("when the response is successful", () => {
      describe("when the status code is 204 No Content", () => {
        beforeEach(() => {
          status = 204;
          mockFetchPromise = Promise.resolve({
            status: status,
            ok: ok,
            json: () => Promise.resolve({}),
          });

          global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
        });

        it("returns an empty json object", (done) => {
          const { get } = useFetch();
          const response = get(url);
          expect(response).toEqual(Promise.resolve({}));

          process.nextTick(() => {
            global.fetch.mockClear();
            done();
          });
        });
      });

      describe("when the status code is any other successful status", () => {
        it("returns the response as json", (done) => {
          const { get } = useFetch();
          const response = get(url);
          expect(response).toEqual(mockJsonPromise);

          process.nextTick(() => {
            global.fetch.mockClear();
            done();
          });
        });
      });
    });

    describe("when the response is not successful", () => {
      describe("when the status code is 401 Unauthorized", () => {
        beforeEach(() => {
          status = 401;
          ok = false;
          mockFetchPromise = Promise.resolve({
            status: status,
            ok: ok,
            json: () => mockJsonPromise,
          });

          global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
        });

        describe("without an onUnauthorized handler passed in", () => {
          it("returns the response as json", (done) => {
            const { get } = useFetch();
            const response = get(url);
            expect(response).toEqual(mockJsonPromise);

            process.nextTick(() => {
              global.fetch.mockClear();
              done();
            });
          });
        });

        describe("with an onUnauthorized handler passed in", () => {
          it("calls the onUnauthorized", async () => {
            const onUnauthorized = jest.fn(() => 3);
            const { get } = useFetch(onUnauthorized);
            await get(url);
            expect(onUnauthorized).toHaveBeenCalled();
          });
        });
      });

      describe("when the status code is any other error ", () => {
        beforeEach(() => {
          status = 500;
          ok = false;
          mockFetchPromise = Promise.resolve({
            status: status,
            ok: ok,
            json: () => mockJsonPromise,
          });

          global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
        });

        describe("without an onError handler passed in", () => {
          it("returns the response as json", (done) => {
            const { get } = useFetch();
            const response = get(url);
            expect(response).toEqual(mockJsonPromise);

            process.nextTick(() => {
              global.fetch.mockClear();
              done();
            });
          });

          describe("with an onError handler passed in", () => {
            it("calls the onError", async () => {
              const onError = jest.fn(() => 3);
              const { get } = useFetch(null, onError);
              await get(url);
              expect(onError).toHaveBeenCalled();
            });
          });
        });
      });
    });
  });

  describe("post", () => {
    beforeEach(() => {
      url = "https://jsonplaceholder.typicode.com/todos";
      data = { title: "Gotta do all the things!", completed: false };
      status = 200;
      ok = true;
      mockFetchPromise = Promise.resolve({
        status: status,
        ok: ok,
        json: () => mockJsonPromise,
      });

      global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
    });

    it("returns the expected response", () => {
      const { post } = useFetch();
      expect(post(url, data)).resolves.toEqual(mockResponse);
    });

    it("calls fetch with the expected parameters", async () => {
      const { post } = useFetch();
      await post(url, data);

      expect(global.fetch).toHaveBeenCalledWith(
        url,
        expect.objectContaining({
          method: "POST",
          body: JSON.stringify(data),
          headers: defaultHeaders,
        })
      );

      process.nextTick(() => {
        global.fetch.mockClear();
      });
    });

    it("calls fetch with the custom headers", async () => {
      const { post } = useFetch();
      await post(url, data, customHeaders);

      expect(global.fetch).toHaveBeenCalledWith(
        url,
        expect.objectContaining({
          method: "POST",
          body: JSON.stringify(data),
          headers: customHeaders,
        })
      );

      process.nextTick(() => {
        global.fetch.mockClear();
      });
    });

    describe("when the response is successful", () => {
      describe("when the status code is 204 No Content", () => {
        beforeEach(() => {
          status = 204;
          mockFetchPromise = Promise.resolve({
            status: status,
            ok: ok,
            json: () => Promise.resolve({}),
          });

          global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
        });

        it("returns an empty json object", (done) => {
          const { post } = useFetch();
          const response = post(url, data);
          expect(response).toEqual(Promise.resolve({}));

          process.nextTick(() => {
            global.fetch.mockClear();
            done();
          });
        });
      });

      describe("when the status code is any other successful status", () => {
        it("returns the response as json", (done) => {
          const { post } = useFetch();
          const response = post(url, data);
          expect(response).toEqual(mockJsonPromise);

          process.nextTick(() => {
            global.fetch.mockClear();
            done();
          });
        });
      });
    });

    describe("when the response is not successful", () => {
      describe("when the status code is 401 Unauthorized", () => {
        beforeEach(() => {
          data = { title: "Gotta do all the things!", completed: false };
          status = 401;
          ok = false;
          mockFetchPromise = Promise.resolve({
            status: status,
            ok: ok,
            json: () => mockJsonPromise,
          });

          global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
        });

        describe("without an onUnauthorized handler passed in", () => {
          it("returns the response as json", (done) => {
            const { post } = useFetch();
            const response = post(url, data);
            expect(response).toEqual(mockJsonPromise);

            process.nextTick(() => {
              global.fetch.mockClear();
              done();
            });
          });
        });

        describe("with an onUnauthorized handler passed in", () => {
          it("calls the onUnauthorized", async () => {
            const onUnauthorized = jest.fn();
            const { post } = useFetch(onUnauthorized);
            await post(url, data);
            expect(onUnauthorized).toHaveBeenCalled();
          });
        });
      });

      describe("when the status code is any other error ", () => {
        beforeEach(() => {
          status = 500;
          ok = false;
          mockFetchPromise = Promise.resolve({
            status: status,
            ok: ok,
            json: () => mockJsonPromise,
          });

          global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
        });

        describe("without an onError handler passed in", () => {
          it("returns the response as json", (done) => {
            const { post } = useFetch();
            const response = post(url, data);
            expect(response).toEqual(mockJsonPromise);

            process.nextTick(() => {
              global.fetch.mockClear();
              done();
            });
          });
        });

        describe("with an onError handler passed in", () => {
          it("calls the onError", async () => {
            const onError = jest.fn();
            const { post } = useFetch(null, onError);
            await post(url, data);
            expect(onError).toHaveBeenCalled();
          });
        });
      });
    });
  });

  describe("put", () => {
    beforeEach(() => {
      url = "https://jsonplaceholder.typicode.com/todos";
      data = { title: "Gotta do all the things!", completed: false };
      status = 200;
      ok = true;
      mockFetchPromise = Promise.resolve({
        status: status,
        ok: ok,
        json: () => mockJsonPromise,
      });

      global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
    });

    it("returns the expected response", () => {
      const { put } = useFetch();
      expect(put(url, data)).resolves.toEqual(mockResponse);
    });

    it("calls fetch with the expected parameters", async () => {
      const { put } = useFetch();
      await put(url, data);

      expect(global.fetch).toHaveBeenCalledWith(
        url,
        expect.objectContaining({
          method: "PUT",
          body: JSON.stringify(data),
          headers: defaultHeaders,
        })
      );

      process.nextTick(() => {
        global.fetch.mockClear();
      });
    });

    it("calls fetch with the custom headers", async () => {
      const { put } = useFetch();
      await put(url, data, customHeaders);

      expect(global.fetch).toHaveBeenCalledWith(
        url,
        expect.objectContaining({
          method: "PUT",
          body: JSON.stringify(data),
          headers: customHeaders,
        })
      );

      process.nextTick(() => {
        global.fetch.mockClear();
      });
    });

    describe("when the response is successful", () => {
      describe("when the status code is 204 No Content", () => {
        beforeEach(() => {
          status = 204;
          mockFetchPromise = Promise.resolve({
            status: status,
            ok: ok,
            json: () => Promise.resolve({}),
          });

          global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
        });

        it("returns an empty json object", (done) => {
          const { put } = useFetch();
          const response = put(url, data);
          expect(response).toEqual(Promise.resolve({}));

          process.nextTick(() => {
            global.fetch.mockClear();
            done();
          });
        });
      });

      describe("when the status code is any other successful status", () => {
        it("returns the response as json", (done) => {
          const { put } = useFetch();
          const response = put(url, data);
          expect(response).toEqual(mockJsonPromise);

          process.nextTick(() => {
            global.fetch.mockClear();
            done();
          });
        });
      });
    });

    describe("when the response is not successful", () => {
      describe("when the status code is 401 Unauthorized", () => {
        beforeEach(() => {
          data = { title: "Gotta do all the things!", completed: false };
          status = 401;
          ok = false;
          mockFetchPromise = Promise.resolve({
            status: status,
            ok: ok,
            json: () => mockJsonPromise,
          });

          global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
        });

        describe("without an onUnauthorized handler passed in", () => {
          it("returns the response as json", (done) => {
            const { put } = useFetch();
            const response = put(url, data);
            expect(response).toEqual(mockJsonPromise);

            process.nextTick(() => {
              global.fetch.mockClear();
              done();
            });
          });
        });

        describe("with an onUnauthorized handler passed in", () => {
          it("calls the onUnauthorized", async () => {
            const onUnauthorized = jest.fn();
            const { put } = useFetch(onUnauthorized);
            await put(url, data);
            expect(onUnauthorized).toHaveBeenCalled();
          });
        });
      });

      describe("when the status code is any other error ", () => {
        beforeEach(() => {
          status = 500;
          ok = false;
          mockFetchPromise = Promise.resolve({
            status: status,
            ok: ok,
            json: () => mockJsonPromise,
          });

          global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
        });

        describe("without an onError handler passed in", () => {
          it("returns the response as json", (done) => {
            const { put } = useFetch();
            const response = put(url, data);
            expect(response).toEqual(mockJsonPromise);

            process.nextTick(() => {
              global.fetch.mockClear();
              done();
            });
          });

          describe("with an onError handler passed in", () => {
            it("calls the onError", async () => {
              const onError = jest.fn();
              const { put } = useFetch(null, onError);
              await put(url, data);
              expect(onError).toHaveBeenCalled();
            });
          });
        });
      });
    });
  });

  describe("patch", () => {
    beforeEach(() => {
      url = "https://jsonplaceholder.typicode.com/todos";
      data = { title: "Gotta do all the things!", completed: false };
      status = 200;
      ok = true;
      mockFetchPromise = Promise.resolve({
        status: status,
        ok: ok,
        json: () => mockJsonPromise,
      });

      global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
    });

    it("returns the expected response", () => {
      const { patch } = useFetch();
      expect(patch(url, data)).resolves.toEqual(mockResponse);
    });

    it("calls fetch with the expected parameters", async () => {
      const { patch } = useFetch();
      await patch(url, data);

      expect(global.fetch).toHaveBeenCalledWith(
        url,
        expect.objectContaining({
          method: "PATCH",
          body: JSON.stringify(data),
          headers: defaultHeaders,
        })
      );

      process.nextTick(() => {
        global.fetch.mockClear();
      });
    });

    it("calls fetch with the custom headers", async () => {
      const { patch } = useFetch();
      await patch(url, data, customHeaders);

      expect(global.fetch).toHaveBeenCalledWith(
        url,
        expect.objectContaining({
          method: "PATCH",
          body: JSON.stringify(data),
          headers: customHeaders,
        })
      );

      process.nextTick(() => {
        global.fetch.mockClear();
      });
    });

    describe("when the response is successful", () => {
      describe("when the status code is 204 No Content", () => {
        beforeEach(() => {
          status = 204;
          mockFetchPromise = Promise.resolve({
            status: status,
            ok: ok,
            json: () => Promise.resolve({}),
          });

          global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
        });

        it("returns an empty json object", (done) => {
          const { patch } = useFetch();
          const response = patch(url, data);
          expect(response).toEqual(Promise.resolve({}));

          process.nextTick(() => {
            global.fetch.mockClear();
            done();
          });
        });
      });

      describe("when the status code is any other successful status", () => {
        it("returns the response as json", (done) => {
          const { patch } = useFetch();
          const response = patch(url, data);
          expect(response).toEqual(mockJsonPromise);

          process.nextTick(() => {
            global.fetch.mockClear();
            done();
          });
        });
      });
    });

    describe("when the response is not successful", () => {
      describe("when the status code is 401 Unauthorized", () => {
        beforeEach(() => {
          data = { title: "Gotta do all the things!", completed: false };
          status = 401;
          ok = false;
          mockFetchPromise = Promise.resolve({
            status: status,
            ok: ok,
            json: () => mockJsonPromise,
          });

          global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
        });

        describe("without an onUnauthorized handler passed in", () => {
          it("returns the response as json", (done) => {
            const { patch } = useFetch();
            const response = patch(url, data);
            expect(response).toEqual(mockJsonPromise);

            process.nextTick(() => {
              global.fetch.mockClear();
              done();
            });
          });
        });

        describe("with an onUnauthorized handler passed in", () => {
          it("calls the onUnauthorized", async () => {
            const onUnauthorized = jest.fn();
            const { patch } = useFetch(onUnauthorized);
            await patch(url, data);
            expect(onUnauthorized).toHaveBeenCalled();
          });
        });
      });

      describe("when the status code is any other error ", () => {
        beforeEach(() => {
          status = 500;
          ok = false;
          mockFetchPromise = Promise.resolve({
            status: status,
            ok: ok,
            json: () => mockJsonPromise,
          });

          global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
        });

        describe("without an onError handler passed in", () => {
          it("returns the response as json", (done) => {
            const { patch } = useFetch();
            const response = patch(url, data);
            expect(response).toEqual(mockJsonPromise);

            process.nextTick(() => {
              global.fetch.mockClear();
              done();
            });
          });

          describe("with an onError handler passed in", () => {
            it("calls the onError", async () => {
              const onError = jest.fn();
              const { patch } = useFetch(null, onError);
              await patch(url, data);
              expect(onError).toHaveBeenCalled();
            });
          });
        });
      });
    });
  });

  describe("del", () => {
    beforeEach(() => {
      url = "https://jsonplaceholder.typicode.com/todos/1";
      status = 200;
      ok = true;
      mockFetchPromise = Promise.resolve({
        status: status,
        ok: ok,
        json: () => mockJsonPromise,
      });

      global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
    });

    it("returns the expected response", () => {
      const { del } = useFetch();
      expect(del(url)).resolves.toEqual(mockResponse);
    });

    it("calls fetch with the expected parameters", async () => {
      const { del } = useFetch();
      await del(url);

      expect(global.fetch).toHaveBeenCalledWith(
        url,
        expect.objectContaining({
          method: "DELETE",
          body: null,
          headers: defaultHeaders,
        })
      );

      process.nextTick(() => {
        global.fetch.mockClear();
      });
    });

    it("calls fetch with the custom headers", async () => {
      const { del } = useFetch();
      await del(url, customHeaders);

      expect(global.fetch).toHaveBeenCalledWith(
        url,
        expect.objectContaining({
          method: "DELETE",
          body: null,
          headers: customHeaders,
        })
      );

      process.nextTick(() => {
        global.fetch.mockClear();
      });
    });

    describe("when the response is successful", () => {
      describe("when the status code is 204 No Content", () => {
        beforeEach(() => {
          status = 204;
          mockFetchPromise = Promise.resolve({
            status: status,
            ok: ok,
            json: () => Promise.resolve({}),
          });

          global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
        });

        it("returns an empty json object", (done) => {
          const { del } = useFetch();
          const response = del(url);
          expect(response).toEqual(Promise.resolve({}));

          process.nextTick(() => {
            global.fetch.mockClear();
            done();
          });
        });
      });

      describe("when the status code is any other successful status", () => {
        it("returns the response as json", (done) => {
          const { del } = useFetch();
          const response = del(url);
          expect(response).toEqual(mockJsonPromise);

          process.nextTick(() => {
            global.fetch.mockClear();
            done();
          });
        });
      });
    });

    describe("when the response is not successful", () => {
      describe("when the status code is 401 Unauthorized", () => {
        beforeEach(() => {
          status = 401;
          ok = false;
          mockFetchPromise = Promise.resolve({
            status: status,
            ok: ok,
            json: () => mockJsonPromise,
          });

          global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
        });

        describe("without an onUnauthorized handler passed in", () => {
          it("returns the response as json", (done) => {
            const { del } = useFetch();
            const response = del(url);
            expect(response).toEqual(mockJsonPromise);

            process.nextTick(() => {
              global.fetch.mockClear();
              done();
            });
          });
        });

        describe("with an onUnauthorized handler passed in", () => {
          it("calls the unauthorizedHandler", async () => {
            const onUnauthorized = jest.fn();
            const { del } = useFetch(onUnauthorized);
            await del(url);
            expect(onUnauthorized).toHaveBeenCalled();
          });
        });
      });

      describe("when the status code is any other error ", () => {
        beforeEach(() => {
          status = 500;
          ok = false;
          mockFetchPromise = Promise.resolve({
            status: status,
            ok: ok,
            json: () => mockJsonPromise,
          });

          global.fetch = jest.fn().mockImplementation(() => mockFetchPromise);
        });

        describe("without an onError handler passed in", () => {
          it("returns the response as json", (done) => {
            const { del } = useFetch();
            const response = del(url);
            expect(response).toEqual(mockJsonPromise);

            process.nextTick(() => {
              global.fetch.mockClear();
              done();
            });
          });

          describe("with an onError handler passed in", () => {
            it("calls the onError", async () => {
              const onError = jest.fn();
              const { del } = useFetch(null, onError);
              await del(url);
              expect(onError).toHaveBeenCalled();
            });
          });
        });
      });
    });
  });
});