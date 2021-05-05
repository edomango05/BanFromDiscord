local httpService = game:GetService("HttpService")
local DDS = game:GetService("DataStoreService") 
local Players = game:GetService("Players")
local BanHammerStore = DDS:GetDataStore("BanHammer", 2) 
local webhookLog = "jesus"
local webserverEndpoint = "http://jesus:3000"
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
		return tostring(time/3600).." hour"
	elseif time >= 86400 and time < 604800 then
		return tostring(time/86400).." days"
	elseif time >= 604800 then
		return tostring(time/604800).." weeks"
	end
end
setmetatable(playersToDestroy,{
	__newindex = function(self,index,data)
		local player = Players:FindFirstChild(data.playerName)
		spawn(function()
			if  player then
				local Success, Error = pcall(function() 
					BanHammerStore:SetAsync(
						tostring(Players[data.playerName].UserId), 
						httpService:JSONEncode({BanStart = tick(), 
							BanDuration = data.time ,
							BanReason = data.reason
						})
					)
					local response = httpService:RequestAsync({
						Url = webhookLog, 
						Method = "POST",
						Headers = {
							["Content-Type"] = "application/json" 
						},
						Body = httpService:JSONEncode({
							embeds = {
								{
									title= data.playerName.." has been TEMPBANNED",
									description = "ban from discord to Roblox" ,
									color = 1677797 ,
									fields =  {
										{
											name = "Reason",
											value = data.reason
										},
										{
											name= "Duration",
											value= parser(data.time)
										},{
											name= "Author",
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
					print(response.StatusMessage)
					wait(5)
					Players[data.playerName]:Kick(data.reason) 
				end)

			else
				httpService:RequestAsync({
					Url = webhookLog,, 
					Method = "POST",
					Headers = {
						["Content-Type"] = "application/json" 
					},
					Body = httpService:JSONEncode({
						embeds = {
							{
								title= "Player not found!",
								description = "moderation failed because player isn't in game / doesn't esist" ,
								fields =  {
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
		if Result.BanStart + Result.BanDuration < tick() then 
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
				Url = webserverEndpoint,  
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
