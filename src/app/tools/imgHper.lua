local cfg_head = require "app.config.head"
local cfg_hero = require "app.config.hero"
local cfg_equip = require "app.config.equip"
local cfg_item = require "app.config.item"
local cfg_skill = require "app.config.skill"
local cfg_petskill = require "app.config.petskill"
local cfg_guildskill = require "app.config.guildskill"
local LabelHelper = require "app.tools.labelHelper"
local AnimationHelper = require "app.tools.animationHelper"

local ImageHelper = {}

local BASE_DIR = "images/"
local MAP_DIR = "maps/"
local HEAD_DIR = "avatar/"
local ITEM_DIR = "item/"
local EQUIP_DIR = "equipment/"
local SKIN_DIR = "skin/"
local SKILL_DIR = "skill/"
local GSKILL_DIR = "guildSkill/"
local GFLAG_DIR = "guild/"
local BUFF_DIR = "buff/"
local UI_DIR = "ui/"
local HOOK_MAP_DIR = "hookscenes/"
local LOADING_DIR = "loading/"

local JOB_ICON_PATH = {
    [1] = "public/public_mark_class_warrior.png",
    [2] = "public/public_mark_class_mage.png",
    [3] = "public/public_mark_class_ranger.png",
    [4] = "public/public_mark_class_assassin.png",
    [5] = "public/public_mark_class_priest.png",
}

local GROUP_ICON_PATH = {
    [1] = "public/public_faction_shadow.png",
    [2] = "public/public_faction_fortess.png",
    [3] = "public/public_faction_abyss.png",
    [4] = "public/public_faction_forest.png",
    [5] = "public/public_faction_dark.png",
    [6] = "public/public_faction_light.png",
}

local ICON_WIDTH = 102
local ICON_HEIGHT = 102
local ICON_SCALE_FACTOR = 104/114

-- 表示装备、物品数量的字号大小
local ICON_NUM_FONT_SIZE = 22

function ImageHelper.createHeroHeadByHid(hid)
    local HerosData = require "app.data.heros"
    local h = HerosData.find(hid)
    return ImageHelper.createHeroHead(h.id, h.lv, true, true, h.wake, nil, nil, hid)
end

function ImageHelper.createHeroHeadIcon(id)
    local info = GApi.getHeroDetailInfo(id)
    local name = string.format("%s%04d.png", HEAD_DIR, info.icon)
    return fs.Image:create(name)
end

function ImageHelper.createPlayerHeadById(id)
    if id <= #cfg_head then
        local name = string.format("%s%04d.png", HEAD_DIR, cfg_head[id].iconId)
        return fs.Image:create(name)
    else
        return ImageHelper.createHeroHeadIcon(id)
    end
end

function ImageHelper.createPlayerHead(id, lv, flip_x, border)
    local bg = fs.Image:create("public/public_player_box.png")

    local head = ImageHelper.createPlayerHeadById(id)

    local function createAni()
        local img_url = "images/spine_ui_common"
        local json = "spinejson/ui/ui_avatar_high"
        AnimationHelper.loadSpineRes(img_url, json)
        local head_ani = AnimationHelper.createSpine(json)
        head_ani:playAnimation("animation",-1)
        head_ani:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2)
        bg:addChild(head_ani, 10)
        AnimationHelper.markSpineResAttachTo(head, img_url, json)
    end
    if cfg_head[id] and cfg_head[id].isShine then
        createAni()
    elseif not cfg_head[id] and cfg_hero[id] and cfg_hero[id].maxStar == 10 then
        createAni()
    end

    if id ~= 185 and id ~= 222 and flip_x == true then   -- 185头像2019
        head:setScale(-ICON_SCALE_FACTOR, ICON_SCALE_FACTOR)
    else
        head:setScale(ICON_SCALE_FACTOR)
    end
    head:setPosition(bg:getContentSize().width/2, bg:getContentSize().height/2)
    bg:addChild(head)

    if border then
        local border_icon = ImageHelper.createBorderIcon2(border)
        border_icon:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
        bg:addChild(border_icon)
    end

    if lv then
        local show_lv_bg = fs.Image:create("public/public_playerlv_box.png")
        if flip_x == true then
            show_lv_bg:setPosition(64 + 14, 21)
        else
            show_lv_bg:setPosition(30, 21)
        end
        bg:addChild(show_lv_bg, GConst.Z_ORDER_TOP)

        local show_lv_label = LabelHelper.createOutlineFont(20, lv)
        show_lv_label:setPosition(show_lv_bg:getContentSize().width/2 -1, show_lv_bg:getContentSize().height/2)
        show_lv_bg:addChild(show_lv_label)
    end
    return bg
end

function ImageHelper.createPlayerHeadForArena(id, lv, border)
    local bg = fs.Image:create("public/public_player_box.png")

    local head
    if cfg_head[id] then
        head = ImageHelper.createPlayerHeadById(id)
        if cfg_head[id].isShine then
            local img_url = "images/spine_ui_common"
            local json = "spinejson/ui/ui_avatar_high"
            AnimationHelper.loadSpineRes(img_url, json)
            local head_ani = AnimationHelper.createSpine(json)
            head_ani:playAnimation("animation",-1)
            head_ani:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2)
            bg:addChild(head_ani, 10)
            AnimationHelper.markSpineResAttachTo(head, img_url, json)
        end
    else
        head = ImageHelper.createHeroHeadIcon(id)
    end
    head:setScale(0.95)
    head:setPosition(bg:getContentSize().width/2, bg:getContentSize().height/2)
    bg:addChild(head)

    if border then
        local border_icon = ImageHelper.createBorderIcon2(border)
        border_icon:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
        bg:addChild(border_icon)
    end

    if lv then
        local show_lv_bg = fs.Image:create("public/public_playerlv_box.png")
        show_lv_bg:setPosition(30, 21)
        bg:addChild(show_lv_bg, 1000)

        local show_lv_label = LabelHelper.createOutlineFont(20, lv)
        show_lv_label:setPosition(show_lv_bg:getContentSize().width/2 -1, show_lv_bg:getContentSize().height/2)
        show_lv_bg:addChild(show_lv_label)
    end


    return bg
