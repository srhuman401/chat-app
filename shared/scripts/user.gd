class_name User
extends RefCounted

var display_name: String = "Guest"
var uuid: int = -1
var usedpassword: String = ""

func serialize() -> Dictionary:
	return {
		"display_name": display_name,
		"uuid": uuid,
	}

static func new_user(name: String, id: int) -> User:
	var instance = User.new()
	instance.display_name = name
	instance.uuid = id
	return instance

static func from_dict(dict: Dictionary) -> User:
	var instance = User.new()
	
	if dict.has("display_name"):
		instance.display_name = dict.get("display_name")
	
	if dict.has("uuid"):
		instance.uuid = dict.get("uuid")
	
	return instance
