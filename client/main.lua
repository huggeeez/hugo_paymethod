local QBCore = exports['qb-core']:GetCoreObject()

local function showPaymentMenu(price, resourceName, context)
    QBCore.Functions.TriggerCallback('hugo_paymethod:checkBankCard', function(hasBankCard)
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'setPaymentPrice',
            data = price,
            resourceName = resourceName,
            hasBankCard = hasBankCard,
            context = context
        })
        CurrentPayMethodContext = context
    end)
end

local function handlePaymentMethod(method, price)
    SetNuiFocus(false, false)
    TriggerServerEvent('hugo_paymethod:processPayment', method, price, nil, CurrentPayMethodContext)
end

RegisterNUICallback('selectPaymentMethod', function(data, cb)
    if data.method == 'card' then
        QBCore.Functions.TriggerCallback('hugo_paymethod:checkBankCard', function(hasBankCard)
            if hasBankCard then
                SetNuiFocus(false, false)
                TriggerServerEvent('hugo_paymethod:processPayment', data.method, data.price, data.card, CurrentPayMethodContext)
            else
                TriggerEvent('QBCore:Notify', 'You need a bank card to pay by card!', 'error')
            end
        end)
    else
        SetNuiFocus(false, false)
        TriggerServerEvent('hugo_paymethod:processPayment', data.method, data.price, nil, CurrentPayMethodContext)
    end
    cb('ok')
end)

RegisterNUICallback('cancelPayment', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('getPlayerCards', function(_, cb)
    local cards = {}
    local items = exports.ox_inventory:Search('slots', 'bank_card')
    for _, item in ipairs(items) do
        if item.metadata then
            table.insert(cards, {
                name = item.metadata.owner or 'Bank Card',
                number = item.metadata.cardNumber or 'XXXX-XXXX',
            })
        end
    end
    cb(cards)
end)

exports('showPaymentMenu', showPaymentMenu)
exports('handlePaymentMethod', handlePaymentMethod)

RegisterCommand("testpaymenu", function()
    showPaymentMenu(100, GetCurrentResourceName(), "testpay")
end, false)