end

function ImageHelper.createJobIcon(job)
    return fs.Image:create(JOB_ICON_PATH[job])
end

function ImageHelper.createSkinIcon(id)
    local cfg_equip = require "app.config.equip"
    return fs.Image:create(SKIN_DIR .. cfg_equip[id].icon .. ".png")
end

function ImageHelper.createSkin(id)
    local cfg_equip = require "app.config.equip"
    local cfg_hero = require "app.config.hero"
    local skin = ImageHelper.createSkinIcon(id)
    local fram_bg = nil
    if cfg_equip[id].powerful and cfg_equip[id].powerful == 1 then
        fram_bg = fs.Image:create("public/public_hero_skin_box2.png")
    elseif cfg_equip[id].powerful and cfg_equip[id].powerful == 2 then
        fram_bg = fs.Image:create("public/public_hero_skin_box3.png")
        local img_url = "images/spine_ui_skin"
        local json = "spinejson/ui/ui_skin_cardglow"
        AnimationHelper.loadSpineRes(img_url, json)
        local ani_touxiang = AnimationHelper.createSpine("spinejson/ui/ui_skin_cardglow")
        ani_touxiang:playAnimation("ui_pifu_cardglow", -1)
        ani_touxiang:setPosition(skin:getContentSize().width/2, skin:getContentSize().height/2)
        skin:addChild(ani_touxiang)
        AnimationHelper.markSpineResAttachTo(ani_touxiang, img_url, json)
    else
        fram_bg = fs.Image:create("public/public_hero_skin_box1.png")
    end
    fram_bg:setAnchorPoint(0.5, 0)
    fram_bg:setPosition(skin:getContentSize().width/2, -7)
    skin:addChild(fram_bg)

    local group_icon = ImageHelper.createGroupIcon(cfg_hero[cfg_equip[id].heroId[1]].group)
    group_icon:setScale(0.66)
    group_icon:setPosition(18, skin:getContentSize().height-18)
    skin:addChild(group_icon, 1)

    return skin
end

function ImageHelper.createEquipIcon(id)
    return fs.Image:create(EQUIP_DIR .. cfg_equip[id].icon .. ".png")
end

function ImageHelper.createEquipQualityBg(id)
    return fs.Image:create("public/public_item_box_" .. cfg_equip[id].qlt .. ".png")
end

function ImageHelper.createEquipQualityBgForBorder(id)
    return fs.Image:create("public/public_item_box_" .. cfg_equip[id].qlt .. "_1.png")
end

function ImageHelper.createItemIcon(id)
    return fs.Image:create(ITEM_DIR .. cfg_item[id].icon .. ".png")
end

function ImageHelper.createItemIcon2(id)
    return fs.Image:create(ITEM_DIR .. cfg_item[id].icon2 .. ".png")
end

function ImageHelper.getItemIconUrlForId(id)
    return ITEM_DIR .. id .. ".png"
end

function ImageHelper.createItemIconForId(id)
    return fs.Image:create(ITEM_DIR .. id .. ".png")
end

-- 技能图标
function ImageHelper.createSkill(id)
    local res_name = BASE_DIR .. SKILL_DIR .. cfg_skill[id].iconId
    local res_path = res_name .. ".png"
    ResManager:loadUnpackedImage(res_name)
    return fs.Image:create(res_path)
end

function ImageHelper.unloadAllSkill()
    for _, cfg in ipairs(cfg_skill) do
        if cfg.iconId then
            local res_name = BASE_DIR .. SKILL_DIR .. cfg.iconId
            ResManager:unloadUnpackedImage(res_name)
        end
    end
end

-- 战宠的buff技能图标
function ImageHelper.createPetBuff(id)
    local res_name = BASE_DIR .. SKILL_DIR .. cfg_petskill[id].icon
    local res_path = res_name  .. ".png"
    ResManager:loadUnpackedImage(res_name)
    return fs.Image:create(res_path)
end

function ImageHelper.unloadAllPetBuff()
    for _, cfg in ipairs(cfg_petskill) do
        if cfg.icon then
            local res_name = BASE_DIR .. SKILL_DIR .. cfg.icon
            ResManager:unloadUnpackedImage(res_name)
        end
    end
end

-- 公会技能图标
function ImageHelper.createGSkill(id)
    local res_name = BASE_DIR .. GSKILL_DIR .. cfg_guildskill[id].icon
    local res_path = res_name .. ".png"
    ResManager:loadUnpackedImage(res_name)
    return fs.Image:create(res_path)
end

function ImageHelper.unloadAllGSkill()
    for _, cfg in ipairs(cfg_guildskill) do
        if cfg.icon then
            local full_name = BASE_DIR .. GSKILL_DIR .. cfg.icon
            ResManager:unloadUnpackedImage(full_name)
        end
    end
end

-- 公会旗帜
local guild_res_loaded = false
function ImageHelper.createGFlag(id)
    if not guild_res_loaded then
        ResManager:loadPlist("images/guild")
    end
    local res_path = GFLAG_DIR .. "guild_flag" .. id .. ".png"
    return fs.Image:create(res_path)
end

function ImageHelper.unloadAllGFlag()
    if guild_res_loaded then
        ResManager:unloadPlist("images/guild")
    end
end

-- loading
function ImageHelper.createLoading(name)
    local res_name = BASE_DIR .. LOADING_DIR .. name
    local res_path = res_name .. ".png"
    ResManager:loadUnpackedImage(res_name)
    return fs.Image:create(res_path)
