class_name UserList
extends RefCounted

signal users_changed

var users: Array[User] = []

func add(new_user: User):
	if !users.has(new_user):
		users.append(new_user)
		users_changed.emit()

func remove(user: User):
	if users.has(user):
		users.erase(user)
		users_changed.emit()

func serialize() -> Dictionary:
	var serialized_users: Array[Dictionary] = []
	for user in users:
		serialized_users.append(user.serialize())
	
	return {
		"users": serialized_users
	}

static func from_dict(dict: Dictionary) -> UserList:
	var instance = UserList.new()
	var dict_users = dict.get("users")
	
	if dict_users and dict_users is Array:
		for user_dict in dict_users:
			instance.users.append(User.from_dict(user_dict))
	
	return instance
