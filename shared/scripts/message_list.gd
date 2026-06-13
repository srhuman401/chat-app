class_name MessageStore
extends RefCounted

const MAX_MESSAGES = 10

var messages: Array[Message] = []

func _ready():
	messages.resize(MAX_MESSAGES)

func push(msg: Message): 
	if messages.size() >= MAX_MESSAGES:
		var first: Message = messages[0]
		messages.erase(first)
		first.free()
	messages.append(msg)

func serialize() -> Array[Dictionary]:
	var serialized: Array[Dictionary] = []
	for msg in messages:
		serialized.append(msg.serialize())
	return serialized

static func from_array(arr: Array) -> MessageStore:
	var instance = MessageStore.new()
	
	for serialized_msg in arr:
		instance.messages.append(Message.from_dict(serialized_msg))
	
	return instance
