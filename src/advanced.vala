using Gtk;
using Adw;

public class AdvancedDialog : Adw.Dialog {
    private File config_file;

    public AdvancedDialog (Gtk.Window parent) {
        Object ();

        var header_bar = new Gtk.HeaderBar ();
        header_bar.set_show_title_buttons (true);
        header_bar.add_css_class ("flat");

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.append (header_bar);
        main_box.append (create_advanced_content ());
        this.set_child (main_box);
        this.present (parent);
    }

    private Gtk.Widget create_advanced_content () {
        var scrolled_window = new Gtk.ScrolledWindow ();
        scrolled_window.set_hexpand (true);
        scrolled_window.set_vexpand (true);

        var clamp = new Adw.Clamp ();
        clamp.set_maximum_size (800);

        var group = new Adw.PreferencesGroup ();

        var list_box = new ListBox ();
        list_box.set_selection_mode (SelectionMode.NONE);
        list_box.set_margin_start (12);
        list_box.set_margin_end (12);
        list_box.set_margin_top (12);
        list_box.set_margin_bottom (12);
        list_box.add_css_class ("boxed-list");

        // Загрузка конфигурационного файла
        var config_dir = File.new_for_path (Environment.get_home_dir ()).get_child (".config").get_child ("MangoHud");
        config_file = config_dir.get_child ("MangoHud.conf");

        if (config_file.query_exists ()) {
            try {
                var input_stream = config_file.read ();
                var data_stream = new DataInputStream (input_stream);
                string line;

                while ((line = data_stream.read_line ()) != null) {
                    add_config_row (list_box, line);
                }

                input_stream.close ();
            } catch (Error e) {
                print ("Ошибка при чтении файла: %s\n", e.message);
            }
        } else {
            print ("Файл конфигурации не найден: %s\n", config_file.get_path ());
        }

        clamp.set_child (list_box);
        group.add (clamp);

        // Добавляем содержимое в ScrolledWindow
        scrolled_window.set_child (group);

        return scrolled_window;
    }

    private void add_config_row (ListBox list_box, string line) {
        var action_row = new Adw.ActionRow ();
        action_row.title = _("Configuration Line");
        action_row.subtitle = line; // Подзаголовок - это строка из файла

        // Кнопка для перетаскивания
        var drag_button = new Gtk.Button ();
        drag_button.icon_name = "list-drag-handle-symbolic";
        drag_button.tooltip_text = "Перетащить";
        drag_button.has_frame = false;
        enable_drag_and_drop (drag_button, list_box, action_row);
        action_row.add_prefix (drag_button);

        var up_button = new Gtk.Button ();
        up_button.icon_name = "go-up-symbolic";
        up_button.tooltip_text = "Переместить вверх";
        up_button.has_frame = false;
        up_button.clicked.connect (() => {
            disable_scroll (list_box);
            move_row_up (list_box, action_row);
            save_config_to_file (list_box);
            enable_scroll (list_box);
        });
        action_row.add_suffix (up_button);

        var down_button = new Gtk.Button ();
        down_button.icon_name = "go-down-symbolic";
        down_button.tooltip_text = "Переместить вниз";
        down_button.has_frame = false;
        down_button.clicked.connect (() => {
            disable_scroll (list_box);
            move_row_down (list_box, action_row);
            save_config_to_file (list_box);
            enable_scroll (list_box);
        });
        action_row.add_suffix (down_button);

        list_box.append (action_row);
    }

    private void disable_scroll (ListBox list_box) {
        var scrolled_window = list_box.get_ancestor (typeof (Gtk.ScrolledWindow)) as Gtk.ScrolledWindow;
        if (scrolled_window != null) {
            scrolled_window.get_vadjustment ().set_value (scrolled_window.get_vadjustment ().get_value ());
            scrolled_window.set_sensitive (false);
        }
    }

    private void enable_scroll (ListBox list_box) {
        var scrolled_window = list_box.get_ancestor (typeof (Gtk.ScrolledWindow)) as Gtk.ScrolledWindow;
        if (scrolled_window != null) {
            scrolled_window.set_sensitive (true);
        }
    }

