
local Update_Interval_ms = 100

VSpeedometer = {
    ShowForPassengers = true,
}
Package.Export("VSpeedometer", VSpeedometer)

VSpeedometer.VSpeedometer_UI = WebUI(
    "VSpeedometer UI",
    "file://ui/index.html",
    WidgetVisibility.Hidden
)

local function GetLocalCharacter()
    local ply = Client.GetLocalPlayer()
    if ply then
        return ply:GetControlledCharacter()
    end
end

local function GetCurrentVehicleSpeedInKmH()
    local char = GetLocalCharacter()
    if char then
        local veh = char:GetVehicle()
        if veh then
            local vel = veh:GetVelocity()
            local size = vel:Size()
            return size*0.036
        end
    end
end


local function CharacterEnterVehicle(self, char, seat)
    if self:IsValid() then
        if (seat == 0 or VSpeedometer.ShowForPassengers) then
            local local_char = GetLocalCharacter()
            if (local_char and local_char:IsValid()) then
                if char == local_char then
                    VSpeedometer.VSpeedometer_UI:SetVisibility(WidgetVisibility.VisibleNotHitTestable)
                end
            end
        end
    end
end
VehicleWheeled.Subscribe("CharacterEnter", CharacterEnterVehicle)
VehicleWater.Subscribe("CharacterEnter", CharacterEnterVehicle)

local function CharacterLeaveVehicle(self, char)
    if self:IsValid() then
        local local_char = GetLocalCharacter()
        if (local_char and local_char:IsValid()) then
            if char == local_char then
                VSpeedometer.VSpeedometer_UI:SetVisibility(WidgetVisibility.Hidden)
            end
        end
    end
end
VehicleWheeled.Subscribe("CharacterLeave", CharacterLeaveVehicle)
VehicleWater.Subscribe("CharacterLeave", CharacterLeaveVehicle)

local function PlayerLoaded(local_player)
    local char = local_player:GetControlledCharacter()
    if char and char:IsValid() then
        local veh = char:GetVehicle()
        if veh and veh:IsValid() then
            local driver = veh:GetPassenger(0)
            if ((driver == char) or VSpeedometer.ShowForPassengers) then
                VSpeedometer.VSpeedometer_UI:SetVisibility(WidgetVisibility.VisibleNotHitTestable)
            end
        end
    end
end
if Client.GetLocalPlayer() then
    PlayerLoaded(Client.GetLocalPlayer())
else
    Client.Subscribe("SpawnLocalPlayer", PlayerLoaded)
end

local function ReloadVehicleSpawn(veh)
    if veh:IsValid() then
        local char = veh:GetPassenger(0)
        if char and char:IsValid() then
            local ply = char:GetPlayer()
            if ply:IsValid() and ply == Client.GetLocalPlayer() then
                PlayerLoaded(Client.GetLocalPlayer())
                VehicleWheeled.Unsubscribe("Spawn", ReloadVehicleSpawn)
                VehicleWater.Unsubscribe("Spawn", ReloadVehicleSpawn)
            end
        end
    end
end
VehicleWheeled.Subscribe("Spawn", ReloadVehicleSpawn)
VehicleWater.Subscribe("Spawn", ReloadVehicleSpawn)

Timer.SetInterval(function()
    if VSpeedometer.VSpeedometer_UI then
        if (VSpeedometer.VSpeedometer_UI:GetVisibility() == WidgetVisibility.VisibleNotHitTestable) then
            local speed = GetCurrentVehicleSpeedInKmH()
            if speed then
                VSpeedometer.VSpeedometer_UI:CallEvent("UpdateSpeed", speed)
            end
        end
    end
end, Update_Interval_ms)