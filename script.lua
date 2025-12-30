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

-- Action wheel setup
local mainPage = action_wheel:newPage()
action_wheel:setPage(mainPage)

-- Ping function for toggle (syncs across clients)
function pings.toggleSkin(state)
    vanillaMode = state
    
    -- Toggle visibilities
    vanilla_model.ALL:setVisible(state)
    models:setVisible(not state)
    
    local pos = player:getPos()
    for i = 1, 50 do
        particles:newParticle("explosion", 
            pos + vec(math.random(-2,2), math.random(1,3), math.random(-2,2)),
            vec(math.random(-0.5,0.5), math.random(0.2,0.8), math.random(-0.5,0.5))
        )
    end
end

-- Toggle action
local toggleAction = mainPage:newAction()
    :title("Custom Model")  
    :toggleTitle("Vanilla Skin")
    :item("diamond_sword")
    :toggleItem("player_head")
    :hoverColor(1, 0.5, 0)
    :setOnToggle(pings.toggleSkin)
