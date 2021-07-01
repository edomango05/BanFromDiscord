--[[
	== BanFromDiscord ==
	This is the Roblox script that is put in your ServerScriptService.
	It links the Discord bot to your game.
	Try not to touch anything if you don't know what you are doing.
	GitHub: https://github.com/pollovolante/BanFromDiscord#readme
	Discord: POLLOVOLANTE#4315
	Special thanks for contributors like MarsRon#7602 (github : https://github.com/MarsRon)
]]

--[[
	Please modify the following two lines by following this guide:
	https://github.com/pollovolante/BanFromDiscord#add-roblox-script
]]
local notificationWebhook = ""
local endpoint = "http://ip:3000/ban"

--[[ REQUIRING SERVICES ]]
local httpService = game:GetService("HttpService")
local DDS = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local BanHammerStore = DDS:GetDataStore("BanHammer", 2) --[[ getting datastore with scope 2  ]]

--[[ Inizializing ban queue table ]]
local playersToDestroy = {}

--[[ Parses from seconds ( duration ) to a readable string ]]
function parser(time)
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

--[[ creates a metatable attached to playersToDestroy ]]
setmetatable(playersToDestroy,{
	--[[ Listens for new user to ban ]]
	__newindex = function(self,index,data)
		--[[ makes a thread (cause metamethods cannot yield the main thread) ]]
		spawn(function()
			if data.playerid then
				--[[ protected call to check for errors and for a protected script execution ( without erorrs trow into the thread )...cheking for status ]]	
				local Success, Error = pcall(function() 
					--[[ makes a thread (cause metamethods cannot yield the main thread) ]]
					BanHammerStore:SetAsync(
						tostring(data.playerid), 
						httpService:JSONEncode({
							BanStart = tick(), 
							BanDuration = data.time ,
							BanReason = data.reason
						})
					)
					--[[ Body for the POST request to discord API ( LUA table format ) ]]
					--[[ Check Discord API docs for further info executing webhooks ]]	
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
					--[[ Send a POST request to webhook endpoint ]]	
					local response = httpService:RequestAsync({
						Url = notificationWebhook, 
						Method = "POST",
						Headers = {
							["Content-Type"] = "application/json" --[[ set application/json Content-Type for json format body ]]	
						},
						Body = httpService:JSONEncode(requestTable) --[[ encodes LUA table to Json string format ]]
					})
					local player = Players:FindFirstChild(data.playerName)
					if player and data.time ~= 0 then
						--[[ kicks the player ]]
						player:Kick(data.reason) 
					end
				end)
				--[[ check for error into the pcall() ]]
				if not Success then
					warn(Error)
				end
			else    
				--[[ Player wasn't found case ]]
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
		--[[ removes player from the ban queue (playersToDestroy < --- table ) ]]--
		table.remove(self,index) 
	end
})
--[[ checks if a user is banned or not  ]]--
function GetBanInfo(Player)
	local Success, Result = pcall(function()
		return httpService:JSONDecode(BanHammerStore:GetAsync(tostring(Player.UserId)))
	end)
	--[[ if player was found into datastore... ]]--
	if Success and Result then
		--[[ checks if ban expired with UNIX time... ]]--
		if Result.BanDuration and Result.BanStart + Result.BanDuration < tick() then 
			return 
		else
			return Result.BanReason --[[ if banned it returns the ban reason ]]--
		end
	end
end
Players.PlayerAdded:Connect(function(plr)
	local IsBanned = GetBanInfo(plr) 
	if IsBanned  then --[[ if not null it is equal to BanReason ]]--
		plr:Kick(IsBanned) 
	end
end)
--[[ creates a new coroutine and starts the while loop  ]]--
coroutine.wrap(function()
	--[[ 
		it doesn't spam as it can seem 
		cause roblox uses CURL as HTTP request handler...
		so as default it waits 2 minutes after repeating the 
		loop if no response arrived ( if no one has to be banned ) 
	]]--
	while wait() do
		--[[ 
			sends GET request to Express server and waits for a server side event ( with event emitter ) 
			which contains ban infos ( check the node.js side of the project ) 
		]]--
		local success, result = pcall(function()
			return httpService:RequestAsync({
				Url = endpoint,  
				Method = "GET"
			})
		end)
		--[[ 
			if HTTP request sent code between 200 amd 300...
		]]--
		if success then
			--[[ decodes json body string to LUA table]]--
			local data = httpService:JSONDecode(result.Body)
			--[[ if there is at least 1 ban in queue ...]]--
			if #data >0 then
				--[[ adds each ban player from response data to playersToDestroy ]]--
				for i = 1 , #data do 
					--[[ adds as last element of the array ]]--
					playersToDestroy[#playersToDestroy+1]= data[i]
				end
			end
		else
			warn("fetching...")
			wait(2)
		end
	end
end)()
