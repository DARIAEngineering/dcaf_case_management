
// import jquery from 'jquery';
// window.jQuery = jquery;
import 'stupid-table-plugin';

const sortTable = (table) => {
  const stupidtable = $(table).stupidtable();
  stupidtable.on('beforetablesort', (_event, data) => {
    stupidtable.find('th')
      .filter(index => index !== data.column)
      .find('.arrow')
      .html('[-]');
  });

  stupidtable.on('aftertablesort', (_event, data) => {
    const arrow = data.direction === $.fn.stupidtable.dir.ASC ? '[&uarr;]' : '[&darr;]';
    stupidtable.find('th')
      .eq(data.column)
      .find('.arrow')
      .html(arrow);
  });
};

const sortTables = () => $('table').each((_index, table) => sortTable(table));
$(document).on('turbolinks:load', sortTables);
