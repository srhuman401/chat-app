class_name Message
extends RefCounted

var sender: int
var contents: String

func serialize() -> Dictionary:
	return {
		"sender": sender,
		"contents": contents,
	}

static func from_dict(dict: Dictionary) -> Message:
	var instance = Message.new()
	
	if dict.has("sender"):
		instance.sender = dict.get("sender")
	
	if dict.has("contents"):
		instance.contents = dict.get("contents")
	
	return instance
