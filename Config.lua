
local function deleteNote(npcId, noteId)
    local creatureData = MobIntelDB.creature[npcId]
    if not creatureData then return end
    for i, note in ipairs(creatureData.notes) do
        if note.id == noteId then
            table.remove(creatureData.notes, i)
            if #creatureData.notes == 0 then
                MobIntelDB.creature[npcId] = nil
            end
            return
        end
    end
end

-- GUID map IDs are old-style continent/instance IDs, not C_Map UI map IDs
local GUID_MAP_NAMES = {
    ["0"]   = "Eastern Kingdoms",
    ["1"]   = "Kalimdor",
    ["530"] = "Outland",
    -- Classic instances
    ["33"]  = "Shadowfang Keep",
    ["34"]  = "Stormwind Stockade",
    ["36"]  = "Deadmines",
    ["43"]  = "Wailing Caverns",
    ["47"]  = "Razorfen Kraul",
    ["48"]  = "Blackfathom Deeps",
    ["70"]  = "Uldaman",
    ["90"]  = "Gnomeregan",
    ["109"] = "Sunken Temple",
    ["129"] = "Razorfen Downs",
    ["189"] = "Scarlet Monastery",
    ["209"] = "Zul'Farrak",
    ["229"] = "Blackrock Spire",
    ["230"] = "Blackrock Depths",
    ["249"] = "Onyxia's Lair",
    ["289"] = "Scholomance",
    ["309"] = "Zul'Gurub",
    ["329"] = "Stratholme",
    ["349"] = "Maraudon",
    ["389"] = "Ragefire Chasm",
    ["409"] = "Molten Core",
    ["429"] = "Dire Maul",
    ["469"] = "Blackwing Lair",
    ["489"] = "Warsong Gulch",
    ["509"] = "Ruins of Ahn'Qiraj",
    ["529"] = "Arathi Basin",
    ["531"] = "Temple of Ahn'Qiraj",
    ["533"] = "Naxxramas",
    -- TBC instances
    ["532"] = "Karazhan",
    ["534"] = "Hyjal Summit",
    ["540"] = "Hellfire Ramparts",
    ["542"] = "Blood Furnace",
    ["543"] = "Hellfire Citadel",
    ["544"] = "Steamvault",
    ["545"] = "The Underbog",
    ["546"] = "The Slave Pens",
    ["547"] = "Escape from Durnholde",
    ["552"] = "The Arcatraz",
    ["553"] = "The Botanica",
    ["554"] = "The Mechanar",
    ["555"] = "Shadow Labyrinth",
    ["556"] = "Sethekk Halls",
    ["557"] = "Mana-Tombs",
    ["558"] = "Auchenai Crypts",
    ["560"] = "The Underbog",
    ["562"] = "Blade's Edge Arena",
    ["564"] = "Black Temple",
    ["565"] = "Gruul's Lair",
    ["568"] = "Zul'Aman",
    ["572"] = "Ruins of Lordaeron",
    ["580"] = "Sunwell Plateau",
}

local function getAreaName(mapId)
    local key = tostring(mapId)
    if GUID_MAP_NAMES[key] then return GUID_MAP_NAMES[key] end
    return "Area " .. key
end

-- Edit dialog
local editDialog = CreateFrame("Frame", "MobIntelEditNoteDialog", UIParent, "BasicFrameTemplateWithInset")
editDialog:SetSize(500, 230)
editDialog:SetPoint("CENTER")
editDialog:SetMovable(true)
editDialog:EnableMouse(true)
editDialog:RegisterForDrag("LeftButton")
editDialog:SetScript("OnDragStart", editDialog.StartMoving)
editDialog:SetScript("OnDragStop", editDialog.StopMovingOrSizing)
editDialog:SetFrameStrata("DIALOG")
editDialog:Hide()

editDialog.title = editDialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
editDialog.title:SetPoint("LEFT", editDialog.TitleBg, "LEFT", 5, 0)
editDialog.title:SetText("Edit Note")

local editScrollFrame = CreateFrame("ScrollFrame", "MobIntelEditScrollFrame", editDialog, "UIPanelScrollFrameTemplate")
editScrollFrame:SetPoint("TOPLEFT", editDialog, "TOPLEFT", 12, -30)
editScrollFrame:SetPoint("BOTTOMRIGHT", editDialog, "BOTTOMRIGHT", -30, 45)

