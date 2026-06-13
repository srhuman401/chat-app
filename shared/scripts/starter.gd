extends Node

func _ready() -> void:
	print("[GAME] launching")
	print("[GAME] checking features")
	
	if OS.has_feature("dedicated_server"):
		print("[GAME] detected 'dedicated_server' in features")
		print("[GAME] changing to dedicatedserver...")
		get_tree().change_scene_to_file.call_deferred("res://server/scenes/server_root.tscn")
	else:
		print("[GAME] detected client, no special features as of launch")
		print("[GAME] launching into client application...")
		get_tree().change_scene_to_file.call_deferred("res://client/scenes/client_main.tscn")
