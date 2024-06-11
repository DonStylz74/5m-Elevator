local NUI = require 'client.modules.nui'
local Utils = require 'client.modules.utils'
local TP = require 'client.modules.teleport'

local resourceName = GetCurrentResourceName()
local currentElevator, isMoving = nil, false

AddEventHandler(("%s:openElevator"):format(resourceName), function (data)
    local data = data.data
    DebugPrint('[^2openElevator^7]', data)
    currentElevator = data.elevator
    NUI.SendReactMessage('setFloors', {
        currentFloor = data.floor,
        floorButtons = Utils.FormatFloors(Config.Elevators?[data.elevator]?.floors)
    })
    NUI.ToggleNui(true)
end)

RegisterCommand('show-nui', function()
    NUI.ToggleNui(true)
    DebugPrint('Show NUI frame')
end)

RegisterNUICallback('hideFrame', function(_, cb)
    NUI.ToggleNui(false)
    currentElevator = nil
    DebugPrint('Hide NUI frame')
    cb({})
end)

RegisterNUICallback('setNewFloor', function(data, cb)

    if isMoving then return cb(false) end

    isMoving = true
    DebugPrint('Data received from NUI', json.encode(data))

    local success = Citizen.Await(TP.GoToNewFloor(currentElevator, data.clickedFloor))

    isMoving = false
    cb(success)

    SetTimeout(250, function ()
        NUI.ToggleNui(false)
    end)
end)