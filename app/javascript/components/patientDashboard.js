import React, { Component } from "react";
import I18n from '../i18n-js/index.js.erb';
{
  /* <div class="form-group">
<label for="exampleInputEmail1">Email address</label>
<input type="email" class="form-control" id="exampleInputEmail1" aria-describedby="emailHelp" placeholder="Enter email"></input>
<small id="emailHelp" class="form-text text-muted">We'll never share your email with anyone else.</small>
</div>
<div class="form-group">
<label for="exampleInputPassword1">Password</label>
<input type="password" class="form-control" id="exampleInputPassword1" placeholder="Password"></input>
</div>
<div class="form-group form-check">
<input type="checkbox" class="form-check-input" id="exampleCheck1"></input>
<label class="form-check-label" for="exampleCheck1">Check me out</label>
</div>
<button type="submit" class="btn btn-primary">Submit</button>
</form> */
}
class PatientDashboard extends Component {
  // console.log(I18n.t('hello'))
  render() {
    const { name, primary_phone_display} = this.props.patient;
    console.log(this.props.patient);
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
                <label for="last_menstraul_period_weeks">{I18n.t('patient.dashboard.weeks_along')}</label>
                <div class="dropdown">
  <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
    Dropdown button
  </button>
  <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
    <a class="dropdown-item" href="#">Action</a>
    <a class="dropdown-item" href="#">Another action</a>
    <a class="dropdown-item" href="#">Something else here</a>
  </div>
</div>

              </div>
              <div class="col-sm-6 hide-label">
                <label for="last_menstrual_period_days">days along</label>

                <div class="dropdown">
  <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
    Dropdown button
  </button>
  <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
    <a class="dropdown-item" href="#">Action</a>
    <a class="dropdown-item" href="#">Another action</a>
    <a class="dropdown-item" href="#">Something else here</a>
  </div>
</div>
              </div>
            </div>
            <div class="row">
              <div class="col-sm-12">
                <p><strong>{I18n.t('patient.shared.status')}</strong> <span id='patient_status'>{this.props.patient.status}</span></p>
              </div>
            </div>
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
