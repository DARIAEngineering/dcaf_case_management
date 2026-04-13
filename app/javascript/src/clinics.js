// Filter clinics to just whether they accept medicaid/naf
// when checking boxes in patient edit view, by graying out
// select options.
const filterClinicsByNAF = () => {
  const checked = document.getElementById('patient_naf_filter')?.checked;
  document.querySelectorAll('#patient_clinic_id > option').forEach(element => {
    if (element.dataset.naf === 'false') {
      element.disabled = checked;
    }
  });
};

const filterClinicsByMedicaid = () => {
  const checked = document.getElementById('patient_medicaid_filter')?.checked;
  document.querySelectorAll('#patient_clinic_id > option').forEach(element => {
    if (element.dataset.medicaid === 'false') {
      element.disabled = checked;
    }
  });
};

document.addEventListener('DOMContentLoaded', () => {
  document.addEventListener('click', (e) => {
    if (e.target.id === 'patient_naf_filter') filterClinicsByNAF();
    if (e.target.id === 'patient_medicaid_filter') filterClinicsByMedicaid();
  });
});
