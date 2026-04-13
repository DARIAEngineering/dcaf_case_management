import { Application } from "@hotwired/stimulus"
import AutosaveController from "../autosave_controller"

describe("AutosaveController", () => {
  let application
  let container

  function createDOM(attrs = {}) {
    const url = attrs.url || "/patients/123"
    const debounce = attrs.debounce || 200 // short for tests
    const maxInterval = attrs.maxInterval || 1000

    container = document.createElement("div")
    container.innerHTML = `
      <form data-controller="autosave"
            data-autosave-url-value="${url}"
            data-autosave-debounce-value="${debounce}"
            data-autosave-max-interval-value="${maxInterval}"
            data-action="input->autosave#changed">
        <input type="text" name="patient[name]" value="Alice" />
        <span data-autosave-target="indicator" class="autosave-indicator d-none"></span>
      </form>
    `
    document.body.appendChild(container)
  }

  beforeEach(() => {
    // CSRF meta tag
    const meta = document.createElement("meta")
    meta.name = "csrf-token"
    meta.content = "test-csrf-token"
    document.head.appendChild(meta)

    application = Application.start()
    application.register("autosave", AutosaveController)

    jest.useFakeTimers()
    global.fetch = jest.fn(() =>
      Promise.resolve({ ok: true, json: () => Promise.resolve({}) })
    )
    global.navigator.sendBeacon = jest.fn(() => true)
  })

  afterEach(() => {
    application.stop()
    if (container) container.remove()
    document.head.querySelector('meta[name="csrf-token"]')?.remove()
    jest.useRealTimers()
    jest.restoreAllMocks()
  })

  describe("connect", () => {
    it("initializes state on connect", async () => {
      createDOM()
      await new Promise(r => setTimeout(r, 0))
      // Controller connects without errors — indicator is hidden
      const indicator = container.querySelector('[data-autosave-target="indicator"]')
      expect(indicator.classList.contains("d-none")).toBe(true)
    })
  })

  describe("debounce behavior", () => {
    it("fires save after debounce delay", async () => {
      createDOM({ debounce: 200 })
      await new Promise(r => setTimeout(r, 0))

      const input = container.querySelector("input")
      input.value = "Bob"
      input.dispatchEvent(new Event("input", { bubbles: true }))

      // Before debounce - no fetch
      expect(fetch).not.toHaveBeenCalled()

      // After debounce
      jest.advanceTimersByTime(250)
      await Promise.resolve() // flush microtasks

      expect(fetch).toHaveBeenCalledTimes(1)
    })

    it("resets debounce on subsequent changes", async () => {
      createDOM({ debounce: 200 })
      await new Promise(r => setTimeout(r, 0))

      const input = container.querySelector("input")
      input.dispatchEvent(new Event("input", { bubbles: true }))

      jest.advanceTimersByTime(150) // not yet
      input.dispatchEvent(new Event("input", { bubbles: true })) // reset

      jest.advanceTimersByTime(150) // 150ms since last change, not 200
      await Promise.resolve()
      expect(fetch).not.toHaveBeenCalled()

      jest.advanceTimersByTime(100) // now 250ms since last change
      await Promise.resolve()
      expect(fetch).toHaveBeenCalledTimes(1)
    })
  })

  describe("max interval", () => {
    it("forces save at max interval even with continuous changes", async () => {
      createDOM({ debounce: 200, maxInterval: 500 })
      await new Promise(r => setTimeout(r, 0))

      const input = container.querySelector("input")

      // Simulate rapid typing that keeps resetting debounce
      for (let i = 0; i < 5; i++) {
        input.dispatchEvent(new Event("input", { bubbles: true }))
        jest.advanceTimersByTime(100) // 100ms between each input
      }
      // At 500ms total, max interval should trigger
      jest.advanceTimersByTime(50)
      await Promise.resolve()

      expect(fetch).toHaveBeenCalledTimes(1)
    })
  })

  describe("save request", () => {
    it("sends PATCH with FormData and CSRF token", async () => {
      createDOM({ debounce: 100 })
      await new Promise(r => setTimeout(r, 0))

      const input = container.querySelector("input")
      input.dispatchEvent(new Event("input", { bubbles: true }))
      jest.advanceTimersByTime(150)
      await Promise.resolve()

      expect(fetch).toHaveBeenCalledWith(
        "/patients/123",
        expect.objectContaining({
          method: "PATCH",
          headers: expect.objectContaining({
            "Accept": "application/json",
            "X-CSRF-Token": "test-csrf-token"
          })
        })
      )
    })
  })

  describe("indicator states", () => {
    it("shows 'Saving...' then '✓ Saved' on success", async () => {
      let resolvePromise
      fetch.mockImplementation(() => new Promise(r => { resolvePromise = r }))

      createDOM({ debounce: 100 })
      await new Promise(r => setTimeout(r, 0))

      const indicator = container.querySelector('[data-autosave-target="indicator"]')
      const input = container.querySelector("input")

      input.dispatchEvent(new Event("input", { bubbles: true }))
      jest.advanceTimersByTime(150)
      await Promise.resolve()

      // During save
      expect(indicator.textContent).toBe("Saving...")
      expect(indicator.classList.contains("text-muted")).toBe(true)

      // Resolve fetch
      resolvePromise({ ok: true })
      await Promise.resolve()
      await Promise.resolve() // extra tick for async

      expect(indicator.textContent).toBe("✓ Saved")
      expect(indicator.classList.contains("text-success")).toBe(true)
    })

    it("shows error indicator on fetch failure", async () => {
      fetch.mockImplementation(() => Promise.resolve({ ok: false, status: 500 }))

      createDOM({ debounce: 100 })
      await new Promise(r => setTimeout(r, 0))

      const indicator = container.querySelector('[data-autosave-target="indicator"]')
      const input = container.querySelector("input")

      input.dispatchEvent(new Event("input", { bubbles: true }))
      jest.advanceTimersByTime(150)
      await Promise.resolve()
      await Promise.resolve()

      expect(indicator.textContent).toBe("⚠ Save failed")
      expect(indicator.classList.contains("text-danger")).toBe(true)
    })

    it("shows error indicator on network error", async () => {
      fetch.mockImplementation(() => Promise.reject(new Error("Network error")))

      createDOM({ debounce: 100 })
      await new Promise(r => setTimeout(r, 0))

      const indicator = container.querySelector('[data-autosave-target="indicator"]')
      const input = container.querySelector("input")

      input.dispatchEvent(new Event("input", { bubbles: true }))
      jest.advanceTimersByTime(150)
      await Promise.resolve()
      await Promise.resolve()

      expect(indicator.textContent).toBe("⚠ Save failed")
    })
  })

  describe("error recovery", () => {
    it("re-marks dirty on failed save and schedules retry", async () => {
      fetch
        .mockImplementationOnce(() => Promise.resolve({ ok: false }))
        .mockImplementationOnce(() => Promise.resolve({ ok: true }))

      createDOM({ debounce: 100 })
      await new Promise(r => setTimeout(r, 0))

      const input = container.querySelector("input")
      input.dispatchEvent(new Event("input", { bubbles: true }))

      // First save (fails)
      jest.advanceTimersByTime(150)
      await Promise.resolve()
      await Promise.resolve()

      expect(fetch).toHaveBeenCalledTimes(1)

      // Retry after debounce
      jest.advanceTimersByTime(150)
      await Promise.resolve()
      await Promise.resolve()

      expect(fetch).toHaveBeenCalledTimes(2)
    })
  })

  describe("disconnect", () => {
    it("uses sendBeacon when dirty on disconnect", async () => {
      createDOM({ debounce: 5000 }) // long debounce, won't fire
      await new Promise(r => setTimeout(r, 0))

      const input = container.querySelector("input")
      input.dispatchEvent(new Event("input", { bubbles: true }))

      // Disconnect before debounce fires
      application.stop()

      expect(navigator.sendBeacon).toHaveBeenCalledWith(
        "/patients/123",
        expect.any(FormData)
      )
    })

    it("does not sendBeacon when not dirty", async () => {
      createDOM()
      await new Promise(r => setTimeout(r, 0))

      application.stop()

      expect(navigator.sendBeacon).not.toHaveBeenCalled()
    })
  })
})