end

function ImageHelper.unloadLoading(name)
    local res_name = BASE_DIR .. LOADING_DIR .. name
    ResManager:unloadUnpackedImage(res_name)
end

function ImageHelper.unloadAllHeroBg()
    for ii=1,6 do
        ResManager:unloadPlist("ui_hero_bg" .. ii)
    end
end

-- 进入主UI卸载无关资源
function ImageHelper.unloadForTown()
    ImageHelper.unloadAllSkill()
    ImageHelper.unloadAllPetBuff()
    ImageHelper.unloadAllGSkill()
    ImageHelper.unloadAllGFlag()
    ImageHelper.unloadAllHeroBg()
end

-- buff图标
function ImageHelper.createBuff(icon_id)
    return fs.Image:create(BUFF_DIR .. icon_id .. ".png")
end

-- buff图标带数字
function ImageHelper.createBuffWithNum(icon_id)
    local icon = fs.Image:create(BUFF_DIR .. icon_id .. ".png")
    local num_label = LabelHelper.createFont(9, "", LabelHelper.LABEL_COLOR.LABEL_WHITE)
    num_label:setPosition(12, 4)
    icon:addChild(num_label, 100)
    icon.lbl = num_label
    return icon
end

-- batchNode
function ImageHelper.createBatchNodeForUI(name)
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
    return cc.SpriteBatchNode:createWithTexture(frame:getTexture())
end

-- 挂机缩略图
function ImageHelper.createHookMap(map_id)
    local res_name = BASE_DIR .. HOOK_MAP_DIR .. map_id
    local res_path = res_name .. ".png"
    ResManager:loadUnpackedImage(res_name)
    return fs.Image:create(res_path)
end

function ImageHelper.unloadHookMap(map_id)
    if not map_id then return end
    local res_name = BASE_DIR .. HOOK_MAP_DIR .. map_id
    ResManager:unloadUnpackedImage(res_name)
end

-- 挂机背景图
function ImageHelper.createHookBg(map_name)
    local map_path = map_name .. ".png"
    ResManager:loadUnpackedImage(map_name)
    return fs.Image:create(map_path)
end

function ImageHelper.unloadHookBg(map_name)
    if not map_name then return end
    ResManager:unloadUnpackedImage(map_name)
end

function ImageHelper.createSkinPieceIcon(id)
    local w, h = ICON_WIDTH, ICON_HEIGHT
    local container = fs.Widget:create()
    container:setContentSize(cc.size(w, h))
    container:setCascadeOpacityEnabled(true)

    local bg = fs.Image:create("public/public_hero_box1.png")
    local bg_size = bg:getContentSize()
    local icon_id
    if id == GConst.ITEM_ID_PIECE_SKIN then
        icon_id = GConst.HERO_ID_SKIN
    else
        icon_id = cfg_equip[cfg_item[id].equip.id].icon
    end
    local icon = fs.Image:create(string.format("%s%04d.png", HEAD_DIR, icon_id))
    icon:setPosition(bg_size.width/2, bg_size.height/2)
    bg:addChild(icon)
    bg:setScale(ICON_SCALE_FACTOR)
    bg:setCascadeOpacityEnabled(true)

    bg:setPosition(w/2, h/2)
    container:addChild(bg)

    return container
end

function ImageHelper.createGroupIcon(group)
    return fs.Image:create(GROUP_ICON_PATH[group])
end

