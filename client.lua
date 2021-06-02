ESX              = nil
local PlayerData = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

------------------------------------------------------------------------
------------------------------- Elo ------------------------------------
------------------------------------------------------------------------

local inVeh = false
local event = false

usebrake = 0
brakeprecent = 100
brake = nil
curbrake = 0.0

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            if GetPedInVehicleSeat(veh, -1) then
                if GetIsVehicleEngineRunning(veh) then
                    if not event then
                        local plate = ESX.Game.GetVehicleProperties(veh).plate
                        TriggerServerEvent('eloo:enterVehicle', plate)
                        event = true
                    end
                    inVeh = true
                else
                    if event then
                        local plate = ESX.Game.GetVehicleProperties(veh).plate
                        TriggerServerEvent('eloo:leftVehicle', plate)
                    end
                    inVeh = false
                end
            --else
                --TriggerServerEvent('eloo:leftVehicle')
            end
        else
            inVeh = false
        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    local numwhel 
    local wheel = {}
    while true do
        if inVeh then
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)

            -- Getting max breaking value

            if brake == nil then
                local hash = GetEntityModel(veh)
                brake = GetVehicleModelMaxBraking(hash)
            end

            -- Getting amount of wheels

            if numwhel == nil then
                numwhel = GetVehicleNumberOfWheels(veh)
                local l = 0
                for i=1, numwhel do
                    table.insert(wheel,l)
                    l = i
                end
            end
            local allbrake = 0

            -- Check brake pressure for wheels

            for i=1, #wheel do
                --local wheel2 = wheel[i]
                local pressbrake = GetVehicleWheelBrakePressure(veh, wheel[i])
                allbrake = allbrake + pressbrake
            end

            -- Setting up degradation status for brakes

            if usebrake <= 100 then
                usebrake = usebrake + allbrake
            else
                brakeprecent = brakeprecent - 1
                curbrake = brake * (brakeprecent / 100)
                SetVehicleHandlingFloat(veh, 'CHandlingData', 'fBrakeForce', curbrake)
                usebrake = 0
            end

            -- Maths for degratation precent of engine
            
            local rpm = GetVehicleCurrentRpm(veh)
            if rpm >= 0.8 and curengine > 0.0 then
                if useengine <= 100 then
                    useengine = useengine + 1
                else
                    engineprecent = engineprecent - 1
                    curengine = 1 * (engineprecent / 100)
                    useengine = 0
                end
            end

            Citizen.Wait(100)
			
        else

            usebrake = 0
            brakeprecent = 100
            brake = nil
            curbrake = 0.0
            numwhel = nil
            wheel = {}

            curengine = 1.0
            engineprecent = 100
            useengine = 0

            Citizen.Wait(1000)
        end
    end
end)

useengine = 0
engineprecent = 100
curengine = 1.0

--Function who needed work every frame

Citizen.CreateThread(function()
    while true do
        if inVeh then
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)

            -- Set engine cant run when curengine is 0

            if curengine <= 0.0 then
                SetVehicleEngineOn(veh, false, true, true)
            end

            --Setting value of power for engine

            SetVehicleCheatPowerIncrease(veh, curengine)

            Citizen.Wait(0)
        else
            Citizen.Wait(1000)
        end
    end
end)



RegisterCommand('status', function(source, args)
    TriggerEvent('chat:addMessage', {color = {255, 0, 0}, args = {"Status: ", "Hamulce: " .. brakeprecent .. "%"}})
    TriggerEvent('chat:addMessage', {color = {255, 0, 0}, args = {"Status: ", "Silnik: " .. engineprecent .. "%"}})
end)

RegisterCommand('deb', function(source, args) 
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local testo = GetVehicleMaxBraking(veh)
    print(veh)
    print(ped)
    print(testo)
end)

RegisterCommand('debugtest', function(source, args)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)


    while true do
        SetVehicleCheatPowerIncrease(veh, 0.1)
        Citizen.Wait(0)
    end
    --SetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce', 0.70)
    --SetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDragCoeff', 1.0)
    --SetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveMaxFlatVel', 300.0)
end)

RegisterCommand('debugtest2', function(source, args)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local test = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fBrakeForce')
    --local test2 = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce')
    --local test3 = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDragCoeff')
    --local test4 = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveMaxFlatVel')
    print(test)
    --print(test2)
	--procent = 0.10
	--hamulce = test * procent
	--print(hamulce)
    --print(test3)
    --print(test4)
end)

RegisterCommand('ped', function(source, args)
	if args[1] then
		TriggerEvent('esx:spawnPed', args[1])
	end
end)

RegisterNetEvent('esx:spawnPed')
AddEventHandler('esx:spawnPed', function(model)
	model           = (tonumber(model) ~= nil and tonumber(model) or GetHashKey(model))
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)
	local forward   = GetEntityForwardVector(playerPed)
	local x, y, z   = table.unpack(coords + forward * 1.0)

	Citizen.CreateThread(function()
		RequestModel(model)

		while not HasModelLoaded(model) do
			Citizen.Wait(1)
		end

		ped = CreatePed(5, model, x, y, z, 0.0, true, false)
	end)
end)