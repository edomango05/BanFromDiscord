--[[
	== BanFromDiscord ==

	This is the Roblox script that is put in your ServerScriptService.
	It links the Discord bot to your game.
	Try not to touch anything if you don't know what you are doing.

	GitHub: https://github.com/pollovolante/BanFromDiscord#readme
	Discord: Savastano#0204
]]

--[[
	Please modify the following two lines by following this guide:
	https://github.com/pollovolante/BanFromDiscord#add-roblox-script
]]
local notificationWebhook = ""
local endpoint = "http://ip:3000/ban"

local Http = game:GetService("HttpService")
local Players = game:GetService("Players")
local Datastore = game:GetService("DataStoreService"):GetDataStore("BanHammer", 2)

local playersToDestroy = {}

function timeParser(time)
	if time >= 604800 then
		return tostring(time/604800).." weeks"
	elseif time >= 86400 then
		return tostring(time/86400).." days"
	elseif time >= 3600 then
		return tostring(time/3600).." hours"
	elseif time >= 60 then
		return tostring(time/60).." minutes"
	end
	return time.." seconds"
end

setmetatable(playersToDestroy, {
	__newindex = function(self, index, data)
		coroutine.wrap(function()
			if data.playerid then
				local suc, err = pcall(function()
					Datastore:SetAsync(
						tostring(data.playerid),
						Http:JSONEncode({
							BanStart = tick(),
							BanDuration = data.time,
							BanReason = data.reason
						})
					)
					local requestTable = {embeds = {{
						author = {
							url = "https://www.roblox.com/users/"..data.playerid.."/profile",
							name = data.playerName,
							icon_url = "http://www.roblox.com/Thumbs/Avatar.ashx?x=100&y=100&Format=Png&userid="..data.playerid
						},
						image = {
							url = "http://www.roblox.com/Thumbs/Avatar.ashx?x=420&y=420&Format=Png&userid="..data.playerid
						},
						title = data.time == 0 and "UNBANNED "..data.playerName or "BANNED "..data.playerName,
						description = data.time == 0 and "Unbanned in Roblox through Discord" or "Banned in Roblox through Discord",
						color = data.time == 0 and 38650 or 14855741,
						fields = {
							{
								name = "Reason",
								value = data.reason
							},
							{
								name = "Duration",
								value = data.time and timeParser(data.time) or "Permanent"
							},
							{
								name = "Author",
								value = data.author
							}
						},
						thumbnail = {
							url = "https://cdn.discordapp.com/attachments/730851911233831074/839434121419554816/maxw-690.jpg"
						}
					}}}
					Http:RequestAsync({
						Url = notificationWebhook,
						Method = "POST",
						Headers = {["Content-Type"] = "application/json"},
						Body = Http:JSONEncode(requestTable)
					})
					local player = Players:FindFirstChild(data.playerName)
					if player and data.time >= 0 then
						player:Kick(data.reason)
					end
				end)
				if not suc then
					warn(err)
				end
			else
				Http:RequestAsync({
					Url = notificationWebhook,
					Method = "POST",
					Headers = {["Content-Type"] = "application/json"},
					Body = Http:JSONEncode({embeds = {{
						title = "Player not found!",
						description = "Moderation failed because player doesn't exist",
						fields = {
							{
								name = "Author",
								value = data.author
							}
						},
						thumbnail = {
							url = "https://cdn.discordapp.com/attachments/730851911233831074/839434121419554816/maxw-690.jpg"
						}
					}}})
				})
				warn("BanFromDiscord - Player not found")
			end
		end)()
		table.remove(self, index)
	end
})

function GetBanInfo(Player)
	local suc, res = pcall(function()
		return Http:JSONDecode(Datastore:GetAsync(tostring(Player.UserId)))
	end)
	if suc and res then
		if not res.BanDuration or res.BanStart + res.BanDuration >= tick() then
			return res.BanReason
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	local IsBanned = GetBanInfo(player)
	if IsBanned then
		player:Kick(IsBanned)
	end
end)

while wait(1) do
	local suc, res = pcall(Http.RequestAsync, Http, {
		Url = endpoint,
		Method = "GET"
	})
	if suc then
		for _,v in ipairs(Http:JSONDecode(res.Body)) do
			playersToDestroy[#playersToDestroy+1] = v
		end
	else
		print("BanFromDiscord - Retrying fetch... "..res)
		wait(2)
	end
end
