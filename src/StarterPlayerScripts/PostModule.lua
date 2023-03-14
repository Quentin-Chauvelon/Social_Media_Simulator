local PostModule = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local PostTemplates = ReplicatedStorage:WaitForChild("PostsTemplates")

local playersThumbnails = {}
local camera = workspace.CurrentCamera

local THUMBNAIL_TYPE = Enum.ThumbnailType.AvatarBust
local THUMBNAIL_SIZE = Enum.ThumbnailSize.Size180x180
local POSTS_ANIMATION_DURATION = 0.2


--[[
	Make invisible all posts that are out of the screen (above)
	
	@param screen : Frame, the screen whose posts to check 
]]--
local function DisableInvisiblePosts(screen : Frame)
	for _,post : Frame in ipairs(screen:GetChildren()) do
		if post.Position.Y.Offset < -70 then
			post.Visible = false
		end
	end
end


--[[
	Reuse a post that would be disabled (out of screen) and whose type matches the type in parameter.
	In which case, we set reset the size, position and visibility of the post.
	Otherwise, if no frames matched the requirements, we create a new one
	
	@param screen : Frame, the screen whose to check for posts to reuse
	@param postType : string, the type of post to use
	@param start : boolean, true if the post is the firts of a dialog or reply (and should be on the right), false otherwise
	@return Frame, the reused or created frame
]]--
local function ReuseOrCreatePost(screen : Frame, postType : string, start : boolean) : Frame
	for _,post : Frame in ipairs(screen:GetChildren()) do
		if not post.Visible and post:GetAttribute("PostType") == postType and post:GetAttribute("Start") == start then
			
			post.Parent = nil
			post.Size = UDim2.new(0,0,0,0)
			post.Position = UDim2.new(0.5,0,0,1570)
			post.Visible = true
			post.Like.Image = "http://www.roblox.com/asset/?id=12526148593"
			post.React.Image = ""
			
			return post
		end
	end
	
	if postType == "post" then
		return PostTemplates.Post:Clone()
	elseif postType == "reply" then
		return PostTemplates.Reply:Clone()
	elseif postType == "dialog" then
		return PostTemplates.Dialog:Clone()
	end
end


--[[
	Tween or move all the posts up to post a new one
	
	@param screen : Frame, the screen whose to move the posts
	@param offset : number, the amount of pixels to move the posts up (y offset)
	@param tween : boolean, indicates if the posts should be tweened up or simply moved, based on
	if the post is visible on the player screen. True to tween, false to move
]]--
local function MoveAllPostsUp(screen : Frame, offset : number, tween : boolean)
	for _,post : Frame in ipairs(screen:GetChildren()) do
		
		if post.Name ~= "LastPost" then
			
			if tween then
				post:TweenPosition(
					post.Position - UDim2.new(0,0,0, offset + 70),
					Enum.EasingDirection.InOut,
					Enum.EasingStyle.Linear,
					POSTS_ANIMATION_DURATION,
					true
				)
			else
				post.Position = UDim2.new(post.Position.X, UDim.new(post.Position.Y.Scale, post.Position.Y.Offset - offset - 70))
			end
		end
	end
end


