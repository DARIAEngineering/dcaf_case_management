# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "click", "#toggle-call-log", ->
  $(".old-calls").toggleClass("hidden")
  html = if $(".old-calls").hasClass("hidden") then "View all calls" else "Limit list"
  $("#toggle-call-log").html(html)

$(document).on "change", ".edit_patient", ->
  $(this).submit()

$(document).on "click", ".add-button", ->
  value = $(".pledges-select").val()
  if value == ""
    alert("You have to select a value from the dropdown menu!")
  else
    html = """
          <div class="form-group">
            <label class="control-label"> #{value} </label>
            <div class="input-group">
              <span class="input-group-addon">$</span>
              <input type="text" autocomplete="off" class="form-control">
            </div>
          </div>
          """
    $("#pledge-contributions").append(html)

