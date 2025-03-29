local strings = require("cc.strings")
local monitor = peripheral.find("monitor")

local questionLinesCount = 1

function drawQuestion(question)
    local width, height = term.getSize()
    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.white)
    
    local questionLines = strings.wrap(question, width - 2, 3)
    -- side effect
    questionLinesCount = #questionLines
    
    paintutils.drawFilledBox(1, 1, width, #questionLines)
    
    for i = 1, #questionLines do
        term.setCursorPos(2, i)
        term.write(questionLines[i])
    end
end

function drawVotes(yesVotes, noVotes, expectedVoters)
    local width, height = term.getSize()

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.gray)
    
    term.setCursorPos(2, questionLinesCount + 2)
    term.write("YAY")
            
    term.setCursorPos(2, questionLinesCount + 3)
    term.write("NAY")
    
    term.setCursorPos(2, questionLinesCount + 4)
    term.write("Did not vote")
    
    local yesCount = string.format("%d", #yesVotes)
    term.setTextColor(colors.green)
    term.setCursorPos(width - #yesCount, questionLinesCount + 2)
    term.write(yesCount)

    local noCount = string.format("%d", #noVotes)
    term.setTextColor(colors.red)
    term.setCursorPos(width - #noCount, questionLinesCount + 3)
    term.write(noCount)

    local notVotedCount = string.format("%d", expectedVoters - #yesVotes - #noVotes)
    term.setTextColor(colors.gray)
    term.setCursorPos(width - #notVotedCount, questionLinesCount + 4)
    term.write(notVotedCount)
end

function drawVoteDistribution(yesVotes, noVotes, expectedVoters)
    local width, height = term.getSize()

    local lineWidth = width - 3
            
    local yesPercent = math.min(#yesVotes / expectedVoters, 1)
    local noPercent = math.min(#noVotes / expectedVoters, 1)
    local notVotedPercent = math.max(1 - yesPercent - noPercent, 0)
    
    local yesWidth = math.floor((yesPercent * lineWidth) + 0.5)    
    local noWidth = math.floor((noPercent * lineWidth) + 0.5)
    local notVotedWidth = math.floor((notVotedPercent * lineWidth) + 0.5)
    
    local linePos = height - 1
    local yesEnd = 2 + yesWidth
    
    term.setBackgroundColor(colors.green)
    term.setTextColor(colors.white)
    paintutils.drawLine(2, linePos, yesEnd, linePos)
    
    if (yesWidth >= 5) then
        local yesPercentFormatted = string.format("%d%%", yesPercent * 100)
        term.setCursorPos(2 + math.floor((yesWidth - #yesPercentFormatted) / 2 + 0.5), linePos)
        term.write(yesPercentFormatted)
    end
    
    local noEnd = yesEnd + noWidth
    
    term.setBackgroundColor(colors.red)
    term.setTextColor(colors.white)
    paintutils.drawLine(yesEnd, linePos, noEnd, linePos)
    
    if (noWidth >= 5) then
        local noPercentFormatted = string.format("%d%%", noPercent * 100)
        term.setCursorPos(yesEnd + math.floor((noWidth - #noPercentFormatted) / 2 + 0.5), linePos)
        term.write(noPercentFormatted)
    end

    local notVotedEnd = noEnd + notVotedWidth
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.black)
    paintutils.drawLine(noEnd, linePos, notVotedEnd, linePos)

    if (notVotedWidth >= 5) then
        local notVotedPercentFormatted = string.format("%d%%", notVotedPercent * 100)
        term.setCursorPos(noEnd + math.floor((notVotedWidth - #notVotedPercentFormatted) / 2 + 0.5), linePos)
        term.write(notVotedPercentFormatted)
    end
end

function updateVoteDisplayMotionPending(voterCount)
    monitor.setTextScale(2)
    term.redirect(monitor)
    term.setBackgroundColor(colors.blue)
    term.clear()

    local width, height = term.getSize()

    local pending = "Please stand by until the next vote."
    local votersText = string.format("Registered voters: %d", voterCount)

    local pendingLines = strings.wrap(pending, width - 2, 3)
    local votersLines = strings.wrap(votersText, width - 2, 3)

    term.setTextColor(colors.white)

    for i = 1, #pendingLines do
        term.setCursorPos((width / 2) - (#pendingLines[i] / 2) + 1, (height / 2) - 1 - #pendingLines + i)
        term.write(pendingLines[i])
    end

    for i = 1, #votersLines do
        term.setCursorPos((width / 2) - (#votersLines[i] / 2) + 1, (height / 2) + i)
        term.write(votersLines[i])
    end

    term.redirect(term.native())
end

function updateVoteDisplay(question, yesVotes, noVotes, expectedVoters)
    monitor.setTextScale(2)
    term.redirect(monitor)
    term.setBackgroundColor(colors.black)
    term.clear()
    
    drawQuestion(question)
    drawVotes(yesVotes, noVotes, expectedVoters)
    drawVoteDistribution(yesVotes, noVotes, expectedVoters)
    term.redirect(term.native())
end

function updateVoteDisplayConcludeAccept(question, yesVotes, noVotes, expectedVoters)
    monitor.setTextScale(2)
    term.redirect(monitor)
    term.setBackgroundColor(colors.black)
    term.clear()

    local width, height = term.getSize()

    drawQuestion(question)
    drawVotes(yesVotes, noVotes, expectedVoters)

    local acceptMessage = "The motion has been accepted."
    local acceptMessageLines = strings.wrap(acceptMessage, width - 2, 3)

    term.setBackgroundColor(colors.green)
    term.setTextColor(colors.white)
    paintutils.drawFilledBox(1, height - #acceptMessageLines - 1, width, height)

    for i = 1, #acceptMessageLines do
        term.setCursorPos((width / 2) - (#acceptMessageLines[i] / 2) + 1, height - #acceptMessageLines + i - 1)
        term.write(acceptMessageLines[i])
    end

    term.redirect(term.native())
end

function updateVoteDisplayConcludeReject(question, yesVotes, noVotes, expectedVoters)
    monitor.setTextScale(2)
    term.redirect(monitor)
    term.setBackgroundColor(colors.black)
    term.clear()

    local width, height = term.getSize()

    drawQuestion(question)
    drawVotes(yesVotes, noVotes, expectedVoters)

    local rejectMessage = "The motion has been rejected."
    local rejectMessageLines = strings.wrap(rejectMessage, width - 2, 3)

    term.setBackgroundColor(colors.red)
    term.setTextColor(colors.white)
    paintutils.drawFilledBox(1, height - #rejectMessageLines - 1, width, height)

    for i = 1, #rejectMessageLines do
        term.setCursorPos((width / 2) - (#rejectMessageLines[i] / 2) + 1, height - #rejectMessageLines + i - 1)
        term.write(rejectMessageLines[i])
    end

    term.redirect(term.native())
end

return {
    updateVoteDisplayMotionPending = updateVoteDisplayMotionPending,
    updateVoteDisplay = updateVoteDisplay,
    updateVoteDisplayConcludeAccept = updateVoteDisplayConcludeAccept,
    updateVoteDisplayConcludeReject = updateVoteDisplayConcludeReject
}