--[[
	Update all the informations of the post (display name, guild, name, message...) and tweens it or moves it to the screen
	
	@param post : Frame, the post whose to update the information
	@param screen : Frame, the screen on which to post
	@param plr : Player, the player who posts (not necessarily the localPlayer in case of a dialog for example)
	@param message : string, the message to post
	@param tween : boolean, indicates if the posts should be tweened or simply moved, based on
	if the post is visible on the player screen. True to tween, false to move
]]--
local function UpdatePostContent(post : Frame, screen : Frame, plr : Player, message : string, tween : boolean)
	post.Name = "LastPost"

	post.DisplayName.Text = plr.DisplayName
	post.PlayerName.Text = "@" .. plr.Name
	post.Guild.Text = "| GuildName"
	
	if post:GetAttribute("Start") then
		-- move the player display name textLabel based on the length of the player's display name
		post.DisplayName.Position = UDim2.new(1, post.Guild.Position.X.Offset - TextService:GetTextSize(post.Guild.Text, 50, Enum.Font.FredokaOne, Vector2.new(650, 50)).X - 15, 0, 13)
	else
		-- move the guild textLabel based on the length of player's display name
		post.Guild.Position = UDim2.new(0, post.DisplayName.Position.X.Offset + TextService:GetTextSize(post.DisplayName.Text, 55, Enum.Font.FredokaOne, Vector2.new(650, 55)).X + 15, 0, 13)
	end
	 
	post.Message.Text = message
	
	-- change the height of the message textlabel to fit the amount of lines the text takes
	local messageTextSize: Vector2 = TextService:GetTextSize(message, 50, Enum.Font.FredokaOne, Vector2.new(750, 500))
	post.Message.Size = UDim2.new(0.92, 0, 0, messageTextSize.Y)

	local playerThumbnail = playersThumbnails[plr.UserId]
	if not playerThumbnail then

		if #playersThumbnails > 10 then
			-- remove disconnected players from the thumbnails table
			for k,_ in pairs(playersThumbnails) do
				if not Players:FindFirstChild(k) then
					playersThumbnails[k] = nil
				end
			end
		end

		-- add the player to the thumbnails table so that we don't have to use GetUserThumbnailAsync everytime
		coroutine.wrap(function()
			playerThumbnail = Players:GetUserThumbnailAsync(plr.UserId, THUMBNAIL_TYPE, THUMBNAIL_SIZE)
		end)()
		playersThumbnails[plr.UserId] = playerThumbnail
	end

	post.Thumbnail.Image = playerThumbnail or ""
	
	local lastPost :Frame? = screen:FindFirstChild("LastPost")
	
	-- if it's a reply, change the post information of the quoted post
	if post:GetAttribute("PostType") == "reply" then
		local quotedPost : Frame = post:FindFirstChild("Post")
		if quotedPost and lastPost then
			quotedPost.DisplayName.Text = lastPost.DisplayName.Text
			quotedPost.PlayerName.Text = lastPost.PlayerName.Text
			quotedPost.Guild.Text = lastPost.Guild.Text
			
			-- move the guild textLabel based on the length of player's display name
			quotedPost.Guild.Position = UDim2.new(0, quotedPost.DisplayName.Position.X.Offset + TextService:GetTextSize(quotedPost.DisplayName.Text, 55, Enum.Font.FredokaOne, Vector2.new(650, 55)).X + 15, 0, 13)
			
			quotedPost.Message.Text = lastPost.Message.Text
			quotedPost.Message.Size = lastPost.Message.Size
			
			quotedPost.Thumbnail.Image = lastPost.Thumbnail.Image
			
			quotedPost.Size = UDim2.new(quotedPost.Size.X, UDim.new(quotedPost.Size.Y.Scale, 150 + lastPost.Message.Size.Y.Offset))
			
			-- change the message text size so that the message will be resized bigger and allow space for the quoted post
			messageTextSize += Vector2.new(0, quotedPost.Size.Y.Offset)
			
			post.Message.Position = UDim2.new(post.Message.Position.X, UDim.new(post.Message.Position.X, 260 + quotedPost.Message.Size.Y.Offset))
			
			quotedPost.Like.Image = lastPost.Like.Image
			quotedPost.React.Image = lastPost.React.Image
		end
	end

	
	-- rename the last post to post so that the lastPost can be easily identified
	if lastPost then
		lastPost.Name = "Post"
	end
	
	-- move all the other posts up to make room for the new post
	MoveAllPostsUp(screen, 220 + messageTextSize.Y, tween)
	
	post.Parent = screen
	
	if tween then
		-- if the tween can't be played, set the size and position of the post
		if not
			post:TweenSizeAndPosition(
				UDim2.new(0.86, 0, 0, 170 + messageTextSize.Y),
				UDim2.new(0.5, 0, 0, 1570),
				Enum.EasingDirection.InOut,
				Enum.EasingStyle.Linear,
				POSTS_ANIMATION_DURATION,
				true
			)
		then
			post.Size = UDim2.new(0.86, 0, 0, 170 + messageTextSize.Y)
			post.Position = UDim2.new(0.5, 0, 0, 1570)
		end
	else
		post.Size = UDim2.new(0.86, 0, 0, 170 + messageTextSize.Y)
		post.Position = UDim2.new(0.5, 0, 0, 1570)
	end
end



--[[
	Post a new post on the given screen with the information (plr, message) given
	
	@param postType : string, the type of the post
	@param screen : Frame, the screen on which to post
	@param plr : Player, the player who posts (not necessarily the localPlayer in case of a dialog for example)
	@param message : string, the message to post
	@param start : boolean, true if this post if the very first of a dialog or reply, false otherwise
]]--
function PostModule:Post(postType : string, screen : Frame, plr : Player, message : string, start : boolean?)
	
	-- check if the post is visible on the player's screen
	local _, isVisible = camera:WorldToViewportPoint(screen.Parent.Parent.Parent.Position)
	
	if postType == "like" then
		local lastPost : Frame? = screen:FindFirstChild("LastPost")
		if lastPost then
			local like = lastPost.Like
			
			like.Image = "http://www.roblox.com/asset/?id=12554514242"
			
			if isVisible then
				TweenService:Create(
					like,
					TweenInfo.new(
						0.15,
						Enum.EasingStyle.Linear,
						Enum.EasingDirection.InOut,
						0,
						true
					),
					{
						Size = UDim2.new(0,80,0,80),
						Position = UDim2.new(like.Position.X.Scale, like.Position.X.Offset / 2, 0, like.Position.Y.Offset / 2)
					}
				)
				:Play()
			end
		end
		
		return
	end
	
	
	if postType == "react" then
		local lastPost : Frame? = screen:FindFirstChild("LastPost")
		if lastPost then
			local react = lastPost.React
			
			react.Image = message
			
			if isVisible then
				TweenService:Create(
					react,
					TweenInfo.new(
						0.15,
						Enum.EasingStyle.Linear,
						Enum.EasingDirection.InOut,
						0,
						true
					),
					{
						Size = UDim2.new(0,80,0,80),
						Position = UDim2.new(react.Position.X.Scale, react.Position.X.Offset / 2, 1, react.Position.Y.Offset / 2)
					}
				)
				:Play()
			end
		end
		
		return
	end
	
	-- disable all posts that are out of the screen so that they can be reused later (instead of always creating new ones)
	DisableInvisiblePosts(screen)
	
	-- update the information of the post
	if postType == "dialog" and start then
		UpdatePostContent(ReuseOrCreatePost(screen, "dialog", start), screen, plr, message, isVisible)
	elseif postType == "reply" and not start then
		UpdatePostContent(ReuseOrCreatePost(screen, "reply", start), screen, plr, message, isVisible)
	else
		UpdatePostContent(ReuseOrCreatePost(screen, "post", false), screen, plr, message, isVisible)
	end
end

return PostModule