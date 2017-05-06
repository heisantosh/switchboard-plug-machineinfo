namespace MachineInfo {
	[DBus (name="org.freedesktop.hostname1")]
	public interface HostnameClient : Object {
    	public abstract string hostname { owned get; }
    	public abstract string static_hostname { owned get; }
    	public abstract string pretty_hostname { owned get; }
    	public abstract string icon_name { owned get; }
    	public abstract string chassis { owned get; }
    	public abstract string deployment { owned get; }
    	public abstract string location { owned get; }

	    public abstract void set_hostname (string name, bool user_interaction) throws IOError;
	    public abstract void set_static_hostname (string name, bool user_interaction) throws IOError;
	    public abstract void set_pretty_hostname (string name, bool user_interaction) throws IOError;
	    public abstract void set_icon_name (string name, bool user_interaction) throws IOError;
	    public abstract void set_chassis (string name, bool user_interaction) throws IOError;
	    public abstract void set_deployment (string name, bool user_interaction) throws IOError;
	    public abstract void set_location (string name, bool user_interaction) throws IOError;
    }
}

