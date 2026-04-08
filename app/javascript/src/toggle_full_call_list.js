// Toggle a patient call list between recent few and full rack.
document.addEventListener('DOMContentLoaded', () => {
  document.addEventListener('click', (e) => {
    if (e.target.id === 'toggle-call-log' || e.target.closest('#toggle-call-log')) {
      document.querySelectorAll('.old-calls').forEach(el => el.classList.toggle('d-none'));
      const hidden = document.querySelector('.old-calls')?.classList.contains('d-none');
      document.getElementById('toggle-call-log').innerHTML = hidden ? 'View all calls' : 'Limit list';
    }
  });
});
