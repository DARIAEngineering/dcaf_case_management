import React, { useState, useEffect } from "react";
import Input from './Input'
import Select from './Select'
import Tooltip from './Tooltip'
import mount from "../mount";
import { usei18n, useFetch, useFlash, useDebounce } from "../hooks";

export default PatientDashboardForm = ({
  patient,
  weeksOptions,
  daysOptions,
  isAdmin,
  patientPath,
  formAuthenticityToken
}) => {
  const i18n = usei18n();
  const { put } = useFetch();
  const flash = useFlash();
  const { debounce, cleanupDebounce } = useDebounce();

  const [patientData, setPatientData] = useState(patient)

  const autosave = async (updatedData) => {
    const updatedPatientData = { ...patientData, ...updatedData }

    const putData = {
      name: updatedPatientData.name,
      last_menstrual_period_days: updatedPatientData.last_menstrual_period_days,
      last_menstrual_period_weeks: updatedPatientData.last_menstrual_period_weeks,
      appointment_date: updatedPatientData.appointment_date,
      primary_phone: updatedPatientData.primary_phone,
      pronouns: updatedPatientData.pronouns,
    }

    const data = await put(patientPath, { ...putData, authenticity_token: formAuthenticityToken })
    flash.render(data.flash)
    if (data.patient) {
      setPatientData(data.patient)
    }
  }

  const debouncedAutosave = debounce(autosave);

  // Stop the invocation of the debounced function after unmounting
  useEffect(() => {
    return () => {
      cleanupDebounce();
    }
  }, []);

  return (
    <form
      id="patient_dashboard_form"
      action={patientPath}
      data-remote="true" method="post"
      className="grid grid-columns-3 grid-rows-2"
    >
      <Input
        id="patient_name"
        name="patient[name]"
        label={i18n.t('patient.shared.name')}
        value={patientData.name}
        required
        onChange={(e) => debouncedAutosave({ name: e.target.value })}
      />

      <div className="grid grid-columns-2">
        <Select
          id="patient_last_menstrual_period_weeks"
          name="patient[last_menstrual_period_weeks]"
          label={i18n.t('patient.dashboard.weeks_along')}
          options={weeksOptions}
          value={weeksOptions.find(opt => opt.value === patientData.last_menstrual_period_weeks)?.value}
          help={i18n.t('patient.dashboard.currently', { weeks: patientData.last_menstrual_period_now_weeks, days: patientData.last_menstrual_period_now_days })}
          onChange={e => autosave({ last_menstrual_period_weeks: e.target.value })}
        />

        <Select
          id="patient_last_menstrual_period_days"
          name="patient[last_menstrual_period_days]"
          label={i18n.t('common.days_along')}
          labelClassName="sr-only"
          options={daysOptions}
          value={daysOptions.find(opt => opt.value === patientData.last_menstrual_period_days)?.value}
          help={i18n.t('patient.dashboard.called_on', { date: patientData.initial_call_date_display })}
          onChange={e => autosave({ last_menstrual_period_days: e.target.value })}
        />
      </div>

      <Input
        id="patient_appointment_date"
        name="patient[appointment_date]"
        label={i18n.t('patient.shared.appt_date')}
        type="date"
        help={
          i18n.t('patient.dashboard.approx_gestation', {
            weeks: patientData.last_menstrual_period_at_appt_weeks,
            days: patientData.last_menstrual_period_at_appt_days
          })
        }
        value={patientData.appointment_date}
        onChange={e => debouncedAutosave({ appointment_date: e.target.value })}
      />

      <Input
        id="patient_primary_phone"
        name="patient[primary_phone]"
        label={i18n.t('patient.dashboard.phone')}
        value={patientData.primary_phone_display}
        onChange={e => debouncedAutosave({ primary_phone: e.target.value })}
      />

      <div className="grid grid-columns-2">
        <Input
          id="patient_pronouns"
          name="patient[pronouns]"
          label={i18n.t('activerecord.attributes.patient.pronouns')}
          value={patientData.pronouns}
          onChange={e => debouncedAutosave({ pronouns: e.target.value })}
        />

        <Input
          id="patient_status_display"
          label={i18n.t('patient.shared.status')}
          value={patientData.status}
          className="form-control-plaintext"
          disabled={true}
          tooltip={patientData.status_help_text ? <Tooltip text={patientData.status_help_text} /> : null}
        />
      </div>


      <div>
        {isAdmin && (
          <>
            <label>{i18n.t('patient.dashboard.delete_label')}</label>
            <div>
              <a className="btn btn-danger" data-confirm={i18n.t('patient.dashboard.confirm_del', { name: patient.name })} rel="nofollow" data-method="delete" href={patientPath}>{i18n.t('patient.dashboard.delete')}</a>
            </div>
          </>
        )}
      </div>
    </form>
  )
};

mount({
  PatientDashboardForm,
});