function ImageHelper.createHeroHeadByParam(param)
    local id = param.id
    local lv = param.lv
    local show_group = param.show_group
    local show_star = param.show_star
    local wake = param.wake
    local orange_fx = param.orange_fx
    local pet_id = param.pet_id
    local hid = param.hid
    local skin = param.skin

    local info = GApi.getHeroDetailInfo(id)

    local bg = nil
    if wake and wake >= 4 then
        bg = fs.Image:create("public/public_hero_box3.png")
    else
        bg = fs.Image:create("public/public_hero_box1.png")
    end
    -- bg:setCascadeOpacityEnabled(true)
    local bg_size = bg:getContentSize()

    local icon
    if hid then
        if GApi.getHeroSkin(hid) then
            icon = fs.Image:create(string.format("%s%04d.png", HEAD_DIR, cfg_equip[GApi.getHeroSkin(hid)].heroBody))
        else
            icon = fs.Image:create(string.format("%s%04d.png", HEAD_DIR, info.icon))
        end
    else
        if skin then
            icon = fs.Image:create(string.format("%s%04d.png", HEAD_DIR, cfg_equip[skin].heroBody))
        else
            icon = fs.Image:create(string.format("%s%04d.png", HEAD_DIR, info.icon))
        end
    end
    icon:setPosition(bg_size.width/2, bg_size.height/2)
    bg:addChild(icon)
    bg.icon = icon

    if pet_id ~= nil then
        local pet_spr = fs.Image:create("public/public_hero_monster".. (math.floor(pet_id/100)) .. ".png")
        pet_spr:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2)
        bg:addChild(pet_spr)
        
        --加入宠物特效
        local img_url = "images/spine_ui_common"
        local json = "spinejson/ui/ui_avater_monster"
        AnimationHelper.loadSpineRes(img_url, json)
        local pet_ani = AnimationHelper.createSpine(json)
        pet_ani:playAnimation("animation",-1)
        pet_ani:setName("pet_ani")
        pet_ani:setPosition(pet_spr:getContentSize().width/2,pet_spr:getContentSize().height/2)
        bg:addChild(pet_ani)
        AnimationHelper.markSpineResAttachTo(pet_spr, img_url, json)
    end

    -- lv
    if lv then
        local LabelHelper = require "app.tools.labelHelper"
        local lv_label = LabelHelper.createOutlineFont(20, lv)
        lv_label:setAnchorPoint(cc.p(1, 0.5))
        lv_label:setPosition(bg_size.width - 18, bg_size.height - 24)
        bg:addChild(lv_label)
    end
    -- group
    if show_group and info.group and info.group ~= 9 then
        local group_bg = fs.Image:create("public/public_mark_faction_board.png")
        group_bg:setPosition(22, bg_size.height - 22)
        bg:addChild(group_bg)
        local group_icon = ImageHelper.createGroupIcon(info.group)
        group_icon:setScale(0.45)
        group_icon:setPosition(22, bg_size.height - 22)
        bg:addChild(group_icon)
    end
    -- star
    if show_star then
        if info.qlt <= 5 then
            for i = info.qlt, 1, -1 do
                local star = fs.Image:create("public/public_hero_star1.png")
                star:setScale(0.62)
                star:setPosition(bg_size.width/2 + (i-(info.qlt+1)/2)*16, 19)
                bg:addChild(star)
            end
        elseif info.qlt == 6 then
            local red_star = 1
            if wake and wake ~= 0 then
                red_star = wake+1
            end
            if red_star >= 6 then
                local icon_json = "spinejson/ui/ui_avater_10star"
                ResManager:loadSpineJson(icon_json)
                local star_ani = AnimationHelper.createSpine(icon_json)
                star_ani:playAnimation("animation", -1)
                star_ani:setPosition(bg_size.width/2, bg_size.height/2)
                star_ani:setName("star_ani")
                bg:addChild(star_ani)
                ResManager:markSpineJsonAttachTo(star_ani, icon_json)

                local img_url = "images/spine_ui_avater"
                local json = "spinejson/ui/ui_avater_10star_talen"
                AnimationHelper.loadSpineRes(img_url, json)
                local talen_ani = AnimationHelper.createSpine(json)
                talen_ani:playAnimation("animation", -1)
                talen_ani:setPosition(bg_size.width/2, 19)
                talen_ani:setScale(0.7)
                talen_ani:setName("talen_ani")
                bg:addChild(talen_ani)
                local talen_ani_lab = LabelHelper.createOutlineFont(26, red_star-5)
                talen_ani_lab:setPosition(talen_ani:getContentSize().width/2, 0)
                talen_ani:addChild(talen_ani_lab, 100)
                AnimationHelper.markSpineResAttachTo(talen_ani, img_url, json)
            elseif red_star >= 5 then
                local icon_json = "spinejson/ui/ui_avater_10star"
                ResManager:loadSpineJson(icon_json)
                local star_ani = AnimationHelper.createSpine(icon_json)
                star_ani:playAnimation("animation", -1)
                star_ani:setPosition(bg_size.width/2, bg_size.height/2)
                star_ani:setName("star_ani")
                bg:addChild(star_ani)
                ResManager:markSpineJsonAttachTo(star_ani, icon_json)

                local star = fs.Image:create("public/public_hero_star3.png")
                star:setScale(0.7)
                star:setPosition(bg_size.width/2, 19)
                bg:addChild(star)
            else
                for i = red_star, 1, -1 do
                    local star = fs.Image:create("public/public_hero_star2.png")
                    star:setScale(0.7)
                    star:setPosition(bg_size.width/2 + (i-(red_star+1)/2)*16, 19)
                    bg:addChild(star)
                end
            end
        elseif info.qlt == 9 then
            local red_star = 4
            for i = red_star, 1, -1 do
                local star = fs.Image:create("public/public_hero_star2.png")
                star:setScale(0.7)
                star:setPosition(bg_size.width/2 + (i-(red_star+1)/2)*16, 19)
                bg:addChild(star)
            end
        elseif info.qlt == 10 then
            local star = fs.Image:create("public/public_hero_star3.png")
            star:setScale(0.7)
            star:setPosition(bg_size.width/2, 19)
            bg:addChild(star)
        end
    end

    function bg:shaderEffect()
        local pet_ani = bg:getChildByName("pet_ani")
        if pet_ani then
            pet_ani:stopAnimation()
        end
        local star_ani = bg:getChildByName("star_ani")
        if star_ani then
            star_ani:stopAnimation()
        end
        local talen_ani = bg:getChildByName("talen_ani")
        if talen_ani then
            talen_ani:playAnimation("talen", -1)
        end
    end

    function bg:resumeEffect()
        local pet_ani = bg:getChildByName("pet_ani")
        if pet_ani then
            pet_ani:playAnimation("animation",-1)
        end
        local star_ani = bg:getChildByName("star_ani")
        if star_ani then
            star_ani:playAnimation("animation",-1)
        end
        local talen_ani = bg:getChildByName("talen_ani")
        if talen_ani then
            talen_ani:playAnimation("animation",-1)
        end
    end

    return bg
end

function ImageHelper.createHeroHead(id, lv, show_group, show_star, wake, orange_fx, pet_id, hid)
    local param = {
        id = id,
        lv = lv,
        show_group = show_group,
        show_star = show_star,
        wake = wake,
        orange_fx = orange_fx,
        pet_id = pet_id,
        hid = hid
    }
    return ImageHelper.createHeroHeadByParam(param)
end

