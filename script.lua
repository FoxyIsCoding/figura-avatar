-- Start with vanilla ON, model OFF
vanilla_model.ALL:setVisible(true)
models:setVisible(false)

local gaze = require("Gaze")

local mainGaze = gaze:newGaze()
mainGaze:newAnim(animations.model.LookHorizontal, animations.model.LookVertical)
mainGaze:newBlink(animations.model.Blink)

nameplate.ALL:setText('{"text":"${name} :blahaj:","color":"#89c3e7"}')

-- Toggle state tracker (true = vanilla ON/model OFF, false = model ON/vanilla OFF)
local vanillaMode = true
local capeVisible = true
local elytraVisible = true
local autoSwitchTicks = 0
local autoSwitched = false

-- Coin flip animation state
local coinFlipActive = false
local coinFlipPlayed = false
local coinFlipTicks = 0

local function setVisibleSafe(part, flag)
    if part and part.setVisible then part:setVisible(flag) end
end

local function applyVisibility()
    if not vanilla_model then return end

    setVisibleSafe(vanilla_model.PLAYER, vanillaMode)

    -- Cape (both aliases)
    setVisibleSafe(vanilla_model.CAPE, vanillaMode and capeVisible)
    setVisibleSafe(vanilla_model.CAPE_MODEL, vanillaMode and capeVisible)

    -- Elytra (group + wings)
    setVisibleSafe(vanilla_model.ELYTRA, vanillaMode and elytraVisible)
    setVisibleSafe(vanilla_model.LEFT_ELYTRA, vanillaMode and elytraVisible)
    setVisibleSafe(vanilla_model.RIGHT_ELYTRA, vanillaMode and elytraVisible)

    -- Armor overall (no per-slot controls)
    setVisibleSafe(vanilla_model.ARMOR, vanillaMode)
    setVisibleSafe(vanilla_model.HELMET, false)
    setVisibleSafe(vanilla_model.CHESTPLATE, vanillaMode)
    setVisibleSafe(vanilla_model.LEGGINGS, vanillaMode)
    setVisibleSafe(vanilla_model.BOOTS, vanillaMode)

    models:setVisible(not vanillaMode)
end

-- Main menu page (iron armor theme)
local mainPage = action_wheel:newPage()
action_wheel:setPage(mainPage)

-- Submenu page for skins
local skinPage = action_wheel:newPage()

-- Submenu page for show/hide controls
local visibilityPage = action_wheel:newPage()

-- Submenu page for emotes
local emotePage = action_wheel:newPage()

-- Ping function for skin switching (syncs across clients)
function pings.switchSkin(state)
    vanillaMode = state
    applyVisibility()
    
    local pos = player:getPos()
    for i = 1, 50 do
        particles:newParticle("poof", 
            pos + vec(math.random(-2,2), math.random(1,3), math.random(-2,2)),
            vec(math.random(-0.5,0.5), math.random(0.2,0.8), math.random(-0.5,0.5))
        )
    end
end

-- Main menu button: Opens skin submenu (iron armor 🛡️)
local skinMenuAction = mainPage:newAction()
    :title(":mci_iron_chestplate: Skins")
    :item("iron_chestplate")
    :hoverColor(1, 0.5, 0)
    :onLeftClick(function()
        action_wheel:setPage(skinPage)
    end)

-- Main menu button: Opens visibility submenu
local visibilityMenuAction = mainPage:newAction()
    :title("Show/Hide")
    :item("lever")
    :hoverColor(0.9, 0.9, 0.2)
    :onLeftClick(function()
        action_wheel:setPage(visibilityPage)
    end)

-- Main menu button: Opens emotes submenu
local emotesMenuAction = mainPage:newAction()
    :title("Emotes...")
    :item("player_head")
    :hoverColor(0.8, 0.8, 0.5)
    :onLeftClick(function()
        action_wheel:setPage(emotePage)
    end)

-- Submenu: Vanilla Skin button (grass block 🌿)
local vanillaAction = skinPage:newAction()
    :title(":mcb_grass_block: Vanilla Skin")
    :item("grass_block")
    :hoverColor(0.2, 0.8, 0.2)
    :onLeftClick(function()
        pings.switchSkin(true)
    end)

-- Submenu: Model Skin button (:blahaj:)
local modelAction = skinPage:newAction()
    :title(":blahaj: Model Skin")
    :item("player_head")
    :hoverColor(0.5, 0.5, 1)
    :onLeftClick(function()
        pings.switchSkin(false)
    end)

-- Back button on submenu
local backAction = skinPage:newAction()
    :title("◀ Back")
    :item("arrow")
    :hoverColor(0.7, 0.7, 0.7)
    :onLeftClick(function()
        action_wheel:setPage(mainPage)
    end)

-- Visibility submenu: Cape toggle
local capeAction = visibilityPage:newAction()
    :title("Cape: shown")
    :item("red_banner")
    :hoverColor(0.2, 0.8, 0.8)
    :onLeftClick(function()
        pings.setCapeVisible(not capeVisible)
    end)

-- Visibility submenu: Elytra toggle
local elytraAction = visibilityPage:newAction()
    :title("Elytra: shown")
    :item("elytra")
    :hoverColor(0.6, 0.4, 0.9)
    :onLeftClick(function()
        pings.setElytraVisible(not elytraVisible)
    end)

