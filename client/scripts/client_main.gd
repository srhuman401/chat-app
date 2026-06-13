extends Node

var ip: String = "localhost"
var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var peer_ready: bool = false

@export var connecting_screen: Control
@export var start_menu: Control
@export var room_screen: RoomUI
@export var nickname_input: LineEdit
@export var ip_input: LineEdit
@export var password_input: LineEdit
@export var connect_button: Button

signal connection_attempt_result(bool)
signal server_user_connection_result(bool)

func _ready():
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	Networker.server_message_recieved.connect(_on_message_recieved)
	connect_button.pressed.connect(try_and_connect)

func get_nickname() -> String:
	if nickname_input.text.is_empty():
		return "Guest"
	return nickname_input.text

func get_ip() -> String:
	return ip_input.text

func get_password() -> String:
	return password_input.text

func try_and_connect() -> void:
	start_menu.visible = false
	connecting_screen.visible = true
	
	var connected_success = false
	var attempts: int = 0
	while !connected_success:
		if attempts > 4:
			print("[CLIENT] to many failed attempts, stopping")
			return
		
		print("[CLIENT] trying to connect")
		try_connection()
		
		connected_success = await connection_attempt_result
		print("[CLIENT] connected: ", connected_success)
		
		if not connected_success:
			attempts += 1
			print("[CLIENT] waiting for 2s")
			await get_tree().create_timer(2.0).timeout
	connecting_screen.visible = false
	if !connected_success: 
		start_menu.visible = true
		return
	peer_ready = true
	Networker.send_message_to_server.rpc(MsgType.CLIENT_CONNECT_REQUEST, [
		get_nickname(),
		get_password()
	])
	
	var server_approved = await server_user_connection_result
	if server_approved == false: 
		start_menu.visible = true
		return
	print("[CLIENT] server approved user")
	room_screen.visible = true

func try_connection() -> void:
	if peer != null:
		peer.close()
		peer = null
		await get_tree().process_frame
	peer = ENetMultiplayerPeer.new()
	
	var error = peer.create_client(get_ip(), Config.DEFAULT_PORT)
	if error == OK:
		multiplayer.multiplayer_peer = peer
	else:
		connection_attempt_result.emit(false)

func request_user():
	pass

func handle_server_approve_connection_msg(info: Array):
	if info.size() < 2:
		server_user_connection_result.emit(false)
		return
	
	if info[0] == false:
		server_user_connection_result.emit(false)
		return
	
	server_user_connection_result.emit(true)

func _on_message_recieved(message: String, info: Array):
	print("[CLIENT|RECIEVE] recieved msg: ", message, " with ", info)
	match message:
		MsgType.SERVER_APPROVE_CONNECTION:
			handle_server_approve_connection_msg(info)
		MsgType.SERVER_SEND_ROOM_SNAPSHOT:
			if info.size() < 1: return
			if !(info[0] is Dictionary): return 
			room_screen.update_to_snapshot(info[0])

func _on_connected_to_server():
	print("[CLIENT] established connection to server")
	connection_attempt_result.emit(true)

func _on_connection_failed():
	print("[CLIENT] failed to establish connection")
	connection_attempt_result.emit(false)
