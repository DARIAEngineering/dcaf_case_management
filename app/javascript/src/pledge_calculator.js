var updateBalance = function() {
    if ($("#patient_procedure_cost").val()) {
        $(".outstanding-balance-ctn").removeClass('hidden');
        return $("#outstanding-balance").text('$' + calculateRemainder());
    } else {
        return $(".outstanding-balance-ctn").addClass('hidden');
    }
};

var calculateRemainder = function() {
    var contributions, total;
    total = valueToNumber($("#patient_procedure_cost").val());
    contributions =
        valueToNumber($("#patient_patient_contribution").val()) +
        valueToNumber($("#patient_naf_pledge").val()) +
        valueToNumber($("#patient_fund_pledge").val()) +
        valueToNumber($(".external_pledge_amount").toArray().reduce(function(acc, next) {
        return acc + valueToNumber($(next).val());
    }, 0));
    return total - contributions;
};

var valueToNumber = function(val) {
    return +val || 0;
};

var markFulfilledWhenFieldsChecked = function() {
    var el, empty, i, pledge_fields;
    pledge_fields = ['#patient_fulfillment_fund_payout',
        '#patient_fulfillment_check_number',
        '#patient_fulfillment_gestation_at_procedure',
        '#patient_fulfillment_date_of_check',
        '#patient_fulfillment_procedure_date'];

    i = 0;
    empty = true;
    el = $('#patient_fulfillment_fulfilled');
    while (i < pledge_fields.length) {
        if ($(pledge_fields[i]).val().length > 0) {
            empty = false;
            if (el.prop('checked')) {
                break;
            } else {
                el.prop('checked', true);
            }
            i++;
        } else {
            i++;
        }
    }
    if (empty === true) {
        return el.prop('checked', false);
    }
};

$(document).on("change", "#pledge_fulfillment_form", function() {
    markFulfilledWhenFieldsChecked();
    return $(this).submit();
});

$(document).on("submit", "#generate-pledge-form form", function() {
    if ($("#case_manager_name").val()) {
        return true;
    } else {
        $("#generate-pledge-form .alert").show();
        return false;
    }
});
