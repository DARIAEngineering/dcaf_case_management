const activateMultiModal = () => {
  // select all elements with id ending with "modal"
  $('[id$=modal]').modalSteps()

};

$(document).on('DOMContentLoaded', activateMultiModal);
