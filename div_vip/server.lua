local QBCore = exports["qb-core"]:GetCoreObject()

local config = require('config')

lib.callback.register('beli:vipla', function(source)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local cid = xPlayer.PlayerData.citizenid
    local coin = xPlayer.PlayerData.money['coin']
    local hargavip = config.hargavip
    if coin >= hargavip then
        xPlayer.Functions.RemoveMoney('coin', hargavip, 'vip status')
        local updateQuery = 'UPDATE player_vip SET date_expiried = ?, registered = ? WHERE citizenid = ?'
        local updateVIP = exports.oxmysql:updateSync(updateQuery,
        {
            os.date('%Y-%m-%d', os.time() + (30 * 24 * 60 * 60)),
            'yes',
            xPlayer.PlayerData.citizenid
        })
        TriggerClientEvent('QBCore:Notify', source, config.notify.dahbeli, 'success')
        return true
    else
        TriggerClientEvent('QBCore:Notify', source, config.notify.takdeduit, 'error')
        return false
    end
end)

lib.callback.register('check:vipstatus', function(source)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local p = promise.new()
    exports.oxmysql:scalar('SELECT * FROM player_vip WHERE citizenid = @cid AND registered = "yes"', {
        ['@cid'] = xPlayer.PlayerData.citizenid
    }, function(vip)
        if vip then
            p:resolve(true)
        else
            p:resolve(false)
        end
    end)
    return Citizen.Await(p)
end)


lib.callback.register('check:tarikvip', function(source)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local p = promise.new()

    exports.oxmysql:execute('SELECT * FROM player_vip WHERE citizenid = @cid AND registered = "yes"', {
        ['@cid'] = xPlayer.PlayerData.citizenid
    }, function(result)
        if result and #result > 0 then
            local dateExpiried = tonumber(result[1].date_expiried) / 1000
            local currentTime = os.time()
            local daysLeft = math.ceil((dateExpiried - currentTime) / (24 * 60 * 60))
            p:resolve(daysLeft)
        else
            p:resolve(nil)
        end
    end)

    return Citizen.Await(p)
end)

CreateThread(function()
    while true do
        exports.oxmysql:updateSync('UPDATE player_vip SET registered = ?, date_expiried = ? WHERE registered != ? AND date_expiried IS NOT NULL AND date_expiried <= CURDATE()', {'not', nil, 'not'})
        Wait(10 * 60000)
    end
end)

lib.callback.register('register:vip', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    MySQL.query('SELECT * FROM player_vip WHERE citizenid = ?', {citizenid}, function(result)
        if #result == 0 then
            MySQL.insert('INSERT INTO player_vip (citizenid) VALUES (?)', {citizenid})
        end
    end)
    return
end)

lib.callback.register('claim:barangvip', function(source)
    local src = source
    for _, v in pairs(config.barangreward) do
        exports['qb-inventory']:AddItem(src, v.item, v.amount, false, false, 'div-vip')
    end
end)