Config = {}

Config.UseRPName = true 							-- If set to true, it uses either esx-legacy or qb-core built-in function to get players' RP name

Config.LetPlayersChangeVisibilityOfRadioList = true	-- Let players to toggle visibility of the list
Config.RadioListVisibilityCommand = "radiolist" 	-- Only works if Config.LetPlayersChangeVisibilityOfRadioList is set to true

Config.LetPlayersSetTheirOwnNameInRadio = true		-- Let players to customize how their name is displayed on the list
Config.ResetPlayersCustomizedNameOnExit = true		-- Only works if Config.LetPlayersSetTheirOwnNameInRadio is set to true - Removes customized name players set for themselves on their server exit
Config.RadioListChangeNameCommand = "nameinradio" 	-- Only works if Config.LetPlayersSetTheirOwnNameInRadio is set to true

Config.RadioChannelsWithName = {
	["0"] = "Admin",
	["1"] = "Police",
	["2"] = "Police",
	["3"] = "Police",
	["4"] = "Ambulance",
	["13"] = "FARX",
	["44"] = "RTX",
	["57"] = "VXT",
	["269"] = "TDC",
	["24.9"] = "ARZ",
	["369"] = "MEOW",
    ["41"] = "ACT",
    ["75.1"] = "Spadikam",
    ["78.9"] = "AK47",
    ["47"] = "ACM",
    ["143"] = "ELD",
    ["444"] = "RGR",
    ["46"] = "SOLX",
    ["916"] = "NARACHI",
    ["500"] = "VORTEX",
}