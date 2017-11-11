const initialize_calendar = function() {
  $('.calendar').each(function(){
    var calendar = $(this);
    calendar.fullCalendar({
      // events: '/events.json',
    });
  });
};

$(document).ready(initialize_calendar);