local editBox = CreateFrame("EditBox", nil, editScrollFrame)
editBox:SetMultiLine(true)
editBox:SetWidth(440)
editBox:SetHeight(300)
editBox:SetAutoFocus(false)
editBox:SetFontObject("GameFontNormal")
editBox:SetMaxLetters(0)
editScrollFrame:SetScrollChild(editBox)

local saveBtn = CreateFrame("Button", nil, editDialog, "GameMenuButtonTemplate")
saveBtn:SetSize(80, 25)
saveBtn:SetPoint("BOTTOMRIGHT", editDialog, "BOTTOMRIGHT", -10, 10)
saveBtn:SetText("Save")

local cancelBtn = CreateFrame("Button", nil, editDialog, "GameMenuButtonTemplate")
cancelBtn:SetSize(80, 25)
cancelBtn:SetPoint("RIGHT", saveBtn, "LEFT", -5, 0)
cancelBtn:SetText("Cancel")

editDialog.onSave = nil

saveBtn:SetScript("OnClick", function()
    if editDialog.onSave then
        editDialog.onSave(editBox:GetText())
    end
    editDialog:Hide()
end)

cancelBtn:SetScript("OnClick", function()
    editDialog:Hide()
end)

-- Preview panel (sits below the scroll frame, hidden by default)
local previewFrame = CreateFrame("Frame", nil, editDialog, "InsetFrameTemplate")
previewFrame:SetPoint("TOPLEFT", editScrollFrame, "TOPLEFT")
previewFrame:SetPoint("BOTTOMRIGHT", editScrollFrame, "BOTTOMRIGHT")
previewFrame:Hide()

local previewLabel = previewFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
previewLabel:SetPoint("TOPLEFT", previewFrame, "TOPLEFT", 6, -6)
previewLabel:SetPoint("BOTTOMRIGHT", previewFrame, "BOTTOMRIGHT", -6, 6)
previewLabel:SetJustifyH("LEFT")
previewLabel:SetJustifyV("TOP")

local previewBtn = CreateFrame("Button", nil, editDialog, "UIPanelButtonTemplate")
previewBtn:SetSize(80, 25)
previewBtn:SetPoint("RIGHT", cancelBtn, "LEFT", -5, 0)
previewBtn:SetText("Preview")
previewBtn:SetScript("OnClick", function()
    if previewFrame:IsShown() then
        previewFrame:Hide()
        editScrollFrame:Show()
        previewBtn:SetText("Preview")
    else
        previewLabel:SetText(MobIntel.utils.formatNote(editBox:GetText(), ""))
        previewFrame:Show()
        editScrollFrame:Hide()
        previewBtn:SetText("Edit")
    end
end)

function editDialog:open(currentText, onSave)
    self.onSave = onSave
    editBox:SetText(currentText or "")
    previewFrame:Hide()
    editScrollFrame:Show()
    previewBtn:SetText("Preview")
    self:Show()
    editBox:SetFocus()
end

-- Spell / icon picker
local spellPicker = CreateFrame("Frame", "MobIntelSpellPicker", UIParent, "BasicFrameTemplateWithInset")
spellPicker:SetSize(320, 460)
spellPicker:SetMovable(true)
spellPicker:EnableMouse(true)
spellPicker:RegisterForDrag("LeftButton")
spellPicker:SetScript("OnDragStart", spellPicker.StartMoving)
spellPicker:SetScript("OnDragStop", spellPicker.StopMovingOrSizing)
spellPicker:SetFrameStrata("DIALOG")
spellPicker:Hide()

spellPicker.title = spellPicker:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
spellPicker.title:SetPoint("LEFT", spellPicker.TitleBg, "LEFT", 5, 0)
spellPicker.title:SetText("Select Icon")

local pickerSearch = CreateFrame("EditBox", "MobIntelSpellPickerSearch", spellPicker, "SearchBoxTemplate")
pickerSearch:SetPoint("TOPLEFT", spellPicker, "TOPLEFT", 8, -32)
pickerSearch:SetPoint("TOPRIGHT", spellPicker, "TOPRIGHT", -28, -32)
pickerSearch:SetHeight(20)
pickerSearch:SetAutoFocus(false)

