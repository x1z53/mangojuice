using Gtk;
using GLib;
using Adw;
using Gee;

public class MangoJuice : Adw.Application {
    private Button saveButton;
    private Button resetButton;
    private Button logsPathButton;
    private Switch[] gpu_switches;
    private Switch[] cpu_switches;
    private Switch[] other_switches;
    private Switch[] system_switches;
    private Switch[] wine_switches;
    private Switch[] options_switches;
    private Switch[] battery_switches;
    private Switch[] other_extra_switches;
    private Switch[] box3_switches;
    private Label[] gpu_labels;
    private Label[] cpu_labels;
    private Label[] other_labels;
    private Label[] system_labels;
    private Label[] wine_labels;
    private Label[] options_labels;
    private Label[] battery_labels;
    private Label[] other_extra_labels;
    private Label[] box3_labels;
    private Entry custom_command_entry;
    private Entry custom_logs_path_entry;
    private DropDown logs_key_combo;
    private DropDown fps_limit_method;
    private DropDown toggle_fps_limit;
    private DropDown vulcan_dropdown;
    private DropDown opengl_dropdown;
    private Scale duracion_scale;
    private Scale autostart_scale;
    private Scale interval_scale;
    private Scale scale;
    private Label duracion_value_label;
    private Label autostart_value_label;
    private Label interval_value_label;
    private Label fps_limit_label;
    private StringList logs_key_model;

    private DropDown filter_dropdown;
    private Scale filter_scale1;
    private Scale filter_scale2;
    private Label filter_scale1_label;
    private Label filter_scale2_label;

    private const string GPU_TITLE = "GPU";
    private const string CPU_TITLE = "CPU";
    private const string OTHER_TITLE = "Other";
    private const string SYSTEM_TITLE = "System";
    private const string WINE_TITLE = "Wine";
    private const string OPTIONS_TITLE = "Options";
    private const string BATTERY_TITLE = "Battery";
    private const string OTHER_EXTRA_TITLE = "Other Extras";
    private const string BOX3_TITLE = "Infotmation";
    private const string LIMITERS_TITLE = "Limiters FPS";
    private const string FILTERS_TITLE = "Filters";

    private const int MAIN_BOX_SPACING = 10;
    private const int FLOW_BOX_ROW_SPACING = 10;
    private const int FLOW_BOX_COLUMN_SPACING = 10;
    private const int FLOW_BOX_MARGIN = 10;

    private bool vkcube_was_running = false;

    private string[] gpu_config_vars = {
        "gpu_stats", "gpu_load_change", "vram", "gpu_core_clock", "gpu_mem_clock",
        "gpu_temp", "gpu_mem_temp", "gpu_junction_temp", "gpu_fan", "gpu_name",
        "gpu_power", "gpu_voltage", "throttling_status", "throttling_status_graph", "vulkan_driver"
    };
    private string[] cpu_config_vars = {
        "cpu_stats", "cpu_load_change", "core_load", "cpu_mhz", "cpu_temp",
        "cpu_power"
    };
    private string[] other_config_vars = {
        "ram", "io_stats", "procmem", "swap"
    };
    private string[] system_config_vars = {
        "exec=lsb_release -d | cut -f2", "refresh_rate", "resolution", "exec=echo $XDG_SESSION_TYPE",
        "time", "arch"
    };
    private string[] wine_config_vars = {
        "wine", "engine", "engine_short_names"
    };
    private string[] battery_config_vars = {
        "battery", "battery_watt", "battery_time", "device_battery"
    };
    private string[] other_extra_config_vars = {
        "media_player", "network", "full", "log_versioning", "upload_logs"
    };
    private string[] box3_config_vars = {
        "fps", "fps_metrics=avg,0.01", "fps_metrics=avg,0.001", "show_fps_limit", "frame_timing", "histogram", "frame_count"
    };
    private string[] options_config_vars = {
        "version", "gamemode", "vkbasalt", "fcat", "fsr", "hdr"
    };
    private string[] gpu_label_texts = {
        "GPU Load", "Load Color", "VRAM", "Core Freq", "Mem Freq",
        "GPU Temp", "Memory Temp", "Juntion", "Fans", "Model",
        "Power", "Voltage", "Throttling", "Throttling GRAPH", "Vulcan Driver"
    };
    private string[] cpu_label_texts = {
        "CPU Load", "CPU Load Color", "CPU Core Load", "CPU Freq", "CPU Temp",
        "CPU Power"
    };
    private string[] other_label_texts = {
        "RAM", "Disk IO", "Procces", "Swap"
    };
    private string[] system_label_texts = {
        "Distro", "Refresh rate*", "Resolution", "Session",
        "Time", "Arch"
    };
    private string[] wine_label_texts = {
        "Version", "Engine Ver", "Short names"
    };
    private string[] options_label_texts = {
        "Hud Version", "Gamemode", "VKbasalt", "Fcat", "FSR*", "HDR*"
    };
    private string[] battery_label_texts = {
        "Percentage", "Wattage", "Time remain", "Device"
    };
    private string[] other_extra_label_texts = {
        "Media", "Network", "Full ON", "Log Versioning", "Upload Results"
    };
    private string[] box3_label_texts = {
        "FPS", "FPS low 1%", "FPS low 0.1%", "Frame limit", "Frame time", "Histogram/Curve", "Frame"
    };

