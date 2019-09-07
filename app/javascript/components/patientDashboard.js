import React, { Component } from "react";
import I18n from "../i18n-js/index.js.erb";

class PatientDashboard extends Component {
  deletePatient(e) {
    e.preventDefault();
    console.log('delete')
  }
  render() {
    console.log(this.props.patient)
    const {current_user} = this.props;
    const { name, 
      primary_phone_display, 
      last_menstrual_period_days,
      last_menstrual_period_weeks,
      initial_call_date,
      appointment_date
       } = this.props.patient;
    return (
      <div id="patient_dashboard_content">
        <form>
          <div class="form-group">
            <div class="col-sm-4">
              <label for="name">First and last name</label>
              <input
                type="text"
                class="form-control"
                id="name"
                aria-describedby="emailHelp"
                value={name}
              ></input>

              <label for="phone">Phone number</label>

              <input
                type="text"
                class="form-control"
                id="primary_phone"
                aria-describedby="emailHelp"
                value={primary_phone_display}
              ></input>
            </div>

            <div class="col-sm-4">
              <div class="row">
                <div class="col-sm-6">
                  <label for="last_menstraul_period_weeks">
                    {I18n.t("patient.dashboard.weeks_along")}
                  </label>
                  <div class="dropdown">
                    <button
                      class="btn btn-secondary dropdown-toggle"
                      type="button"
                      id="dropdownMenuButton"
                      data-toggle="dropdown"
                      aria-haspopup="true"
                      aria-expanded="false"
                    >
                      Dropdown button
                    </button>
                    <div
                      class="dropdown-menu"
                      aria-labelledby="dropdownMenuButton"
                    >
                      <a class="dropdown-item" href="#">
                        Action
                      </a>
                    </div>
                  </div>
                </div>
                <div class="col-sm-6 hide-label">
                  <label for="last_menstrual_period_days">days along</label>
                  <div class="dropdown">
                    <button
                      class="btn btn-secondary dropdown-toggle"
                      type="button"
                      id="dropdownMenuButton"
                      data-toggle="dropdown"
                      aria-haspopup="true"
                      aria-expanded="false"
                    >
                      Dropdown button
                    </button>
                    <small class="form-text text-muted">Currently: {last_menstrual_period_weeks}w {last_menstrual_period_days}d</small>
                    <div
                      class="dropdown-menu"
                      aria-labelledby="dropdownMenuButton"
                    >
                      <a class="dropdown-item" href="#">
                        Action
                      </a>
                    </div>
                    <small class="form-text text-muted">Called on: {initial_call_date}</small>

                  </div>
                </div>
              </div>
              <div class="row">
                <div class="col-sm-12">
                  <p>
                    <strong>{I18n.t("patient.shared.status")}</strong>{" "}
                    <span id="patient_status">{this.props.patient.status} Source?</span>
                  </p>
                </div>
              </div>
            </div>
            <div class="col-sm-4">
              <div class="row">
              <label for="example-datetime-local-input" class="col-2 col-form-label">Date and time</label>
    <input class="form-control" type="datetime-local" value={appointment_date} id="example-datetime-local-input"></input>
    <small class="form-text text-muted">{I18n.t("patient.dashboard.approx_gestation", {weeks: 7, days: 5 })}</small>

              </div>
            </div>
            <div class="row">
              {current_user.role==="admin" &&
                <button> onClick={()=> this.deletePatient()}delete duplicate patient record</button>
                }
            </div>
            
          </div>
        </form>
      </div>

      //             <div id="patient_dashboard_content">

      //   <%= bootstrap_form_for patient, html: { id: 'patient_dashboard_form' }, remote: true do |f| %>
      //     <div class="col-sm-4" >
      //       <%= f.text_field :name, label: t('patient.shared.name'), autocomplete: 'off' %>
      //       <%= f.text_field :primary_phone, value: patient.primary_phone_display, label: t('patient.dashboard.phone'), autocomplete: 'off' %>
      //     </div>

      // <div class="col-sm-4">
      //   <div class="row">
      //     <div class="col-sm-6">
      //       <%= f.select :last_menstrual_period_weeks,
      //                    options_for_select(weeks_options, patient.last_menstrual_period_weeks ),
      //                    label: t('patient.dashboard.weeks_along'),
      //                    autocomplete: 'off',
      //                    help: t('patient.dashboard.currently', weeks: patient.last_menstrual_period_now_weeks, days: patient.last_menstrual_period_now_days) %>
      //     </div>
      //     <div class="col-sm-6 hide-label">
      //       <%= f.select :last_menstrual_period_days, options_for_select(days_options, patient.last_menstrual_period_days ), autocomplete: 'off', skip_label: true, help: t('patient.dashboard.called_on', date: patient.initial_call_date.strftime("%m/%d/%Y")) %>
      //       <%= f.label :last_menstrual_period_days, t('52.days_along'), class: "sr-only" %>
      //     </div>
      //   </div>
      //   <div class="row">
      //     <div class="col-sm-12">
      //       <p><strong><%= t 'patient.shared.status' %></strong> <span id='patient_status'><%= patient.status %></span> <%= tooltip_shell status_help_text(patient) %></p>
      //     </div>
      //   </div>
      // </div>

      //     <div class="col-sm-4">
      //       <div class="row">
      //         <%= f.date_field :appointment_date,
      //                          label: t('patient.shared.appt_date'),
      //                          autocomplete: 'off',
      //                          help: t('patient.dashboard.approx_gestation', weeks: patient.last_menstrual_period_at_appt_weeks, days: patient.last_menstrual_period_at_appt_days) %>
      //       </div>
      //       <div class="row">
      //         <% if current_user.admin? %>
      //           <%= link_to t('patient.dashboard.delete'), patient_path(patient), class: 'btn btn-danger', method: :delete, data: { confirm: t('patient.dashboard.confirm_del', name: patient.name) }, remote: true %>
      //         <% end %>
      //       </div>
      //     </div>
      //   <% end %>
      // </div>
    );
  }
}

export default PatientDashboard;
