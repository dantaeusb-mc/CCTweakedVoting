local strings = require("cc.strings")

_QUESTION = nil
_HOVERED_BUTTON = "yes"
_ACKNOWLEDGED_VOTE = nil

local BUTTON_HEIGHT = 3
_BUTTON_YES = nil
_BUTTON_NO = nil

function drawWaiting()
    term.setBackgroundColor(colors.blue)
    term.clear()

    local width, height = term.getSize()

    local pending = "Please stand by until the next vote."
    local pendingLines = strings.wrap(pending, width - 2)

    term.setTextColor(colors.white)

    for i = 1, #pendingLines do
        term.setCursorPos((width / 2) - (#pendingLines[i] / 2) + 1, (height / 2) - 1 - #pendingLines + i)
        term.write(pendingLines[i])
    end
end

function drawQuestion(question)
    local width, height = term.getSize()
    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.white)

    local questionLines = strings.wrap(question, width - 2, 7)

    paintutils.drawFilledBox(1, 1, width, #questionLines + 1)
    term.setCursorPos(2, 1)
    term.write("Question:")

    for i = 1, #questionLines do
        term.setCursorPos(2, 1 + i)
        term.write(questionLines[i])
    end
end

function drawYesButton()
    term.setBackgroundColor(colors.green)
    term.setTextColor(colors.white)

    paintutils.drawFilledBox(_BUTTON_YES.x, _BUTTON_YES.y, _BUTTON_YES.x + _BUTTON_YES.width, _BUTTON_YES.y + _BUTTON_YES.height - 1)

    term.setCursorPos(_BUTTON_YES.x + (_BUTTON_YES.width / 2), _BUTTON_YES.y + (_BUTTON_YES.height / 2))
    term.write("YAY")

    if _HOVERED_BUTTON == "yes" then
        paintutils.drawBox(_BUTTON_YES.x - 1, _BUTTON_YES.y - 1, _BUTTON_YES.x + _BUTTON_YES.width + 1, _BUTTON_YES.y + _BUTTON_YES.height, colors.white)
    end
end

function drawNoButton()
    term.setBackgroundColor(colors.red)
    term.setTextColor(colors.white)

    paintutils.drawFilledBox(_BUTTON_NO.x, _BUTTON_NO.y, _BUTTON_NO.x + _BUTTON_NO.width, _BUTTON_NO.y + _BUTTON_NO.height - 1)

    term.setCursorPos(_BUTTON_NO.x + (_BUTTON_NO.width / 2), _BUTTON_NO.y + (_BUTTON_NO.height / 2))
    term.write("NAY")

    if _HOVERED_BUTTON == "no" then
        paintutils.drawBox(_BUTTON_NO.x - 1, _BUTTON_NO.y - 1, _BUTTON_NO.x + _BUTTON_NO.width + 1, _BUTTON_NO.y + _BUTTON_NO.height, colors.white)
    end
end

function drawCurrentState()
    local width, height = term.getSize()

    local blockWidth = width - 5
    local blockHeight = 3
    local blockX = 3
    local blockY = height - (BUTTON_HEIGHT + 1) * 2 - blockHeight - 1

    if _ACKNOWLEDGED_VOTE == "yes" then
        local message = "You voted YAY"

        term.setBackgroundColor(colors.green)
        term.setTextColor(colors.white)
        paintutils.drawFilledBox(blockX, blockY, blockX + blockWidth, blockY + blockHeight - 1)
        term.setCursorPos(blockX + (blockWidth / 2) - (#message / 2), blockY + 1)
        term.write(message)
    elseif _ACKNOWLEDGED_VOTE == "no" then
        local message = "You voted NAY"

        term.setBackgroundColor(colors.red)
        term.setTextColor(colors.white)
        paintutils.drawFilledBox(blockX, blockY, blockX + blockWidth, blockY + blockHeight - 1)
        term.setCursorPos(blockX + (blockWidth / 2) - (#message / 2), blockY + 1)
        term.write(message)
    else
        local message = "Not voted yet"

        paintutils.drawFilledBox(blockX, blockY, blockX + blockWidth, blockY + blockHeight - 1)
        term.setBackgroundColor(colors.gray)
        term.setTextColor(colors.white)
        paintutils.drawFilledBox(blockX, blockY, blockX + blockWidth, blockY + blockHeight - 1)
        term.setCursorPos(blockX + (blockWidth / 2) - (#message / 2), blockY + 1)
        term.write(message)
    end
end

function initVoting(question, yesCallback, noCallback)
    _QUESTION = question
    _HOVERED_BUTTON = "yes"
    _ACKNOWLEDGED_VOTE = nil

    local width, height = term.getSize()

    _BUTTON_YES = {
        x = 2,
        y = height - (BUTTON_HEIGHT + 1) * 2 + 1,
        width = width - 3,
        height = BUTTON_HEIGHT,
        callback = yesCallback
    }

    _BUTTON_NO = {
        x = 2,
        y = height - BUTTON_HEIGHT,
        width = width - 3,
        height = BUTTON_HEIGHT,
        callback = noCallback
    }
end

function drawVoting()
    local width, height = term.getSize()
    term.setBackgroundColor(colors.gray)
    term.clear()

    drawQuestion(_QUESTION)
    drawCurrentState()

    local yesButtonX, yesButtonY, yesButtonWidth, yesButtonHeight = drawYesButton()
    local noButtonX, noButtonY, noButtonWidth, noButtonHeight = drawNoButton()
end

function processAcknowledgedVote(vote)
    if vote == "yes" then
        _ACKNOWLEDGED_VOTE = "yes"
    elseif vote == "no" then
        _ACKNOWLEDGED_VOTE = "no"
    end

    drawVoting()
end

function processClick(x, y)
    if x >= _BUTTON_YES.x and x <= _BUTTON_YES.x + _BUTTON_YES.width and y >= _BUTTON_YES.y and y <= _BUTTON_YES.y + _BUTTON_YES.height then
        _HOVERED_BUTTON = "yes"
        _BUTTON_YES.callback()
    elseif x >= _BUTTON_NO.x and x <= _BUTTON_NO.x + _BUTTON_NO.width and y >= _BUTTON_NO.y and y <= _BUTTON_NO.y + _BUTTON_NO.height then
        _HOVERED_BUTTON = "no"
        _BUTTON_NO.callback()
    end

    drawVoting()
end

function processKey(key)
    if key == keys.up then
        _HOVERED_BUTTON = "yes"
    elseif key == keys.down then
        _HOVERED_BUTTON = "no"
    elseif key == keys.enter then
        if _HOVERED_BUTTON == "yes" then
            _BUTTON_YES.callback()
        else
            _BUTTON_NO.callback()
        end
    end

    drawVoting()
end

function drawResult(result)
    local width, height = term.getSize()
    term.setBackgroundColor(colors.gray)
    term.clear()

    drawQuestion(_QUESTION)

    if result == "yes" then
        term.setBackgroundColor(colors.green)
        term.setTextColor(colors.white)
        paintutils.drawFilledBox(1, height - 3, width, 2)
        term.setCursorPos(2, height - 2)
        term.write("The vote passed!")
    elseif result == "no" then
        term.setBackgroundColor(colors.red)
        term.setTextColor(colors.white)
        paintutils.drawFilledBox(1, height - 3, width, 2)
        term.setCursorPos(2, height - 3)
        term.write("The vote failed!")
    end
end

return {
    drawWaiting = drawWaiting,
    initVoting = initVoting,
    drawVoting = drawVoting,
    processHover = processHover,
    processClick = processClick,
    processKey = processKey,
    processAcknowledgedVote = processAcknowledgedVote,
    drawResult = drawResult
}