-- Visibility submenu: Open armor submenu

-- Back button on visibility submenu
local visibilityBackAction = visibilityPage:newAction()
    :title("◀ Back")
    :item("arrow")
    :hoverColor(0.7, 0.7, 0.7)
    :onLeftClick(function()
        action_wheel:setPage(mainPage)
    end)





-- Emote submenu: spin emote
local spinEmoteAction = emotePage:newAction()
    :title("Spinny head :3")
    :item("compass")
    :hoverColor(0.6, 0.8, 0.6)
    :onLeftClick(function()
        pings.playEmote("Spin")
    end)

-- Emote submenu: Point emote
local pointEmoteAction = emotePage:newAction()
    :title("Point")
    :item("stick")
    :hoverColor(0.8, 0.6, 0.9)
    :onLeftClick(function()
        pings.playEmote("Point")
    end)

-- Emote submenu: No emote
local noEmoteAction = emotePage:newAction()
    :title("No")
    :item("barrier")
    :hoverColor(0.6, 0.8, 0.6)
    :onLeftClick(function()
        pings.playEmote("No")
    end)

-- Emote submenu: Coin flip toggle
local coinFlipAction = emotePage:newAction()
    :title("Coin Flip")
    :item("gold_block")
    :hoverColor(1, 0.84, 0)
    :setOnToggle(function(state)
        pings.toggleCoinFlip(state)
    end)

-- Emote submenu: Yes emote
local yesEmoteAction = emotePage:newAction()
    :title("Yes")
    :item("green_banner")
    :hoverColor(0.6, 0.8, 0.6)
    :onLeftClick(function()
        pings.playEmote("Yes")
    end)

-- Emote submenu: Clap emote
local clapEmoteAction = emotePage:newAction()
    :title("Clap")
    :item("note_block")
    :hoverColor(0.6, 0.8, 0.6)
    :onLeftClick(function()
        pings.playEmote("Clap")
    end)

-- Back button on emote submenu
local emoteBackAction = emotePage:newAction()
    :title("◀ Back")
    :item("arrow")
    :hoverColor(0.7, 0.7, 0.7)
    :onLeftClick(function()
        action_wheel:setPage(mainPage)
    end)

-- Emote submenu: Wave emote
local waveEmoteAction = emotePage:newAction()
    :title("Wave")
    :item("blue_banner")
    :hoverColor(0.6, 0.8, 0.6)
    :onLeftClick(function()
        pings.playEmote("Wave")
    end)

-- Emote submenu: Test emote
local testEmoteAction = emotePage:newAction()
    :title("Test Emote")
    :item("command_block")
    :hoverColor(0.6, 0.8, 0.6)
    :onLeftClick(function()
        pings.playEmote("Test")
    end)



function pings.setCapeVisible(state)
    capeVisible = state
    applyVisibility()
end

function pings.setElytraVisible(state)
    elytraVisible = state
    applyVisibility()
end

function pings.playEmote(emoteName)
    if animations.model[emoteName] then
        animations.model[emoteName]:play()
        if emoteName == "Wave" then
            sounds:playSound("sounds.hi", player:getPos())
        elseif emoteName == "Spin" then
            sounds:playSound("sounds.yay", player:getPos())
        elseif emoteName == "Clap" then
            sounds:playSound("sounds.wow", player:getPos())
        end
    end
end

function pings.toggleCoinFlip(state)
    coinFlipActive = state
    if coinFlipActive then
        print("Toggling CoinFlip ON")
        if animations.model.CoinFlip then
            print("Playing CoinFlip")
            animations.model.CoinFlip:play()
        else
            print("ERROR: CoinFlip not found!")
        end
        -- Hide hand items
        if vanilla_model.LEFT_ITEM then
            vanilla_model.LEFT_ITEM:setVisible(false)
        end
        if vanilla_model.RIGHT_ITEM then
            vanilla_model.RIGHT_ITEM:setVisible(false)
        end
    else
        print("Toggling CoinFlip OFF")
        if animations.model.CoinFlip then
            animations.model.CoinFlip:stop()
        end
        -- Show hand items back
        if vanilla_model.LEFT_ITEM then
            vanilla_model.LEFT_ITEM:setVisible(true)
        end
        if vanilla_model.RIGHT_ITEM then
            vanilla_model.RIGHT_ITEM:setVisible(true)
        end
    end
end

applyVisibility()

events.TICK:register(function()
    if autoSwitched then return end
    autoSwitchTicks = autoSwitchTicks + 1
    if autoSwitchTicks >= 20 then
        autoSwitched = true
        pings.switchSkin(false)
    end
    
    -- Coin flip animation loop - keep restarting until toggled off
    if coinFlipActive then
        if animations.model.CoinFlip then
            local isPlaying = animations.model.CoinFlip:isPlaying()
            print("CoinFlip is playing: " .. tostring(isPlaying))
            if not isPlaying then
                print("Restarting CoinFlip")
                animations.model.CoinFlip:play()
            end
        else
            print("ERROR: CoinFlip animation not found!")
        end
    end

end)