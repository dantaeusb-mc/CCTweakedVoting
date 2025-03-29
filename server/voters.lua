function readVoters()
    local voters = {}
    local file = fs.open("data/voters.key", "r") or error("Voters file not found")

    while true do
        local line = file.readLine()

        if line == nil then
            break
        end

        if string.sub(line, 1, 1) == "#" then
            -- Skip comments
            goto continue
        end

        local name, key = string.match(line, "([%w_]+)|([%w+=/]+)$")

        local voter = {
            name = name,
            key = key,
            vote = nil
        }

        table.insert(voters, voter)
        ::continue::
    end

    file.close()

    return voters
end

function verifyVote(vote)
    if vote == nil or vote.type ~= "vote" or type(vote.name) ~= "string" or type(vote.key) ~= "string" or type(vote.vote) ~= "string" then
        return false
    end

    for i, voter in ipairs(voters) do
        if voter["name"] == vote.name then
            if voter["key"] == vote.key then
                return vote.vote == "yes" or vote.vote == "no"
            else
                return false
            end
        end
    end

    return false
end

function setVote(voters, voterName, voterKey, vote)
    for i, voter in ipairs(voters) do
        if voter["name"] == voterName then
            if voter["key"] ~= voterKey then
                error("Invalid voter key")
            end

            if (vote ~= "yes" and vote ~= "no") then
                error("Invalid vote")
            end

            print("Setting vote for " .. voterName .. " to " .. vote)

            voter["vote"] = vote
            break
        end
    end

    return voters
end

function mapVoters(voters)
    local yesVoters = {}
    local noVoters = {}

    for i, voter in ipairs(voters) do
        if voter["vote"] == "yes" then
            table.insert(yesVoters, voter["name"])
        elseif voter["vote"] == "no" then
            table.insert(noVoters, voter["name"])
        end
    end

    return yesVoters, noVoters
end

return {
    readVoters = readVoters,
    verifyVote = verifyVote,
    mapVoters = mapVoters,
    setVote = setVote
}