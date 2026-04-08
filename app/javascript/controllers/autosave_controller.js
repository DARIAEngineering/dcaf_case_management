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
    // Save any pending changes before teardown
    if (this.dirty && !this.saving) {
      this.save()
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

    this.dirty = false
    this.saving = true
    this.clearTimers()
    this.showIndicator("saving")

    try {
      const formData = new FormData(this.element)
      const token = document.querySelector('meta[name="csrf-token"]')?.content

      const response = await fetch(this.urlValue || this.element.action, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": token,
          "Accept": "application/json"
        },
        body: formData
      })

      if (response.ok) {
        this.showIndicator("saved")
      } else {
        this.showIndicator("error")
      }
    } catch (error) {
      this.showIndicator("error")
    } finally {
      this.saving = false
    }

    // If more changes came in while saving, schedule another save
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
