local ResHper = require "app.tools.resHper"
local AsyncHper = require "app.tools.asyncHper"
-- local ResFormatMap = require "app.common.resFormatMap"

local ResMgr = {}

ResMgr.RES_TYPE = {
    IMAGE = 1,
    PLIST = 2,
    SPINE_JSON = 3,
    PARTICLES = 4
}

local SPINE_JSON_EXTENSION = ".json"
local IMAGE_EXTENSION = ".png"
local PLIST_EXTENSION = ".plist"

local texture_cache = cc.Director:getInstance():getTextureCache()
local sprite_frame_cache = cc.SpriteFrameCache:getInstance()
--local skeleton_data_cache = fs.DHSkeletonDataCache:getInstance()

function ResMgr:loadUnpackedImage(path, async_cb)
    local full_path = path .. IMAGE_EXTENSION
    local key = full_path -- 直接将路径作为 key
    ResHper:record(full_path, "By loadUnpackedImage")
    if (not async_cb) then
        if not ResHper:shouldLoad(full_path) then
            return
        end
        -- 如果 full_path 被添加过，直接返回
        if sprite_frame_cache:getSpriteFrame(key) then
            return
        end
        local tex = self:addImage(full_path)
        local size = tex:getContentSize()
        local rect = cc.rect(0, 0, size.width, size.height)
        local frame = cc.SpriteFrame:createWithTexture(tex, rect)
        sprite_frame_cache:addSpriteFrame(frame, key)
    else
        self:addImageAsync(full_path, function(tex)
            tex:getContentSize()
            local size = tex:getContentSize()
            local rect = cc.rect(0, 0, size.width, size.height)
            local frame = cc.SpriteFrame:createWithTexture(tex, rect)
            sprite_frame_cache:addSpriteFrame(frame, key)
            async_cb()
        end)
    end
end

function ResMgr:unloadUnpackedImage(path)
    local full_path = path .. IMAGE_EXTENSION
    ResHper:unRecord(full_path)
    if not ResHper:shouldUnload(full_path) then
        return
    end
    local key = full_path -- 默认路径是 key
    local tex = texture_cache:getTextureForKey(key)
    if tex then
        sprite_frame_cache:removeSpriteFramesFromTexture(tex)
        texture_cache:removeTextureForKey(key)
    end
end

-- 资源附着到 node，当 node 释放时，同时释放资源
function ResMgr:markUnpackImageAttachTo(node, path)
    local node_attach = cc.Node:create()
    node:addChild(node_attach)
    local cleaned = false
    node_attach:registerScriptHandler(
        function(event_name)
            if event_name == "cleanup" and not cleaned then
                cleaned = true
                ResMgr:unloadUnpackedImage(path)
                print("unload image in mark attach to : " .. path)
            end
        end
    )
end

function ResMgr:loadPlist(path, async_cb)
    local full_path = path .. PLIST_EXTENSION
    ResHper:record(full_path, "By loadPlist")
    if not async_cb then
        if not ResHper:shouldLoad(full_path) then
            return
        end
        sprite_frame_cache:addSpriteFrames(full_path)
    else
        local img_of_plist = path .. IMAGE_EXTENSION
        self:addImageAsync(img_of_plist, function(tex)
            sprite_frame_cache:addSpriteFrames(full_path)
            async_cb()
        end)
    end
end

-- 粒子的纹理是创建的时候 解析后直接加到纹理，没有走资源管理，所以只有unload
function ResMgr:unloadParticles(path)
    local key = cc.FileUtils:getInstance():fullPathForFilename(path .. PLIST_EXTENSION) .. path .. IMAGE_EXTENSION
    local tex = texture_cache:getTextureForKey(key)
    if tex then
        texture_cache:removeTextureForKey(key)
    end
end

function ResMgr:unloadPlist(path)
    local full_path = path .. PLIST_EXTENSION
    ResHper:unRecord(full_path)
    if not ResHper:shouldUnload(full_path) then
        return
    end
    local tex = texture_cache:getTextureForKey(path .. IMAGE_EXTENSION)
    if tex then
        sprite_frame_cache:removeSpriteFramesFromFile(full_path)
        texture_cache:removeTextureForKey(path .. IMAGE_EXTENSION)
    end
