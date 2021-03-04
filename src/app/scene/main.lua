-- replaceScene(require("ui.login.home").create())

local MainScene = class("MainScene")

function MainScene:ctor()
	self.scene = cc.Scene:create()

	self.scene:onNodeEvent("enter", function ()
		self:onEnter()
	end)
end

function MainScene:enter()
	cc.Director:getInstance():replaceScene(self.scene)
end

function MainScene:onEnter()
	UIMgr:init(self.scene)
	local LoginMgr = require "app.ui.login.loginMgr"
	LoginMgr:showLoginMain()
end

return MainScene