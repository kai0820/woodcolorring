
local DataHelper = {}

function DataHelper.initAllData(uid, sid, data)
    -- 初始化各种数据
    local PlayerData = require "app.data.player"
    PlayerData.init(uid, sid, data.player)
    if data.final_rank then
        PlayerData.final_rank = data.final_rank
    else
        PlayerData.final_rank = nil
    end
    if data.hide_vip then
        PlayerData.hide_vip = data.hide_vip
    else
        PlayerData.hide_vip = nil
    end
    if data.chatblocks then
        PlayerData.chatblocks = data.chatblocks
    else
        PlayerData.chatblocks = 0
    end
    PlayerData.buy_hlimit = data.buy_hlimit or 0
    local BagData = require "app.data.bag"
    BagData.init(data.bag)
    local HerosData = require "app.data.heros"
    HerosData.init(data.heroes)
    local GachaData = require "app.data.gacha"
    GachaData.init(data.gacha)
    GachaData.initspacesummon(data.space_gacha)
    local SkinBook = require "app.data.skinBook"
    SkinBook.init(data.sf_ids)
    local HeroBook = require "app.data.heroBook"
    HeroBook.init(data.hero_ids)
    local RateUs = require "app.data.rateUs"
    RateUs.init(data.rate_us)
    local VideoAd = require "app.data.videoAd"
    VideoAd.init(data.video_cd)
    local TrialData = require "app.data.trial"
    TrialData.init(data.trial)
    local ChatData = require "app.data.chat"
    ChatData.deSync()
    ChatData.registEvent()
    if data.htask then
        local HeroTaskData = require "app.data.heroTask"
        HeroTaskData.init(data.htask)
    end
    local Mail = require "app.data.mail"
    Mail.init(data.mails)
    Mail.registEvent()
    local midas = require "app.data.midas"
    midas.init(data.midas_cd, data.midas_flag)
    local AchieveData = require "app.data.achieve"
    AchieveData.init(data.achieve)
    local BraveData = require "app.data.brave"
    BraveData.clear()
    if data.reddot then
        BraveData.initRedDot(data.reddot)
    end
    if data.tasks then
        local TaskData = require "app.data.task"
        TaskData.syncInit({tasks=data.tasks})
        TaskData.setCD(data.task_cd or 3600*2400)
    end
    if data.online then
        local OnlineData = require "app.data.online"
        OnlineData.sync(data.online)
    end

    -- 新手挑战活动
    if data.ract then
        local rk = require "app.data.activityRookie"
        rk.init(data.ract)
    end

    -- 特殊活动
    -- data.sact
    local thanks_giving = require "app.data.thanksGiving"
    thanks_giving.init(data.sact)
    thanks_giving.print()

    local black_friday = require "app.data.blackFriday"
    black_friday.init(data.sact)
    black_friday.print()

    -- activities
    if data.acts then
        local ActivityData = require "app.data.activity"
        ActivityData.init({status=data.acts})
        ActivityData.print()
    end
    -- limitactivities
    local ActivityLimitData = require "app.data.activityLimit"
    if data.limitacts then
        ActivityLimitData.init({status=data.limitacts})
    else
        ActivityLimitData.init({status=nil})
    end

    if data.mact then
        local MonthlyActivityData = require "app.data.monthlyActivity"
        print("****mactivity****")
        MonthlyActivityData.init({status=data.mact})
        MonthlyActivityData.print()
    end

    local HookData = require "app.data.hook"
    HookData.init(data.hook)
    local Friend = require "app.data.friend"
    if data.friends then
        Friend.init(data.friends)
    end
    Friend.registEvent()
    if data.reddot then
        Friend.initRedDot(data.reddot)
    end
    local FrdArenaData = require "app.data.frdArena"
    FrdArenaData.registEvent()
    local WorldArenaData = require "app.data.worldArena"
    if data.reddot then
        WorldArenaData.initRedDot(data.reddot)
    end
    local WorldArenaData = require "app.data.worldArena"
    WorldArenaData.resetAll()
    
    local GuildData = require "app.data.guild"
    GuildData.deInit()
    GuildData.Listen()
    GuildData.initLineupFlag(data.reddot)
    local GuildMillData = require "app.data.guildMill"
    if data.reddot then
        GuildMillData.initRedDot(data.reddot)
    end
    local Shop = require "app.data.shop"
    Shop.init(data.pay_num)
    if data.subscribed and data.subscribed >= 1 then
        Shop.setPay(33, 1)
    else
        Shop.setPay(33, 0)
    end
    Shop.subId(data.subscribed or 0)
    local MonthLoginData = require "app.data.monthLogin"
    if data.alogin then
        MonthLoginData.init(data.alogin)
    end
    -- local smith = require "ui.smith.main"
    -- smith.equipformulas.init()
    local AirIslandData = require "app.data.airIsland"
    if data.reddot then
        AirIslandData.initRedDot(data.reddot)
    end
    if data.cds then
        require("app.data.cd").initCDS(data.cds)
    end
    -- 公会科技技能, 英雄面板展示，先初始化
    require("app.data.gskill").sync(data.gskls)
    require("app.data.gskill").initCode(data.gsklcode)
    --宠物
    local PetData = require "app.data.pet"
    PetData.data  = {}
    PetData.initData()
    if data.pets then
        --做一些数据兼容处理，如果要读pet代码，必须了解
        PetData.setData(data.pets)
    end
    --单挑赛
    local SoloData = require "app.data.solo"
    if data.reddot then
        SoloData.initRedDot(data.reddot)
    end
    --空岛
    AirIslandData.setCount()
    -- 教程
    local TutorialData = require "app.data.tutorial"
    TutorialData.init(data.tutorial, data.tutorial2)
    TutorialData.print()
    --防沉迷
    if not GApi.isChannel() then
        local PreventAddictionData = require("app.data.preventAddiction")
        if data.identity then
            PreventAddictionData.init2(data.identity)
        else
            PreventAddictionData.init(0,0)
        end
    end
    --大小月卡购买信息
    local CardPayData = require("app.data.cardPay")
    CardPayData.init(data.off_card)

    --封印之地
    if data.reddot then
        local SealLandData = require "app.data.sealland"
        SealLandData:initRedDot(data.reddot)
    end

    local customerService = require "app.data.customerService"
    if customerService:isOpen() then
        customerService:clear()
        local webSocket = require("app.net.webSocket")
        webSocket:close()
        webSocket:connect(webSocket.URL,true)
    end
end

function DataHelper.purge()
    local HookData = require "app.data.hook"
    HookData.purge()
    local HeartBeat = require "app.data.heartBeat"
    HeartBeat.stop()
end

return DataHelper