local pickerScroll = CreateFrame("ScrollFrame", "MobIntelSpellPickerScroll", spellPicker, "UIPanelScrollFrameTemplate")
pickerScroll:SetPoint("TOPLEFT", spellPicker, "TOPLEFT", 8, -58)
pickerScroll:SetPoint("BOTTOMRIGHT", spellPicker, "BOTTOMRIGHT", -28, 8)

local pickerContent = CreateFrame("Frame", nil, pickerScroll)
pickerContent:SetWidth(270)
pickerContent:SetHeight(1)
pickerScroll:SetScrollChild(pickerContent)

local pickerIconFrames = {}
local ICON_SIZE     = 36
local ICON_PADDING  = 4
local ICONS_PER_ROW = 6

local pickerOnSelect = nil

local function addIconButton(texture, tooltipText, yOffset, col, spellId)
    local btn = CreateFrame("Button", nil, pickerContent)
    btn:SetPoint("TOPLEFT", pickerContent, "TOPLEFT",
        4 + col * (ICON_SIZE + ICON_PADDING), -yOffset)
    btn:SetSize(ICON_SIZE, ICON_SIZE)

    local ico = btn:CreateTexture(nil, "ARTWORK")
    ico:SetAllPoints()
    ico:SetTexture(texture)

    local hl = btn:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    hl:SetBlendMode("ADD")

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(tooltipText)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    btn:SetScript("OnClick", function()
        if pickerOnSelect then pickerOnSelect(spellId) end
        spellPicker:Hide()
    end)

    table.insert(pickerIconFrames, btn)
end

local function buildIconGrid(filter)
    for _, f in ipairs(pickerIconFrames) do
        f:Hide()
    end
    wipe(pickerIconFrames)

    local yOffset = 4
    local col     = 0

    -- If the input is a number treat it as a spell ID — this reliably resolves
    -- any spell including monster-only spells not in the player's spell cache.
    -- Name lookup via GetSpellInfo only works for spells the client has cached
    -- (i.e. spells the player learned or recently encountered in a tooltip).
    if filter and filter ~= "" then
        local spellId = tonumber(filter)
        local name, _, texture = GetSpellInfo(spellId or filter)
        if name and texture then
            addIconButton(texture, name, yOffset, col, spellId)
            col = col + 1
            if col >= ICONS_PER_ROW then
                col = 0
                yOffset = yOffset + ICON_SIZE + ICON_PADDING
            end
        end
    end

    -- Walk the player spellbook, filtered by name when a search term is set
    local filterLower = filter and filter:lower() or ""
    local numTabs = GetNumSpellTabs()
    for tabIndex = 1, numTabs do
        local _, _, tabOffset, tabNumEntries = GetSpellTabInfo(tabIndex)
        for slot = tabOffset + 1, tabOffset + tabNumEntries do
            local spellType, spellId = GetSpellBookItemInfo(slot, BOOKTYPE_SPELL)
            if spellType == "SPELL" then
                local spellName = GetSpellBookItemName(slot, BOOKTYPE_SPELL)
                local texture   = GetSpellBookItemTexture(slot, BOOKTYPE_SPELL)
                if texture and spellName then
                    local matches = filterLower == "" or spellName:lower():find(filterLower, 1, true)
                    if matches then
                        addIconButton(texture, spellName, yOffset, col, spellId)
                        col = col + 1
                        if col >= ICONS_PER_ROW then
                            col = 0
                            yOffset = yOffset + ICON_SIZE + ICON_PADDING
                        end
                    end
                end
            end
        end
    end

    if col > 0 then
        yOffset = yOffset + ICON_SIZE + ICON_PADDING
    end
    pickerContent:SetHeight(math.max(yOffset + 4, 1))
end

pickerSearch:SetScript("OnTextChanged", function(self)
    buildIconGrid(self:GetText())
    pickerScroll:SetVerticalScroll(0)
end)

function spellPicker:open(onSelect)
    pickerOnSelect = onSelect
    self:ClearAllPoints()
    self:SetPoint("LEFT", editDialog, "RIGHT", 5, 0)
    pickerSearch:SetText("")
    buildIconGrid("")
    self:Show()
end

