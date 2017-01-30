# GodotHub Client Class
# Author: Nik Mirza
# Email: nik96mirza[at]gmail.com

signal error(err) # Declare signals
signal listening
signal connected
signal join(id)
signal left(id)
signal message(data)

var conn

var server = {
	port = 5000,
	host = '127.0.0.1',
}

var client = {
	ID = "",
	channel = 'global'
}

func _init(serverport = 5000, serverhost = '127.0.0.1', serverchannel= "global", listenport = 4000):
	server.host = serverhost
	server.port = serverport
	client.channel = serverchannel
	
	conn = PacketPeerUDP.new()
	var err = conn.listen(listenport)
	if err:
		emit_signal("error", err)
		
	emit_signal("listening")
	
	conn.set_send_address(server.host,server.port)
	send_data({event="connecting"})
	
func is_listening():
	if !conn.is_listening():
		return false
	
	if data_available():
		var data = get_data()
		
		if data.event == "connected":
			emit_signal("connected")
			client.ID = data.ID
			return
			
		if data.event == "join":
			emit_signal("join", data.ID)#join signal when data is received
			return
			
		if data.event == "left":
			emit_signal("left", data.ID)#join signal when data is received
			return
			
		emit_signal("message",data)#message signal when data is received
		
func change_channel(channel):
	client.channel = channel
	send_data({event="channel"})
	
func data_available():
	if conn.get_available_packet_count() > 0:
		return true
	return false
	
func get_data():#As dictionary
	var data = conn.get_var()
	var dict = {}
	dict.parse_json(data)
	return dict
	
func send_data(data): #Only accept dictionary
	client.data = data
	conn.put_var(client.to_json())
		
func disconnect():
	send_data({event="disconnect"})
	conn.close()