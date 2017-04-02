// Найти подходящее соотношение масштаба
// * zoom - какую часть scale вернуть
function get_scale(zoom)
{
    zoom = zoom || 1;
    var scale_w = document.documentElement.clientWidth  / View.width;
    var scale_h = document.documentElement.clientHeight / View.height;
    return Math.min(scale_w, scale_h)*zoom;
}

function scale_this(value)
{
    return value * View.scale;
}

// shorter
function scale(value)
{
    return value * View.scale;
}

// TODO unit and shell inheritance from object to reduce code size
// fixme maybe we should not store x and y View.data_s
// Graphical objects (Sprites) and their parameters
function Unit(id, x, y, health, energy)
{
    // Константы
    Unit.texture;
    Unit.radius;

    // Оригинальные параметры
    this.id = id;
    this.x = x;
    this.y = y;
    this.health = health;
    this.energy = energy;

    // Мастабированные параметры
    this.x_s = scale_this(x);
    this.y_s = scale_this(y);

    //Создание и настройка спрайта
    this.sprite = new PIXI.Sprite(Unit.texture);
    this.sprite.width  = 2 * scale_this(Unit.radius); // diameter
    this.sprite.height = 2 * scale_this(Unit.radius);

    this.sprite.anchor   = new PIXI.Point(0.5, 0.5);
    this.sprite.position = new PIXI.Point(this.x_s, this.y_s);

    View.stage.addChild(this.sprite);
}

function Shell(x, y)
{
    // Константы
    Shell.texture;
    Shell.radius;

    // Оригинальные параметры
    this.x = x;
    this.y = y;

    // Масштабированные параметры
    this.x_s = scale_this(x);
    this.y_s = scale_this(y);

    //Создание и настройка спрайта
    this.sprite = new PIXI.Sprite(Shell.texture);
    this.sprite.width  = 2 * scale_this(Shell.radius);
    this.sprite.height = 2 * scale_this(Shell.radius);

    this.sprite.anchor   = new PIXI.Point(0.5, 0.5);
    this.sprite.position = new PIXI.Point(this.x_s, this.y_s);

    View.stage.addChild(this.sprite);
}

// Information View
// TODO unit sprite should be near of infomation, because you can't understand where is your unit
// TODO this will work only if sprites will be unique
function UnitInfo( x, y, name )
{
    var x_s = scale(x);
    var y_s = scale(y);
    var font = scale(0.5) + 'px Arial'; // this line seems bad
    var line_spacing = scale(0.5);

    var this_unit_info = this;
    var color_titles = [0x241C05, 0xFF2B2B, 0x322BFF, 0x75A4C1];
    ['name', 'health', 'energy', 'coordinates'].forEach(function(property, index)
    {
        this_unit_info[property] = new PIXI.Text("", {font : font , fill : color_titles[index]});
        this_unit_info[property].position = new PIXI.Point(x_s, y_s + line_spacing * index);
        View.stage.addChild(this_unit_info[property]);
    });

    this.name.text = "Name: " + name;

    this.update = function(unit) {
        this.health.text = "Health: " + unit.health;
        this.energy.text = "Energy: " + unit.energy;
        this.coordinates.text = "Coord: " + "( " + unit.x + " ; " + unit.y + " )";
    };

    this.clear = function() {
        this.health.text = "Health: 0";
        this.energy.text = "Energy: 0"
    }
}

// Фон игрового поля
// FIXME if side is bigger, Background will take more area
function Background(side)
{
    // Константы
    Background.texture;

    // Оригинальные параметры
    this.side = side;

    // Масштабированные параметры
    this.scaled_size = scale_this(this.side);

    // Настройка и создание спрайта
    this.sprite = new PIXI.Sprite(Background.texture);

    this.sprite.anchor   = new PIXI.Point(0, 0);
    this.sprite.position = new PIXI.Point(0, 0); //Привязываем к верхнему левому углу (вроде как)

    this.sprite.width  = this.scaled_size;
    this.sprite.height = this.scaled_size; //т.к. игровое поле - квадрат со стороной side

    View.stage.addChild(this.sprite);
}


