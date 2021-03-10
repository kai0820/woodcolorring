local UserData = {}

UserData.KEYS = {
	MUSIC_BG = "music_bg",
	MUSIC_FX = "music_fx",
	MUSIC_BG_VOLUME = "music_bg_volume",
	MUSIC_FX_VOLUME = "music_fx_volume",
}

local u = cc.UserDefault:getInstance()

function UserData.getString(k, default) 
	default = default or ""
	return u:getStringForKey(k, default)
end

function UserData.setString(k, v)
	u:setStringForKey(k, v)
	u:flush()
end

function UserData.getBool(k, default)
	local s = UserData.getString(k)
	if s == "1" then
		return true
	elseif s == "0" then
		return false
	else
		return default or false
	end
end

function UserData.setBool(k, v)
	if v then
		UserData.setString(k, "1")
	else
		UserData.setString(k, "0")
	end
end

function UserData.getInt(k, default)
	return tonumber(UserData.getString(k), 10) or default or 0
end

function UserData.setInt(k, v)
	UserData.setString(k, tostring(v))
end

return UserData