    private Entry custom_text_entry;

    public MangoJuice() {
        Object(application_id: "com.radiolamp.mangojuice", flags: ApplicationFlags.DEFAULT_FLAGS);
        set_resource_base_path("/usr/local/share/icons/hicolor/scalable/apps/");
    }

    protected override void activate() {
        var window = new Adw.ApplicationWindow(this);
        window.set_default_size(980, 600);
        window.set_title("MangoJuice");

        var main_box = new Box(Orientation.VERTICAL, MAIN_BOX_SPACING);
        main_box.set_homogeneous(true);

        var scrolled_window = new ScrolledWindow();
        scrolled_window.set_policy(PolicyType.NEVER, PolicyType.AUTOMATIC);
        scrolled_window.set_vexpand(true);

        var view_stack = new ViewStack();
        var toolbar_view_switcher = new ViewSwitcher();
        toolbar_view_switcher.stack = view_stack;

        var box1 = new Box(Orientation.VERTICAL, MAIN_BOX_SPACING);
        var box2 = new Box(Orientation.VERTICAL, MAIN_BOX_SPACING);
        var box3 = new Box(Orientation.VERTICAL, MAIN_BOX_SPACING);
        var box4 = new Box(Orientation.VERTICAL, MAIN_BOX_SPACING);

        gpu_switches = new Switch[gpu_config_vars.length];
        cpu_switches = new Switch[cpu_config_vars.length];
        other_switches = new Switch[other_config_vars.length];
        system_switches = new Switch[system_config_vars.length];
        wine_switches = new Switch[wine_config_vars.length];
        options_switches = new Switch[options_config_vars.length];
        battery_switches = new Switch[battery_config_vars.length];
        other_extra_switches = new Switch[other_extra_config_vars.length];
        box3_switches = new Switch[box3_config_vars.length];

        gpu_labels = new Label[gpu_label_texts.length];
        cpu_labels = new Label[cpu_label_texts.length];
        other_labels = new Label[other_label_texts.length];
        system_labels = new Label[system_label_texts.length];
        wine_labels = new Label[wine_label_texts.length];
        options_labels = new Label[options_label_texts.length];
        battery_labels = new Label[battery_label_texts.length];
        other_extra_labels = new Label[other_extra_label_texts.length];
        box3_labels = new Label[box3_label_texts.length];

        create_switches_and_labels(box1, GPU_TITLE, gpu_switches, gpu_labels, gpu_config_vars, gpu_label_texts);
        create_switches_and_labels(box1, CPU_TITLE, cpu_switches, cpu_labels, cpu_config_vars, cpu_label_texts);
        create_switches_and_labels(box1, OTHER_TITLE, other_switches, other_labels, other_config_vars, other_label_texts);

        create_switches_and_labels(box2, SYSTEM_TITLE, system_switches, system_labels, system_config_vars, system_label_texts);
        create_switches_and_labels(box2, WINE_TITLE, wine_switches, wine_labels, wine_config_vars, wine_label_texts);
        create_switches_and_labels(box2, OPTIONS_TITLE, options_switches, options_labels, options_config_vars, options_label_texts);
        create_switches_and_labels(box2, BATTERY_TITLE, battery_switches, battery_labels, battery_config_vars, battery_label_texts);
        create_switches_and_labels(box2, OTHER_EXTRA_TITLE, other_extra_switches, other_extra_labels, other_extra_config_vars, other_extra_label_texts);

        create_scales_and_labels(box2);

        create_switches_and_labels(box3, BOX3_TITLE, box3_switches, box3_labels, box3_config_vars, box3_label_texts);

        var limiters_label = new Label(LIMITERS_TITLE);
        limiters_label.set_halign(Align.CENTER);
        limiters_label.set_margin_top(FLOW_BOX_MARGIN);
        limiters_label.set_margin_start(FLOW_BOX_MARGIN);
        limiters_label.set_margin_end(FLOW_BOX_MARGIN);
        box3.append(limiters_label);

        fps_limit_method = new DropDown(new StringList(new string[] { "late", "early" }), null);
        scale = new Scale.with_range(Orientation.HORIZONTAL, 0, 240, 1);
        fps_limit_label = new Label("");
        scale.value_changed.connect(() => fps_limit_label.label = "%d".printf((int)scale.get_value()));
        toggle_fps_limit = new DropDown(new StringList(new string[] { "Shift_L+F1", "Shift_L+F2", "Shift_L+F3", "Shift_L+F4" }), null);

        var limiters_box = new Box(Orientation.HORIZONTAL, MAIN_BOX_SPACING);
        limiters_box.set_margin_start(FLOW_BOX_MARGIN);
        limiters_box.set_margin_end(FLOW_BOX_MARGIN);
        limiters_box.set_margin_top(FLOW_BOX_MARGIN);
        limiters_box.set_margin_bottom(FLOW_BOX_MARGIN);
        limiters_box.set_hexpand(true);  // Устанавливаем растягивание по горизонтали

        scale.set_hexpand(true);  // Устанавливаем растягивание по горизонтали для ползунка

        limiters_box.append(fps_limit_method);
        limiters_box.append(scale);
        limiters_box.append(fps_limit_label);
        limiters_box.append(toggle_fps_limit);
        box3.append(limiters_box);

        var vsync_label = new Label("VSync");
        vsync_label.set_halign(Align.CENTER);
        vsync_label.set_margin_top(FLOW_BOX_MARGIN);
        vsync_label.set_margin_start(FLOW_BOX_MARGIN);
        vsync_label.set_margin_end(FLOW_BOX_MARGIN);
        box3.append(vsync_label);

        vulcan_dropdown = new DropDown(new StringList(new string[] { "Unset", "ON", "Adaptive", "Mailbox", "OFF" }), null);
        opengl_dropdown = new DropDown(new StringList(new string[] { "Unset", "ON", "Adaptive", "Mailbox", "OFF" }), null);

        var vulcan_label = new Label("Vulcan");
        vulcan_label.set_halign(Align.START);
        vulcan_label.set_margin_start(FLOW_BOX_MARGIN);
        vulcan_label.set_margin_end(FLOW_BOX_MARGIN);

        var opengl_label = new Label("OpenGL");
        opengl_label.set_halign(Align.START);
        opengl_label.set_margin_start(FLOW_BOX_MARGIN);
        opengl_label.set_margin_end(FLOW_BOX_MARGIN);

        var vsync_box = new Box(Orientation.HORIZONTAL, MAIN_BOX_SPACING);
        vsync_box.set_halign(Align.CENTER);
        vsync_box.set_margin_start(FLOW_BOX_MARGIN);
        vsync_box.set_margin_end(FLOW_BOX_MARGIN);
        vsync_box.set_margin_top(FLOW_BOX_MARGIN);
        vsync_box.set_margin_bottom(FLOW_BOX_MARGIN);
        vsync_box.append(vulcan_dropdown);
        vsync_box.append(vulcan_label);
        vsync_box.append(opengl_dropdown);
        vsync_box.append(opengl_label);
        box3.append(vsync_box);

        // Добавляем блок "Filters"
        var filters_label = new Label(FILTERS_TITLE);
        filters_label.set_halign(Align.CENTER);
        filters_label.set_margin_top(FLOW_BOX_MARGIN);
        filters_label.set_margin_start(FLOW_BOX_MARGIN);
        filters_label.set_margin_end(FLOW_BOX_MARGIN);
        box3.append(filters_label);

        filter_dropdown = new DropDown(new StringList(new string[] { "none", "bicubic", "trilinear", "retro" }), null);
        filter_dropdown.set_size_request(100, -1);  // Уменьшаем размер по горизонтали
        filter_dropdown.set_valign(Align.CENTER);  // Устанавливаем выравнивание по вертикали

        filter_scale1 = new Scale.with_range(Orientation.HORIZONTAL, 0, 16, 1);
        filter_scale1.set_hexpand(true);
        filter_scale1.set_margin_start(FLOW_BOX_MARGIN);
        filter_scale1.set_margin_end(FLOW_BOX_MARGIN);
        filter_scale1.set_margin_top(FLOW_BOX_MARGIN);
        filter_scale1.set_margin_bottom(FLOW_BOX_MARGIN);
        filter_scale1_label = new Label("");
        filter_scale1_label.set_halign(Align.END);
        filter_scale1.value_changed.connect(() => filter_scale1_label.label = "%d".printf((int)filter_scale1.get_value()));

        filter_scale2 = new Scale.with_range(Orientation.HORIZONTAL, -16, 16, 1);
        filter_scale2.set_hexpand(true);
        filter_scale2.set_margin_start(FLOW_BOX_MARGIN);
        filter_scale2.set_margin_end(FLOW_BOX_MARGIN);
        filter_scale2.set_margin_top(FLOW_BOX_MARGIN);
        filter_scale2.set_margin_bottom(FLOW_BOX_MARGIN);
        filter_scale2.set_value(0);  // Устанавливаем значение по умолчанию на середину
        filter_scale2_label = new Label("");
        filter_scale2_label.set_halign(Align.END);
        filter_scale2.value_changed.connect(() => filter_scale2_label.label = "%d".printf((int)filter_scale2.get_value()));

        var filters_box = new Box(Orientation.HORIZONTAL, MAIN_BOX_SPACING);
        filters_box.set_margin_start(FLOW_BOX_MARGIN);
        filters_box.set_margin_end(FLOW_BOX_MARGIN);
        filters_box.set_margin_top(FLOW_BOX_MARGIN);
        filters_box.set_margin_bottom(FLOW_BOX_MARGIN);
        filters_box.append(filter_dropdown);
        filters_box.append(new Label("Anisotropic filtering"));
        filters_box.append(filter_scale1);
        filters_box.append(filter_scale1_label);
        filters_box.append(new Label("Mipmap LoD bias"));
        filters_box.append(filter_scale2);
        filters_box.append(filter_scale2_label);
        box3.append(filters_box);

        view_stack.add_titled(box1, "box1", "Metrics").icon_name = "view-continuous-symbolic";
        view_stack.add_titled(box2, "box2", "Extras").icon_name = "application-x-addon-symbolic";
        view_stack.add_titled(box3, "box3", "Performance").icon_name = "emblem-system-symbolic";
        view_stack.add_titled(box4, "box4", "Visual").icon_name = "preferences-desktop-appearance-symbolic";

        custom_command_entry = new Entry();
        custom_command_entry.placeholder_text = "Raw Custom Cmd";

        custom_logs_path_entry = new Entry();
        custom_logs_path_entry.placeholder_text = "Home";

        logsPathButton = new Button.with_label("Folder logs");
        logsPathButton.clicked.connect(() => open_folder_chooser_dialog());

        logs_key_model = new StringList(new string[] { "Shift_L+F2", "Shift_L+F3", "Shift_L+F4", "Shift_L+F5" });
        logs_key_combo = new DropDown(logs_key_model, null);
        logs_key_combo.notify["selected-item"].connect(() => {
            if (logs_key_combo.selected_item != null) {
                update_logs_key_in_file((logs_key_combo.selected_item as StringObject).get_string());
            }
        });

        resetButton = new Button.with_label("Reset Config");
        resetButton.add_css_class("destructive-action");
        resetButton.clicked.connect(() => {
            delete_mangohub_conf();
            restart_application();
        });

        var custom_command_box = new Box(Orientation.HORIZONTAL, MAIN_BOX_SPACING);
        custom_command_box.set_margin_start(FLOW_BOX_MARGIN);
        custom_command_box.set_margin_end(FLOW_BOX_MARGIN);
        custom_command_box.set_margin_top(FLOW_BOX_MARGIN);
        custom_command_box.set_margin_bottom(FLOW_BOX_MARGIN);
        custom_command_box.append(custom_command_entry);
        custom_command_box.append(new Label("Logs key"));
        custom_command_box.append(logs_key_combo);
        custom_command_box.append(new Label(""));
        custom_command_box.append(custom_logs_path_entry);
        custom_command_box.append(logsPathButton);
        custom_command_box.append(resetButton);
        box2.append(custom_command_box);

        var header_bar = new Adw.HeaderBar();
        header_bar.set_title_widget(toolbar_view_switcher);

        saveButton = new Button.with_label("Save");
        saveButton.add_css_class("suggested-action");
        header_bar.pack_end(saveButton);
        saveButton.clicked.connect(() => {
            save_states_to_file();
            restart_vkcube();
        });

        var testButton = new Button.with_label("Test");
        testButton.clicked.connect(() => {
            try {
                Process.spawn_command_line_sync("pkill vkcube");
                Process.spawn_command_line_async("mangohud vkcube");
            } catch (Error e) {
                stderr.printf("Ошибка при запуске команды: %s\n", e.message);
            }
        });
        header_bar.pack_start(testButton);

        var content_box = new Box(Orientation.VERTICAL, 0);
        content_box.append(header_bar);
        content_box.append(scrolled_window);
        window.set_content(content_box);
        scrolled_window.set_child(view_stack);

        window.present();
        load_states_from_file();
        vkcube_was_running = is_vkcube_running();

        // Добавляем обработчик события закрытия окна
        window.close_request.connect(() => {
            if (is_vkcube_running()) {
                try {
                    Process.spawn_command_line_sync("pkill vkcube");
                } catch (Error e) {
                    stderr.printf("Ошибка при закрытии vkcube: %s\n", e.message);
                }
            }
            return false;
        });

        box3_switches[1].notify["active"].connect(() => {
            if (box3_switches[1].active) {
                box3_switches[2].active = false;
            }
        });

        box3_switches[2].notify["active"].connect(() => {
            if (box3_switches[2].active) {
                box3_switches[1].active = false;
            }
        });

        // Добавляем поле ввода текста в box4
        custom_text_entry = new Entry();
        custom_text_entry.placeholder_text = "You Text";
        custom_text_entry.hexpand = true; // Устанавливаем растягивание по горизонтали
        custom_text_entry.set_margin_start(25); // Добавляем отступы по 5 пикселей
        custom_text_entry.set_margin_end(25);
        custom_text_entry.set_margin_top(10);
        custom_text_entry.set_margin_bottom(10);
        custom_text_entry.changed.connect(() => save_custom_text_to_file());

        box4.append(custom_text_entry);
    }

