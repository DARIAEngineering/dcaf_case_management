// Filter clinics to just whether they accept medicaid/naf
// when checking boxes in patient edit view, by graying out
// select options.
const filterClinicsByNAF = () => {
  const checked = $('#patient_naf_filter').prop('checked');
  $('#patient_clinic_id > option').each((_index, element) => {
    if ($(element).attr('data-naf') === 'false') {
      $(element).attr('disabled', checked);
    }
  });
};

const filterClinicsByMedicaid = () => {
  const checked = $('#patient_medicaid_filter').prop('checked');
  $('#patient_clinic_id > option').each((_index, element) => {
    if ($(element).attr('data-medicaid') === 'false') {
      $(element).attr('disabled', checked);
    }
  });
};

const ready = () => {
  $(document).on('click', '#patient_naf_filter', () => {
    filterClinicsByNAF();
  });

  $(document).on('click', '#patient_medicaid_filter', () => {
    filterClinicsByMedicaid();
  });
};

$(document).on('DOMContentLoaded', ready);
