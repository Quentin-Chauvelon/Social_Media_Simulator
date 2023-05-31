local TextService = game:GetService("TextService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
local PostModule = require(ServerScriptService:WaitForChild("PostModule"))

local ListCustomPostsRE : RemoteEvent = ReplicatedStorage:WaitForChild("ListCustomPosts")

DataStore2.Combine("SMS", "customPosts")


export type CustomPost = {
	__index : CustomPost,
	player : Player,
	nextId : number,
	posts : {post},
	postModule : PostModule.PostModule,
	listCustomPostConnection : {RBXScriptConnection}?,
    new : (plr : Player, postModule : PostModule.PostModule) -> CustomPost,
	CreatePost : (self : CustomPost, postType : string, text1 : string, text2 : string) -> boolean,
    SavePost : (self : CustomPost, id : number, postType : string, text1 : string, text2 : string) -> boolean,
    DeletePost : (self : CustomPost, id : number) -> nil,
    GetPostWithId : (self : CustomPost, id : number) -> post?,
    GetAllPosts : (self : CustomPost, type : string, id : number?) -> nil,
    OnLeave : (self : CustomPost) -> nil
}

type post = {
    id : number,
    postType : string,
    text1 : string,
    text2 : string
}


local CustomPost : CustomPost = {}
CustomPost.__index = CustomPost


function CustomPost.new(plr : Player, postModule : {})
    local customPost : CustomPost = {}

    customPost.player = plr
    customPost.nextId = 1
    customPost.posts = DataStore2("customPosts", plr):Get({})
    customPost.postModule = postModule

    -- adds the custom posts to each table of posts in the post module so they can be used
    for _,post : post in ipairs(customPost.posts) do
        if post.postType == "post" then
            table.insert(customPost.postModule.posts, function()
                return post.text1
            end)
            
        elseif post.postType == "dialog" then
            table.insert(customPost.postModule.dialogs, function()
                return post.text1, {post.text2}
            end)
        
        else
            table.insert(customPost.postModule.replies, function()
                return post.text1, {post.text2}
            end)
        end
    end

    -- update the number of posts for each table
    customPost.postModule.numberOfPosts = #customPost.postModule.posts
    customPost.postModule.numberOfDialogs = #customPost.postModule.dialogs
    customPost.postModule.numberOfReplies = #customPost.postModule.replies

    -- get the highest id out of all the custom posts and add 1 to get the next id that should be created
    for _,post in ipairs(customPost.posts) do
        if post.id >= customPost.nextId then
            customPost.nextId = post.id + 1
        end
    end

    customPost.listCustomPostConnection = ListCustomPostsRE.OnServerEvent:Connect(function(player : Player)
        if plr == player then
            if customPost.listCustomPostConnection then
                customPost.listCustomPostConnection:Disconnect()
                customPost.listCustomPostConnection = nil
            end

            customPost:GetAllPosts("all")
        end
    end)

    return setmetatable(customPost, CustomPost)
end


--[[
    Creates a new custom post

    @param postType : string, the post type of the post to create (post, reply or dialog)
    @param text1 : string, the first text of the post to create
    @param text2 : string, the second text of the post to create (if postType == post, text2 = text1)
    @return boolean, true if the post could be created, false otherwise
]]--
function CustomPost:CreatePost(postType : string, text1 : string, text2 : string) : boolean
    if postType and typeof(postType) == "string" and text1 and typeof(text1) == "string" and text2 and typeof(text2) == "string" then
        if postType == "post" or postType == "reply" or postType == "dialog" then

            -- can't create more than 10 posts
            if #self.posts >= 10 then
                return false
            end
            
            -- post texts should not be empty nor be more than 200 characters long
            if text1 == "" or #text1 >= 200 or text2 == "" or #text2 >= 200 then
                return false
            end

            -- filter the texts
            local success, _ = pcall(function()
                text1 = TextService:FilterStringAsync(text1, self.player.UserId):GetNonChatStringForBroadcastAsync() or ""
                text2 = TextService:FilterStringAsync(text2, self.player.UserId):GetNonChatStringForBroadcastAsync() or ""
            end)

            if not success then
                return false
            end

            -- create the new post
            local post = {
                id = self.nextId,
                postType = postType,
                text1 = text1,
                text2 = text2
            }

            -- increase the id for the next post we could create
            self.nextId += 1

            -- add the post to the table of posts and save it
            table.insert(self.posts, post)
            DataStore2("customPosts", self.player):Set(self.posts)

            -- add the post to the corresponding table of posts in the post module so that it can be used
            if postType == "post" then
                table.insert(self.postModule.posts, function()
                    return text1
                end)

                -- update the number of post in the table
                self.postModule.numberOfPosts += 1

            elseif post.postType == "dialog" then
                table.insert(self.postModule.dialogs, function()
                    return text1, {text2}
                end)

                self.postModule.numberOfDialogs += 1
            
            else
                table.insert(self.postModule.replies, function()
                    return text1, {text2}
                end)

                self.postModule.numberOfReplies += 1
            end

            self:GetAllPosts("create", post.id)

            return true
        end
    end

    return false
end


--[[
    Edits and saves a custom post

    @param id : number, the id of the post to save
    @param postType : string, the post type of the post to create (post, reply or dialog)
    @param text1 : string, the first text of the post to create
    @param text2 : string, the second text of the post to create (if postType == post, text2 = text1)
    @return boolean, true if the post could be saved, false otherwise
]]--
function CustomPost:SavePost(id : number, postType : string, text1 : string, text2 : string) : boolean
    if id and typeof(id) == "number" and postType and typeof(postType) == "string" and text1 and typeof(text1) == "string" and text2 and typeof(text2) == "string" then
        if postType == "post" or postType == "reply" or postType == "dialog" then

            -- post texts can't be empty nor more than 200 characters long
            if text1 == "" or #text1 >= 200 or text2 == "" or #text2 >= 200 then
                return false
            end

            local oldText1 : string, oldText2 : string = "", ""

            -- get the post with the given id
            local foundPost : boolean = false
            for i : number,post : post in pairs(self.posts) do
                if post.id == id then
                    oldText1 = post.text1
                    oldText2 = post.text2

                    self.posts[i].postType = postType
                    self.posts[i].text1 = text1
                    self.posts[i].text2 = text2

                    foundPost = true
                    break
                end
            end

            if not foundPost then
                return false
            end

            -- save the post in the datastore
            DataStore2("customPosts", self.player):Set(self.posts)
            -- fire the client with the post to give them the updated post
            self:GetAllPosts("modify", id)

            -- add the post to the corresponding post table in the post module
            if postType == "post" then
                for i : number, simplePost : (number) -> string in pairs(self.postModule.posts) do
                    if simplePost() == oldText1 then
                        self.postModule.posts[i] = function()
                            return text1
                        end
                    end
                end

            elseif postType == "dialog" then
                for i : number, dialog : (number) -> (string, {string}) in pairs(self.postModule.dialogs) do
                    local dialogText1, dialogTable2 = dialog()

                    if dialogText1 == oldText1 and #dialogTable2 > 0 and dialogTable2[1] == oldText2 then
                        self.postModule.dialogs[i] = function()
                            return text1, {text2}
                        end
                    end
                end

            else
                for i : number, reply : (number) -> (string, {string}) in pairs(self.postModule.replies) do
                    local replyText1, replyTable2 = reply()

                    if replyText1 == oldText1 and #replyTable2 > 0 and replyTable2[1] == oldText2 then
                        self.postModule.replies[i] = function()
                            return text1, {text2}
                        end
                    end
                end
            end

            return true
        end
    end

    return false
end


--[[
    Deletes a post

    @param id : number, the id of the post to delete
]]--
function CustomPost:DeletePost(id : number)
    if id and typeof(id) == "number" then
        
        for i : number,post in pairs(self.posts) do
            if post.id == id then
                table.remove(self.posts, i)

                DataStore2("customPosts", self.player):Set(self.posts)

                self:GetAllPosts("delete", id)
                break
            end
        end
    end
end


--[[
    Gets the post matching the given id

    @param id : number, the id of the post
    @return post?, the post if it was found, nil otherwise
]]--
function CustomPost:GetPostWithId(id : number) : post?
    for _,post in pairs(self.posts) do
        if post.id == id then
            return post
        end
    end

    return nil
end


--[[
    Fires the client to update the custom post ui based on the last action they did

    @param type : string, the action the player last did
    @param id : number?, the id of the post
]]--
function CustomPost:GetAllPosts(type : string, id : number?)
    if type == "delete" then
        ListCustomPostsRE:FireClient(self.player, type, id)
    elseif type == "create" then
        ListCustomPostsRE:FireClient(self.player, type, id, self:GetPostWithId(id))
    elseif type == "modify" then
        ListCustomPostsRE:FireClient(self.player, type, id, self:GetPostWithId(id))
    else
        ListCustomPostsRE:FireClient(self.player, type, 0, self.posts)
    end
end


function CustomPost:OnLeave()
	setmetatable(self, nil)
	self = nil
end


return CustomPost