    private void create_switches_and_labels(Box parent_box, string title, Switch[] switches, Label[] labels, string[] config_vars, string[] label_texts) {
        var label = new Label(title);
        label.set_halign(Align.CENTER);
        label.set_margin_top(FLOW_BOX_MARGIN);
        label.set_margin_start(FLOW_BOX_MARGIN);
        label.set_margin_end(FLOW_BOX_MARGIN);
        parent_box.append(label);

        var flow_box = new FlowBox();
        flow_box.set_homogeneous(true);
        flow_box.set_max_children_per_line(5);
        flow_box.set_min_children_per_line(3);
        flow_box.set_row_spacing(FLOW_BOX_ROW_SPACING);
        flow_box.set_column_spacing(FLOW_BOX_COLUMN_SPACING);
        flow_box.set_margin_start(FLOW_BOX_MARGIN);
        flow_box.set_margin_end(FLOW_BOX_MARGIN);
        flow_box.set_margin_top(FLOW_BOX_MARGIN);
        flow_box.set_margin_bottom(FLOW_BOX_MARGIN);
        flow_box.set_selection_mode(SelectionMode.NONE);

        for (int i = 0; i < config_vars.length; i++) {
            var row_box = new Box(Orientation.HORIZONTAL, MAIN_BOX_SPACING);
            switches[i] = new Switch();
            labels[i] = new Label(label_texts[i]);
            labels[i].set_halign(Align.START);
            row_box.append(switches[i]);
            row_box.append(labels[i]);
            flow_box.insert(row_box, -1);
        }

        parent_box.append(flow_box);
    }