end

-- 资源附着到 node，当 node 释放时，同时释放资源
function ResMgr:markPlistAttachTo(node, path)
    local node_attach = cc.Node:create()
    node:addChild(node_attach)
    local cleaned = false
    node_attach:registerScriptHandler(
        function(event_name)
            if event_name == "cleanup" and not cleaned then
                cleaned = true
                ResMgr:unloadPlist(path)
                -- print("unload plist in mark attach to: " .. path)
            end
        end
    )
end

function ResMgr:loadSpineJson(key, async_cb)
    local full_path = key .. SPINE_JSON_EXTENSION
    ResHper:record(full_path, "By loadSpineJson")
    if not async_cb then
        if not ResHper:shouldLoad(full_path) then
            return
        end
        --skeleton_data_cache:loadSkeletonData(full_path, full_path)
    else
        --skeleton_data_cache:loadSkeletonData(full_path, full_path)
        async_cb() -- loadjson 直接同步 load，调用回调
    end
end

function ResMgr:unloadSpineJson(key)
    local full_path = key .. SPINE_JSON_EXTENSION
    ResHper:unRecord(full_path)
    if not ResHper:shouldUnload(full_path) then
        return
    end
    --skeleton_data_cache:removeSkeletonData(full_path)
end

-- 资源附着到 node，当 node 释放时，同时释放资源
function ResMgr:markSpineJsonAttachTo(node, path)
    local node_attach = cc.Node:create()
    node:addChild(node_attach)
    local cleaned = false
    node_attach:registerScriptHandler(
        function(event_name)
            if event_name == "cleanup" and not cleaned then
                cleaned = true
                ResMgr:unloadSpineJson(path)
                -- print("unload spine json in mark attach to: " .. path)
            end
        end
    )
end

function ResMgr:loadPlists(plists)
    for k, v in ipairs(plists) do
        self:loadPlist(v)
    end
end

function ResMgr:loadSpineJsons(jsons)
    for k, v in ipairs(jsons) do
        self:loadSpineJson(v)
    end
end

function ResMgr:loadResList(res_list)
    local image_array = res_list[ResMgr.RES_TYPE.IMAGE]
    if image_array then
        for k, v in ipairs(image_array) do
            self:loadUnpackedImage(v)
        end
    end
    local plist_array = res_list[ResMgr.RES_TYPE.PLIST]
    if plist_array then
        self:loadPlists(plist_array)
    end
    local json_array = res_list[ResMgr.RES_TYPE.SPINE_JSON]
    if json_array then
        self:loadSpineJsons(json_array)
    end
end

function ResMgr:loadResListAsync(res_list, call_back)
    local function frameAsync(res_name, load_func, type)
        local task = function(async_cb)
            load_func(self, res_name, async_cb)
        end
        AsyncHper.pushTask(task, call_back, "load " .. res_name, type)
    end
    local image_array = res_list[ResMgr.RES_TYPE.IMAGE]
    if image_array then
        for k, res_name in ipairs(image_array) do
            frameAsync(res_name, self.loadUnpackedImage, ResMgr.RES_TYPE.IMAGE)
        end
    end
    local plist_array = res_list[ResMgr.RES_TYPE.PLIST]
    if plist_array then
        for k, res_name in ipairs(plist_array) do
            frameAsync(res_name, self.loadPlist, ResMgr.RES_TYPE.PLIST)
        end
    end
    -- json 的加载依赖 plist 的加载完成，需保证顺序
    local json_array = res_list[ResMgr.RES_TYPE.SPINE_JSON]
    if json_array then
        for k, res_name in ipairs(json_array) do
            frameAsync(res_name, self.loadSpineJson, ResMgr.RES_TYPE.SPINE_JSON)
        end
    end
end

function ResMgr:unloadResList(res_list)
    -- 分帧 unload，不会有资源冲突
    -- 如果 load 和 unload 同时存在，会先做完所有 load，再慢慢 unload
    self:unloadResListAsync(res_list)
end

