
local AudioMgr = {
	bg_music_enabled = true,
	effect_enabled = true
}

-- 所有音乐文件
AudioMgr.AUDIO_ID = {
	CLICK = "click",
	GAME_BGM = "GameBgm",
}

-- 音乐文件存放的地方
local BASE_DIR = "audio/"

-- 音乐文件扩展名
local EXT = ".mp3"

-- local audio_engine = cc.AudioEngine
local audio_engine = ccexp.AudioEngine

AudioMgr.INVALID_ID = -1

AudioMgr.AUDIO_STATE = {
	ERROR = -1,
	INITIALIZING = 0,
	PLAYING = 1,
	PAUSED = 2
}

AudioMgr.PRELOAD_AUDIO = {
	BG_MUSIC = BASE_DIR .. AudioMgr.AUDIO_ID.GAME_BGM .. EXT
}

function AudioMgr:init()
	-- 记录音乐 id
	self._music_id = self.INVALID_ID
	-- 记录音效 id
	self._effect_ids = {}
	-- self.bg_music_enabled = --UserData.getBool(--UserData.KEYS.MUSIC_BG, true)
	-- self.effect_enabled = --UserData.getBool(--UserData.KEYS.MUSIC_FX, true)
	-- self.bg_music_volume = --UserData.getInt(--UserData.KEYS.MUSIC_BG_VOLUME, 100) / 100
	-- self.effect_volume = --UserData.getInt(--UserData.KEYS.MUSIC_FX_VOLUME, 100) / 100
	self.bg_music_enabled = true
	self.effect_enabled = true
	self.bg_music_volume =  100 / 100
	self.effect_volume = 100 / 100
end

-- 背景音乐是否生效
function AudioMgr:isBackgroundMusicEnabled()
	return self.bg_music_enabled
end

-- 设置背景音乐是否生效
function AudioMgr:setBackgroundMusicEnabled(b)
	if self.bg_music_enabled ~= b then
		self.bg_music_enabled = b
		--UserData.setBool(--UserData.KEYS.MUSIC_BG, self.bg_music_enabled)
		local is_playing = self:isBackgroundMusicPlaying()
		if self.bg_music_enabled and not is_playing then
			self:playBackgroundMusic(self.AUDIO_ID.UI_BG)
		elseif not self.bg_music_enabled and is_playing then
			self:stopBackgroundMusic()
		end
	end
end

function AudioMgr:playBackgroundMusic(name)
	if self:isBackgroundMusicEnabled() then
		if self:isBackgroundMusicPlaying() then
			audio_engine:setCurrentTime(self._music_id, 0)
		else
			local fullname = BASE_DIR .. name .. EXT
			self:_playMusic(fullname)
		end
	end
end

function AudioMgr:stopBackgroundMusic()
	if self._music_id ~= self.INVALID_ID then
		audio_engine:stop(self._music_id)
	end
	self._music_id = self.INVALID_ID
end

-- 暂停背景音乐
function AudioMgr:pauseBackgroundMusic()
	if not self:isBackgroundMusicEnabled() then
		return
	end
	if self:isBackgroundMusicPlaying() then
		audio_engine:pause(self._music_id)
	end
end

-- 继续背景音乐
function AudioMgr:resumeBackgroundMusic()
	if not self:isBackgroundMusicEnabled() then
		return
	end
	audio_engine:resume(self._music_id)
end

-- 背景音乐在播放吗
function AudioMgr:isBackgroundMusicPlaying()
	local is_play = false
	if self._music_id ~= self.INVALID_ID then
		is_play = (audio_engine:getState(self._music_id) == self.AUDIO_STATE.PLAYING)
	end
	return is_play
end

function AudioMgr:isEffectEnabled()
	return self.effect_enabled
end

-- 设置音效是否生效
function AudioMgr:setEffectEnabled(b)
	if self.effect_enabled ~= b then
		self.effect_enabled = b
		--UserData.setBool(--UserData.KEYS.MUSIC_FX, b)
	end
end

-- 停止所有音效
function AudioMgr:stopAllEffects()
	for pos=1, #self._effect_ids do
		audio_engine:stop(self._effect_ids[pos])
	end
	self._effect_ids = {}