    private void create_scales_and_labels(Box parent_box) {
        duracion_scale = new Scale.with_range(Orientation.HORIZONTAL, 0, 200, 1);
        duracion_scale.set_value(0);
        duracion_scale.set_hexpand(true);
        duracion_scale.set_margin_start(FLOW_BOX_MARGIN);
        duracion_scale.set_margin_end(FLOW_BOX_MARGIN);
        duracion_scale.set_margin_top(FLOW_BOX_MARGIN);
        duracion_scale.set_margin_bottom(FLOW_BOX_MARGIN);
        duracion_value_label = new Label("");
        duracion_value_label.set_halign(Align.END);
        duracion_scale.value_changed.connect(() => duracion_value_label.label = "%d s".printf((int)duracion_scale.get_value()));

        autostart_scale = new Scale.with_range(Orientation.HORIZONTAL, 0, 30, 1);
        autostart_scale.set_value(0);
        autostart_scale.set_hexpand(true);
        autostart_scale.set_margin_start(FLOW_BOX_MARGIN);
        autostart_scale.set_margin_end(FLOW_BOX_MARGIN);
        autostart_scale.set_margin_top(FLOW_BOX_MARGIN);
        autostart_scale.set_margin_bottom(FLOW_BOX_MARGIN);
        autostart_value_label = new Label("");
        autostart_value_label.set_halign(Align.END);
        autostart_scale.value_changed.connect(() => autostart_value_label.label = "%d s".printf((int)autostart_scale.get_value()));

        interval_scale = new Scale.with_range(Orientation.HORIZONTAL, 0, 500, 1);
        interval_scale.set_value(0);
        interval_scale.set_hexpand(true);
        interval_scale.set_margin_start(FLOW_BOX_MARGIN);
        interval_scale.set_margin_end(FLOW_BOX_MARGIN);
        interval_scale.set_margin_top(FLOW_BOX_MARGIN);
        interval_scale.set_margin_bottom(FLOW_BOX_MARGIN);
        interval_value_label = new Label("");
        interval_value_label.set_halign(Align.END);
        interval_scale.value_changed.connect(() => interval_value_label.label = "%d ms".printf((int)interval_scale.get_value()));

        var scales_box = new Box(Orientation.HORIZONTAL, MAIN_BOX_SPACING);
        scales_box.set_margin_start(FLOW_BOX_MARGIN);
        scales_box.set_margin_end(FLOW_BOX_MARGIN);
        scales_box.set_margin_top(FLOW_BOX_MARGIN);
        scales_box.set_margin_bottom(FLOW_BOX_MARGIN);
        scales_box.append(new Label("Duracion"));
        scales_box.append(duracion_scale);
        scales_box.append(duracion_value_label);
        scales_box.append(new Label("Autostart"));
        scales_box.append(autostart_scale);
        scales_box.append(autostart_value_label);
        scales_box.append(new Label("Interval"));
        scales_box.append(interval_scale);
        scales_box.append(interval_value_label);

        var logging_label = new Label("Logging");
        logging_label.set_valign(Align.CENTER);
        logging_label.set_margin_top(FLOW_BOX_MARGIN);
        logging_label.set_margin_start(FLOW_BOX_MARGIN);
        logging_label.set_margin_end(FLOW_BOX_MARGIN);
        parent_box.append(logging_label);
        parent_box.append(scales_box);
    }

