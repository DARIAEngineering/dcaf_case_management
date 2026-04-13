import { Controller } from "@hotwired/stimulus"

// Re-initializes stupidtable sorting when a table is inserted via Turbo Stream.
// Attach with data-controller="table-sort" on the <table> element.
export default class extends Controller {
  connect() {
    var stupidtable = $(this.element).stupidtable()

    stupidtable.on('beforetablesort', function(event, data) {
      return stupidtable.find('th').filter(function(i) {
        return i !== data.column
      }).find('.arrow').html('[-]')
    })

    stupidtable.on('aftertablesort', function(event, data) {
      var arrow = data.direction === $.fn.stupidtable.dir.ASC ? '[&uarr;]' : '[&darr;]'
      return stupidtable.find('th').eq(data.column).find('.arrow').html(arrow)
    })
  }
}
