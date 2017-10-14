jQuery ->
  App.cable.subscriptions.create "EventChannel",
    received: (data) ->
      $('#event-list').append '<p>'+data['event']+'<p>'
