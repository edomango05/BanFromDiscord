--[[
	Roblox to Discord Link! CheckOUT my repo https://github.com/pollovolante/BanFromDiscord/tree/main
	discord : polloarrosto01
]]
local httpService = game:GetService("HttpService")
local DDS = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local BanHammerStore = DDS:GetDataStore("BanHammer", 2) 
local notificationWebhook = ""
local endpoint = "http://ip:3000/ban"
local playersToDestroy = {}
function parser(time)
	local timeObject = {
		m= 60,
		h= 3600,
		g= 86400,
		s=604800
	}
	if time >= 60 and time < 3600 then
		return tostring(time/60).." minutes"
	elseif time >= 3600 and time < 86400 then
		return tostring(time/3600).." hours"
	elseif time >= 86400 and time < 604800 then
		return tostring(time/86400).." days"
	elseif time >= 604800 then
		return tostring(time/604800).." weeks"
	elseif time  == 0 then
		return "undefined"
	end
end
setmetatable(playersToDestroy,{
	__newindex = function(self,index,data)
		spawn(function()
			if  data.playerid then
				local Success, Error = pcall(function() 
					BanHammerStore:SetAsync(
						tostring(data.playerid), 
						httpService:JSONEncode({
							BanStart = tick(), 
							BanDuration = data.time ,
							BanReason = data.reason
						})
					)
					local requestTable = {
						embeds = {
							{
								author = {
									url = "https://www.roblox.com/users/"..data.playerid.."/profile",
									name = data.playerName,
									icon_url = "http://www.roblox.com/Thumbs/Avatar.ashx?x=100&y=100&Format=Png&userid="..data.playerid
								},
								image={
									url="http://www.roblox.com/Thumbs/Avatar.ashx?x=50&y=50&Format=Png&userid="..data.playerid
								},
								title= data.time == 0 and data.playerName.." has been UNBANNED" or data.playerName.." has been BANNED",
								description = data.time == 0 and "unban from discord to roblox" or "ban from discord to roblox" ,
								color =   data.time == 0 and 38650 or 14855741 ,
								fields =  {
									{
										name = "Reason",
										value = data.reason
									},
									{
										name= "Duration",
										value= data.time and parser(data.time) or "Perma"
									},
									{
										name= "Author",
										value= data.author
									}
								},
								thumbnail= {
									url= "https://cdn.discordapp.com/attachments/730851911233831074/839434121419554816/maxw-690.jpg"
								}
							}
						}
					}
					local response = httpService:RequestAsync({
						Url = notificationWebhook, 
						Method = "POST",
						Headers = {
							["Content-Type"] = "application/json" 
						},
						Body = httpService:JSONEncode(requestTable)
					})
					local player = Players:FindFirstChild(data.playerName)
					if player and data.time ~= 0 then
						player:Kick(data.reason) 
					end
				end)
				if not Success then
					warn(Error)
				end
			else
				httpService:RequestAsync({
					Url = notificationWebhook, 
					Method = "POST",
					Headers = {
						["Content-Type"] = "application/json" 
					},
					Body = httpService:JSONEncode({
						embeds = {
							{
								title= "Player not found!",
								description = "moderation failed because player doesn't exist" ,
								fields =  {
									{
										name= "Autore",
										value= data.author
									}
								},
								thumbnail= {
									url= "https://cdn.discordapp.com/attachments/730851911233831074/839434121419554816/maxw-690.jpg"
								}
							}
						}
					})
				})
				warn("Player not found")
			end
		end)
		table.remove(self,index)
	end
})
function GetBanInfo(Player)
	local Success, Result = pcall(function()
		return httpService:JSONDecode(BanHammerStore:GetAsync(tostring(Player.UserId)))
	end)
	if Success and Result then
		if Result.BanDuration and Result.BanStart + Result.BanDuration < tick() then 
			return 
		else
			return Result.BanReason
		end
	end
end
Players.PlayerAdded:Connect(function(plr)
	local IsBanned = GetBanInfo(plr) 
	if IsBanned  then
		plr:Kick(IsBanned) 
	end
end)
coroutine.wrap(function()
	while wait(4) do
		wait()
		local success, result = pcall(function()
			return httpService:RequestAsync({
				Url = endpoint,  
				Method = "GET"
			})
		end)
		if success then
			local data = httpService:JSONDecode(result.Body)
			if #data >0 then
				for i = 1 , #data do 
					playersToDestroy[#playersToDestroy+1]= data[i]
				end
			end
		else
			warn("error fetching")
			wait(2)
		end
	end
end)()