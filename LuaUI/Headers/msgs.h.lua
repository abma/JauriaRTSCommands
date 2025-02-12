VFS.Include("LuaUI/Headers/utilities.lua")

local SendLuaUIMsg = Spring.SendLuaUIMsg
local SendLuaRulesMsg = Spring.SendLuaRulesMsg

LuaMessages = {}

MSG_TYPES = {
	-- Progress bars
	PBAR_CREATE = "pbar_create",
	PBAR_PROGRESS = "pbar_progress",
	PBAR_DESTROY = "pbar_destroy",
	PBAR_FINISHED= "pbar_finished",

	BUILD_UNIT_FAILED = "build_unit_failed",

	BUILDING_COMPLETE = "building_complete",
	UPGRADE_COMPLETE = "upgrade_complete",

	CONVERT_FINISHED = "convert_finished",
	CONVERT_FAILED = "convert_failed",

	POWER_FAILED = "power_failed",

	UNIT_LEVELLED_UP = "unit_levelled_up",
	MORPH = "MORPH",

	GADGET_STATE_QUERY = "GADGET_STATE_QUERY",
	GADGET_STATE_REPLY = "GADGET_STATE_REPLY",

	MULTIPLIER_ADDED = "multiplier_added",
	MULTIPLIER_REMOVED = "multiplier_removed",

	ADD_FAITH = "ADD_FAITH",
}

ACTION_TYPES = {
}

LuaMessages.SEPARATOR = "|"

function LuaMessages.serialize(msg_type, params)
	return msg_type..LuaMessages.SEPARATOR..table.concat(
		utils.map(utils.to_string, params), LuaMessages.SEPARATOR)
end

function LuaMessages.deserialize(message)
	local msg_table = utils.string.split(message, LuaMessages.SEPARATOR)
	local msg_type = msg_table[1]
	table.remove(msg_table, 1)
	return msg_type, msg_table
end

function LuaMessages.SendLuaUIMsg(msg_type, params)
	SendLuaUIMsg(LuaMessages.serialize(msg_type, params))
end

function LuaMessages.SendLuaRulesMsg(msg_type, params)
	SendLuaRulesMsg(LuaMessages.serialize(msg_type, params))
end

function LuaMessages.SendMsgToAll(msg_type, params)
	local msg = LuaMessages.serialize(msg_type, params)
	SendLuaUIMsg(msg)
	SendLuaRulesMsg(msg)
end
