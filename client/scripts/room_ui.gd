class_name RoomUI
extends Control

@export var send_message_button: Button
@export var message_box: LineEdit
@export var messages_text: RichTextLabel
@export var user_list_text: RichTextLabel

func _ready():
	send_message_button.pressed.connect(_on_send_message_button_pressed)

func _on_send_message_button_pressed():
	var message_content = message_box.text
	if message_content.is_empty(): return
	Networker.send_message_to_server.rpc(
		MsgType.CLIENT_SEND_MESSAGE,
		[message_content]
	)

func update_to_snapshot(snapshot: Dictionary):
	var serialized_userlist: Dictionary = snapshot.get("user_list")
	var serialized_messagestore: Array = snapshot.get("message_store")
	
	var user_list: UserList
	
	if serialized_userlist:
		user_list = UserList.from_dict(serialized_userlist)
		var text = "Online users\n"
		for user in user_list.users:
			text = text + user.display_name + "\n"
		user_list_text.text = text
	else:
		user_list = UserList.new()
	
	if serialized_messagestore:
		var message_store: MessageStore = MessageStore.from_array(serialized_messagestore)
		var text = ""
		for msg in message_store.messages:
			var nick: String = "Unknown sender"
			for user in user_list.users:
				if user.uuid == msg.sender:
					nick = user.display_name
					break
			text = text + (nick + ": " + msg.contents) + "\n"
		messages_text.text = text