    private void enable_drag_and_drop (Gtk.Button drag_button, ListBox list_box, ListBoxRow row) {
        var drag_source = new Gtk.DragSource ();
        drag_source.set_actions (Gdk.DragAction.MOVE);

        double scroll_position = 0;

        drag_source.drag_begin.connect ((source, drag) => {
            row.add_css_class ("card");
            var paintable = new Gtk.WidgetPaintable (row);
            drag_source.set_icon (paintable, 0, 0);

            var scrolled_window = list_box.get_ancestor (typeof (Gtk.ScrolledWindow)) as Gtk.ScrolledWindow;
            if (scrolled_window != null) {
                scroll_position = scrolled_window.get_vadjustment ().get_value ();
            }
        });

        drag_source.drag_end.connect ((source, drag) => {
            row.remove_css_class ("card");

            var scrolled_window = list_box.get_ancestor (typeof (Gtk.ScrolledWindow)) as Gtk.ScrolledWindow;
            if (scrolled_window != null) {
                scrolled_window.get_vadjustment ().set_value (scroll_position);
            }
        });

        drag_source.prepare.connect ((source, x, y) => {
            Value value = Value (typeof (ListBoxRow));
            value.set_object (row);
            return new Gdk.ContentProvider.for_value (value);
        });

        drag_button.add_controller (drag_source);

        var drop_target = new Gtk.DropTarget (typeof (ListBoxRow), Gdk.DragAction.MOVE);
        drop_target.drop.connect ((target, value, x, y) => {
            var source_row = value.get_object () as ListBoxRow;
            var dest_row = list_box.get_row_at_y ((int)y);
            if (source_row != null && dest_row != null && source_row != dest_row) {
                int dest_index = get_row_index (list_box, dest_row);
                list_box.remove (source_row);
                list_box.insert (source_row, dest_index);
                save_config_to_file (list_box);
                return true;
            }
            return false;
        });

        drop_target.enter.connect ((target, x, y) => {
            var dest_row = list_box.get_row_at_y ((int)y);
            if (dest_row != null) {
                dest_row.add_css_class ("accent");
            }
            return Gdk.DragAction.MOVE;
        });

        drop_target.leave.connect ((target) => {
            var child = list_box.get_first_child ();
            while (child != null) {
                child.remove_css_class ("accent");
                child = child.get_next_sibling ();
            }
        });

        drop_target.motion.connect ((target, x, y) => {
            var dest_row = list_box.get_row_at_y ((int)y);
            if (dest_row != null) {
                var child = list_box.get_first_child ();
                while (child != null) {
                    if (child == dest_row) {
                        child.add_css_class ("accent");
                    } else {
                        child.remove_css_class ("accent");
                    }
                    child = child.get_next_sibling ();
                }
            }
            return Gdk.DragAction.MOVE;
        });

        list_box.add_controller (drop_target);
    }

    private int get_row_index (ListBox list_box, ListBoxRow row) {
        int index = 0;
        var child = list_box.get_first_child ();
        while (child != null) {
            if (child == row) return index;
            index++;
            child = child.get_next_sibling ();
        }
        return -1;
    }

    private int get_row_count (ListBox list_box) {
        int count = 0;
        var child = list_box.get_first_child ();
        while (child != null) {
            count++;
            child = child.get_next_sibling ();
        }
        return count;
    }

    private void move_row_up (ListBox list_box, ListBoxRow row) {
        int index = get_row_index (list_box, row);
        if (index > 0) {
            list_box.remove (row);
            list_box.insert (row, index - 1);
        }
    }

    private void move_row_down (ListBox list_box, ListBoxRow row) {
        int index = get_row_index (list_box, row);
        if (index < get_row_count (list_box) - 1) {
            list_box.remove (row);
            list_box.insert (row, index + 1);
        }
    }

    private void save_config_to_file (ListBox list_box) {
        try {
            var output_stream = config_file.replace (
                null, // etag
                false, // make_backup
                FileCreateFlags.NONE, // flags
                null // cancellable
            );
            var data_stream = new DataOutputStream (output_stream);

            var child = list_box.get_first_child ();
            while (child != null) {
                var action_row = child as Adw.ActionRow;
                if (action_row != null) {
                    data_stream.put_string (action_row.subtitle + "\n", null);
                }
                child = child.get_next_sibling ();
            }

            output_stream.close ();
        } catch (Error e) {
            print ("Ошибка при записи файла: %s\n", e.message);
        }
    }
}