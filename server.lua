ESX = nil

local have = false

vehstatus = {{plate = 0, orginalbrakes = 0.0, brakes = 0.0}}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('eloo:enterVehicle')
AddEventHandler('eloo:enterVehicle', function(plate)
    for i=1, #vehstatus do
        if vehstatus[i].plate ~= plate then
            MySQL.Async.fetchAll('SELECT durability FROM owned_vehicles WHERE plate=@plate'{ ['@plate'] = plate}, function(result)
                if result == nil then
                    local insert = {plate = plate, orginalbrakes = 0.0, brakes = 0.0}
                    MySQL.Async.execute('INSERT INTO owned_vehicles (durability) VALUES (@durability)', { ['@durability'] = insert})
                else
                    print(result[1].plate)
                end
            end)
        end
    end
end)

--[[RegisterNetEvent('baseevents:enteredVehicle')
AddEventHandler('baseevents:enteredVehicle', function(veh, seat, name, id)
    local ped = GetPlayerPed(source)
    local veh2 = GetVehiclePedIsIn(ped, false)
    local plate = GetVehicleNumberPlateTextIndex(veh2)
    print(plate)
    getData(plate)
    TriggerClientEvent('eloo:enterVehicle', source, veh, seat)
end)

RegisterNetEvent('baseevents:leftVehicle')
AddEventHandler('baseevents:leftVehicle', function(veh, seat, name, id)
    TriggerClientEvent('eloo:leftVehicle', source, veh, seat)
end)

RegisterNetEvent('eloo:saveFirstData')
AddEventHandler('eloo:saveFirstData', function(plates, hamulce)
    saveFirstData(plates, hamulce)
end)

RegisterNetEvent('eloo:saveData')
AddEventHandler('eloo:saveData', function(plates, hamulcenow)
    saveData(plates, hamulcenow)
end)

function saveFirstData(plates, breake)
    checkVeh(plates)
    if not have then
        table.insert(vehstatus, {plate = plates, orginalbrakes = breake, brakes = breake})
        print('breake')
    else
        print('test')
    end
end

function saveData(plates, breakenow)
    for i=1, #vehstatus do
        if vehstatus[i].plate == plates then
            vehstatus[i].brakes = breakenow
            print('breakenow')
        end
    end
end


function getData(plates)
    for i=1, #vehstatus do
        if vehstatus[i].plate == plates then
            print(plates)
            local orginalbrakes
            local brakes
            vehstatus[i].orginalbrakes = orginalbrakes
            vehstatus[i].brakes = brakes
            return orginalbrakes, brakes
        end
    end
end

function checkVeh(plates)
    for i=1, #vehstatus do
        if vehstatus[i].plate ~= plates then
            have = false
        else
            have = true
        end
    end
end

RegisterCommand('debug', function(source, args) 
    print(ESX.DumpTable(vehstatus))
end)]]--