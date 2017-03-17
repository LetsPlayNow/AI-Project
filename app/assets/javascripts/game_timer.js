// Simple timer with using library EasyTimer.js
// http://albert-gonzalez.github.io/easytimer.js/#gettingTimeValuesExample
function start_timer()
{
    var to_end = seconds_remaining();
    if (to_end <= 0)
        return;

    var timer = new Timer();
    timer.start({countdown: true, startValues: {seconds: to_end}, precision: 'seconds'});
    timer.addEventListener('secondsUpdated',  function (e) {
        $('#timer-value').html(timer.getTimeValues().toString());
    });
    timer.addEventListener('targetAchieved', function (e) {
        window.location.href = '/simulation';
    });
}

function seconds_remaining()
{
    var time_str = $('#timer-value').attr('data-time-remaining');
    return parseInt(time_str);
}