-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------
ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    table.wipe(ESX.PlayerData)
    ESX.PlayerLoaded = false
end)

RegisterNetEvent('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)


RegisterNetEvent('lynn_stockshop:setProductPrice')
AddEventHandler('lynn_stockshop:setProductPrice', function(shop, slot)
    local input = lib.inputDialog(Strings.sell_price, {Strings.amount_input})
    local price
    if not input then price = 0 end
    price = tonumber(input[1])
    if price < 0 then price = 0 end
    TriggerEvent('ox_inventory:closeInventory')
    TriggerServerEvent('lynn_stockshop:setData', shop, slot, math.floor(price))
    lib.notify({
        title = Strings.success,
        description = (Strings.item_stocked_desc):format(price),
        type = 'success'
    })
end)

local function createBlip(coords, sprite, color, text, scale)
    local x,y,z = table.unpack(coords)
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, scale)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    return blip
end

CreateThread(function()
    for _,v in pairs(TokoCFG.Shops) do
        if v.blip.enabled then
            createBlip(v.blip.coords, v.blip.sprite, v.blip.color, v.blip.string, v.blip.scale)
        end
    end
end)

CreateThread(function()
    local textUI, points = nil, {}
    while not ESX.PlayerLoaded do Wait(1000) end
    for k,v in pairs(TokoCFG.Shops) do
        local stashLoc = v.locations.stash.coords
        local shopLoc = v.locations.shop.coords
        local bossLoc
        if v.bossMenu.enabled then
            bossLoc = v.bossMenu.coords
        end
        if not points[k] then points[k] = {} end
        points[k].stash = lib.points.new({
            coords = v.locations.stash.coords,
            distance = v.locations.stash.range,
            shop = k
        })
        points[k].shop = lib.points.new({
            coords = v.locations.shop.coords,
            distance = v.locations.shop.range,
            shop = k
        })
        if v.bossMenu.enabled then
            points[k].bossMenu = lib.points.new({
                coords = v.bossMenu.coords,
                distance = v.bossMenu.range,
                shop = k
            })
        end
    end
    for k,v in pairs(points) do
        function v.stash:nearby()
            if not self.isClosest or ESX.PlayerData.job.name ~= self.shop then return end
            if self.currentDistance < self.distance then
                if not textUI then
                    lib.showTextUI(TokoCFG.Shops[self.shop].locations.stash.string)
                    textUI = true
                end
                if IsControlJustReleased(0, 38) then
                    exports.ox_inventory:openInventory('stash', self.shop)
                end
            end
        end
        function v.stash:onExit()
            if not self.isClosest then return end
            if textUI then
                lib.hideTextUI()
                textUI = nil
            end
        end

        function v.shop:nearby()
            if not self.isClosest then return end
            if self.currentDistance < self.distance then
                if not textUI then
                    lib.showTextUI(TokoCFG.Shops[self.shop].locations.shop.string)
                    textUI = true
                end
                if IsControlJustReleased(0, 38) then
                    exports.ox_inventory:openInventory('shop', { type = self.shop, id = 1 })
                end
            end
        end
        function v.shop:onExit()
            if not self.isClosest then return end
            if textUI then
                lib.hideTextUI()
                textUI = nil
            end
        end

        if v?.bossMenu then
            function v.bossMenu:nearby()
                if not self.isClosest then return end
                if self.currentDistance < self.distance then
                    if not textUI then
                        lib.showTextUI(TokoCFG.Shops[self.shop].bossMenu.string)
                        textUI = true
                    end
                    if IsControlJustReleased(0, 38) and ESX.PlayerData.job.grade_name == 'boss' then
                        TriggerEvent('esx_society:openBossMenu', ESX.PlayerData.job.name, function(data, menu)
                            menu.close()
                        end, {wash = false})
                    end
                end
            end
            function v.bossMenu:onExit()
                if textUI then
                    lib.hideTextUI()
                    textUI = nil
                end
            end
        end
    end
end)
