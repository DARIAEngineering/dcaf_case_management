// Stimulus controller registration for auto-save feature.
// Requires @hotwired/stimulus from #3544 (stimulus-dashboard).
import { Application } from "@hotwired/stimulus"
import AutosaveController from "./autosave_controller"

// Use existing Stimulus instance from window (set by #3544) or start a new one
const application = window.Stimulus || Application.start()
application.register("autosave", AutosaveController)
