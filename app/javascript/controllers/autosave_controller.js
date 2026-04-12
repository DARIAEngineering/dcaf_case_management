import { Controller } from "@hotwired/stimulus"

// Office 365-style auto-save controller.
// Debounces saves: 2s after last change, forced save at 15s max interval.
// Visual feedback: "Saving..." → "✓ Saved" → fades after 3s.
//
// Usage:
//   <form data-controller="autosave"
//         data-autosave-url-value="/patients/123"
//         data-action="input->autosave#changed select->autosave#changed">
//     <div data-autosave-target="indicator" class="autosave-indicator"></div>
//     ...
//   </form>
export default class extends Controller {
  static targets = ["indicator"]
  static values = {
    url: String,
    debounce: { type: Number, default: 2000 },
    maxInterval: { type: Number, default: 15000 }
  }

  connect() {
    this.debounceTimer = null
    this.maxTimer = null
    this.dirty = false
    this.saving = false
  }

  disconnect() {
    this.clearTimers()
    // Use sendBeacon for reliable delivery during page unload
    if (this.dirty && !this.saving) {
      const formData = new FormData(this.element)
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
      if (csrfToken) formData.append('authenticity_token', csrfToken)
      const url = this.urlValue || this.element.action
      navigator.sendBeacon(url, formData)
      this.dirty = false
    }
  }

  changed() {
    this.dirty = true

    // Reset debounce timer on every change
    clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(() => this.save(), this.debounceValue)

    // Start max interval timer if not already running
    if (!this.maxTimer) {
      this.maxTimer = setTimeout(() => this.save(), this.maxIntervalValue)
    }
  }

  async save() {
    if (!this.dirty || this.saving) return

    this.saving = true
    this.dirty = false
    const dirtyAtStart = true
    this.clearTimers()
    this.showIndicator("saving")

    try {
      const formData = new FormData(this.element)
      const csrfMeta = document.querySelector('meta[name="csrf-token"]')
      const token = csrfMeta ? csrfMeta.content : null

      const headers = { "Accept": "application/json" }
      if (token) headers["X-CSRF-Token"] = token

      const response = await fetch(this.urlValue || this.element.action, {
        method: "PATCH",
        headers: headers,
        body: formData
      })

      if (response.ok) {
        this.showIndicator("saved")
      } else {
        // Re-mark dirty so retry picks up the failed save
        this.dirty = true
        this.showIndicator("error")
      }
    } catch (error) {
      this.dirty = true
      this.showIndicator("error")
    } finally {
      this.saving = false
    }

    // If new changes came in during save, or save failed, schedule retry
    if (this.dirty) {
      this.debounceTimer = setTimeout(() => this.save(), this.debounceValue)
    }
  }

  showIndicator(state) {
    if (!this.hasIndicatorTarget) return

    const el = this.indicatorTarget
    el.classList.remove("d-none")

    switch (state) {
      case "saving":
        el.textContent = "Saving..."
        el.className = "autosave-indicator text-muted"
        break
      case "saved":
        el.textContent = "✓ Saved"
        el.className = "autosave-indicator text-success"
        // Fade out after 3 seconds
        setTimeout(() => {
          el.classList.add("autosave-fade")
          setTimeout(() => el.classList.add("d-none"), 500)
        }, 3000)
        break
      case "error":
        el.textContent = "⚠ Save failed"
        el.className = "autosave-indicator text-danger"
        break
    }
  }

  clearTimers() {
    clearTimeout(this.debounceTimer)
    clearTimeout(this.maxTimer)
    this.debounceTimer = null
    this.maxTimer = null
  }
}
