local votersHelper = require("voters")

local modem = peripheral.find("modem", rednet.open)
local _QUESTION = ""
local votingInProgress = false

function init(question)
    rednet.host("homeland_voting", "mayor")
    _QUESTION = question
end

function broadcastActiveVote()
    local question = _QUESTION
    local votingPacket = { type = "question", question = question }

    while votingInProgress do
        rednet.broadcast(textutils.serializeJSON(votingPacket), "homeland_voting")
        sleep(3)
    end
end

function catchVote()
    while votingInProgress do
        local id, message = rednet.receive("homeland_voting")
        local contents = textutils.unserializeJSON(message)

        local validVote = votersHelper.verifyVote(contents)

        if not validVote then
            print("Invalid vote received")
            goto continue
        end

        os.queueEvent("vote", contents)

        local ackPacket = { type = "acknowledge", name = contents.name, vote = contents.vote }
        rednet.send(id, textutils.serializeJSON(ackPacket), "homeland_voting")
        ::continue::
    end
end

function voteStart()
    votingInProgress = true

    parallel.waitForAny(broadcastActiveVote, catchVote)
end

function voteEnd(result)
    votingInProgress = false

    local endPacket = { type = "finish", result = result }

    rednet.broadcast(textutils.serializeJSON(endPacket), "homeland_voting")
end

function free()
    rednet.unhost("homeland_voting")
end

return {
    init = init,
    voteStart = voteStart,
    voteEnd = voteEnd,
    free = free
}