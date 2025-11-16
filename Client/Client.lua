local ESX = exports['es_extended']:getSharedObject()


local PlayerServerID = GetPlayerServerId(PlayerId())
local PlayersInRadio = {}
local firstTimeEventGetsTriggered = true
local RadioChannelsName = {}

RegisterNetEvent('uv-RadioList:Client:SyncRadioChannelPlayers')
AddEventHandler('uv-RadioList:Client:SyncRadioChannelPlayers', function(src, RadioChannelToJoin, PlayersInRadioChannel)
    if firstTimeEventGetsTriggered then
        for i, v in pairs(Config.RadioChannelsWithName) do
            local frequency = tonumber(i)
            local minFrequency, maxFrequency = frequency, frequency + 1
            for index = minFrequency, maxFrequency + 0.0, 0.01 do
                RadioChannelsName[tostring(index)] = tostring(v)
            end
            if frequency ~= 0 then
                RadioChannelsName[tostring(frequency)] = tostring(v)
            end
        end	
        firstTimeEventGetsTriggered = false
    end

    PlayersInRadio = PlayersInRadioChannel
    local totalPlayers = 0
    for _, _ in pairs(PlayersInRadio) do totalPlayers = totalPlayers + 1 end

    if src == PlayerServerID then
        -- 🔹 SELF ACTION
        if RadioChannelToJoin > 0 then
            local radioChannelToJoin = tostring(RadioChannelToJoin)
            HideTheRadioList()

            for _, player in pairs(PlayersInRadio) do
                local isSelf = (player.Source == src)
                SendNUIMessage({
                    radioId   = player.Source,
                    radioName = player.Name,
                    channel   = RadioChannelsName[radioChannelToJoin] or radioChannelToJoin,
                    self      = isSelf
                })
            end

            -- Update count on UI
            SendNUIMessage({ updateCount = true, total = totalPlayers })

            -- ESX notify self join
            exports['uv_notify']:notify(
                "info", -- type (blue/info theme)
                "Radio", -- title
                ("You joined radio %s (%s players)"):format(
                    RadioChannelsName[radioChannelToJoin] or radioChannelToJoin,
                    totalPlayers
                ),
                2000, -- duration (5s)
                ""    -- no sound
            )


            ResetTheRadioList()
        else
            ResetTheRadioList()
            HideTheRadioList()

            -- ESX notify self leave
            exports['uv_notify']:notify(
                "info",             -- type (blue/info style)
                "Radio",            -- title
                "You left the radio", -- message
                2000,               -- duration (5s)
                ""                  -- no sound
            )

        end
    elseif src ~= PlayerServerID then
        -- 🔹 OTHER PLAYER ACTION
        if RadioChannelToJoin > 0 then
            local radioChannelToJoin = tostring(RadioChannelToJoin)

            -- Find player name safely
            local playerName = "Unknown"
            for _, player in pairs(PlayersInRadio) do
                if player.Source == src then
                    playerName = player.Name
                    break
                end
            end

            SendNUIMessage({
                radioId   = src,
                radioName = playerName,
                channel   = RadioChannelsName[radioChannelToJoin] or radioChannelToJoin
            })
            ResetTheRadioList()

            -- Update count on UI
            SendNUIMessage({ updateCount = true, total = totalPlayers })

            -- ESX notify join
            exports['uv_notify']:notify(
                "info", -- theme (blue/info)
                "Radio", -- title
                ("%s joined radio %s (%s players)"):format(
                    playerName,
                    RadioChannelsName[radioChannelToJoin] or radioChannelToJoin,
                    totalPlayers
                ),
                2000, -- duration (5s)
                ""    -- no sound
            )

        else
            SendNUIMessage({ radioId = src }) -- Remove player from radio list

            local newCount = totalPlayers - 1 >= 0 and totalPlayers - 1 or 0
            SendNUIMessage({ updateCount = true, total = newCount })

            -- ✅ Only show leave notification if it's not me leaving
            if src ~= PlayerServerID then
                -- Find player name safely
                local playerName = "Unknown"
                for _, player in pairs(PlayersInRadio) do
                    if player.Source == src then
                        playerName = player.Name
                        break
                    end
                end

                -- ESX notify leave
                exports['uv_notify']:notify(
                    "info", -- theme (blue/info)
                    "Radio", -- title
                    ("%s left the radio (%s players remaining)"):format(
                        playerName,
                        newCount
                    ),
                    2000, -- duration (5s)
                    ""    -- no sound
                )

            end
        end
    end
end)