end

function AudioMgr:getBackgroundMusicVolume()
	return self.bg_music_volume
end

function AudioMgr:setBackgroundMusicVolume(volume)
	if not self:isBackgroundMusicEnabled() and volume > 0 then
		self:setBackgroundMusicEnabled(true)
	elseif self:isBackgroundMusicEnabled() and volume == 0 then
		self:setBackgroundMusicEnabled(false)
	end
	--UserData.setInt(--UserData.KEYS.MUSIC_BG_VOLUME, volume * 100)
	self.bg_music_volume = volume
	audio_engine:setVolume(self._music_id, volume)
end

function AudioMgr:getEffectsVolume()
	return self.effect_volume
end

function AudioMgr:setEffectsVolume(volume)
	if not self:isEffectEnabled() and volume > 0 then
		self:setEffectEnabled(true)
	elseif self:isEffectEnabled() and volume == 0 then
		self:setEffectEnabled(false)
	end
	--UserData.setInt(--UserData.KEYS.MUSIC_FX_VOLUME, volume * 100)
	-- 下一次播放音效时，会使用此音量
	self.effect_volume = volume
end

-- 播放一个音效
function AudioMgr:play(name)
	if self:isEffectEnabled() then
		local fullname = BASE_DIR .. name .. EXT
		self:_playEffect(fullname)
	end
end

-- 播放普攻音效, name为hero表或monster表中的配置项atkSound
function AudioMgr:playAttack(name)
	if self:isEffectEnabled() then
		local fullname = BASE_DIR .. "ui/" .. name .. EXT
		self:_playEffect(fullname)
	end
end

-- 播放技能音效, name为hero表或monster表中的配置项sound
function AudioMgr:playSkill(name)
	if self:isEffectEnabled() then
		local fullname = BASE_DIR .. "skill/" .. name .. EXT
		self:_playEffect(fullname)
	end
end

-- 播放英雄talk
function AudioMgr:playHeroTalk(name)
	if self:isEffectEnabled() then
		local lgg_str = "us/"
		local lgg = I18n.getLanguageShortName()
		if lgg == "cn" or lgg == "tw" then
			lgg_str = "cn/"
		elseif lgg == "jp" then
			lgg_str = "jp/"
		end
		local fullname = BASE_DIR .. "hero/" .. lgg_str .. name
		self:stopAllEffects()
		self:_playEffect(fullname)
	end
end

function AudioMgr:stopAll()
	self:stopAllEffects()
	self:stopBackgroundMusic()
end

function AudioMgr:_playMusic(fullname)
	-- print("AudioMgr play2d music: " .. fullname)
	self._music_id = audio_engine:play2d(fullname, true, self.bg_music_volume)
end

function AudioMgr:_playEffect(fullname)
	-- audio_engine:preload(fullname, function(is_success)
	-- 	if is_success then
			Log.print("AudioManager play2d effect: " .. fullname)
			local cur_id = audio_engine:play2d(fullname, false, self.effect_volume)
			self._effect_ids[#self._effect_ids + 1] = cur_id
			-- 音效播放结束，移除记录的音效 ID
			audio_engine:setFinishCallback(cur_id, function(id, path)
				for pos = 1, #self._effect_ids do
					if self._effect_ids[pos] == id then
						table.remove(self._effect_ids, pos)
						return
					end
				end
			end)
		-- end
	-- end)
	-- print("AudioMgr play2d effect: " .. fullname)
	-- local profile = cc.AudioProfile:new()
	-- profile.name = fullname
	-- local cur_id = audio_engine:play2d(fullname, false, self.effect_volume, profile)
	-- self._effect_ids[#self._effect_ids + 1] = cur_id
	-- -- 音效播放结束，移除记录的音效 ID
	-- audio_engine:setFinishCallback(cur_id, function(id, path)
	--     for pos = 1, #self._effect_ids do
	--         if self._effect_ids[pos] == id then
	--             table.remove(self._effect_ids, pos)
	--             return
	--         end
	--     end
	-- end)
end

return AudioMgr
