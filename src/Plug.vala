//
//  Copyright (C) 2017 Santosh Heigrujam
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

namespace MachineInfo {
    public class Plug : Switchboard.Plug {
        private Gtk.Box main_box;
        private Gtk.InfoBar infobar;
        private Gtk.LockButton lock_button;
        private Gtk.Grid settings_grid;
        private Granite.Widgets.Avatar machine_avatar;
        private Gdk.Pixbuf? avatar_pixbuf;
        private Gtk.Button avatar_button;
        private Gtk.Label hostname_label;
        private Gtk.Entry hostname_entry;
        private Gtk.Label pretty_hostname_label;
        private Gtk.Entry pretty_hostname_entry;
        private Gtk.Image hostname_lock;
        private Gtk.Image pretty_hostname_lock;
        // private static Polkit.Permission? permission = null;

        private string permission_require_info_string = _("Settings require administrator rights to be changed");
        private string no_permisson_string = _("You do not the permission to change this");
        private string avatar_string = _("Click image to change machine avatar");

        private int avatar_size = 72;

        public Plug () {
            Object (category: Category.NETWORK,
                    code_name: "network-pantheon-machineinfo",
                    display_name: _("Machine Info"),
                    description: _("Configure machine information"),
                    icon: "computer");
        }

        public override Gtk.Widget get_widget () {
            if (main_box == null) {
                setup_info ();
                setup_ui ();
            }

            return main_box;
        }

        public override void shown () {}

        public override void hidden () {
            if (get_permission ().allowed) {
                try {
                    get_permission ().release();
                } catch (Error e) {
                    critical (e.message);
                }
            }
        }

        public override void search_callback (string location) {}

        // 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior")
        public override async Gee.TreeMap<string, string> search (string search) {
            return new Gee.TreeMap<string, string> (null, null);
        }

        private void setup_info () {
            MachineInfo.init ();
        }

        private void setup_ui () {
            main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
            
            infobar = new Gtk.InfoBar ();
            infobar.message_type = Gtk.MessageType.INFO;
            main_box.pack_start (infobar, false, false, 0);
            
            var area = infobar.get_action_area () as Gtk.Container;
            lock_button = new Gtk.LockButton (get_permission ());
            area.add (lock_button);

            var content = infobar.get_content_area () as Gtk.Container;
            var label = new Gtk.Label (permission_require_info_string);
            content.add (label);
            
            get_permission ().notify["allowed"].connect (() => {
                if (get_permission ().allowed) {
                    infobar.no_show_all = true;
                    infobar.hide ();
                } else {
                    infobar.no_show_all = false;
                    infobar.show ();
                }
            });
            
            settings_grid = new Gtk.Grid ();
            settings_grid.valign = Gtk.Align.CENTER;
            settings_grid.halign = Gtk.Align.CENTER;
            settings_grid.margin = 24;
            settings_grid.row_spacing = 6;
            settings_grid.column_spacing = 12;
            
            // machine_avatar = new Granite.Widgets.Avatar.with_default_icon (avatar_size);
            Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
            try {
                machine_avatar = new Granite.Widgets.Avatar.from_pixbuf (
                    icon_theme.load_icon (MachineInfo.icon_name, avatar_size, 0));
            } catch (Error e) {
                warning ("Unable to find machine icon " + e.message);
                machine_avatar = new Granite.Widgets.Avatar.with_default_icon (avatar_size);
            }
            machine_avatar.halign = Gtk.Align.CENTER;
            machine_avatar.margin = 12;

            avatar_button = new Gtk.ToggleButton ();
            avatar_button.set_image (machine_avatar);
            avatar_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            avatar_button.clicked.connect (() => {
                Widgets.AvatarPopover popover = new Widgets.AvatarPopover(avatar_button, avatar_size);
                popover.show_all ();
                popover.hide.connect (() => {
                    avatar_pixbuf = popover.avatar_pixbuf;
                });
            });
            
            settings_grid.attach (avatar_button, 1, 0, 1, 1);
            
            pretty_hostname_label = new_name_label (_("Pretty hostname"));
            pretty_hostname_entry = new_name_entry ("pretty-hostname");
            pretty_hostname_entry.set_text (MachineInfo.pretty_hostname);
            pretty_hostname_entry.changed.connect (() => {
                MachineInfo.pretty_hostname = pretty_hostname_entry.get_text ();
            });
            pretty_hostname_lock = new_lock_icon ("pretty-hostname");

            settings_grid.attach (pretty_hostname_label, 0, 1, 1, 1);
            settings_grid.attach (pretty_hostname_entry, 1, 1, 1, 1);
            settings_grid.attach (pretty_hostname_lock, 2, 1, 1, 1);
            
            hostname_label = new_name_label (_("Hostname"));
            hostname_entry = new_name_entry ("hostname");
            hostname_entry.set_text (MachineInfo.static_hostname);
            hostname_entry.changed.connect (() => {
                MachineInfo.static_hostname = hostname_entry.get_text ();
                MachineInfo.transient_hostname = hostname_entry.get_text ();
            });
            hostname_lock = new_lock_icon ("hostname");
            
            settings_grid.attach (hostname_label, 0, 2, 1, 1);
            settings_grid.attach (hostname_entry, 1, 2, 1, 1);
            settings_grid.attach (hostname_lock, 2, 2, 1, 1);
            main_box.pack_start (settings_grid, false, false, 0);
            main_box.show_all ();
            update_ui ();
            get_permission ().notify["allowed"].connect (update_ui);
        }

