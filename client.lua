local ind = {l = false, r = false}
-- local maxSpeed = 0
local hash = nil
local speed = nil
local inVehicle = false
local sitInVehicle = false
local PedCar = false
local inVehicleSeat = nil
local player = nil
local carSpeed = nil
local ArrowLeft, ArrowRight = false, false
local VehIndicatorLight = nil
local feuPosition, feuRoute = nil, nil
local fuel = nil


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		player = PlayerPedId()
		inVehicle = IsPedInAnyVehicle(player)
		sitInVehicle = IsPedSittingInAnyVehicle(player)
		PedCar = GetVehiclePedIsIn(player, false)
		inVehicleSeat = GetPedInVehicleSeat(PedCar, -1)

		-- Max Speed
		hash = GetEntityModel(PedCar)
		speed = GetVehicleMaxSpeed(hash)

		-- Lights
		_,feuPosition,feuRoute = GetVehicleLightsState(PedCar)

		-- Turn signal
		-- SetVehicleIndicatorLights (1 left -- 0 right)
		VehIndicatorLight = GetVehicleIndicatorLights(GetVehiclePedIsUsing(player))

		fuel = exports["LegacyFuel"]:GetFuel(PedCar)

		
		Citizen.Wait(500)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		-- Speed
		carSpeed = math.ceil(GetEntitySpeed(PedCar) * 3.6)
		-- Key Press
		ArrowLeft = IsControlJustPressed(1, 307)
		ArrowRight = IsControlJustPressed(1, 308)
	end
end)

function setVehicleIndiLight(value, ind)
	SetVehicleIndicatorLights(GetVehiclePedIsUsing(PlayerPedId()), value, ind)
end

function sendNuiMessage(arr)
	SendNUIMessage(arr)
end

Citizen.CreateThread(function()
	while true do
		if(inVehicle) or sitInVehicle then
			if PedCar and inVehicleSeat == player then
				sendNuiMessage({
					showhud = true,
					speed = carSpeed,
					max = ((speed * 3.6) + 80)
				})

				if ArrowLeft then -- ArrowL is pressed
					ind.l = not ind.l
					setVehicleIndiLight(0, ind.l)
				end
				if ArrowRight then -- ArrowR is pressed
					ind.r = not ind.r
					setVehicleIndiLight(1, ind.r)
				end

			else
				sendNuiMessage({
					showhud = false
				})
				Citizen.Wait(500)
			end
		else
			sendNuiMessage({
				showhud = false
			})
			Citizen.Wait(500)
		end

		Citizen.Wait(1)
	end
end)

-- Light Hight
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		if(feuPosition == 1 and feuRoute == 0) then
			sendNuiMessage({
				feuPosition = true
			})
		else
			sendNuiMessage({
				feuPosition = false
			})
		end
		
	end
end)

-- Light Low
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		if(feuPosition == 1 and feuRoute == 1) then
			sendNuiMessage({
				feuRoute = true
			})
		else
			sendNuiMessage({
				feuRoute = false
			})
		end
	end
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		if(VehIndicatorLight == 0) then
			sendNuiMessage({
				clignotantGauche = false,
				clignotantDroite = false,
			})
		elseif(VehIndicatorLight == 1) then
			sendNuiMessage({
				clignotantGauche = true,
				clignotantDroite = false,
			})
		elseif(VehIndicatorLight == 2) then
			sendNuiMessage({
				clignotantGauche = false,
				clignotantDroite = true,
			})
		elseif(VehIndicatorLight == 3) then
			sendNuiMessage({
				clignotantGauche = true,
				clignotantDroite = true,
			})
		end
	end
end)

-- Consume fuel factor
Citizen.CreateThread(function()
	while true do
		if(inVehicle) then
			if PedCar and inVehicleSeat == player then
				sendNuiMessage({
					showfuel = true,
					fuel = fuel
				})
			end
		end
		Citizen.Wait(500)
	end
end)