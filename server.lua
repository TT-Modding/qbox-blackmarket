local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-blackmarket:sellItem', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Config.SellableItems[item] then
        TriggerClientEvent('ox_lib:notify', src, {
            description = 'This item cannot be sold here.',
            type = 'error'
        })
        return
    end

    local playerItem = Player.Functions.GetItemByName(item)
    if not playerItem or playerItem.amount < amount then
        TriggerClientEvent('ox_lib:notify', src, {
            description = 'You do not have enough of ' .. item .. '.',
            type = 'error'
        })
        return
    end

    Player.Functions.RemoveItem(item, amount)
    local totalPay = Config.SellableItems[item] * amount
    Player.Functions.AddMoney('cash', totalPay, "sold-blackmarket-item")

    TriggerClientEvent('ox_lib:notify', src, {
        description = 'You sold ' .. amount .. 'x ' .. item .. ' for $' .. totalPay,
        type = 'success'
    })
end)
