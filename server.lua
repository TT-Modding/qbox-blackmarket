local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-blackmarket:sellItem', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Config.SellableItems[item] then
        TriggerClientEvent('ox_lib:notify', src, { description = 'Det här itemet kan inte säljas.', type = 'error' })
        return
    end

    local playerItem = Player.Functions.GetItemByName(item)
    if not playerItem or playerItem.amount < amount then
        TriggerClientEvent('ox_lib:notify', src, { description = 'Du har inte så många av ' .. item .. '.', type = 'error' })
        return
    end

    Player.Functions.RemoveItem(item, amount)
    local totalPay = Config.SellableItems[item] * amount
    Player.Functions.AddMoney('cash', totalPay, "sold-blackmarket-item")

    TriggerClientEvent('ox_lib:notify', src, { description = 'Du sålde ' .. amount .. 'x ' .. item .. ' för $' .. totalPay, type = 'success' })
end)
