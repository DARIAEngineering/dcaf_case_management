// Make table elements sortable using Tablesort.
import Tablesort from 'tablesort';

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('table[data-sort]').forEach(table => {
    new Tablesort(table);
  });
});
