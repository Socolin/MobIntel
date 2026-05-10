local minimapBtn = CreateFrame("Button", "MobIntelMinimapButton", Minimap)
minimapBtn:SetSize(32, 32)
minimapBtn:SetFrameStrata("MEDIUM")
minimapBtn:SetFrameLevel(8)

local icon = minimapBtn:CreateTexture(nil, "BACKGROUND")
icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
icon:SetSize(20, 20)
icon:SetPoint("CENTER")

local border = minimapBtn:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetSize(56, 56)
border:SetPoint("TOPLEFT")

local angle = 45

local function updatePosition()
    local rad = math.rad(angle)
    minimapBtn:SetPoint("CENTER", Minimap, "CENTER", math.cos(rad) * 80, math.sin(rad) * 80)
end

minimapBtn:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        if MobIntelConfig:IsShown() then
            MobIntelConfig:Hide()
        else
            MobIntelConfig:Show()
        end
    end
end)

minimapBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("MobIntel")
    GameTooltip:AddLine("Click to open / close", 1, 1, 1)
    GameTooltip:Show()
end)

minimapBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

minimapBtn:RegisterForDrag("LeftButton")
minimapBtn:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
        local cx, cy = Minimap:GetCenter()
        local mx, my = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        angle = math.deg(math.atan2(my / scale - cy, mx / scale - cx))
        updatePosition()
    end)
end)
minimapBtn:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
    if MobIntelDB and MobIntelDB.settings then
        MobIntelDB.settings.minimapAngle = angle
    end
end)

local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("ADDON_LOADED")
loadFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName ~= "MobIntel" then return end
    if MobIntelDB and MobIntelDB.settings and MobIntelDB.settings.minimapAngle then
        angle = MobIntelDB.settings.minimapAngle
    end
    updatePosition()
end)

updatePosition()
