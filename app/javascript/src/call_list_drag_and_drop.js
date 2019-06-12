// http://stackoverflow.com/questions/1307705/jquery-ui-sortable-with-table-and-tr-width/1372954#1372954
// http://benw.me/posts/sortable-bootstrap-tables/

import 'jquery-ui/ui/widgets/sortable';
import 'jquery-ui/ui/effects/effect-highlight';

$(document).on('turbolinks:load', () => {
  $('#call_list td').each((index, element) => $(element).css('width', $(element).width()));

  $('#call_list').sortable({
    placeholder: 'ui-state-highlight',
    axis: 'y',
    items: '.patient-data',
    cursor: 'move',
    sort(e, ui) {
      return ui.item.addClass('active-item-shadow');
    },
    stop(e, ui) {
      ui.item.removeClass('active-item-shadow');
      // highlight the row on drop to indicate an update
      return ui.item.children('td').effect('highlight', { color: '#ece0ff' }, 500);
    },
    update(e, ui) {
      const itemId = ui.item[0].id;
      const rows = $(`#${itemId}`).parent().children();
      const order = rows.toArray().map(x => x.id);

      const token = $('meta[name="csrf-token"]').attr('content');

      return $.ajax({
        type: 'PATCH',
        url: '/call_lists/reorder_call_list',
        dataType: 'text',
        beforeSend: function(xhr) {
            xhr.setRequestHeader('X-CSRF-Token', token)
        },
        data: { order },
        // error: function(req, status, err) {
        //   console.error(req, status, err);
        // },
      });
    },
  });
});