    private void save_states_to_file() {
        var config_dir = File.new_for_path(Environment.get_home_dir()).get_child(".config").get_child("MangoHud");
        if (!config_dir.query_exists()) {
            try {
                config_dir.make_directory_with_parents();
            } catch (Error e) {
                stderr.printf("Ошибка при создании директории: %s\n", e.message);
                return;
            }
        }

        var file = config_dir.get_child("MangoHud.conf");
        try {
            var file_stream = file.replace(null, false, FileCreateFlags.NONE);
            var data_stream = new DataOutputStream(file_stream);
            data_stream.put_string("################### File Generated by MangoJuice ###################\n");
            data_stream.put_string("legacy_layout=false\n");

            var custom_text = custom_text_entry.text;
            if (custom_text != "") {
                data_stream.put_string("custom_text_center=%s\n".printf(custom_text));
            }

            save_switches_to_file(data_stream, box3_switches, box3_config_vars);
            save_switches_to_file(data_stream, gpu_switches, gpu_config_vars);
            save_switches_to_file(data_stream, cpu_switches, cpu_config_vars);
            save_switches_to_file(data_stream, other_switches, other_config_vars);
            save_switches_to_file(data_stream, system_switches, system_config_vars);
            save_switches_to_file(data_stream, battery_switches, battery_config_vars);
            save_switches_to_file(data_stream, other_extra_switches, other_extra_config_vars);
            save_switches_to_file(data_stream, wine_switches, wine_config_vars);
            save_switches_to_file(data_stream, options_switches, options_config_vars);

            var custom_command = custom_command_entry.text;
            if (custom_command != "") {
                data_stream.put_string("%s\n".printf(custom_command));
            }

            if (logs_key_combo.selected_item != null) {
                var logs_key = (logs_key_combo.selected_item as StringObject).get_string();
                if (logs_key != "") {
                    data_stream.put_string("toggle_logging=%s\n".printf(logs_key));
                }
            }

            data_stream.put_string("log_duration=%d\n".printf((int)duracion_scale.get_value()));
            data_stream.put_string("autostart_log=%d\n".printf((int)autostart_scale.get_value()));
            data_stream.put_string("log_interval=%d\n".printf((int)interval_scale.get_value()));

            var custom_logs_path = custom_logs_path_entry.text;
            if (custom_logs_path != "") {
                data_stream.put_string("output_folder=%s\n".printf(custom_logs_path));
            }

            if (fps_limit_method.selected_item != null) {
                var fps_limit_method_value = (fps_limit_method.selected_item as StringObject).get_string();
                data_stream.put_string("fps_limit_method=%s\n".printf(fps_limit_method_value));
            }

            if (toggle_fps_limit.selected_item != null) {
                var toggle_fps_limit_value = (toggle_fps_limit.selected_item as StringObject).get_string();
                data_stream.put_string("toggle_fps_limit=%s\n".printf(toggle_fps_limit_value));
            }

            data_stream.put_string("fps_limit=%d\n".printf((int)scale.get_value()));

            if (vulcan_dropdown.selected_item != null) {
                var vulcan_value = (vulcan_dropdown.selected_item as StringObject).get_string();
                var vulcan_config_value = get_vulcan_config_value(vulcan_value);
                data_stream.put_string("vsync=%s\n".printf(vulcan_config_value));
            }

            if (opengl_dropdown.selected_item != null) {
                var opengl_value = (opengl_dropdown.selected_item as StringObject).get_string();
                var opengl_config_value = get_opengl_config_value(opengl_value);
                data_stream.put_string("gl_vsync=%s\n".printf(opengl_config_value));
            }

            if (filter_dropdown.selected_item != null) {
                var filter_value = (filter_dropdown.selected_item as StringObject).get_string();
                if (filter_value != "none") {
                    data_stream.put_string("%s\n".printf(filter_value));
                }
            }

            data_stream.put_string("af=%d\n".printf((int)filter_scale1.get_value()));
            data_stream.put_string("picmip=%d\n".printf((int)filter_scale2.get_value()));

            data_stream.close();
        } catch (Error e) {
            stderr.printf("Ошибка при записи в файл: %s\n", e.message);
        }
    }

