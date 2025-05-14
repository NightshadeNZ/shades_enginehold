
local exitKey = 23        -- F key
local holdTime = 400      -- ms to hold to keep engine on
local isHolding = false
local pressStart = 0
local triggered = false

CreateThread(function()
    while true do
        Wait(10)

        local ped = PlayerPedId()
        if not IsPedInAnyVehicle(ped, false) then
            isHolding = false
            triggered = false
            goto continue
        end

        local veh = GetVehiclePedIsIn(ped, false)
        if GetPedInVehicleSeat(veh, -1) ~= ped then
            isHolding = false
            triggered = false
            goto continue
        end

        if IsControlJustPressed(0, exitKey) then
            pressStart = GetGameTimer()
            isHolding = true
            triggered = false
        end

        if isHolding and not triggered then
            local timeHeld = GetGameTimer() - pressStart

            if timeHeld >= holdTime or IsControlJustReleased(0, exitKey) then
                isHolding = false
                triggered = true

                local keepOn = timeHeld >= holdTime
                local vehNet = VehToNet(veh)

                SetVehicleEngineOn(veh, keepOn, true, true)
                Entity(veh).state.engine_stays_on = keepOn

                TaskLeaveVehicle(ped, veh, 0)

                -- Failsafe: apply engine state again after exit
                CreateThread(function()
                    Wait(200)
                    local vehEntity = NetToVeh(vehNet)
                    if DoesEntityExist(vehEntity) then
                        SetVehicleEngineOn(vehEntity, keepOn, true, true)
                        Entity(vehEntity).state.engine_stays_on = keepOn
                    end
                end)
            end
        end

        ::continue::
    end
end)