function readVoter()
    local file = fs.open("data/voter.key", "r") or error("Voter file not found")

    local contents = file.readAll()

    local name, key = string.match(contents, "([%w_]+)|([%w+=/]+)$")

    local voter = {
        name = name,
        key = key
    }

    file.close()

    return voter
end

return {
    readVoter = readVoter
}