    private void save_switches_to_file(DataOutputStream data_stream, Switch[] switches, string[] config_vars) {
        for (int i = 0; i < switches.length; i++) {
            var state = switches[i].active ? "" : "#";
            try {
                data_stream.put_string("%s%s\n".printf(state, config_vars[i]));
            } catch (Error e) {
                stderr.printf("Ошибка при записи в файл: %s\n", e.message);
            }
        }
    }

    private void load_states_from_file() {
        var config_dir = File.new_for_path(Environment.get_home_dir()).get_child(".config").get_child("MangoHud");
        var file = config_dir.get_child("MangoHud.conf");
        if (!file.query_exists()) {
            return;
        }

        try {
            var file_stream = new DataInputStream(file.read());
            string line;
            while ((line = file_stream.read_line()) != null) {
                load_switch_from_file(line, gpu_switches, gpu_config_vars);
                load_switch_from_file(line, cpu_switches, cpu_config_vars);
                load_switch_from_file(line, other_switches, other_config_vars);
                load_switch_from_file(line, system_switches, system_config_vars);
                load_switch_from_file(line, wine_switches, wine_config_vars);
                load_switch_from_file(line, battery_switches, battery_config_vars);
                load_switch_from_file(line, other_extra_switches, other_extra_config_vars);
                load_switch_from_file(line, box3_switches, box3_config_vars);
                load_switch_from_file(line, options_switches, options_config_vars);

                if (line.has_prefix("custom_command=")) {
                    custom_command_entry.text = line.substring("custom_command=".length);
                }

                if (line.has_prefix("toggle_logging=")) {
                    var logs_key = line.substring("toggle_logging=".length);
                    for (uint i = 0; i < logs_key_model.get_n_items(); i++) {
                        var item = logs_key_model.get_item(i) as StringObject;
                        if (item != null && item.get_string() == logs_key) {
                            logs_key_combo.selected = i;
                            break;
                        }
                    }
                }

                if (line.has_prefix("log_duration=")) {
                    duracion_scale.set_value(int.parse(line.substring("log_duration=".length)));
                    duracion_value_label.label = "%d s".printf((int)duracion_scale.get_value());
                }
                if (line.has_prefix("autostart_log=")) {
                    autostart_scale.set_value(int.parse(line.substring("autostart_log=".length)));
                    autostart_value_label.label = "%d s".printf((int)autostart_scale.get_value());
                }
                if (line.has_prefix("log_interval=")) {
                    interval_scale.set_value(int.parse(line.substring("log_interval=".length)));
                    interval_value_label.label = "%d ms".printf((int)interval_scale.get_value());
                }

                if (line.has_prefix("output_folder=")) {
                    custom_logs_path_entry.text = line.substring("output_folder=".length);
                }

                if (line.has_prefix("fps_limit_method=")) {
                    var fps_limit_method_value = line.substring("fps_limit_method=".length);
                    for (uint i = 0; i < fps_limit_method.model.get_n_items(); i++) {
                        var item = fps_limit_method.model.get_item(i) as StringObject;
                        if (item != null && item.get_string() == fps_limit_method_value) {
                            fps_limit_method.selected = i;
                            break;
                        }
                    }
                }

                if (line.has_prefix("toggle_fps_limit=")) {
                    var toggle_fps_limit_value = line.substring("toggle_fps_limit=".length);
                    for (uint i = 0; i < toggle_fps_limit.model.get_n_items(); i++) {
                        var item = toggle_fps_limit.model.get_item(i) as StringObject;
                        if (item != null && item.get_string() == toggle_fps_limit_value) {
                            toggle_fps_limit.selected = i;
                            break;
                        }
                    }
                }

                if (line.has_prefix("fps_limit=")) {
                    scale.set_value(int.parse(line.substring("fps_limit=".length)));
                    fps_limit_label.label = "%d".printf((int)scale.get_value());
                }

                if (line.has_prefix("vsync=")) {
                    var vulcan_config_value = line.substring("vsync=".length);
                    var vulcan_value = get_vulcan_value_from_config(vulcan_config_value);
                    for (uint i = 0; i < vulcan_dropdown.model.get_n_items(); i++) {
                        var item = vulcan_dropdown.model.get_item(i) as StringObject;
                        if (item != null && item.get_string() == vulcan_value) {
                            vulcan_dropdown.selected = i;
                            break;
                        }
                    }
                }

                if (line.has_prefix("gl_vsync=")) {
                    var opengl_config_value = line.substring("gl_vsync=".length);
                    var opengl_value = get_opengl_value_from_config(opengl_config_value);
                    for (uint i = 0; i < opengl_dropdown.model.get_n_items(); i++) {
                        var item = opengl_dropdown.model.get_item(i) as StringObject;
                        if (item != null && item.get_string() == opengl_value) {
                            opengl_dropdown.selected = i;
                            break;
                        }
                    }
                }

                if (line.has_prefix("filter=")) {
                    var filter_value = line.substring("filter=".length);
                    for (uint i = 0; i < filter_dropdown.model.get_n_items(); i++) {
                        var item = filter_dropdown.model.get_item(i) as StringObject;
                        if (item != null && item.get_string() == filter_value) {
                            filter_dropdown.selected = i;
                            break;
                        }
                    }
                }

                if (line.has_prefix("filter_scale1=")) {
                    filter_scale1.set_value(int.parse(line.substring("filter_scale1=".length)));
                    filter_scale1_label.label = "%d".printf((int)filter_scale1.get_value());
                }

                if (line.has_prefix("filter_scale2=")) {
                    filter_scale2.set_value(int.parse(line.substring("filter_scale2=".length)));
                    filter_scale2_label.label = "%d".printf((int)filter_scale2.get_value());
                }

                // Загружаем пользовательский текст
                if (line.has_prefix("custom_text=")) {
                    custom_text_entry.text = line.substring("custom_text=".length);
                }
            }
        } catch (Error e) {
            stderr.printf("Ошибка при чтении файла: %s\n", e.message);
        }
    }