        private void update_ui () {
            if (!get_permission ().allowed) {
                avatar_button.set_sensitive (false);
                pretty_hostname_entry.set_sensitive (false);
                hostname_entry.set_sensitive (false);

                pretty_hostname_lock.set_opacity (0.5);
                hostname_lock.set_opacity (0.5);

                avatar_button.set_tooltip_text (no_permisson_string);
                pretty_hostname_lock.set_tooltip_text (no_permisson_string);
                hostname_lock.set_tooltip_text (no_permisson_string);
            } else {
                avatar_button.set_sensitive (true);
                pretty_hostname_entry.set_sensitive (true);
                hostname_entry.set_sensitive (true);

                pretty_hostname_lock.set_opacity (0);
                hostname_lock.set_opacity (0);

                avatar_button.set_tooltip_text (avatar_string);
                pretty_hostname_lock.set_tooltip_text (null);
                hostname_lock.set_tooltip_text (null);
            }
        }
        
        private Gtk.Label new_name_label (string _name) {
            Gtk.Label name_label  = new Gtk.Label (_name + ":");
            name_label.halign = Gtk.Align.END;
            return name_label;
        } 

        private Gtk.Entry new_name_entry (string _name) {
            Gtk.Entry name_entry = new Gtk.Entry ();
            name_entry.get_style_context ().add_class ("h3");
            name_entry.activate.connect (() => {
                debug ("%s: %s\n", _name, name_entry.get_text ());
            });
            name_entry.halign = Gtk.Align.START;
            return name_entry;
        }

        private Gtk.Image new_lock_icon (string _name) {
            Gtk.Image lock_icon = new Gtk.Image.from_icon_name ("changes-prevent-symbolic", Gtk.IconSize.BUTTON);
            lock_icon.set_tooltip_text (no_permisson_string);
            lock_icon.halign = Gtk.Align.CENTER;
            return lock_icon;
        }  

        /*
        public static Polkit.Permission? get_permission () {
            if (permission != null) {
                return permission;
            }
            try {
                permission = new Polkit.Permission.sync ("org.pantheon.switchboard.machine-info.administration", 
                    new Polkit.UnixProcess (Posix.getpid ()));
                return permission;
            } catch (Error e) {
                critical (e.message);
                return null;
            }
        }
        */
    }
}


public Switchboard.Plug get_plug (Module module) {
    debug ("Activating Machine Info plug");
    var plug = new MachineInfo.Plug ();
    return plug;
}

