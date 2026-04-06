import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

// Opens a Bootstrap 4 modal when the controller connects to the DOM.
// Use with Turbo Streams to replace modal content, then auto-open.
// Attach with data-controller="modal" on the .modal element.
export default class extends Controller {
  connect() {
    $(this.element).modal('show')
  }

  close() {
    $(this.element).modal('hide')
    $('body').removeClass('modal-open')
    $('.modal-backdrop').remove()
  }
}