function ImageHelper.createHeroPieceIcon(id)
    local w, h = ICON_WIDTH, ICON_HEIGHT
    local container = fs.Widget:create()
    container:setContentSize(cc.size(w, h))
    container:setCascadeOpacityEnabled(true)
    -- icon
    local icon
    if id == GConst.ITEM_ID_PIECE_Q3 then
        icon = ImageHelper.createHeroHead(GConst.HERO_ID_ANY_Q3, nil, nil, true)
    elseif id == GConst.ITEM_ID_PIECE_Q4 then
        icon = ImageHelper.createHeroHead(GConst.HERO_ID_ANY_Q4, nil, nil, true)
    elseif id == GConst.ITEM_ID_PIECE_Q5 then
        icon = ImageHelper.createHeroHead(GConst.HERO_ID_ANY_Q5, nil, nil, true)
    elseif id == GConst.ITEM_ID_PIECE_Q6 then
        icon = ImageHelper.createHeroHead(GConst.HERO_ID_ANY_Q6, nil, nil, true)
    elseif id == GConst.ITEM_ID_PIECE_SKIN then
        icon = ImageHelper.createHeroHead(GConst.HERO_ID_SKIN, nil, nil, true)
    elseif id == GConst.ITEM_ID_EXQ_Q5 then
        icon = ImageHelper.createHeroHead(GConst.HERO_ID_EXQ_Q5, nil, nil, true)
    elseif id == GConst.ITEM_ID_EXQ_LIGHT_Q5 then
        icon = ImageHelper.createHeroHead(GConst.HERO_ID_EXQ_LIGHT_Q5, nil, true, true)
    elseif id == GConst.ITEM_ID_EXQ_DARK_Q5 then
        icon = ImageHelper.createHeroHead(GConst.HERO_ID_EXQ_DARK_Q5, nil, true, true)
    elseif GApi.between(id - GConst.ITEM_ID_PIECE_GROUP_Q3, 1, 9) then
        local group = id - GConst.ITEM_ID_PIECE_GROUP_Q3
        icon = ImageHelper.createHeroHead(GConst.HERO_ID_GROUP_Q3+group*100, nil, true, true)
    elseif GApi.between(id - GConst.ITEM_ID_PIECE_GROUP_Q4, 1, 9) then
        local group = id - GConst.ITEM_ID_PIECE_GROUP_Q4
        icon = ImageHelper.createHeroHead(GConst.HERO_ID_GROUP_Q4+group*100, nil, true, true)
    elseif GApi.between(id - GConst.ITEM_ID_PIECE_GROUP_Q5, 1, 9) then
        local group = id - GConst.ITEM_ID_PIECE_GROUP_Q5
        icon = ImageHelper.createHeroHead(GConst.HERO_ID_GROUP_Q5+group*100, nil, true, true)
    else
        icon = ImageHelper.createHeroHead(cfg_item[id].heroCost.id, nil, true, true)
    end
    icon:setScale(ICON_SCALE_FACTOR)
    icon:setPosition(w/2, h/2)
    container:addChild(icon)

    return container
end

-- 创建物品图标 num:堆叠数量
function ImageHelper.createItem(id, num)
    local bg, size
    if cfg_item[id] == nil then
        print("ERROR: config table lack items: " .. id)
        bg = fs.Image:create("public/public_hero_box1.png")
        size = bg:getContentSize()
    elseif cfg_item[id].type == GConst.ITEM_KIND_HERO_PIECE then
        bg = ImageHelper.createHeroPieceIcon(id)
        size = bg:getContentSize()
        local piece = fs.Image:create("public/public_hero_mark_shard1.png")
        piece:setPosition(size.width - 26, size.height - 26)
        bg:addChild(piece)
    elseif cfg_item[id].type == GConst.ITEM_KIND_SKIN_PIECE then
        bg = ImageHelper.createSkinPieceIcon(id)
        size = bg:getContentSize()

        if id ~= GConst.ITEM_ID_PIECE_SKIN then
            local group_bg = fs.Image:create("public/public_mark_faction_board.png")
            group_bg:setPosition(22, size.height - 22)
            bg:addChild(group_bg)

            if cfg_equip[cfg_item[id].equip.id].heroId[1] then
                local piece_group = cfg_hero[cfg_equip[cfg_item[id].equip.id].heroId[1]].group
                local group_icon = ImageHelper.createGroupIcon(piece_group)
                group_icon:setScale(0.45)
                group_icon:setPosition(22, size.height - 22)
                bg:addChild(group_icon)
            end
        end
        local quality = fs.Image:create("public/public_hero_mark_shard2.png")
        quality:setPosition(size.width/2+24, size.height/2+24)
        bg:addChild(quality)
    else
        bg = fs.Image:create("public/public_item_box.png")
        size = bg:getContentSize()
        if cfg_item[id].type == GConst.ITEM_KIND_TREASURE_PIECE then
            local quality = fs.Image:create("public/public_item_box_" .. cfg_item[id].qlt .. ".png")
            quality:setPosition(size.width/2, size.height/2)
            bg:addChild(quality)
        end
        local icon = ImageHelper.createItemIcon(id)
        icon:setPosition(size.width/2, size.height/2)
        bg:addChild(icon)
    end
    bg:setCascadeOpacityEnabled(true)
    if num then
        local LabelHelper = require "app.tools.labelHelper"
        local num_text = (id == GConst.ITEM_ID_GEM and num <= 10000) and tostring(num) or GApi.convertItemNum(num)
        local l = LabelHelper.createOutlineFont(ICON_NUM_FONT_SIZE, num_text)
        l:setAnchorPoint(1, 0)
        l:setPosition(size.width - 16, 8)
        bg:addChild(l)
        bg.lblNum = l
    end
    return bg
end

-- 创建皮肤装备tips头像
function ImageHelper.createSkinEquip(id)
    local bg = fs.Image:create("public/public_hero_box1.png")
    bg:setPosition(ICON_WIDTH/2, ICON_HEIGHT/2)
    local bg_size = bg:getContentSize()
    local icon = fs.Image:create(string.format("%s%04d.png", HEAD_DIR, cfg_equip[id].icon))
    icon:setPosition(bg_size.width/2, bg_size.height/2)
    bg:addChild(icon)
    bg:setScale(ICON_SCALE_FACTOR)
    return bg
end

