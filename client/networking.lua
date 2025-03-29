local modem = peripheral.find("modem", rednet.open)

function waitForVote()
    local hostId = nil
    local question = nil

    while question == nil do
        local host, message = rednet.receive("homeland_voting")

        local contents = textutils.unserializeJSON(message)

        if not contents or contents.type ~= "question" then
            goto continue
        end

        question = contents.question
        hostId = host

        ::continue::
    end

    return hostId, question
end

function sendVote(hostId, name, key, vote)
    local message = textutils.serializeJSON({
        type = "vote",
        name = name,
        key = key,
        vote = vote
    })

    rednet.send(hostId, message, "homeland_voting")
end

function processResponses(hostId, acknowledgeCallback)
    while true do
        local host, message = rednet.receive("homeland_voting")

        if host ~= hostId then
            goto continue
        end

        local contents = textutils.unserializeJSON(message)

        if not contents then
            goto continue
        end

        if contents.type == "acknowledge" then
            acknowledgeCallback(contents.vote)
        elseif contents.type == "finish" then
            print("Voting has ended.")
            return contents.result
        end

        ::continue::
    end
end

return {
    waitForVote = waitForVote,
    sendVote = sendVote,
    processResponses = processResponses
}