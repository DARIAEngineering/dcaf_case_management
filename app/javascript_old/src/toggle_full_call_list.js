// Toggle a patient call list between recent few and full rack.
const toggleFullCallList = () => {
  $(document).on('click', '#toggle-call-log', function() {
    $(".old-calls").toggleClass("d-none");
    const html = $(".old-calls").hasClass("d-none") ? "View all calls" : "Limit list";
    $("#toggle-call-log").html(html);
  });
};

$(document).on('DOMContentLoaded', toggleFullCallList);