local addSpellBtn = CreateFrame("Button", nil, editDialog, "UIPanelButtonTemplate")
addSpellBtn:SetSize(90, 25)
addSpellBtn:SetPoint("BOTTOMLEFT", editDialog, "BOTTOMLEFT", 10, 10)
addSpellBtn:SetText("Add Icon")
addSpellBtn:SetScript("OnClick", function()
    spellPicker:open(function(spellId)
        editBox:Insert("{spell:" .. tostring(spellId) .. "}")
    end)
end)

StaticPopupDialogs["MOBINTEL_CONFIRM_DELETE_NOTE"] = {
    text = "Delete this note?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self, data)
        deleteNote(data.npcId, data.noteId)
        if data.onDeleted then data.onDeleted() end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}


local function createNotesPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints(parent)

    local scrollFrame = CreateFrame("ScrollFrame", "MobIntelNotesScrollFrame", panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -26, 5)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(760)
    content:SetHeight(1)
    scrollFrame:SetScrollChild(content)

    scrollFrame:SetScript("OnSizeChanged", function(self)
        content:SetWidth(self:GetWidth())
    end)

    local rows = {}

    local function addAreaHeader(yOffset, text)
        local f = CreateFrame("Frame", nil, content)
        f:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOffset)
        f:SetSize(content:GetWidth(), 26)

        local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        label:SetPoint("LEFT", f, "LEFT", 4, 0)
        label:SetText(text)

        local line = f:CreateTexture(nil, "ARTWORK")
        line:SetHeight(1)
        line:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
        line:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
        line:SetColorTexture(0.6, 0.6, 0.6, 0.6)

        table.insert(rows, f)
        return yOffset + 30
    end

    local function addCreatureHeader(yOffset, text)
        local f = CreateFrame("Frame", nil, content)
        f:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -yOffset)
        f:SetSize(content:GetWidth() - 10, 20)

        local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", f, "LEFT", 4, 0)
        label:SetText("|cFFFFD100" .. text .. "|r")

        table.insert(rows, f)
        return yOffset + 22
    end

    local function addNoteRow(yOffset, note, npcId, onRefresh)
        local f = CreateFrame("Frame", nil, content)
        f:SetPoint("TOPLEFT", content, "TOPLEFT", 20, -yOffset)
        f:SetSize(content:GetWidth() - 20, 26)

        local sharedCheck = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
        sharedCheck:SetSize(20, 20)
        sharedCheck:SetPoint("RIGHT", f, "RIGHT", -4, 0)
        sharedCheck:SetChecked(note.shared == true)
        sharedCheck:SetScript("OnClick", function(self)
            note.shared = self:GetChecked()
        end)

        local sharedLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        sharedLabel:SetText("Shared")
        sharedLabel:SetPoint("RIGHT", sharedCheck, "LEFT", -2, 0)

        local deleteBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        deleteBtn:SetSize(60, 22)
        deleteBtn:SetPoint("RIGHT", sharedLabel, "LEFT", -8, 0)
        deleteBtn:SetText("Delete")
        deleteBtn:SetScript("OnClick", function()
            StaticPopup_Show("MOBINTEL_CONFIRM_DELETE_NOTE", nil, nil, {
                npcId = npcId,
                noteId = note.id,
                onDeleted = onRefresh,
            })
        end)

        local editBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        editBtn:SetSize(50, 22)
        editBtn:SetPoint("RIGHT", deleteBtn, "LEFT", -4, 0)
        editBtn:SetText("Edit")
        editBtn:SetScript("OnClick", function()
            editDialog:open(note.text, function(newText)
                note.text = newText
                onRefresh()
            end)
        end)

        local authorLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        authorLabel:SetPoint("LEFT", f, "LEFT", 4, 0)
        authorLabel:SetText("[" .. MobIntel.utils.formatPlayerName(note.author) .. "]")
        authorLabel:SetJustifyH("LEFT")

        local textLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        textLabel:SetPoint("LEFT", authorLabel, "RIGHT", 6, 0)
        textLabel:SetPoint("RIGHT", editBtn, "LEFT", -8, 0)
        textLabel:SetJustifyH("LEFT")
        textLabel:SetMaxLines(1)
        textLabel:SetText(MobIntel.utils.formatNote(note.text or "", ""))

        table.insert(rows, f)
        return yOffset + 28
    end

    local function refresh()
        for _, row in ipairs(rows) do
            row:Hide()
        end
        wipe(rows)

        if not MobIntelDB then print("[MobIntel] MobIntelDB is nil") return end
        if not MobIntelDB.creature then print("[MobIntel] MobIntelDB.creature is nil") return end

        local byArea = {}
        local areaOrder = {}

        for npcId, creatureData in pairs(MobIntelDB.creature) do
            for _, note in ipairs(creatureData.notes) do
                local mapId = tostring(note.mapId or "0")
                if not byArea[mapId] then
                    byArea[mapId] = {}
                    table.insert(areaOrder, mapId)
                end
                local name = note.npcName or "Unknown"
                if not byArea[mapId][name] then
                    byArea[mapId][name] = {}
                end
                table.insert(byArea[mapId][name], { npcId = npcId, note = note })
            end
        end

        local yOffset = 4
        for _, mapId in ipairs(areaOrder) do
            yOffset = addAreaHeader(yOffset, getAreaName(mapId))

            local creatureNames = {}
            for name in pairs(byArea[mapId]) do
                table.insert(creatureNames, name)
            end
            table.sort(creatureNames)

            for _, creatureName in ipairs(creatureNames) do
                yOffset = addCreatureHeader(yOffset, creatureName)
                for _, entry in ipairs(byArea[mapId][creatureName]) do
                    yOffset = addNoteRow(yOffset, entry.note, entry.npcId, refresh)
                end
            end
        end

        content:SetHeight(math.max(yOffset + 4, 1))
    end

    panel.refresh = refresh
    return panel
