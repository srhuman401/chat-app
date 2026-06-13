class_name TestNetworker
extends Node

var server: DedicatedServer

signal server_message_recieved(String, Array)

@rpc("any_peer", "reliable")
func send_message_to_server(message: String, info: Array):
	if multiplayer.is_server() and server != null:
		var sender_id = multiplayer.get_remote_sender_id()
		server.on_server_recieve_message(message, sender_id, info)

@rpc("authority", "reliable")
func send_message_to_client(message: String, info: Array):
	server_message_recieved.emit(message, info)
