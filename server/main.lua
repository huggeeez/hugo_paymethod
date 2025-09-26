local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('hugo_paymethod:checkBankCard', function(source, cb)
    local bankCard = exports.ox_inventory:GetItem(source, 'bank_card', nil, true)
    cb(bankCard and bankCard > 0)
end)

RegisterServerEvent('hugo_paymethod:processPayment')
AddEventHandler('hugo_paymethod:processPayment', function(method, price, card, context)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not method or price == nil or (price <= 0 and context ~= "fuel") then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid payment information!', 'error')
        return
    end

    if method == 'cash' then
        local moneyCount = exports.ox_inventory:GetItemCount(src, 'money') or 0
        if price == 0 and context == "fuel" then
            if moneyCount > 0 then
                TriggerClientEvent('hugo_paymethod:paymentResult', src, true, method, context)
                return
            else
                TriggerClientEvent('QBCore:Notify', src, 'You have no cash!', 'error')
                TriggerClientEvent('hugo_paymethod:paymentResult', src, false, method, context)
                return
            end
        end
        if moneyCount >= price then
            if exports.ox_inventory:RemoveItem(src, 'money', price) then
                TriggerClientEvent('hugo_paymethod:paymentResult', src, true, method, context)
                return
            end
        end
        TriggerClientEvent('QBCore:Notify', src, 'Not enough cash!', 'error')
        TriggerClientEvent('hugo_paymethod:paymentResult', src, false, method, context)
        
    elseif method == 'card' then
        local bankCard = exports.ox_inventory:GetItem(src, 'bank_card', nil, true)
        if not bankCard or bankCard <= 0 then
            TriggerClientEvent('hugo_paymethod:paymentResult', src, false, method, context)
            return
        end

        if Player.PlayerData.money['bank'] >= price then
            Player.Functions.RemoveMoney('bank', price, "card-payment")
            TriggerClientEvent('hugo_paymethod:paymentResult', src, true, method, context)
            return
        end

        TriggerClientEvent('QBCore:Notify', src, 'Not enough money in the bank account!', 'error')
        TriggerClientEvent('hugo_paymethod:paymentResult', src, false, method, context)
    end
end)

RegisterNetEvent('hugo_paymethod:paymentResult')
AddEventHandler('hugo_paymethod:paymentResult', function(success, method)
end)