function ImageHelper.createBorderEquip(id)
    local bg = fs.Image:create("public/public_player_box.png")
    bg:setPosition(ICON_WIDTH/2, ICON_HEIGHT/2)
    local bg_size = bg:getContentSize()

    local icon = ImageHelper.createBorderIcon2(id)
    icon:setPosition(bg_size.width/2, bg_size.height/2)
    bg:addChild(icon)
    bg:setScale(ICON_SCALE_FACTOR)
    return bg
end

-- 创建完整的装备图标
function ImageHelper.createEquip(id, num)
    local grid = fs.Image:create("public/public_item_box.png")
    local size = grid:getContentSize()
    grid:setCascadeOpacityEnabled(true)

    local quality = ImageHelper.createEquipQualityBg(id)
    if cfg_equip[id].pos == GConst.EQUIP_POS_BORDER then
        quality = ImageHelper.createEquipQualityBgForBorder(id)
    end
    quality:setPosition(size.width/2, size.height/2)
    grid:addChild(quality)
    local icon = ImageHelper.createEquipIcon(id)
    icon:setPosition(size.width/2, size.height/2)
    grid:addChild(icon)
    -- star
    for i = 1, cfg_equip[id].star do
        local star = fs.Image:create("public/public_item_lv.png")
        star:setPosition(19, 8+i*12)
        grid:addChild(star)
    end
    -- job
    if cfg_equip[id].job then
        local job = ImageHelper.createJobIcon(cfg_equip[id].job[1])
        job:setPosition(size.width-18, size.height-18)
        grid:addChild(job)
    end
    -- num
    if num then
        local LabelHelper = require "app.tools.labelHelper"
        local l = LabelHelper.createOutlineFont(ICON_NUM_FONT_SIZE, GApi.convertItemNum(num))
        l:setAnchorPoint(1, 0)
        l:setPosition(size.width - 18, 11)
        grid:addChild(l)
    end

    return grid
end

function ImageHelper.createBorder(id, num)
    local grid = fs.Image:create("public/public_item_box.png")
    local size = grid:getContentSize()
    grid:setCascadeOpacityEnabled(true)

    local quality = ImageHelper.createEquipQualityBgForBorder(id)
    quality:setPosition(size.width / 2, size.height / 2)
    grid:addChild(quality)

    local icon = ImageHelper.createBorderIcon1(id)
    icon:setPosition(size.width / 2, size.height / 2)
    grid:addChild(icon)

    if num then
        local LabelHelper = require "app.tools.labelHelper"
        local l = LabelHelper.createOutlineFont(ICON_NUM_FONT_SIZE, GApi.convertItemNum(num))
        l:setAnchorPoint(1, 0)
        l:setPosition(size.width - 18, 11)
        grid:addChild(l)
    end

    return grid
end

-- 创建奖励 icon（物品、装备）
function ImageHelper.createRewardIcon(reward)
    local icon = nil
    if reward.type == 1 then
        icon = ImageHelper.createItem(reward.id, reward.num)
    else
        icon = ImageHelper.createEquip(reward.id, reward.num)
    end
    return icon
end

function ImageHelper.getItemNumFontSize()
    return ICON_NUM_FONT_SIZE
end

function ImageHelper.createFightMap(map_id)
    local name1 = string.format("%s%smap_%02d_a.png", BASE_DIR, MAP_DIR, map_id)
    local name2 = string.format("%s%smap_%02d_b.png", BASE_DIR, MAP_DIR, map_id)
    local bg = cc.Sprite:createWithSpriteFrameName(name1)
    local fg = cc.Sprite:createWithSpriteFrameName(name2)
    return bg, fg
end

