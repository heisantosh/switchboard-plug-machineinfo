namespace MachineInfo {
	/*
	  List of services to be restarted after MachineInfo changed:
	  - avahi-daemon.service
	  - bluetooth
	  - rygel

	  - ... other network dependent services
	  - ... network manager service
	*/
	
	/* Update /etc/hosts file with new hostname to avoid getting the mesage :
	  sudo: unable to resolve host meowbox
	  while running sudo commands.
	*/
	public void updateHostsFile (string old_hostname, string new_hostname) {
		string command = "sudo sed -i /" + old_hostname + "/" + new_hostname + "/g /etc/hosts";
		
		try {
			Process.spawn_command_line_async (command);
		} catch (SpawnError e) {
			critical (e.message);
		}
	}

	public void restartNetworkManager () {
		string command = "sudo "
	}
	
	public void restartAvahi () {}

	public void restartBluetooth () {}

	public void restartRygel () {}


}