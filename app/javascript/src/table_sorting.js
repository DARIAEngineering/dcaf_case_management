// Make table elements sortable using Tablesort.
import Tablesort from 'tablesort';

function initSortableTables() {
  document.querySelectorAll('table[data-sort]').forEach(table => {
    if (!table._tablesort) {
      table._tablesort = new Tablesort(table);
    }
  });
}

document.addEventListener('DOMContentLoaded', initSortableTables);
document.addEventListener('turbo:load', initSortableTables);
document.addEventListener('turbo:frame-load', initSortableTables);
