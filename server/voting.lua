local votersHelper = require("voters")
local display = require("display")
local networking = require("networking")

function prepareVote()
    ::restart::
    local voters = votersHelper.readVoters()
    local voterCount = #voters

    display.updateVoteDisplayMotionPending(voterCount)

    term.clear()

    term.setCursorPos(1, 1)
    term.write(string.format("Registered voters: %d", voterCount))

    term.setCursorPos(1, 2)
    term.write("Start a new vote, enter the question: ")

    term.setCursorPos(1, 3)
    local question = read()

    term.setCursorPos(1, 4)
    term.write("Press 'e' to start the vote or 'q' to cancel")

    while true do
        local event, key = os.pullEvent("key")
        if key == keys.q then
            goto restart
        end

        if key == keys.e then
            break
        end
    end

    return voters, question
end

function vote()
    local result = ni
    local voterCount = #voters
    local yesVoters = { }
    local noVoters = { }

    display.updateVoteDisplay(question, { }, { }, voterCount)

    term.setCursorPos(1, 5)
    term.write("Vote started, waiting for votes...")

    term.setCursorPos(1, 6)
    term.write("Press 'q' to end the vote, 'y' to force win for yes,")
    term.setCursorPos(1, 7)
    term.write("'n' to force win for no")

    while true do
       local event, payload = os.pullEvent()

       if event == "vote" then
           voters = votersHelper.setVote(voters, payload.name, payload.key, payload.vote)
           yesVoters, noVoters = votersHelper.mapVoters(voters)

           display.updateVoteDisplay(question, yesVoters, noVoters, voterCount)
       end

        if event == "key" then
            if payload == keys.q then
                if #yesVoters > #noVoters then
                    result = "yes"
                else
                    result = "no"
                end

                break
            end

            if payload == keys.y then
                result = "yes"
                break
            end

            if payload == keys.n then
                result = "no"
                break
            end
        end
    end

    networking.voteEnd(result)

    if result == "yes" then
        display.updateVoteDisplayConcludeAccept(question, yesVoters, noVoters, voterCount)
    else
        display.updateVoteDisplayConcludeReject(question, yesVoters, noVoters, voterCount)
    end
end

function postVote()
    term.setCursorPos(1, 8)
    term.write("Press any key to start a new vote")
    local event, key = os.pullEvent("key")

    if key == keys.q then
        return false
    end

    return true
end

function main()
    local continue = true

    while continue do
        -- global
        voters, question = prepareVote()
        networking.init(question)
        parallel.waitForAll(vote, networking.voteStart)
        networking.free()
        continue = postVote()
    end
end

return {
    main = main
}
