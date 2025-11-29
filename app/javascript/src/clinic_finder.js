$(document).on('DOMContentLoaded', () => {
  // Click on the clinic-locator expand to show it.
  $(document).on('click', '.clinic-finder-expand', () => {
    $('#clinic-finder-search-form').toggleClass('d-none');
  });
});
