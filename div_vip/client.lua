local QBCore = exports["qb-core"]:GetCoreObject()

local config = require('config')

local userData = {
    lastClaimed = 0,
    canClaim = false,
}

local function loadData(data)
    for k, v in pairs(data) do
        userData[k] = v
    end
end

local function saveData()
    SetResourceKvp('div_dailyclaim', json.encode(userData)) --! jangan tukar 
end

function TimeToDate(time)
	local day = math.floor(time / 86400)
	local hour = math.floor(time / 60 / 60) % 24
	local minute = math.floor(time / 60) % 60
	local second = time % 60

	return day, hour, minute, second
end

function DateToTime(day, hour, minute, second)
	return day * 86400 + hour * 3600 + minute * 60 + second
end

local timeToClaim = DateToTime(0, config.rewardclaim, 0, 0) --! jangan tukar

CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            local data = GetResourceKvpString('div_dailyclaim') --! jangan tukar
            if data then loadData(json.decode(data)) end
            break
        end
        Wait(200)
    end
end)

local jam = 0

CreateThread(function()
    while true do
        Wait(1000)
        if not userData.canClaim then
            local year, month, day, hour, minute, second = GetLocalTime()
            local currentTime = DateToTime(day, hour, minute, second)
            local lastClaimed = userData.lastClaimed
            
            local timeDifference = lastClaimed - currentTime + timeToClaim
            local day, hour, minute, second = TimeToDate(timeDifference)

            if timeDifference <= 0 then
                userData.canClaim = true
                saveData()
            else
                local day, hour, minute, second = TimeToDate(timeDifference)
                if hour < 10 then hour = '0' .. hour end
                if minute < 10 then minute = '0' .. minute end
                if second < 10 then second = '0' .. second end
                jam = hour
            end
        end
    end
end)

RegisterNetEvent('open:vipefnam', function()
    local disablekan = false
    local vip = lib.callback.await('check:vipstatus', false)
    local tarikh = lib.callback.await('check:tarikvip', false) or '..'
    local dahada = false

    if vip then
        dahada = true
        disablekan = false
    else
        dahada = false
        disablekan = true
    end

    lib.registerContext({
        id = 'vip_menusaya',
        title = tarikh.. ' days remaining',
        options = {
            {
                title = '👑 VIP MENU Donation',
                description = 'Buy VIP PASS 30 days',
                icon = 'coins',
                disabled = dahada,
                onSelect = function()
                    --local beli = lib.callback.await('beli:vipla', false)
                end,
            },
            {
                title = 'Open Clothing Menu',
                description = 'Access Your Wardrobe Anywhere',
                disabled = disablekan,
                icon = 'fas fa-tshirt',
                onSelect = function()
                    TriggerEvent('illenium-appearance:client:openOutfitMenu')
                end,
            },
            {
                title = 'VIP Reward',
                description = 'Claim Item',
                icon = 'fa-solid fa-heart-pulse',
                disabled = disablekan,
                onSelect = function()
		    if not userData.canClaim then return end
                    userData.canClaim = false
                    local year, month, day, hour, minute, second = GetLocalTime()
                    userData.lastClaimed = DateToTime(day, hour, minute, second)
                    saveData()                                
                    local dapat = lib.callback.await('claim:barangvip', false)
                end,
            },
            {
                title = 'Auto Pilot',
                description = 'Auto Pilot Anywhere',
                icon = 'fas fa-car',
                disabled = disablekan,
                onSelect = function()
                    AutoPilotMenu()
                end,
            },
            {
                title = 'Change Timecycle',
                description = 'Can Modifier! Timecycle',
                icon = 'fa-solid fa-clock-rotate-left',
                disabled = disablekan,
                onSelect = function()
                    lib.showMenu('timecycle_menu')
                end,
            },
        }
    })
    lib.showContext('vip_menusaya')
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local insertdb = lib.callback.await('register:vip', false)
end)

if config.gunakeybind then
    local keybind = lib.addKeybind({
        name = config.keybindsettings.tajuk,
        description = config.keybindsettings.desc,
        defaultKey = config.keybindsettings.key,
        onReleased = function(self)
            TriggerEvent('open:vipefnam')
        end
    })
end

function AutoPilotMenu()
    lib.registerContext({
        id = 'auto_pilot',
        title = 'VIP MENU',
        options = {
            {
                title = 'start',
                description = 'start autopolit',
                icon = 'car',
                onSelect = function()
                    if cache.vehicle then
                        if DoesBlipExist(GetFirstBlipInfoId(8)) then
                            local blip = GetFirstBlipInfoId(8)
                            local bCoords = GetBlipCoords(blip)
                            DriveToBlipCoord(cache.ped, bCoords, 25.0, 786603)
                        end
                    end
                end,
            },
            {
                title = 'stop',
                description = 'stop autopilot',
                icon = 'car',
                onSelect = function()
                    if cache.vehicle then
                        ClearPedTasks(PlayerPedId())
                    end
                end,
            },
            {
                title = 'back',
                icon = 'rotate-left',
                onSelect = function()
                    lib.showContext('vip_menusaya')
                end,
            },
        }
    })
    lib.showContext('auto_pilot')
end

function DriveToBlipCoord(player, blipCoords, speed, drivingStyle)
    local veh = GetVehiclePedIsIn(cache.ped, false)

    if DoesBlipExist(GetFirstBlipInfoId(8)) then
        ClearPedTasks(player)
        TaskVehicleDriveToCoordLongrange(player, veh, blipCoords.x, blipCoords.y, blipCoords.z, tonumber(speed), drivingStyle, 2.0)
    end
end

RegisterCommand('vip', function()
    TriggerEvent('open:vipefnam')
end)


--! timecycle here!

function CreateListForIndex(modifications)
    local list = {0}
    for i = 1, modifications do
        table.insert(list, i)
    end
    return list
end

local fileJson = LoadResourceFile(GetCurrentResourceName(), 'timecycle.json')
local timecycleOptions = json.decode(fileJson) 

if not timecycleOptions then
    print('file json hilang???')
    return
end

local options = {}

for _, option in ipairs(timecycleOptions) do
    table.insert(options, {
        label = option.Name,
        values = CreateListForIndex(option.ModificationsCount),
        args = {
            isTimecycle = true,
            value = option.Name,
            modificationsCount = option.ModificationsCount
        },
        description = option.Name .. ' - ' .. option.DlcName
    })
end

table.insert(options, {
    label = 'Reset Timecycle',
    onSelected = function()
        ClearTimecycleModifier()
    end,
    description = 'Reset the timecycle to default'
})

lib.registerMenu({
    id = 'timecycle_menu',
    title = 'Timecycle Menu',
    position = 'top-right',
    onSideScroll = function(selected, scrollIndex, args)
        if args.isTimecycle then
            SetTimecycleModifier(tostring(args.value))
            SetTimecycleModifierStrength((tonumber(scrollIndex) + 0.0) / args.modificationsCount)
        end
    end,
    onSelected = function(selected, secondary, args)
        if args.isTimecycle then
            SetTimecycleModifier(tostring(args.value))
            SetTimecycleModifierStrength((args.defaultIndex or 0) + 0.0 / args.modificationsCount)
        end
    end,
    options = options
}, function(selected, scrollIndex, args)
end)
