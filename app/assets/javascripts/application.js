// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require turbolinks
//= require bootstrap-sprockets
//= require google_analytics
//= require_tree .
//= require_tree ../../../vendor/assets/javascripts/.

$(document).ready(function(){
  // TODO migrate to pledges.coffee
	$('.pledge_submit').click(function () {
		$('.pledge_modal_screen1').hide();
		$('.pledge_modal_screen2').show();
	});

	$('.pledge_back_submit').click(function () {
		$('.pledge_modal_screen2').hide();
		$('.pledge_modal_screen1').show();
	});

	$('.pledge_continue').click(function () {
		$('.pledge_modal_screen2').hide();
		$('.pledge_modal_screen3').show();
				console.log('click');
	});

	$('.pledge_back_review').click(function () {
		$('.pledge_modal_screen3').hide();
		$('.pledge_modal_screen2').show();
	});

	$('.pledge_finish').click(function () {
		$('.pledge_modal_screen3').hide();
	});

  $('[data-toggle="toggle"]').bootstrapToggle();


  // TODO migrate to calls.coffee

    $('#call_list').sortable({
      placeholder: "ui-state-highlight",
      axis: 'y',
      items: '.pregnancy-data',
      handle: '.handle',
      helper: fixHelper,
    });


var fixHelper = function(e, tr) {
    var $originals = tr.children();
    var $helper = tr.clone();
    $helper.children().each(function(index)
    {
      $(this).width($originals.eq(index).width())
    });
    console.log("halp");
    return $helper;
};



//#    $( "#call_list_content" ).disableSelection();

//    fixHelper = (e, ui) -> bar * baz




})
