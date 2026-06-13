class_name DedicatedServer
extends Node

var message_store: MessageStore
var active_users: UserList
var requires_password: bool = false
var password: String = ""

const PROPS_FILE_NAME = "server_properties.json"
var properties: ServerProperties

var server_folder = OS.get_executable_path().get_base_dir()

var debug_test_password = true

func try_and_load_props():
	var props_path = server_folder.path_join(PROPS_FILE_NAME)
	var loaded: Dictionary = {}
	
	if FileAccess.file_exists(props_path):
		var file = FileAccess.open(props_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			var json_dict = JSON.parse_string(content)
			if json_dict and (json_dict is Dictionary):
				loaded = json_dict
	
	properties = ServerProperties.from_dict(loaded)

func save_props():
	var json_string = JSON.stringify(properties.serialize(), "\t")
	var path = server_folder.path_join(PROPS_FILE_NAME)
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()

func _ready() -> void:
	print("[SERVER] starting...")
	print("[SERVER] !dedicated Server!")
	print("[SERVER] -------------------")
	
	print("[SERVER] Initializing ServerProperties (server_properties.json)")
	try_and_load_props()
	save_props()
	
	print("[SERVER] Initializing MessageStore")
	message_store = MessageStore.new()
	
	print("[SERVER] Initializing UserList")
	active_users = UserList.new()
	
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(Config.DEFAULT_PORT, 32)
	if error == OK:
		multiplayer.multiplayer_peer = peer
		print("[SERVER] connection made")
		print("[SERVER] started on port: ", Config.DEFAULT_PORT)
		Networker.server = self

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("[SERVER] stopping...")
		save_props()

func _on_peer_disconnected(id: int):
	if !id_connected(id): return
	
	var user = get_user_from_id(id)
	active_users.remove(user)

func _on_peer_connected(id: int):
	print("[SERVER] peer connected: ", str(id), " (THIS DOES NOT MEAN THEY ARE A USER. THEY HAVE NOT GONE THROUGH AUTHENTICATION YET)")

func get_user_from_id(id: int) -> User:
	for user in active_users.users:
		if user.uuid == id:
			return user
	return null

func id_connected(id: int) -> bool:
	return get_user_from_id(id) != null

func send_cl_connect_feedback(id: int, approve: bool, message: String): 
	Networker.send_message_to_client.rpc_id(id, MsgType.SERVER_APPROVE_CONNECTION, [approve, message])

func get_room_snapshot_serialized() -> Dictionary:
	return {
		"user_list": active_users.serialize(),
		"message_store": message_store.serialize()
	}

func send_room_snapshot_to_user(id: int):
	if !id_connected(id): return
	Networker.send_message_to_client.rpc_id(
		id, 
		MsgType.SERVER_SEND_ROOM_SNAPSHOT,
		[get_room_snapshot_serialized()]
	)

func send_room_snapshot_to_all_users():
	for user in active_users.users:
		send_room_snapshot_to_user(user.uuid)

func handle_cl_connect_request(id: int, info: Array):
	var min_arguments = 2 if requires_password else 1
	if info.size() < min_arguments:
		send_cl_connect_feedback(id, false, "missingArguments")
		return 
	
	var nick: String = info[0]
	if nick.is_empty():
		send_cl_connect_feedback(id, false, "invalidNickname")
		return
	
	var usr_password: String = info.get(1)
	if usr_password == null:
		usr_password = ""
	if requires_password:
		if usr_password != password:
			send_cl_connect_feedback(id, false, "wrongPassword")
			return
	
	var user = User.new_user(nick, id)
	user.usedpassword = usr_password
	
	active_users.add(user)
	
	print("[SERVER] added user for peer ", id, " (",user,")")
	send_cl_connect_feedback(id, true, "success")
	send_room_snapshot_to_all_users()

func handle_cl_send_message(id: int, info: Array):
	# messy bs for testing
	# TODO: add ratelimit
	if info.size() < 1:
		return
	
	var msg_content = info[0]
	if !(msg_content is String):
		return
	
	var user = get_user_from_id(id)
	var msg = Message.new()
	msg.contents = msg_content
	msg.sender = user.uuid
	
	message_store.push(msg)
	send_room_snapshot_to_all_users()

func on_server_recieve_message(message: String, remote_id: int, info: Array):
	print("[SERVER | RECIEVE] '", message, "' from peer: ", str(remote_id) )
	
	match message:
		MsgType.CLIENT_SEND_MESSAGE:
			if !id_connected(remote_id): return
			handle_cl_send_message(remote_id, info)
		MsgType.CLIENT_CONNECT_REQUEST:
			if id_connected(remote_id): return
			handle_cl_connect_request(remote_id, info)