end

local function createConfigFrame()
    local frame = CreateFrame("Frame", "MobIntelConfig", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(800, 600)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
    frame.title:SetText("MobIntel Config")

    local innerFrame = CreateFrame("Frame", nil, frame)
    innerFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -30)
    innerFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 5)

    local panelGeneral = CreateFrame("Frame", nil, innerFrame)
    panelGeneral:SetAllPoints(innerFrame)

    local autoShareCheck = CreateFrame("CheckButton", nil, panelGeneral, "UICheckButtonTemplate")
    autoShareCheck:SetPoint("TOPLEFT", panelGeneral, "TOPLEFT", 10, -10)
    autoShareCheck:SetScript("OnClick", function(self)
        MobIntelDB.settings.autoShare = self:GetChecked() == 1
    end)
    panelGeneral:SetScript("OnShow", function()
        autoShareCheck:SetChecked(MobIntelDB.settings.autoShare == true)
    end)

    local autoShareLabel = panelGeneral:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    autoShareLabel:SetPoint("LEFT", autoShareCheck, "RIGHT", 4, 0)
    autoShareLabel:SetText("Automatically share new notes")

    panelGeneral:Hide()

    local panelNotes = createNotesPanel(innerFrame)

    local tabGeneral = CreateFrame("Button", "MobInteltabGeneral", frame, "CharacterFrameTabButtonTemplate")
    tabGeneral:SetText("General")
    tabGeneral:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 10, 0)
    tabGeneral:SetID(1)

    local tabNotes = CreateFrame("Button", "MobInteltabNotes", frame, "CharacterFrameTabButtonTemplate")
    tabNotes:SetText("Notes")
    tabNotes:SetPoint("LEFT", tabGeneral, "RIGHT", -15, 0)
    tabNotes:SetID(2)

    local function selectTab(id)
        if id == 1 then
            tabGeneral:LockHighlight()
            tabNotes:UnlockHighlight()
            panelGeneral:Show()
            panelNotes:Hide()
        else
            tabGeneral:UnlockHighlight()
            tabNotes:LockHighlight()
            panelGeneral:Hide()
            panelNotes:Show()
            panelNotes.refresh()
        end
    end

    tabGeneral:SetScript("OnClick", function() selectTab(1) end)
    tabNotes:SetScript("OnClick", function() selectTab(2) end)

    frame:SetScript("OnShow", function()
        selectTab(2)
    end)

    frame:Hide()
    return frame
end

local frame = createConfigFrame()
SLASH_MOBINTELCONFIG1 = "/mic"
SlashCmdList["MOBINTELCONFIG"] = function()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end
