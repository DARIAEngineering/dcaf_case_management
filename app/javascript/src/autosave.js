$(document).on("turbolinks:load", () => {
    $(document).on("change", ".edit_patient", () => {
        $(this).submit();
    });

    $(document).on("change", ".edit_external_pledge", () => {
        $(this).submit();
    });
});
