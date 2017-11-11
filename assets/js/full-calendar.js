const initialize_calendar = function() {
  $('.calendar').each(function(){
    var calendar = $(this);
    calendar.fullCalendar({
      events: '/api/v1/events',
    });
  });
};

$(document).ready(initialize_calendar);