-- Talking states remain unchanged
RegisterNetEvent('pma-voice:setTalkingOnRadio')
AddEventHandler('pma-voice:setTalkingOnRadio', function(src, talkingState)
    SendNUIMessage({ radioId = src, radioTalking = talkingState })
end)

RegisterNetEvent('pma-voice:radioActive')
AddEventHandler('pma-voice:radioActive', function(talkingState)
    SendNUIMessage({ radioId = PlayerServerID, radioTalking = talkingState })
end)

RegisterNetEvent('uv-RadioList:Client:DisconnectPlayerCurrentChannel')
AddEventHandler('uv-RadioList:Client:DisconnectPlayerCurrentChannel', function()
    ResetTheRadioList()
    HideTheRadioList()
    exports['uv_notify']:notify(
        "info",              -- type (blue/info theme)
        "Radio",             -- title
        "You left the radio",-- message
        2000,                -- time (5s)
        ""                   -- empty = no sound
    )

end)

function ResetTheRadioList()
    PlayersInRadio = {}
end

function HideTheRadioList()
    SendNUIMessage({ clearRadioList = true })
end


--Set talkingState on radio for another radio member = true
RegisterNetEvent('pma-voice:setTalkingOnRadio')
AddEventHandler('pma-voice:setTalkingOnRadio', function(src, talkingState)
	--print("Talking [{"..src.."} "..talkingState.."]")
	SendNUIMessage({ radioId = src, radioTalking = talkingState }) -- Set player talking in radio list
end)

--Set talkingState on radio for self = true
RegisterNetEvent('pma-voice:radioActive')
AddEventHandler('pma-voice:radioActive', function(talkingState)
	--print("Talking [{"..PlayerServerID.."} "..tostring(talkingState).."]")
	SendNUIMessage({ radioId = PlayerServerID, radioTalking = talkingState }) -- Set player talking in radio list
end)

RegisterNetEvent('uv-RadioList:Client:DisconnectPlayerCurrentChannel')
AddEventHandler('uv-RadioList:Client:DisconnectPlayerCurrentChannel', function()
	ResetTheRadioList() -- Delete the PlayersInRadio contents so it opens up memory
	HideTheRadioList()
end)

-- Deletes the PlayersInRadio contents so it opens up memory
function ResetTheRadioList()
	PlayersInRadio = {}
end

-- Hides and closes the radio list
function HideTheRadioList()
	SendNUIMessage({ clearRadioList = true }) -- Clear radio listPlayersInRadio 
end

if Config.LetPlayersChangeVisibilityOfRadioList then
	local visibility = true
	RegisterCommand(Config.RadioListVisibilityCommand,function()
		visibility = not visibility
		SendNUIMessage({ changeVisibility = true, visible = visibility })
	end)
	TriggerEvent("chat:addSuggestion", "/"..Config.RadioListVisibilityCommand, "Show/Hide Radio List")
end

if Config.LetPlayersSetTheirOwnNameInRadio then
	
    TriggerEvent("chat:addSuggestion", "/nameinradio", "Customize your name to be shown in the radio list", {
        { name = 'customized name', help = "Enter your desired name to be shown in the radio list" }
    })

    TriggerEvent("chat:addSuggestion", "/nrm", "Customize your name to be shown in the radio list", {
        { name = 'customized name', help = "Enter your desired name to be shown in the radio list" }
    })
end