    private void load_switch_from_file(string line, Switch[] switches, string[] config_vars) {
        for (int i = 0; i < config_vars.length; i++) {
            if (line.has_prefix("#%s".printf(config_vars[i]))) {
                switches[i].active = false;
            } else if (line.has_prefix("%s".printf(config_vars[i]))) {
                switches[i].active = true;
            }
        }
    }

    private void restart_vkcube() {
        try {
            Process.spawn_command_line_sync("pkill vkcube");
            Process.spawn_command_line_async("mangohud vkcube");
        } catch (Error e) {
            stderr.printf("Ошибка при перезапуске vkcube: %s\n", e.message);
        }
    }

    private bool is_vkcube_running() {
        try {
            string[] argv = { "pgrep", "vkcube" };
            int exit_status;
            string standard_output;
            string standard_error;
            Process.spawn_sync(null, argv, null, SpawnFlags.SEARCH_PATH, null, out standard_output, out standard_error, out exit_status);

            return exit_status == 0;
        } catch (Error e) {
            stderr.printf("Ошибка при проверке запущенных процессов: %s\n", e.message);
            return false;
        }
    }

    private void delete_mangohub_conf() {
        var config_dir = File.new_for_path(Environment.get_home_dir()).get_child(".config").get_child("MangoHud");
        var file = config_dir.get_child("MangoHud.conf");
        if (file.query_exists()) {
            try {
                file.delete();
                warning("MangoHud.conf file deleted.");
            } catch (Error e) {
                stderr.printf("Ошибка при удалении файла: %s\n", e.message);
            }
        } else {
            warning("MangoHud.conf file does not exist.");
        }
    }

