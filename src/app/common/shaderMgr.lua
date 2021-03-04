local ShaderMgr = {
    loaded_shaders = {}
}

ShaderMgr.SHADER_TYPE = {
    GRAY         = "gray",
    GRAY2        = "gray2",
    HIGHLIGHT    = "highlight",
    ICE          = "ice",
    INJURED      = "injured",
    DARK         = "dark",
    HOOK_MAP     = "hook_map",
    GAUSSIAN     = "gaussian",
    BSC          = "bsc",  -- 亮度、饱和度、对比度
}

function ShaderMgr:loadShader(name, fsh)
    if self.loaded_shaders[name] then
        return
    end
    self.loaded_shaders[name] = fsh

    local vshFile = "shaders/default.vsh"
	local vshFile_MVP = "shaders/default_mvp.vsh"
	local fshFile = "shaders/" .. fsh

	local program = cc.GLProgramCache:getInstance():getGLProgram(name)
	if program == nil then
		program = cc.GLProgram:create(vshFile, fshFile)
		program:link()
		program:updateUniforms()
		cc.GLProgramCache:getInstance():addGLProgram(program, name)
	end

	-- local program_mvp = cc.GLProgramCache:getInstance():getGLProgram(name .. "_mvp")
	-- if program_mvp == nil then
	-- 	program_mvp = cc.GLProgram:create(vshFile_MVP, fshFile)
	-- 	program_mvp:link()
	-- 	program_mvp:updateUniforms()
	-- 	cc.GLProgramCache:getInstance():addGLProgram(program_mvp, name .. "_mvp")
	-- end
end

function ShaderMgr:reloadShader(name, fsh)
	local vshFile = "shaders/default.vsh"
	local vshFile_MVP = "shaders/default_mvp.vsh"
	local fshFile = "shaders/" .. fsh

	local p = cc.GLProgramCache:getInstance():getGLProgram(name)
	if p then
		p:reset()
		p:initWithFilenames(vshFile, fshFile)
		p:link()
		p:updateUniforms()
	end

	-- local mvp = cc.GLProgramCache:getInstance():getGLProgram(name .. "_mvp")
	-- if mvp then
	-- 	mvp:reset()
	-- 	mvp:initWithFilenames(vshFile_MVP, fshFile)
	-- 	mvp:link()
	-- 	mvp:updateUniforms()
	-- end
end

function ShaderMgr:updateUniforms(params)
    local p = cc.GLProgramCache:getInstance():getGLProgram(params.shader)
    if p == nil then
        return
    end
    local gl_state = cc.GLProgramState:getOrCreateWithGLProgram(p)
    local u_color = gl.getUniformLocation(p:getProgram(), params.uniform)
    if params.f1 and params.f2 and params.f3 then
        gl_state:setUniformVec4(u_color, cc.vec4(params.f1, params.f2, params.f3, params.f4 or 0))
    elseif params.f1 and params.f2 then
        gl_state:setUniformVec2(u_color, cc.vec2(params.f1, params.f2))
    elseif params.f1 then
        gl_state:setUniformFloat(u_color, params.f1)
    end
end

function ShaderMgr:init()
    self.loaded_shaders = {}
    self:loadShader(ShaderMgr.SHADER_TYPE.GRAY, "gray.fsh")
    self:loadShader(ShaderMgr.SHADER_TYPE.GRAY2, "gray2.fsh")
    self:loadShader(ShaderMgr.SHADER_TYPE.HIGHLIGHT, "highlight.fsh")
    self:loadShader(ShaderMgr.SHADER_TYPE.ICE, "ice.fsh")
    self:loadShader(ShaderMgr.SHADER_TYPE.INJURED, "injured.fsh")
    self:loadShader(ShaderMgr.SHADER_TYPE.DARK, "dark.fsh")
    self:loadShader(ShaderMgr.SHADER_TYPE.HOOK_MAP, "hook_map.fsh")
    self:loadShader(ShaderMgr.SHADER_TYPE.GAUSSIAN, "gaussian.fsh")
    self:loadShader(ShaderMgr.SHADER_TYPE.BSC, "bsc.fsh")
end

function ShaderMgr:reloadCustomGLProgram()
    if self.loaded_shaders then
        for k, v in pairs(self.loaded_shaders) do
            self:reloadShader(k, v)
        end
    end
end

function ShaderMgr:_setShader(node, gl_program, recursively, shader)
    if not node or tolua.isnull(node) then return end
    if tolua.type(node) ~= "cc.Label" then
        if node.getVirtualRenderer then
            node:getVirtualRenderer():setGLProgram(gl_program)
        elseif node.setGLProgram then
            node:setGLProgram(gl_program)
        end
    else
        if shader then
            if node.setLabelShader then
                node:setLabelShader(shader)
            end
        else
            if node.resetLabelShader then
                node:resetLabelShader()
            end
        end
    end

    if recursively then
        local children = node:getChildren()
        for k, v in ipairs(children) do
            self:_setShader(v, gl_program, recursively, shader)
		end
    end
end

