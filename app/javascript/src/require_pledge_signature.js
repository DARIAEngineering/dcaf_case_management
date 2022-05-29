// Require a pledge signature when generating a pledge.

const requirePledgeSignature = () => {
  $(document).on('submit', '$generate-pledge-form', function() {
    if ($('#case_manager_name').val()) {
      return true;
    } else {
      $("#generate-pledge-form .alert").show();
      return false;
    }
  });
};

$(document).on('turbolinks:load', requirePledgeSignature);
