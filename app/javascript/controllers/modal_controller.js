import { Controller } from "@hotwired/stimulus"

// Opens a Bootstrap 4 modal via jQuery when Turbo Stream injects content.
// Attach data-controller="modal" on the .modal element.
// Observes child mutations to auto-show when turbo_stream updates modal content.
export default class extends Controller {
  connect() {
    // If modal body already has content (e.g., injected by turbo_stream), show immediately
    const content = this.element.querySelector('.modal-content')
    if (content && content.children.length > 0 && content.textContent.trim() !== '') {
      $(this.element).modal('show')
    }

    // Observe future content changes (turbo_stream updates)
    this.observer = new MutationObserver(() => {
      if (content && content.children.length > 0) {
        $(this.element).modal('show')
      }
    })
    if (content) {
      this.observer.observe(content, { childList: true })
    }
  }

  disconnect() {
    this.observer?.disconnect()
  }

  close() {
    $(this.element).modal('hide')
    $('body').removeClass('modal-open')
    $('.modal-backdrop').remove()
  }
}