    private void update_logs_key_in_file(string logs_key) {
        var config_dir = File.new_for_path(Environment.get_home_dir()).get_child(".config").get_child("MangoHud");
        var file = config_dir.get_child("MangoHud.conf");
        if (!file.query_exists()) {
            return;
        }

        try {
            var lines = new ArrayList<string>();
            var file_stream = new DataInputStream(file.read());
            string line;
            while ((line = file_stream.read_line()) != null) {
                if (line.has_prefix("toggle_logging=")) {
                    line = "toggle_logging=%s".printf(logs_key);
                }
                lines.add(line);
            }

            var file_stream_write = new DataOutputStream(file.replace(null, false, FileCreateFlags.NONE));
            foreach (var l in lines) {
                file_stream_write.put_string(l + "\n");
            }
            file_stream_write.close();
        } catch (Error e) {
            stderr.printf("Ошибка при записи в файл: %s\n", e.message);
        }
    }

    private void open_folder_chooser_dialog() {
        var dialog = new Gtk.FileDialog();
        dialog.select_folder.begin(this.active_window, null, (obj, res) => {
            try {
                var folder = dialog.select_folder.end(res);
                custom_logs_path_entry.text = folder.get_path();
            } catch (Error e) {
                stderr.printf("Ошибка при выборе папки: %s\n", e.message);
            }
        });
    }

    private string get_vulcan_config_value(string vulcan_value) {
        switch (vulcan_value) {
            case "Unset":
                return "0";
            case "ON":
                return "3";
            case "Adaptive":
                return "0";
            case "Mailbox":
                return "2";
            case "OFF":
                return "1";
            default:
                return "0";
        }
    }

    private string get_opengl_config_value(string opengl_value) {
        switch (opengl_value) {
            case "Unset":
                return "-1";
            case "ON":
                return "n";
            case "Adaptive":
                return "-1";
            case "Mailbox":
                return "1";
            case "OFF":
                return "0";
            default:
                return "-1";
        }
    }

    private string get_vulcan_value_from_config(string vulcan_config_value) {
        switch (vulcan_config_value) {
            case "0":
                return "Unset";
            case "3":
                return "ON";
            case "2":
                return "Mailbox";
            case "1":
                return "OFF";
            default:
                return "Unset";
        }
    }

    private string get_opengl_value_from_config(string opengl_config_value) {
        switch (opengl_config_value) {
            case "-1":
                return "Unset";
            case "n":
                return "ON";
            case "1":
                return "Mailbox";
            case "0":
                return "OFF";
            default:
                return "Unset";
        }
    }

    private void restart_application() {
        try {
            // Завершаем текущий экземпляр приложения
            this.quit();

            // Запускаем новый экземпляр приложения
            Process.spawn_command_line_async(Environment.get_prgname());
        } catch (Error e) {
            stderr.printf("Ошибка при перезапуске приложения: %s\n", e.message);
        }
    }

    private void save_custom_text_to_file() {
        var custom_text = custom_text_entry.text;
        if (custom_text == "") {
            return;
        }

        var config_dir = File.new_for_path(Environment.get_home_dir()).get_child(".config").get_child("MangoHud");
        var file = config_dir.get_child("MangoHud.conf");

        try {
            var file_stream = new DataOutputStream(file.replace(null, false, FileCreateFlags.NONE));
            file_stream.put_string("custom_text=%s\n".printf(custom_text));
            file_stream.close();
        } catch (Error e) {
            stderr.printf("Ошибка при записи в файл: %s\n", e.message);
        }
    }

    public static int main(string[] args) {
        var app = new MangoJuice();
        return app.run(args);
    }
}