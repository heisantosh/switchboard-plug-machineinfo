/***
Copyright (C) 2017 Santosh Heigrujam <santosh.hei@gmail.com>

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License version 3, as published
by the Free Software Foundation.
This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranties of
MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along
with this program. If not, see http://www.gnu.org/licenses/.
***/

namespace MachineInfoIcon {	
	public static int main (string[] args) {
		string tmpFile = args[1];
		var file = File.new_for_path (tmpFile);
		var destination = File.new_for_path ("/usr/share/pixmaps/machine-icon.png");
		try {
			file.copy (destination, FileCopyFlags.OVERWRITE);
		} catch (Error e) {
			error ("Failed to save icon : " + e.message);
			return 1;
		}
		return 0;
	}
}