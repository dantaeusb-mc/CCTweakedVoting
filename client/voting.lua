local voterHelper = require("voter")
local screen = require("screen")
local networking = require("networking")

local _HOST_ID = nil
local _QUESTION = nil
local _RESULT = nil

function getRegisterYesCallback(hostId, name, key)
    return function ()
        networking.sendVote(hostId, name, key, "yes")
    end
end

function getRegisterNoCallback(hostId, name, key)
    return function()
        networking.sendVote(hostId, name, key, "no")
    end
end

function handleClicks()
    while true do
        local event, button, x, y = os.pullEvent("mouse_click")

        if event == "mouse_click" then
            if button == 1 then
                screen.processClick(x, y)
            end
        end
    end
end

function handleKeys()
    while true do
        local event, key = os.pullEvent("key")

        if event == "key" then
            screen.processKey(key)
        end
    end
end

function handleRednet()
    _RESULT = networking.processResponses(_HOST_ID, screen.processAcknowledgedVote)
end

function init()
   _HOST_ID = nil
   _QUESTION = nil
   _RESULT = nil
end

function main()
    while true do
        init()
        local voter = voterHelper.readVoter()

        os.setComputerLabel(voter.name .. " voting terminal")

        screen.drawWaiting()

        _HOST_ID, _QUESTION = networking.waitForVote()

        screen.initVoting(_QUESTION, getRegisterYesCallback(_HOST_ID, voter.name, voter.key), getRegisterNoCallback(_HOST_ID, voter.name, voter.key))
        screen.drawVoting()
        parallel.waitForAny(handleClicks, handleKeys, handleRednet)

        screen.drawResult(_RESULT)
        sleep(5)
    end
end

return {
    main = main
}