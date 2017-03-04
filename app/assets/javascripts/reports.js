// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/

$(function() {
  ['weekly_report', 'monthly_report', 'yearly_report'].forEach(function(reportName) {
    var chart = c3.generate({
      bindto: '#chart-' + reportName,
      data: {
          json: [
            gon[reportName]['DC'],
            gon[reportName]['MD'],
            gon[reportName]['VA']
          ],
          type: 'bar',
          keys: {
            x: 'name',
            value: ['patients_contacted', 'new_patients_contacted', 'pledges_sent'],
          }
      },
      bar: {
          width: {
              ratio: 0.5
          }
      },
      axis: {
        x: {
          type: 'category'
        }
      }
    });
  });
});
