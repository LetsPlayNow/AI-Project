// Send post request, when leave before game session creation
function update_game_status() {
    jQuery.getJSON('/waiting_status', function(data, textStatus) {
        console.log(data);
        if (data['game_ready'] == true) {
            console.log("We will be redirrected! Wow");
            window.location.replace('/game_page');
        }

        jQuery('#players-count').html(data['players_count']);
    });
}

// Отправить серверу оповещение о том, что игрок ушел со страницы ожидания
function cancel_waiting() {
    jQuery.post('/cancel_waiting');
}

function preset_game_waiting()
{
    var period_request = 3000; // Fixme hardcored thing
    var wait_interval  = setInterval(update_game_status, period_request);
    window.onbeforeunload = cancel_waiting;
}

jQuery(preset_game_waiting);