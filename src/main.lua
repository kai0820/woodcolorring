--[[
				   _ooOoo_
				  o8888888o
				  88" . "88
				  (| -_- |)
				  O\  =  /O
			   ____/`---'\____
			 .'  \\|     |//  `.
		    /  \\|||  :  |||//  \
		   /  _||||| -:- |||||-  \
		   |   | \\\  -  /// |   |
		   | \_|  ''\---/''  |   |
		   \  .-\__  `-`  ___/-. /
		 ___`. .'  /--.--\  `. . __
	  ."" '<  `.___\_<|>_/___.'  >'"".
	 | | :  `- \`.;`\ _ /`;.`/ - ` : | |
	 \  \ `-.   \_ __\ /__ _/   .-` /  /
======`-.____`-.___\_____/___.-`____.-'======
				   `=---='
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		 佛祖保佑!       永无BUG!
]]

require "config"

cc.FileUtils:getInstance():setPopupNotify(false)

local last_error_msg = ""

function __G__TRACKBACK__(msg)
    local error_msg = debug.traceback(msg, 3)
    release_print("----------------------------------------")
    release_print("LUA ERROR: " .. tostring(error_msg))
    release_print("----------------------------------------")
end

-- if DEBUG > 1 then
--     local debugXpCall = nil
--     local socketHandle = nil
--     socketHandle, debugXpCall = require("debug.LuaDebugjit")("localhost", 7003, true) 
--     cc.Director:getInstance():getScheduler():scheduleScriptFunc(socketHandle, 0.1, false)
-- end
-- if DEBUG > 1 then
-- 	release_print('debug only enabled when debug and no-crypto') 
-- 	local debugXpCall = nil
-- 	local socketHandle = nil
-- 	socketHandle, debugXpCall = require("debug.LuaDebug")("localhost", 7003) 
-- 	cc.Director:getInstance():getScheduler():scheduleScriptFunc(socketHandle, 0.1, false)
-- end

local function main()
    -- cocos2dx的安卓开启LuaJit反而会导致性能下降
    if jit then
		jit.off()
	end
	collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    -- fps stats
    
    cc.Director:getInstance():setDisplayStats(CC_SHOW_FPS)

    Game = require "app.game"
    Game:recordloadedList()
    Game:showLaunchScreen()
end

xpcall(main, __G__TRACKBACK__)
