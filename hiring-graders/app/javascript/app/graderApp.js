let calendarOpened = false;
$( document ).on('turbolinks:load', function() {
  calendarOpened = false;
});
/**
 * Add a new row to the form to fill out grades
 */
addGradeRow = function () {

  const graderAppForm = $('.form-group div.gradeRow:last').parent()
  let numClasses = $('.form-group .gradeRow').length + 1;
  let gradeRow = $('.form-group .gradeRow:last').clone();
  gradeRow.find(".courseNum")[0].name = `courseNum${(numClasses)}`;
  gradeRow.find(".grade")[0].name = `grade${(numClasses)}`;
  gradeRow.find(".gradeInterest")[0].name = `grade${(numClasses)}`;

  gradeRow.appendTo(graderAppForm);
  $('.form-group .gradeRow .classAddIcon').each(function () {
    $(this).css("display", "none");
  })
  $('.form-group .gradeRow .classAddIcon:last').each(function () {
    $(this).css("display", "block");
  })

}

showGradeForm = function () {
  $('.studentGradeForm').css('display', 'block');
  $('.studentAvailabilityForm').css('display', 'none');
}
/**
 * Generate the availability calendar
 * SOURCE FOR WEEKLY SCHEDULE LOGIC: 
 * https://github.com/shonihei/weekly-scheduler-component
 */
displayWeeklyCalendar = function () {
  const settings = {
    days: [ "mon", "tue", "wed", "thu", "fri"], // Days displayed
    hours: "8:00AM-8:00PM", // Hours displyed
    fontFamily: "sans-serif", // Font used in the component
    fontColor: "#212529", // Font colot used in the component
    fontWeight: "80", // Font weight used in the component
    fontSize: "1.3em", // Font size used in the component
    headerBackgroundColor: "transparent", // Background color of headers
  }
  $(".studentGradeForm").css('display', 'none');
  $('.studentAvailabilityForm').css('display', 'block');

  if(!calendarOpened) {
    $('#targetCalendar').weekly_schedule(settings);

  } 
  calendarOpened = true;
}

saveAvailability = function () {
  let allAvailableHours = {}
    
  const selectedHours = $('#targetCalendar').weekly_schedule('getSelectedHour');
  for(column in selectedHours) {
  let hoursAvailable = [];
    if(selectedHours[column].length > 0) {
      for(hour of selectedHours[column]) {
        hoursAvailable.push(hour.classList[1])
      }
    }
    allAvailableHours[column] = hoursAvailable;
  }
  $.ajax({ 
    type: 'POST', 
    url: '/student/availability', 
    data: allAvailableHours, 
    success: function(data){
    } 
  });
}
showApplicationStatus = function () {
  $(".appStatus").toggleClass('active');
  const text = $("#appStatusButton").text();
  $("#appStatusButton").text(text == "Application Status" ? "Hide Application Status": "Application Status");
}
backToStudentProfile = function () {
  window.history.back();
}