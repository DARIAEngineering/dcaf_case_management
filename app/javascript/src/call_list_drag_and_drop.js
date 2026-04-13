// Sortable call list using SortableJS (replaces jQuery UI sortable)
import Sortable from 'sortablejs';

document.addEventListener('DOMContentLoaded', () => {
  const callList = document.getElementById('call_list');
  if (!callList) return;

  const tbody = callList.querySelector('tbody') || callList;

  Sortable.create(tbody, {
    animation: 150,
    handle: '.patient-data',
    draggable: '.patient-data',
    ghostClass: 'ui-state-highlight',
    chosenClass: 'active-item-shadow',
    onEnd(evt) {
      // Highlight dropped row
      const item = evt.item;
      item.querySelectorAll('td').forEach(td => {
        td.style.backgroundColor = '#ece0ff';
        setTimeout(() => { td.style.backgroundColor = ''; }, 500);
      });

      // Send new order to server
      const rows = Array.from(tbody.querySelectorAll('.patient-data'));
      const order = rows.map(r => r.id);
      const token = document.querySelector('meta[name="csrf-token"]')?.content;

      fetch('/call_lists/reorder_call_list', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-CSRF-Token': token,
        },
        body: order.map(id => `order[]=${encodeURIComponent(id)}`).join('&'),
      });
    },
  });
});
