namespace MachineInfo {
    public static Polkit.Permission? permission = null;

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
}