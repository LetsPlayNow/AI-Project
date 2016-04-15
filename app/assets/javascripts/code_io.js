// Codemirror - CSS + JS библиотека, выполняющая подсветку кода, нумерацию строк, форматирование и т.д.
// =====================================================================================
var code_mirror;
function preset_codemirror()
{
    code_mirror = CodeMirror.fromTextArea(document.getElementById('code'), {
        mode:  'ruby',
        theme: 'mdn-like',
        lineNumbers: true,
        tabSize: 2
    });

    jQuery('#send-code').click(send_code);
}

// Отсылает код игрока с jQuery.post
function send_code()
{
    jQuery.post('/code', {'player_code': code_mirror.getValue()}, 'json')
        .fail(function() {alert("Can't send code! Please, reload the page");}) // FIXME Нужна адекватная защита от подобных ошибок
        .done(function(data) {jQuery('#errors-text').html(data['errors']);})
}