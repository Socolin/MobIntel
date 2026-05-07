


-- local frame = CreateFrame("Frame")
-- local elapsed = 0

-- frame:SetScript("OnUpdate", function(self, delta)
--     elapsed = elapsed + delta
--     if elapsed < 0.5 then return end
--     elapsed = 0

--     local mapId = C_Map.GetBestMapForUnit("player")
--     local position = C_Map.GetPlayerMapPosition(mapId, "player")
--     local x, y = position.x, position.y

--     -- local width, height = C_Map.GetMapWorldSize(mapId)  not available on tbc annirsary

--     local vectorCenter = CreateVector2D(0.5, 0.5)
--     local vectorTopLeft = CreateVector2D(0, 0)

--     local _, topLeftPos = C_Map.GetWorldPosFromMapPos(mapId, vectorTopLeft)
--     local _, centerPos = C_Map.GetWorldPosFromMapPos(mapId, vectorCenter)
--     local width = 0
--     local height = 0
--     local top, left = topLeftPos:GetXY()
--     local bottom, right = centerPos:GetXY()
--     width = (left - right) * 2
--     height = (top - bottom) * 2
--     -- print(width, height)
--     local x2 = 0.490457
--     local y2 = 0.3601262

--     local dx = (x2 - x) * width
--     local dy = (y2 - y) * height
--     local distance = math.sqrt(dx*dx + dy*dy)
--     -- print(mapID)
--     -- print(x, y)
--     print(distance)
--     -- your check here
-- end)

