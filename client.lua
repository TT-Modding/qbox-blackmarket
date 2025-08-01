local QBCore = exports['qb-core']:GetCoreObject()
local marketNpc = nil

function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
    AddTextEntry(entryTitle, textEntry)
    DisplayOnscreenKeyboard(1, entryTitle, "", inputText, "", "", "", maxLength or 30)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do Wait(0) end
    if UpdateOnscreenKeyboard() ~= 2 then
        return GetOnscreenKeyboardResult()
    else
        return nil
    end
end

CreateThread(function()
    RequestModel(Config.MarketNPC.model)
    while not HasModelLoaded(Config.MarketNPC.model) do Wait(10) end

    marketNpc = CreatePed(4, GetHashKey(Config.MarketNPC.model), Config.MarketNPC.coords.x, Config.MarketNPC.coords.y, Config.MarketNPC.coords.z - 1.0, Config.MarketNPC.coords.w, false, true)
    SetEntityInvincible(marketNpc, true)
    SetBlockingOfNonTemporaryEvents(marketNpc, true)
    FreezeEntityPosition(marketNpc, true)

    exports.ox_target:addSphereZone({
        coords = Config.MarketNPC.coords.xyz,
        radius = 1.5,
        debug = false,
        options = {
            {
                name = 'sellToBlackMarket',
                event = 'qb-blackmarket:openSellMenu',
                icon = 'fas fa-hand-holding-usd',
                label = 'Sell to Black Market',
            }
        }
    })
end)

RegisterNetEvent('qb-blackmarket:openSellMenu', function()
    local itemsToSell = {}

    for item, price in pairs(Config.SellableItems) do
        local count = exports.ox_inventory:Search('count', item)
        if count > 0 then
            local itemInfo = exports.ox_inventory:Items()[item]
            local label = (itemInfo and itemInfo.label or item) .. ' x' .. count
            table.insert(itemsToSell, {
                title = label,
                description = 'Price per unit: $' .. price,
                icon = 'dollar-sign',
                onSelect = function()
                    TriggerEvent('qb-blackmarket:sellAmountInput', { item = item, count = count, price = price })
                end
            })
        end
    end

    if #itemsToSell == 0 then
        lib.notify({ title = 'Black Market', description = 'You have no items to sell.', type = 'error' })
        return
    end

    lib.registerContext({
        id = 'blackmarket_menu',
        title = 'Black Market',
        options = itemsToSell
    })

    lib.showContext('blackmarket_menu')
end)

RegisterNetEvent('qb-blackmarket:sellAmountInput', function(itemData)
    local amountStr = KeyboardInput("BLACKMARKET_AMOUNT", "How many do you want to sell? (Max: " .. itemData.count .. ")", "", 5)
    local amount = tonumber(amountStr)

    if amount and amount > 0 and amount <= itemData.count then
        local playerPed = PlayerPedId()
        local npcPed = marketNpc

        RequestAnimDict("mp_common")
        RequestAnimDict("mp_ped_interaction")
        while not HasAnimDictLoaded("mp_common") or not HasAnimDictLoaded("mp_ped_interaction") do Wait(10) end

        TaskPlayAnim(playerPed, "mp_common", "givetake1_a", 8.0, -8.0, 5000, 0, 0, false, false, false)
        TaskPlayAnim(npcPed, "mp_ped_interaction", "handshake_guy_a", 8.0, -8.0, 5000, 0, 0, false, false, false)

        lib.progressCircle({
            duration = 5000,
            position = 'bottom',
            label = 'Selling to the black market...',
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
                move = true,
                combat = true,
            }
        })

        Wait(0) ##Change time until items are removed from player and player is given money.

        ClearPedTasks(playerPed)
        ClearPedTasks(npcPed)

        TriggerServerEvent('qb-blackmarket:sellItem', itemData.item, amount)
    else
        lib.notify({ title = 'Black Market', description = 'Invalid amount or cancelled.', type = 'error' })
    end
end)
