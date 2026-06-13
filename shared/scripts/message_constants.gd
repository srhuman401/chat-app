class_name MsgType
extends RefCounted

const CLIENT_SEND_MESSAGE = "SendMessage"
const CLIENT_CONNECT_REQUEST = "RequestConnectionToServer"

const SERVER_APPROVE_CONNECTION = "RequestConnectionToServerRecvUpdate"
const SERVER_UPDATE_USERLIST = "UserListRecieveUpdate"
const SERVER_MESSAGE_STORE_CHANGED = "MessageStateChangedUpdateStore"
const SERVER_SEND_ROOM_SNAPSHOT = "RecieveRoomSnapshotUpdate"
