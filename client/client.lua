local points       = {}
local isCollecting = false

--
-- Threads
--
function startCollectionThread()
    points = {}

    AddTextEntry('pointDevAlert', 'Press ~INPUT_PICKUP~ to save point.')

    CreateThread(function()
        while true do
            Wait(0)

            if not isCollecting then
                return
            end

            BeginTextCommandDisplayHelp('pointDevAlert')
            EndTextCommandDisplayHelp(0, false, false, -1)
        
            if IsControlJustReleased(0, 38) then
                local pedId = PlayerPedId()
                local pCoords = GetEntityCoords(pedId)
                local heading = GetEntityHeading(pedId)

                pCoords = (pCoords - vector3(0.0, 0.0, 1.0))

                local ph = vector4(pCoords.x, pCoords.y, pCoords.z, heading)
        
                table.insert(points, ph)
        
                TriggerEvent('chat:addMessage', {
                    color     = { 255, 0, 0 },
                    multiline = true,
                    args      = {"PointDev", ("Saved Point #%s: vector4(%s, %s, %s, %s)"):format(
                        #points,
                        mathRound(ph.x, 2),
                        mathRound(ph.y, 2),
                        mathRound(ph.z, 2),
                        mathRound(ph.w, 2)
                    )}
                })
            end
        end
    end)
end

--
-- Functions
--

function mathRound(value, numDecimalPlaces)
    if numDecimalPlaces then
        local power = 10^numDecimalPlaces
        return math.floor((value * power) + 0.5) / (power)
    else
        return math.floor(value + 0.5)
    end
end

--
-- Commands
--
RegisterCommand('pointdev', function()
    if not isCollecting then
        isCollecting = true

        startCollectionThread()

        return
    end

    isCollecting = false

    TriggerServerEvent('encore_pointdev:points', points)
end)