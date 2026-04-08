import { Controller } from "@hotwired/stimulus";

// Debounced autosave for patient dashboard form fields.
// Attach with data-controller="autosave" on the form,
// and data-action="input->autosave#save" on fields that should trigger saves.
export default class extends Controller {
  static values = {
    delay: { type: Number, default: 300 },
    url: String,
  };

  connect() {
    this.timer = null;
  }

  disconnect() {
    clearTimeout(this.timer);
  }

  save() {
    clearTimeout(this.timer);
    this.timer = setTimeout(() => {
      this.element.requestSubmit();
    }, this.delayValue);
  }
}
