document.addEventListener('DOMContentLoaded', () => {
  document.addEventListener('click', (e) => {
    if (e.target.closest('.clinic-finder-expand')) {
      document.getElementById('clinic-finder-search-form')?.classList.toggle('d-none');
    }
  });
});