function ShaderMgr:setShader(node, shader, recursively)
    local p = cc.GLProgramCache:getInstance():getGLProgram(shader)
    if p == nil then
        return
    end
    self:_setShader(node, p, recursively, shader)
end

function ShaderMgr:resetShader(node, recursively)
    local p = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")
    if p == nil then
        return
    end
    self:_setShader(node, p, recursively)
end

return ShaderMgr
-- local ShaderMgr = {
--     loaded_shaders = {}
-- }

-- ShaderMgr.SHADER_TYPE = {
--     DEFAULT      = "default",
--     GRAY         = "gray",
--     GRAY2        = "gray2",
--     HIGHLIGHT    = "highlight",
--     ICE          = "ice",
--     INJURED      = "injured",
--     DARK         = "dark",
-- }

-- function ShaderMgr:loadShader(name, fsh)
--     if self.loaded_shaders[name] then
--         return
--     end

--     local vshFile = "shaders/default.vsh"
-- 	local vshFile_MVP = "shaders/default_mvp.vsh"
--     local fshFile = "shaders/" .. fsh
    
--     local vertexShader = cc.FileUtils:getInstance():getStringFromFile(vshFile)
--     local fragmentShader = cc.FileUtils:getInstance():getStringFromFile(fshFile)
--     local p = ccb.Device:getInstance():newProgram(vertexShader, fragmentShader)
--     self.loaded_shaders[name] = p
-- end

-- function ShaderMgr:reloadShader(name, fsh)
-- 	local vshFile = "shaders/default.vsh"
-- 	local vshFile_MVP = "shaders/default_mvp.vsh"
-- 	local fshFile = "shaders/" .. fsh
--     local vertexShader = cc.FileUtils:getInstance():getStringFromFile("shaders/default.vsh")
--     local fragmentShader = cc.FileUtils:getInstance():getStringFromFile("shaders/" .. shader .. ".fsh")
-- 	local p = ccb.Device:getInstance():newProgram(vertexShader, fragmentShader)
--     self.loaded_shaders[name] = p
-- end

-- function ShaderMgr:updateUniforms(params)
--     local p = cc.ShaderCache:getInstance():getGLProgram(params.shader)
--     if p == nil then
--         return
--     end
--     local gl_state = cc.GLProgramState:getOrCreateWithGLProgram(p)
--     local u_color = gl.getUniformLocation(p:getProgram(), params.uniform)
--     if params.f1 and params.f2 and params.f3 then
--         gl_state:setUniformVec4(u_color, cc.vec4(params.f1, params.f2, params.f3, params.f4 or 0))
--     elseif params.f1 and params.f2 then
--         gl_state:setUniformVec2(u_color, cc.vec2(params.f1, params.f2))
--     elseif params.f1 then
--         gl_state:setUniformFloat(u_color, params.f1)
--     end
-- end

-- function ShaderMgr:init()
--     self.loaded_shaders = {}
--     -- self:loadShader(ShaderMgr.SHADER_TYPE.DEFAULT, "default.fsh")
--     -- self:loadShader(ShaderMgr.SHADER_TYPE.GRAY, "gray.fsh")
--     -- self:loadShader(ShaderMgr.SHADER_TYPE.GRAY2, "gray2.fsh")
--     -- self:loadShader(ShaderMgr.SHADER_TYPE.HIGHLIGHT, "highlight.fsh")
--     -- self:loadShader(ShaderMgr.SHADER_TYPE.ICE, "ice.fsh")
--     -- self:loadShader(ShaderMgr.SHADER_TYPE.INJURED, "injured.fsh")
--     -- self:loadShader(ShaderMgr.SHADER_TYPE.DARK, "dark.fsh")
--     for k,v in pairs(ShaderMgr.SHADER_TYPE) do
--         self:loadShader(v, v .. ".fsh")
--     end
-- end

-- function ShaderMgr:reloadCustomGLProgram()
--     if self.loaded_shaders then
--         for k, v in pairs(self.loaded_shaders) do
--             self:reloadShader(k, v)
--         end
--     end
-- end

-- function ShaderMgr:_setShader(node, gl_program, recursively)
--     if not node or tolua.isnull(node) then return end
--     local state = ccb.ProgramState:new(gl_program)
--     if node.getVirtualRenderer then
--         node:getVirtualRenderer():setProgramState(state)
--     elseif node.setProgramState then
--         node:setProgramState(state)
--     end

--     if recursively then
--         local children = node:getChildren()
--         for k, v in ipairs(children) do
--             self:_setShader(v, gl_program, recursively)
-- 		end
--     end
-- end

-- function ShaderMgr:setShader(node, shader, recursively)
--     local p = self.loaded_shaders[shader]
--     if p == nil then
--         return
--     end
--     self:_setShader(node, p, recursively)
-- end

-- function ShaderMgr:resetShader(node, recursively)
--     local p = self.loaded_shaders[ShaderMgr.SHADER_TYPE.DEFAULT]
--     if p == nil then
--         return
--     end
--     self:_setShader(node, p, recursively)
-- end

-- return ShaderMgr