/***
  Copyright (C) 2014-2015 Switchboard User Accounts Plug Developer
  This program is free software: you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License version 3, as published
  by the Free Software Foundation.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranties of
  MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
  PURPOSE. See the GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program. If not, see http://www.gnu.org/licenses/.
***/

namespace MachineInfo.Widgets {
    public class AvatarPopover : Gtk.Popover {
        private Gtk.Grid button_grid;
        private Dialogs.AvatarDialog avatar_dialog;
        private Gtk.Button avatar_button;
        private int avatar_size;

        public Gdk.Pixbuf? avatar_pixbuf;

        public signal void create_selection_dialog ();

        public AvatarPopover (Gtk.Widget relative, int _avatar_size) {
            avatar_button = (Gtk.Button) relative;
            avatar_size = _avatar_size;
            set_relative_to (relative);
            set_position (Gtk.PositionType.BOTTOM);
            set_modal (true);

            build_ui ();
        }

        private void build_ui () {
            Gtk.Button remove_button = new Gtk.Button.with_label (_("Remove"));
            remove_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            remove_button.clicked.connect (() => { 
                avatar_button.set_image (new Granite.Widgets.Avatar.with_default_icon (avatar_size)); 
                hide ();
            });

            Gtk.Button select_button = new Gtk.Button.with_label (_("Set from File…"));
            select_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            select_button.clicked.connect (select_from_file);
            select_button.grab_focus ();

            button_grid = new Gtk.Grid ();
            button_grid.margin = 6;
            button_grid.column_spacing = 6;
            button_grid.column_homogeneous = true;

            button_grid.add (remove_button);
            button_grid.add (select_button);
            add (button_grid);
        }

        private void select_from_file () {
            var file_dialog = new Gtk.FileChooserDialog (_("Select an image"),
            get_parent_window () as Gtk.Window?, Gtk.FileChooserAction.OPEN, _("Cancel"),
            Gtk.ResponseType.CANCEL, _("Open"), Gtk.ResponseType.ACCEPT);

            Gtk.FileFilter filter = new Gtk.FileFilter ();
            filter.set_filter_name (_("Images"));
            file_dialog.set_filter (filter);
            filter.add_mime_type ("image/jpeg");
            filter.add_mime_type ("image/jpg");
            filter.add_mime_type ("image/png");

            // Add a preview widget
            Gtk.Image preview_area = new Gtk.Image ();
            file_dialog.set_preview_widget (preview_area);
            file_dialog.update_preview.connect (() => {
                string uri = file_dialog.get_preview_uri ();
                // We only display local files:
                if (uri != null && uri.has_prefix ("file://") == true) {
                    try {
                        Gdk.Pixbuf pixbuf = new Gdk.Pixbuf.from_file_at_scale (uri.substring (7), 150, 150, true);
                        preview_area.set_from_pixbuf (pixbuf);
                        preview_area.show ();
                        file_dialog.set_preview_widget_active (true);
                    } catch (Error e) {
                        preview_area.hide ();
                        file_dialog.set_preview_widget_active (false);
                    }
                } else {
                    preview_area.hide ();
                    file_dialog.set_preview_widget_active (false);
                }
            });

            if (file_dialog.run () == Gtk.ResponseType.ACCEPT) {
                var path = file_dialog.get_file ().get_path ();
                file_dialog.hide ();
                file_dialog.destroy ();
                avatar_dialog = new Dialogs.AvatarDialog (path);
                avatar_dialog.request_avatar_change.connect ((pixbuf) => {
                    avatar_pixbuf = pixbuf.scale_simple (avatar_size, avatar_size, Gdk.InterpType.BILINEAR);
                    avatar_button.set_image (new Granite.Widgets.Avatar.from_pixbuf (avatar_pixbuf));
                    avatar_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
                    // Save the icon somewhere after which it can be refered using just the name 'machine-icon'
                    try {
                        saveIcon (avatar_pixbuf);
                        MachineInfo.icon_name = "machine-icon";
                    } catch (Error e) {
                        warning ("Failed to save machine-icon " + e.message);
                        MachineInfo.icon_name = "avatar-default";
                    }
                });
            } else {
                file_dialog.close ();
            }

            hide ();
        }

        private void saveIcon (Gdk.Pixbuf avatar_pixbuf) throws Error {
            // Create a temp file to store the icon
            var fileName = Path.build_filename("/tmp", "machine-icon.png");
            avatar_pixbuf.savev (fileName, "png", {}, {});
            // Copy the temp file to destination using command line
            if (get_permission ().allowed) {
                string output;
                int status;

                try {
                    var cli = "%s/machine-info-icon".printf (Constants.PKGDATADIR);
                    Process.spawn_sync(null,
                        {"pkexec", cli, fileName},
                        Environ.get(),
                        SpawnFlags.SEARCH_PATH,
                        null,
                        out output,
                        null,
                        out status);
                } catch (Error e) {
                    warning ("Error saving machine icon " + e.message);
                }
            }
        }
    }
}