function View() {
    View.s_data;
    View.world_s;
    View.background;
    View.width  = 16;
    View.height = 10;
    View.scale;
    View.renderer;
    View.stage;
    View.units_info;
    View.units;
    View.shells;

    this.run = function()
    {
        load_data(preset_and_process);
    };

    function preset_and_process()
    {
        init();
        visualize();
    }

    // Async function
    // Loads data and store it in View.s_data
    function load_data(preset_and_process_callback)
    {
        // Загружает данные, созданные симулятором
        // в случае удачи начинает загружать текстуры и запускает настройку
        jQuery.getJSON('/simulation')
            .fail(function () {
                alert("Can't load simulation data");
                throw new Error("Can't load simulation data");
            })
            .done(function (data) {
                if (data['errors'] != null)
                    return;

                console.log(data);
                View.s_data = data;
                load_textures();
            });

        function load_textures() {
            PIXI.loader
                .add('background',background_sprite_url)
                .add('unit', unit_sprite_url)
                .add('shell', shell_sprite_url)
                .load(function (loader, resources) {
                    console.log(resources);
                    Background.texture = resources.background.texture;
                    Unit.texture = resources.unit.texture;
                    Shell.texture = resources.shell.texture;
                })
                .once('complete',preset_and_process_callback);
        }
    }

    // Preset View variables
    // Create and preset renderer and stage
    // * in  : View.s_data
    // * out : stage
    // * out : renderer
    function init()
    {
        View.stage = new PIXI.Container();
        View.scale = 100;//get_scale(0.85);
        View.renderer = PIXI.autoDetectRenderer(scale_this(View.width), scale_this(View.height));
        View.renderer.backgroundColor = 0xE9E3CA;
        document.getElementById("view").appendChild(View.renderer.view);

        // Настраиваем константы
        Unit.radius  = View.s_data.options.u_radius;
        Shell.radius = View.s_data.options.s_radius;
        View.world_s = View.s_data.state;

        // Выделяем память для работы
        View.units  = [];
        View.shells = [];

        View.units_info = {};
        var index = 0;
        for (var user_id in View.s_data.users_info) {
            var user = View.s_data.users_info[user_id];
            View.units_info[user_id] = new UnitInfo(10.5, 3*index + 1, user.name);
            index += 1;
        }

        View.background = new Background(View.s_data.options.map_size);
    }

    // Visualize Simulation battle
    // Can be called many times
    // * in : View.world_s
    // TODO Передача аргументов в обработчики событий
    function visualize()
    {
        var game_clock = 0;
        var interval_id = setInterval(animate, 50);
        function animate()
        {
            if (game_clock >= View.world_s.length) {
                function stop_view() {
                    clearInterval(interval_id);
                }

                function alert_winner() {
                    var winner_id = View.s_data.options.winner_id;
                    if (winner_id == null) {
                        alert('There are no winners');
                    } else {
                        var winner = View.s_data.users_info[winner_id];
                        alert('Winner is ' + winner.name);
                    }
                }

                stop_view();
                alert_winner();
                return;
            }

            var world_state = View.world_s[game_clock];
            update_units(View.units, world_state.units);
            update_shells(View.shells, world_state.shells);
            update_info(View.units, View.shells);
            game_clock += 1; // TODO Show this somewhere

            View.renderer.render(View.stage);
        }
    }


    // units: objects for view
    // unit_s: structures with real fata from simulator
    function update_units(units, units_s)
    {
        function remove_old_units() {
            if(units.length > 0) {units.forEach(function(unit) {View.stage.removeChild(unit.sprite);})}
            units.splice(0, units.length);
        }

        function add_new_units() {
            units_s.forEach(function(unit_s)
            {units.push(new Unit(unit_s.id, unit_s.location.x, unit_s.location.y,  unit_s.state.hp, unit_s.state.mp ));})
        }

        remove_old_units();
        add_new_units();
    }

    // shells: objects for view
    // shells_s: structures with real data from simulator
    function update_shells(shells, shells_s)
    {
        function remove_old_shells() {
            if (shells.length > 0) {shells.forEach(function(shell) {View.stage.removeChild(shell.sprite);})}
            shells.splice(0, shells.length);
        }

        function add_new_shells() {
            shells_s.forEach(function(shell_s) {shells.push(new Shell(shell_s.location.x, shell_s.location.y));})
        }

        remove_old_shells();
        add_new_shells();
    }


    //Обновляет информацию о состоянии юнитов
    function update_info(units, shells)
    {
        // Когда 1 из игроков погиб, его данные тоже нужно обнулить
        function update_units_info() {
            units.forEach(function(unit) {
                // FIXME if unit.it == null we have unnecesarry memory allocation for View.units_info
                if (unit.id != null)
                    View.units_info[unit.id].update(unit);
            });
        }

        function clear_units_info() {
            for (var id in View.units_info) {
                View.units_info[id].clear();
            }
        }

        clear_units_info();
        update_units_info();
    }
}