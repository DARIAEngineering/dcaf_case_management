import { Controller } from "@hotwired/stimulus"

// Auto-dismiss flash messages after they are inserted via Turbo Stream.
// Attach with data-controller="flash" on the flash container.
export default class extends Controller {
  connect() {
    this.element.style.display = ""
    this.element.classList.remove("d-none")

    setTimeout(() => {
      this.element.style.display = "none"
    }, 5000)
  }
}
