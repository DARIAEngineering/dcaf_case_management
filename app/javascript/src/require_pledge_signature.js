// Require a pledge signature when generating a pledge.
document.addEventListener('DOMContentLoaded', () => {
  document.addEventListener('submit', (e) => {
    const form = e.target.closest('#generate-pledge-form');
    if (!form) return;

    if (document.getElementById('case_manager_name')?.value) {
      return true;
    } else {
      form.querySelector('.alert')?.style.setProperty('display', '');
      e.preventDefault();
      return false;
    }
  });
});
