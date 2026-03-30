--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

--// SETTINGS
local TEAM_CHECK = false

local USE_TEAM_COLOR = true
local ENEMY_COLOR = Color3.fromRGB(255,0,0)
local ALLY_COLOR = Color3.fromRGB(0,255,0)

local FILL_TRANSPARENCY = 0.5
local OUTLINE_TRANSPARENCY = 0

--// STATE
local Highlights = {}

--// COLOR
local function getColor(player)
	if USE_TEAM_COLOR then
		return player.TeamColor.Color
	end

	return (player.Team == LocalPlayer.Team) and ALLY_COLOR or ENEMY_COLOR
end

--// APPLY CHAMS TO CHARACTER
local function applyChams(player, character)
	if not character then return end
	if TEAM_CHECK and player.Team == LocalPlayer.Team then return end

	local highlight = Highlights[player]

	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.FillTransparency = FILL_TRANSPARENCY
		highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

		Highlights[player] = highlight
	end

	highlight.Parent = character
end

--// SETUP PLAYER
local function setupPlayer(player)
	if player == LocalPlayer then return end

	-- when they respawn
	player.CharacterAdded:Connect(function(char)
		-- wait for character to fully load
		char:WaitForChild("Humanoid", 5)
		applyChams(player, char)
	end)

	-- if already spawned
	if player.Character then
		applyChams(player, player.Character)
	end
end

--// REMOVE
local function removePlayer(player)
	if Highlights[player] then
		Highlights[player]:Destroy()
		Highlights[player] = nil
	end
end

--// UPDATE COLORS + TEAM CHECK
RunService.RenderStepped:Connect(function()
	for player, highlight in pairs(Highlights) do
		if not player or not highlight then continue end

		-- remove from teammates
		if TEAM_CHECK and player.Team == LocalPlayer.Team then
			highlight.Parent = nil
			continue
		end

		if player.Character and highlight.Parent then
			local color = getColor(player)
			highlight.FillColor = color
			highlight.OutlineColor = color
		end
	end
end)

--// EVENTS
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(removePlayer)

--// INIT
for _, player in pairs(Players:GetPlayers()) do
	setupPlayer(player)
end