function ResMgr:unloadResListAsync(res_list)
    local function asyncUnLoad(res_name, unload_func)
        local task = function()
            unload_func(self, res_name)
        end
        AsyncHper.pushTask(task, nil, "unload " .. res_name)
    end
    local image_array = res_list[ResMgr.RES_TYPE.IMAGE]
    if image_array then
        for k, res_name in ipairs(image_array) do
            asyncUnLoad(res_name, self.unloadUnpackedImage)
        end
    end
    local plist_array = res_list[ResMgr.RES_TYPE.PLIST]
    if plist_array then
        for k, res_name in ipairs(plist_array) do
            asyncUnLoad(res_name, self.unloadPlist)
        end
    end
    local json_array = res_list[ResMgr.RES_TYPE.SPINE_JSON]
    if json_array then
        for k, res_name in ipairs(json_array) do
            asyncUnLoad(res_name, self.unloadSpineJson)
        end
    end
    -- 粒子只有unload
    local particles_array = res_list[ResMgr.RES_TYPE.PARTICLES]
    if particles_array then
        for k, res_name in ipairs(particles_array) do
            asyncUnLoad(res_name, self.unloadParticles)
        end
    end
end

function ResMgr:addImage(png_path)
    -- if ResFormatMap[png_path] then
    --     cc.Texture2D:setDefaultAlphaPixelFormat(ResFormatMap[png_path])
    -- end
    local tex = texture_cache:addImage(png_path)
    -- if ResFormatMap[png_path] then
    --     cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    -- end
    return tex
end

function ResMgr:addImageAsync(png_path, callback)
    -- if ResFormatMap[png_path] then
    --     cc.Texture2D:setDefaultAlphaPixelFormat(ResFormatMap[png_path])
    -- end
    texture_cache:addImageAsync(png_path, callback)
    -- if ResFormatMap[png_path] then
    --     cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    -- end
end

-- 返回去重后的列表和总数
function ResMgr:getResTotal(res_list)
    local out_list = {}
    local total = 0
    local image_array = res_list[ResMgr.RES_TYPE.IMAGE]
    local plist_array = res_list[ResMgr.RES_TYPE.PLIST]
    local json_array = res_list[ResMgr.RES_TYPE.SPINE_JSON]
    if image_array then
        local out_img = GApi.arrayToSet(image_array)
        total = total + #out_img
        out_list[ResMgr.RES_TYPE.IMAGE] = out_img
    end
    if plist_array then
        local out_plist = GApi.arrayToSet(plist_array)
        total = total + #out_plist
        out_list[ResMgr.RES_TYPE.PLIST] = out_plist
    end
    if json_array then
        local out_json = GApi.arrayToSet(json_array)
        total = total + #out_json
        out_list[ResMgr.RES_TYPE.SPINE_JSON] = out_json
    end
    return out_list, total
end

-- 应预加载的资源是当前白名单列入的资源
function ResMgr:getPreloadRes()
    local out_lists = {}
    local raw_lists = ResHper:getWhiteList()
    local plist_s, png_s, json_s = {}, {}, {}
    for i = 1, #raw_lists do
        local item = raw_lists[i]
        if string.endwith(item, ".plist") then
            plist_s[#plist_s + 1] = GApi.removeExtension(item)
        elseif string.endwith(item, ".png") then
            png_s[#png_s + 1] = GApi.removeExtension(item)
        elseif string.endwith(item, ".json") then
            json_s[#json_s + 1] = GApi.removeExtension(item)
        end
    end
    out_lists[ResMgr.RES_TYPE.PLIST] = plist_s
    out_lists[ResMgr.RES_TYPE.IMAGE] = png_s
    out_lists[ResMgr.RES_TYPE.SPINE_JSON] = json_s
    return out_lists
end

-- sprite frame 是否存在
function ResMgr:frameExisted(frame_path)
    local frame = sprite_frame_cache:getSpriteFrame(frame_path)
    return frame ~= nil
end

function ResMgr:purge()
    AsyncHper:purge()
    ResHper:purge()
    --skeleton_data_cache:purgeCache()
    sprite_frame_cache:removeSpriteFrames()
    texture_cache:removeAllTextures()
    ResMgr.fight_res = nil
end

return ResMgr