function ImageHelper.getLoadListForFight(params)
    local map_id = params.map_id 
    local hero_list = params.hero_list 
    local buffs = params.buffs
    local skills = params.skills
    
    local cfghero = require "app.config.hero"
    local cfgskill = require "app.config.skill"
    local cfgbuff = require "app.config.buff"
    local cfgfx = require "app.config.fx"
    local cfgequip = require "app.config.equip"
    local herosdata = require "app.data.heros"
    local loadlist = {}
    -- 所有特效名字
    local fxNames = {}
    -- 地图资源, 每张战斗场景可能由map_[map_id]_a.png, map_[map_id]_b.png组成
    if map_id then
        for _, s in ipairs({"a", "b"}) do
            local name = string.format("%s%smap_%02d_%s.png", BASE_DIR, MAP_DIR, map_id, s)
            local path = cc.FileUtils:getInstance():fullPathForFilename(name)
            if cc.FileUtils:getInstance():isFileExist(path) then
                loadlist[#loadlist+1] = { texture = name, frame = name }
            end
        end
    end
    -- 单位资源
    for _, hinfo in ipairs(hero_list) do
        if hinfo.hid then
            local t_hero = herosdata.find(hinfo.hid)
            if t_hero then
                hinfo.id = t_hero.id
                hinfo.skin = hinfo.skin or GApi.getHeroSkin(hinfo.hid)
            end
        end
        local unit_res_id = cfghero[hinfo.id].heroBody
        if hinfo.skin and cfgequip[hinfo.skin] then
            unit_res_id = cfgequip[hinfo.skin].heroBody
        end
        local cha_id = string.format("%04d", unit_res_id)
        loadlist[#loadlist+1] = {
            texture = BASE_DIR .. "spine_cha_" .. cha_id .. ".png",
            plist = BASE_DIR .. "spine_cha_" .. cha_id .. ".plist",
        }
    end
    -- skills
    for _, s in ipairs(skills) do
        local t_skill = require("app.fight.helper.skill").getSkill(s)
        if t_skill then
            for _, f in ipairs({"fxSelf","fxMain1","fxMain2","fxHurt1","fxHurt2"}) do
                local fxes = {}
                if t_skill[f] then
                    fxes = t_skill[f]
                end
                ImageHelper.addFxName(fxNames, fxes)
            end
        end
    end
    -- 图片名字
    local pngNames = ImageHelper.fx2pngNames(fxNames)
    pngNames["common"] = true
    -- 根据所有特效名字来决定加载的png和plist
    local tlist = ImageHelper.getLoadListFromPngNames(pngNames)
    loadlist = GApi.arrayMerge(loadlist, tlist)
    -- buffs
    local buff_loadlist = ImageHelper.getBuffImgList(buffs)
    loadlist = GApi.arrayMerge(loadlist, buff_loadlist)
    return loadlist
end

function ImageHelper.getLoadListForFight2(params)
    local map_id = params.map_id 
    local hero_list = params.hero_list 
    local buffs = params.buffs
    local skills = params.skills
    local hook = params.hook
    
    local cfg_hero = require "app.config.hero"
    local cfg_skill = require "app.config.skill"
    local cfg_fx = require "app.config.fx"
    local loadlist = {}
    -- 所有特效名字
    local fx_names = {}
    -- 地图资源, 每张战斗场景可能由map_[map_id]_a.png, map_[map_id]_b.png组成
    if map_id then
        for _, s in ipairs({"a", "b"}) do
            local name = string.format("%s%smap_%02d_%s.png", BASE_DIR, MAP_DIR, map_id, s)
            local path = cc.FileUtils:getInstance():fullPathForFilename(name)
            if cc.FileUtils:getInstance():isFileExist(path) then
                loadlist[#loadlist+1] = { texture = name, frame = name }
            end
        end
    end
    -- 单位资源
    for _, id in ipairs(hero_list) do
        local unit_res_id = cfg_hero[id].heroBody
        local cha_id = string.format("%04d", unit_res_id)
        loadlist[#loadlist+1] = {
            texture = BASE_DIR .. "spine_cha_" .. cha_id,
            plist = BASE_DIR .. "spine_cha_" .. cha_id ,
        }
    end
    -- config.fx中id以2、3开头的，都要加载，2开头的的是buff，3开头的是特殊特效
    if not hook then
        for id, cfg in pairs(cfg_fx) do
            local pre = string.sub(id, 1, 1)
            if pre == "2" or pre == "3" then
                fx_names[cfg.name] = true
            end
        end
    end
    -- 英雄普攻及技能
    local sk_array 
    if hook then
        sk_array = {"atkId"}
    else
        sk_array = {"atkId","actSkillId","pasSkill1Id","pasSkill2Id","pasSkill3Id"}
    end
    for _, id in pairs(hero_list) do
        for _, s in ipairs(sk_array) do
            local sk = cfg_hero[id][s]
            if sk then
                for _, f in ipairs({"fxSelf","fxMain1","fxMain2","fxHurt1","fxHurt2"}) do
                    local fxes = cfg_skill[sk][f]
                    ImageHelper.addFxName(fx_names, fxes)
                end
            end
        end
        -- 关联技能
        if cfg_hero[id].refSkills then
            local skill_arr = cfg_hero[id].refSkills
            for ii=1, #skill_arr do
                for _, f in ipairs({"fxSelf","fxMain1","fxMain2","fxHurt1","fxHurt2"}) do
                    local fxes = cfg_skill[skill_arr[ii]][f]
                    ImageHelper.addFxName(fx_names, fxes)
                end
            end
        end
        -- 觉醒英雄所有觉醒技能特效
        if cfg_hero[id].disillusSkill then
            local cfgdisillusSkill = cfg_hero[id].disillusSkill
            for ii =1,#cfgdisillusSkill do
                local cfgdisi = cfgdisillusSkill[ii].disi
                for jj=1,#cfgdisi do
                    local sk = cfgdisi[jj]
                    local sks = {}
                    sks[1] = sk
                    -- 转变技能后的特效, 有点累赘
                    if sk and cfg_skill[sk] and cfg_skill[sk].effect and cfg_skill[sk].effect[1].type == "changeCombat" then
                        sks[2] = cfg_skill[sk].effect[1].num
                    end
                    for ii=1,#sks do
                        sk = sks[ii]
                        if sk then
                            for _, f in ipairs({"fxSelf","fxMain1","fxMain2","fxHurt1","fxHurt2"}) do
                                local fxes = cfg_skill[sk][f]
                                ImageHelper.addFxName(fx_names, fxes)
                            end
                        end
                    end
                end
            end
        end
    end
    -- 图片名字
    local png_names = clone(fx_names)
    png_names["common"] = true
    -- 根据所有特效名字来决定加载的png和plist
    local tlist = ImageHelper.getLoadListFromPngNames(png_names)
    loadlist = GApi.arrayMerge(loadlist, tlist)

    return loadlist
end

function ImageHelper.getLoadListForPet(pets)
    local cfgskill = require "app.config.skill"
    local cfgfx = require "app.config.fx"
    local loadlist = {}
    if not pets or #pets <= 0 then return loadlist end
    local cfgpet = require "app.config.pet"
    local petData = require "app.data.pet"
    local pngNames = {}
    local uiNames = {}
    uiNames[#uiNames+1] = "spine_ui_pet_1"
    uiNames[#uiNames+1] = "spine_ui_pet_2"
    for ii=1,#pets do
        local petid = pets[ii].id
        local petInfo = petData.getData(petid)
        -- body
        local petName = cfgpet[petid].petBody
        petName = string.sub(petName, 5, -2)
        --if petName == "eagle" then
        --    petName = "griffin"
        --elseif petName == "ice" then
        --    petName = "icesoul"
        --end
        uiNames[#uiNames+1] = string.format("spine_ui_%s%s", petName, pets[ii].star+1)
        -- skill
        local skills = {}
        local actSkillId = cfgpet[petid].actSkillId + pets[ii].lv - 1
        skills[#skills+1] = actSkillId
        -- 所有特效名字
        local fxNames = {}
        for _, sk in ipairs(skills) do
            if sk then
                for _, f in ipairs({"fxSelf","fxMain1","fxMain2","fxHurt1","fxHurt2"}) do
                    local t_skill = require("app.fight.helper.skill").getSkill(sk)
                    local fxes = t_skill[f]
                    if fxes then
                        for _, fx in ipairs(fxes) do
                            fxNames[#fxNames+1] = cfgfx[fx].name
                        end
                    end
                end
            end
        end
        for ii=1, #fxNames do
            pngNames[string.format("%s", fxNames[ii])] = true
        end
    end
    local tlist = ImageHelper.getLoadListFromPngNames(pngNames)
    loadlist = GApi.arrayMerge(loadlist, tlist)
    for jj=1,#uiNames do
        local name = uiNames[jj]
        local texture = BASE_DIR .. name .. ".png"
        local plist = BASE_DIR  .. name .. ".plist"
        local fullpath = cc.FileUtils:getInstance():fullPathForFilename(texture)
        if cc.FileUtils:getInstance():isFileExist(fullpath) then
            loadlist[#loadlist+1] = { texture = texture, plist = plist }
        end
    end
    return loadlist
end

function ImageHelper.getLoadListForSkin(skins)
    local cfgequip = require "app.config.equip"
    local cfgfx = require "app.config.fx"
    -- 单位资源
    local loadlist = {}
    -- 所有特效名字
    local fxNames = {}
    for ii=1, #skins do
        local unit_res_id = cfgequip[skins[ii]].heroBody
        local cha_id = string.format("%04d", unit_res_id)
        loadlist[#loadlist+1] = {
            texture = BASE_DIR .. "spine_cha_" .. cha_id .. ".png",
            plist = BASE_DIR .. "spine_cha_" .. cha_id .. ".plist",
        }
        local cfg = cfgequip[skins[ii]]
        for _, f in ipairs({"fxSelf","fxMain1","fxMain2","fxHurt1","fxHurt2"}) do
            local fxes = cfg[f]
            ImageHelper.addFxName(fxNames, fxes)
        end
    end
    local pngNames = ImageHelper.fx2pngNames(fxNames)
    --for ii=1, #fxNames do
    --    pngNames[string.format("%s", fxNames[ii])] = true
    --end
    local tlist = ImageHelper.getLoadListFromPngNames(pngNames)
    loadlist = GApi.arrayMerge(loadlist, tlist)
    return loadlist
end

function ImageHelper.addFxName(fxNames, fxes)
    local cfgfx = require "app.config.fx"
    if fxes then
        for _, fx in ipairs(fxes) do
            fxNames[cfgfx[fx].name] = true
            if cfgfx[fx].resName then
                fxNames[cfgfx[fx].resName] = true
            end
        end
    end
end

function ImageHelper.fx2pngNames(fxNames)
    local pngNames = GApi.tableCp(fxNames)
    for fxName, _ in pairs(fxNames) do
        if fxName:endwith("_start") then
            pngNames[fxName:sub(1, -7)] = true
        elseif fxName:endwith("_loop") then
            pngNames[fxName:sub(1, -6)] = true
        elseif fxName:endwith("_end") then
            pngNames[fxName:sub(1, -5)] = true
        end
    end
    return pngNames
end

function ImageHelper.getLoadListFromPngNames(pngNames)
    local loadlist = {}
    -- 根据所有特效名字来决定加载的png和plist
    for name, _ in pairs(pngNames) do
        local i = 1
        while true do
            local texture = BASE_DIR .. "spine_fight_" .. name .. "_" .. i .. ".png"
            local plist = BASE_DIR .. "spine_fight_" .. name .. "_" .. i .. ".plist"
            local fullpath = cc.FileUtils:getInstance():fullPathForFilename(texture)
            if cc.FileUtils:getInstance():isFileExist(fullpath) then
                loadlist[#loadlist+1] = { texture = texture, plist = plist }
                i = i + 1
            else 
                break
            end
        end
    end
    return loadlist
end

function ImageHelper.getBuffImgList(buffs)
    local loadlist = {}
    if not buffs then return loadlist end
    local cfgbuff = require "app.config.buff"
    local bhelper = require "app.fight.helper.buff"
    local fxNames = {}
    local function addBuffFxName(buffId)
        if cfgbuff[buffId] and cfgbuff[buffId].fx then
            local fxes = cfgbuff[buffId].fx
            ImageHelper.addFxName(fxNames, fxes)
        end
        if cfgbuff[buffId] and cfgbuff[buffId].fxOn then
            local fxes = cfgbuff[buffId].fxOn
            ImageHelper.addFxName(fxNames, fxes)
        end
        if cfgbuff[buffId] and cfgbuff[buffId].fxOff then
            local fxes = cfgbuff[buffId].fxOff
            ImageHelper.addFxName(fxNames, fxes)
        end
    end
    for _, buffId in ipairs(buffs) do
        addBuffFxName(buffId)
        -- 印记类特殊处理
        if bhelper.isImpressId(buffId) then
            local bname = bhelper.name(buffId)
            if bname then
                bname = bname .. "B"
                local b_id = bhelper.id(bname)
                if b_id then
                    addBuffFxName(b_id)
                end
            end
        end
        -- 复活buff，特效
        if buffId == 15 then
            ImageHelper.addFxName(fxNames, {2030,2033})
        end
    end
    local pngNames = ImageHelper.fx2pngNames(fxNames)
    local loadlist = ImageHelper.getLoadListFromPngNames(pngNames)
    return loadlist
end

-- 头像框小图标
function ImageHelper.createBorderIcon1(id)
    return ImageHelper.createEquipIcon(id)
end

-- 头像框大图标
function ImageHelper.createBorderIcon2(id)
    return fs.Image:create(EQUIP_DIR .. cfg_equip[id].heroCard .. ".png")
end

return ImageHelper
