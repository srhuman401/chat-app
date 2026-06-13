class_name ServerProperties
extends RefCounted

var display_name: String = "my server"
var password_required: bool = false
var server_password: String = "PASSWORD"

func serialize() -> Dictionary:
	return {
		"display_name": display_name,
		"password_required": password_required,
		"server_password": server_password
	}

static func from_dict(dict: Dictionary) -> ServerProperties:
	var instance = ServerProperties.new()
	
	if dict.has("display_name"):
		instance.display_name = dict.get("display_name", "server")
	
	if dict.has("password_required"):
		instance.password_required = dict.get("password_required", false)
	
	if dict.has("server_password"):
		instance.server_password = dict.get("server_password", "")
	
	return instance
