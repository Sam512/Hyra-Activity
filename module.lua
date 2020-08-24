return function(authId)
	if authId then
		local http = game:GetService("HttpService")
		local Players = game:GetService("Players")
	
		local function httpOn()
			local call = pcall(function()
				game:GetService('HttpService'):GetAsync('http://www.google.com/')
	        end)
			return call
		end
		
		-- 🌐 Check HTTP is Enabled
		if httpOn() then
			
			-- 🔐 Validate the Auth Bearer
			local Info = http:JSONDecode(http:RequestAsync({
				Url = "https://hyra.work/api/activity/info",
				Method = "GET",
				Headers = {
					["Content-Type"] = "application/json",
					["Authorization"] = authId
				},
			}).Body)
			
			if Info.success then
				
				local GroupId = Info.groupId
				local MinRank = Info.minRank
				
				Players.PlayerAdded:Connect(function(Player)
					if Player:GetRankInGroup(GroupId) >= MinRank then
						-- ➕ Send off the join request
						local Request = http:JSONDecode(http:RequestAsync({
							Url = "https://hyra.work/api/activity/start",
							Method = "POST",
							Headers = {
								["Content-Type"] = "application/json",
								["Authorization"] = authId
							},
							Body = http:JSONEncode({
								PlayerId = Player.UserId
							})
						}).Body)
						
						if not Request.success then
							warn("💼 Hyra Activity | Hyra failed to submit join intent for player " .. Player.UserId .. " if problem persists please report to Hyra")
						end
					end
				end)
				
				Players.PlayerRemoving:Connect(function(Player)
					if Player:GetRankInGroup(GroupId) >= MinRank then
						-- ➕ Send off the join request
						local Request = http:JSONDecode(http:RequestAsync({
							Url = "https://hyra.work/api/activity/end",
							Method = "POST",
							Headers = {
								["Content-Type"] = "application/json",
								["Authorization"] = authId
							},
							Body = http:JSONEncode({
								PlayerId = Player.UserId
							})
						}).Body)
						
						if not Request.success then
							warn("💼 Hyra Activity | Hyra failed to submit join intent for player " .. Player.UserId .. " if problem persists please report to Hyra")
						end
					end
				end)
				
			else
				error("💼 Hyra Activity | An invalid auth bearer was present. Please check your AuthId again. Code: " .. Info.error )
			end
			
		else
			error("💼 Hyra Activity | HttpService is NOT ENABLED. Please enable it to make use of this product.")
		end
	end
end
