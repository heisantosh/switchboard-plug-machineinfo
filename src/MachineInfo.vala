namespace MachineInfo {
	public class MachineInfo : Object {
		public static HostnameClient client;

		public static void init () {
			try {
				client = Bus.get_proxy_sync (BusType.SYSTEM, "org.freedesktop.hostname1",
                        "/org/freedesktop/hostname1");
            } catch (IOError e) {
                critical (e.message);
            }
		}

		private delegate void MethodProxy (string s, bool b) throws IOError;

		private static void call_method (MethodProxy dbus_method, string arg) {
			try {
				dbus_method (arg, false);
			} catch (IOError e) {
				critical (e.message);
			}
		}

		public static string pretty_hostname {
			owned get { return client.pretty_hostname; }
			set { call_method (client.set_pretty_hostname, value); }
		}

		public static string transient_hostname {
			owned get { return client.hostname; }
			set { call_method (client.set_hostname, value); }
		}

		public static string static_hostname {
			owned get { return client.static_hostname; }
			set { call_method (client.set_static_hostname, value); }
		}

		public static string icon_name {
			owned get { return client.icon_name; }
			set { call_method (client.set_icon_name, value); }
		}

		public static string chassis {
			owned get { return client.chassis; }
			set { call_method (client.set_chassis, value); }
		}

		public static string deployment {
			owned get { return client.deployment; }
			set { call_method (client.set_deployment, value); }
		}

		public static string location {
			owned get { return client.location; }
			set { call_method (client.set_location, value); }
		}
	}
}