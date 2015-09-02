--*****************************************************************************
--* File: lua/ui/dialogs/teamkill.lua
--* Author: Quark036
--* Summary: pops up to warn of a teamkill and ask if it should be reported
--*****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Popup = import('/lua/ui/controls/popups/popup.lua').Popup
local TextArea = import('/lua/ui/controls/textarea.lua').TextArea

local dialog = false
local shouldReport = false

function CreateDialog(teamkillTable)
    local killTime = teamkillTable.killTime
    WARN("Teamkill at tick" .. killTime)
    if dialog then
       return
    end
	
    local dialogContent = Group(GetFrame(0))
    dialogContent.Width:Set(600)
    dialogContent.Height:Set(200)

    dialog = Popup(GetFrame(0), dialogContent)

    local title = UIUtil.CreateText(dialogContent, "<LOC teamkill_0001>Teamkill Detected", 14, UIUtil.titleFont)
    LayoutHelpers.AtTopIn(title, dialogContent, 5)
    LayoutHelpers.AtHorizontalCenterIn(title, dialogContent)

    local infoText0 = TextArea(dialogContent, 590, 20)
    infoText0:SetText(LOC("<LOC teamkill_0002>You have been killed by friendly fire. The deliberate killing"))
    LayoutHelpers.Below(infoText0, title)
    LayoutHelpers.AtLeftIn(infoText0, dialogContent, 5)
	
    local infoText1 = TextArea(dialogContent, 590, 20)
    infoText1:SetText(LOC("<LOC teamkill_0003> of team-mates is against FAF rules. If you feel your death"))
    LayoutHelpers.Below(infoText1, infoText0)
    LayoutHelpers.AtLeftIn(infoText1, dialogContent, 5)
	
    local infoText2 = TextArea(dialogContent, 590, 20)
    infoText2:SetText(LOC("<LOC teamkill_0004>was deliberate or unsportsmanlike, check the box below."))
    LayoutHelpers.Below(infoText2, infoText1)
    LayoutHelpers.AtLeftIn(infoText2, dialogContent, 5)

    local reportToMod = UIUtil.CreateCheckbox(dialogContent, '/CHECKBOX/', "<LOC teamkill_0005>Report this to a mod", true, 11)
    LayoutHelpers.AtBottomIn(reportToMod, dialogContent, 15)
    LayoutHelpers.AtLeftIn(reportToMod, dialogContent, 5)

    local okBtn = UIUtil.CreateButtonWithDropshadow(dialogContent, '/BUTTON/medium/', "<LOC _Ok>")
    LayoutHelpers.AtHorizontalCenterIn(okBtn, dialogContent)
    LayoutHelpers.AtBottomIn(okBtn, dialogContent, 5)
    okBtn.OnClick = function(self, modifiers)
        dialog:Close()
    end

    dialog.OnClosed = function(self)
        dialog = false
        if reportToMod:IsChecked() then
            local armiesInfo = GetArmiesTable()
            local victimName = armiesInfo.armiesTable[teamkillTable.victim].nickname
            local killerName = armiesInfo.armiesTable[teamkillTable.instigator].nickname
            WARN("Was teamkilled: " .. victimName)
            WARN("At time: " .. killTime)
            WARN("Killed by: " .. killerName)
            GpgNetSend('Teamkill',  killTime,victimName,killerName)
        end
    end
end
