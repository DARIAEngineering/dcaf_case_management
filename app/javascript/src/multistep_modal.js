// Bootstrap 5 multi-step modal (replaces jquery-bootstrap-modal-steps plugin)
const activateMultiModal = () => {
  document.querySelectorAll('[id$=modal]').forEach(modal => {
    const steps = modal.querySelectorAll('.modal-step');
    if (steps.length === 0) return;

    let currentStep = 0;

    const showStep = (index) => {
      steps.forEach((step, i) => {
        step.style.display = i === index ? '' : 'none';
      });
      currentStep = index;
    };

    // Initialize: show first step
    showStep(0);

    // Next/prev button handlers
    modal.addEventListener('click', (e) => {
      if (e.target.closest('.next-step') && currentStep < steps.length - 1) {
        showStep(currentStep + 1);
      }
      if (e.target.closest('.prev-step') && currentStep > 0) {
        showStep(currentStep - 1);
      }
    });

    // Reset to first step when modal is opened
    modal.addEventListener('show.bs.modal', () => showStep(0));
  });
};

document.addEventListener('DOMContentLoaded', activateMultiModal);
