const getClinics = () => $.get('/clinics', (data, status) => {
  if (status === 'success') {
    $.when(data);
  }
}, 'json');

const filterClinicsByNAF = () => {
  const checked = $('#patient_naf_filter').prop('checked');
  $('#patient_clinic_id > option').each((_index, element) => {
    if ($(element).attr('data-naf') === 'false') {
      $(element).attr('disabled', checked);
    }
  });
};

const mapNAFtoClinic = (clinics) => {
  clinics.forEach((clinic) => {
    // eslint-disable-next-line no-underscore-dangle
    const id = clinic._id.$oid;
    const acceptsNAF = clinic.accepts_naf;
    $(`#patient_clinic_id > option[value='${id}']`).attr('data-naf', acceptsNAF);
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

const mapMedicaidToClinic = (clinics) => {
  clinics.forEach((clinic) => {
    // eslint-disable-next-line no-underscore-dangle
    const id = clinic._id.$oid;
    const acceptsMedicaid = clinic.accepts_medicaid;
    $(`#patient_clinic_id > option[value='${id}']`).attr('data-medicaid', acceptsMedicaid);
  });
};

const ready = () => {
  $(document).on('click', '#patient_naf_filter', () => {
    const attr = $('#patient_clinic_id > option').last().attr('data-naf');
    if (typeof attr === 'undefined') {
      return getClinics().then(mapNAFtoClinic).then(filterClinicsByNAF);
    }
    return filterClinicsByNAF();
  });

  $(document).on('click', '#patient_medicaid_filter', () => {
    const attr = $('#patient_clinic_id > option').last().attr('data-medicaid');
    if (typeof attr === 'undefined') {
      return getClinics().then(mapMedicaidToClinic).then(filterClinicsByMedicaid);
    }
    return filterClinicsByMedicaid();
  });
};

$(document).on('turbolinks:load', ready);
