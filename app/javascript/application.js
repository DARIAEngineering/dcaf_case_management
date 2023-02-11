// Entry point for the build script in package.json.
// Core libraries (mostly just initializing)
import './src/jquery';
import {} from 'jquery-ujs'
import './src/jquery-ui';
import * as bootstrap from "bootstrap";

// Vendor
import './src/vendor/jquery-bootstrap-modal-steps.min';

// Custom
import './src/autosave';
import './src/call_list_drag_and_drop';
import './src/clinic_finder';
import './src/clinics';
import './src/fontawesome';
import './src/multistep_modal';
import './src/pledge_calculator';
import './src/require_pledge_signature';
import './src/table_sorting';
import './src/toggle_full_call_list';
import './src/tooltips';
