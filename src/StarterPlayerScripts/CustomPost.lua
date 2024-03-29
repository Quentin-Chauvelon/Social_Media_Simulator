local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = require(script.Parent:WaitForChild("Utility"))

local SaveCustomPostRF : RemoteFunction = ReplicatedStorage:WaitForChild("SaveCustomPost")
local ListCustomPostsRE : RemoteEvent = ReplicatedStorage:WaitForChild("ListCustomPosts")

local lplr = Players.LocalPlayer

local playerGui : PlayerGui = lplr.PlayerGui

local currentCamera : Camera = workspace.CurrentCamera

local customPostTemplate : Frame = ReplicatedStorage:WaitForChild("CustomPostTemplate")

local customPosts : ScreenGui = playerGui:WaitForChild("CustomPosts")
local customPostsButton : ImageButton = playerGui:WaitForChild("Menu"):WaitForChild("SideButtons"):WaitForChild("CustomPostsButton")

local customPostsBackground : Frame = customPosts:WaitForChild("Background")
local customPostsCloseButton : TextButton = customPostsBackground:WaitForChild("Close")
local customPostsCreatePostButton : TextButton = customPostsBackground:WaitForChild("CreatePostContainer"):WaitForChild("CreatePostButton")
-- local customPostsCreatePostPlusText : TextLabel = customPostsCreatePostButton:WaitForChild("PlusText")
-- local customPostsCreatePostPlusTextUIPadding : UIPadding = customPostsCreatePostPlusText:WaitForChild("UIPadding")
local customPostsCreatePostText : TextLabel = customPostsBackground.CreatePostContainer:WaitForChild("CreatePostText")
local customPostsScrollingFrame : ScrollingFrame = customPostsBackground:WaitForChild("ScrollingFrame")

local createPost : Frame = customPosts:WaitForChild("CreatePost")
local createPostPostType : TextButton = createPost:WaitForChild("PostType")
local createPostReplyType : TextButton = createPost:WaitForChild("ReplyType")
local createPostDialogType : TextButton = createPost:WaitForChild("DialogType")
local postContainer : Frame = createPost:WaitForChild("Post")
local postMessage : TextBox = postContainer:WaitForChild("Message")
local dialogContainer : Frame = createPost:WaitForChild("Dialog")
local dialogPost1 : Frame = dialogContainer:WaitForChild("Post1")
local dialogPost2 : Frame = dialogContainer:WaitForChild("Post2")
local dialogPost1Message : TextBox = dialogPost1:WaitForChild("Message")
local dialogPost2Mesage : TextBox = dialogPost2:WaitForChild("Message")
local replyPostContainer : Frame = createPost:WaitForChild("Reply")
local replyPostMessage : TextBox = replyPostContainer:WaitForChild("Message")
local repliedPost : Frame = replyPostContainer:WaitForChild("Post")
local repliedPostMessage : TextBox = repliedPost:WaitForChild("Message")
local createPostCancelButton : TextButton = createPost:WaitForChild("CancelPostButton")
local createPostCreateButton : TextButton = createPost:WaitForChild("CreatePostButton")

local CUSTOM_POSTS_TWEEN_DURATION : number = 0.2
local AlreadyOpenedOnce : boolean = false


--[[
    Loads the guis with the player details (name, thumbnail...)
]]--
local function LoadPlayerDetailsForPost()
    local displayName : string = lplr.DisplayName
    local playerName : string = "@" .. lplr.Name
    local guildName : string = ""
    local thumbnail : string = Players:GetUserThumbnailAsync(lplr.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size352x352)

    postContainer.DisplayName.Text = displayName
    postContainer.PlayerName.Text = playerName
    postContainer.Guild.Text = guildName
    postContainer.Thumbnail.Image = thumbnail

    dialogPost1.DisplayName.Text = displayName
    dialogPost1.PlayerName.Text = playerName
    dialogPost1.Guild.Text = guildName
    dialogPost1.Thumbnail.Image = thumbnail

    dialogPost2.DisplayName.Text = displayName
    dialogPost2.PlayerName.Text = playerName
    dialogPost2.Guild.Text = guildName
    dialogPost2.Thumbnail.Image = thumbnail

    replyPostContainer.DisplayName.Text = displayName
    replyPostContainer.PlayerName.Text = playerName
    replyPostContainer.Guild.Text = guildName
    replyPostContainer.Thumbnail.Image = thumbnail

    repliedPost.DisplayName.Text = displayName
    repliedPost.PlayerName.Text = playerName
    repliedPost.Guild.Text = guildName
    repliedPost.Thumbnail.Image = thumbnail
end


--[[
    Selects and changes the ui for the selected post type

    @param postType : string, the selected post type
]]--
local function selectPostType(postType : string)
    createPostPostType.BackgroundColor3 = Color3.fromRGB(186, 186, 186)
    createPostReplyType.BackgroundColor3 = Color3.fromRGB(186, 186, 186)
    createPostDialogType.BackgroundColor3 = Color3.fromRGB(186, 186, 186)

    createPostPostType.ContextualUIStroke.Color = Color3.fromRGB(52,52,52)
    createPostReplyType.ContextualUIStroke.Color = Color3.fromRGB(52,52,52)
    createPostDialogType.ContextualUIStroke.Color = Color3.fromRGB(52,52,52)

    createPostPostType.UIScale.Scale = 1
    createPostReplyType.UIScale.Scale = 1
    createPostDialogType.UIScale.Scale = 1

    postContainer.Visible = false
    replyPostContainer.Visible = false
    dialogContainer.Visible = false

    if postType == "post" then
        createPostPostType.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
        createPostPostType.ContextualUIStroke.Color = Color3.fromRGB(0,0,0)
        createPostPostType.UIScale.Scale = 1.15
        postContainer.Visible = true

    elseif postType == "reply" then
        createPostReplyType.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
        createPostReplyType.ContextualUIStroke.Color = Color3.fromRGB(0,0,0)
        createPostReplyType.UIScale.Scale = 1.15
        replyPostContainer.Visible = true

    else
        createPostDialogType.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
        createPostDialogType.ContextualUIStroke.Color = Color3.fromRGB(0,0,0)
        createPostDialogType.UIScale.Scale = 1.15
        dialogContainer.Visible = true
    end
end


local function Reset()
    postMessage.Text = ""
    repliedPostMessage.Text = ""
    replyPostMessage.Text = ""
    dialogPost1Message.Text = ""
    dialogPost2Mesage.Text = ""

    customPostsBackground.Visible = true
    createPost.Visible = false
end


export type CustomPost = {
    posts : {post},
    currentPost : post?,
    postListConnections : {RBXScriptConnection},
    utility : Utility.Utility,
    new : (utility : Utility.Utility) -> CustomPost,
    SavePost : (self : CustomPost) -> nil,
    CloseCustomPostGui : (self : CustomPost) -> nil,
    OpenCustomPostGui : (self : CustomPost) -> nil,
    ResizePost : (self : CustomPost, post : Frame) -> nil,
    AddPostFrameToList : (self : CustomPost, post : post) -> nil,
    ListAllPosts : (self : CustomPost, type : string, id : number, posts : {post}) -> nil,
    EditPost : (self : CustomPost, id : number) -> nil,
    DeletePost : (self : CustomPost, id : number) -> nil,

}

type post = {
    id : number,
    postType : string,
    text1 : string,
    text2 : string
}


local CustomPost : CustomPost = {}
CustomPost.__index = CustomPost


function CustomPost.new(utility : Utility.Utility)
    local customPost = {}

    customPost.posts = {}
    customPost.currentPost = nil
    customPost.postListConnections = {}
    customPost.utility = utility

    setmetatable(customPost, CustomPost)

    -- update the list of custom posts when fired from the server
    ListCustomPostsRE.OnClientEvent:Connect(function(type, id, posts)
        customPost:ListAllPosts(type, id, posts)
    end)

    -- store all UIStroke in a table to change them easily later
    local customPostGuiUIStroke : {UIStroke} = {}
    for _,v : Instance in ipairs(customPosts:GetDescendants()) do
        if v:IsA("UIStroke") then
            table.insert(customPostGuiUIStroke, v)
        end
    end
    -- add the UIStroke from RepicatedStorage.CustomPostTemplate as well
    for _,v : Instance in ipairs(customPostTemplate:GetDescendants()) do
        if v:IsA("UIStroke") then
            table.insert(customPostGuiUIStroke, v)
        end
    end

    utility.ResizeUIOnWindowResize(function(viewportSize : Vector2)
        customPostsBackground.Size = UDim2.new(utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 0.8, 0.5), 0, 0.6, 0)

        local customPostsCloseButtonUDim = UDim.new(utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 0.12, 0.15), 0)
        customPostsCloseButton.Size = UDim2.new(customPostsCloseButtonUDim, customPostsCloseButtonUDim)

        -- customPostsCreatePostPlusText.TextSize = customPostsCreatePostButton.AbsoluteSize.Y * 1.5
        -- customPostsCreatePostPlusTextUIPadding.PaddingLeft = UDim.new((customPostsCreatePostPlusText.TextSize - 25) * 0.0011, 0)

        for _,customPostsScrollingFramePost : Frame | UIListLayout in ipairs(customPostsScrollingFrame:GetChildren()) do
            if customPostsScrollingFramePost:IsA("Frame") then
                customPost:ResizePost(customPostsScrollingFramePost)
            end
        end

        local thickness : number = utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 2, 5)
        for _,uiStroke : UIStroke in pairs(customPostGuiUIStroke) do
            uiStroke.Thickness = thickness
        end

        postMessage.TextSize = postMessage.AbsoluteSize.Y / 3
        dialogPost1Message.TextSize = dialogPost1Message.AbsoluteSize.Y / 3 * 2.5
        dialogPost2Mesage.TextSize = dialogPost2Mesage.AbsoluteSize.Y / 3 * 2.5
        replyPostMessage.TextSize = replyPostMessage.AbsoluteSize.Y / 3 * 2.5
        repliedPostMessage.TextSize = repliedPostMessage.AbsoluteSize.Y / 3 * 2.5
    end)

    table.insert(utility.guisToClose, customPostsBackground)

    customPostsButton.MouseButton1Down:Connect(function()
        if not customPostsBackground.Visible then
            customPost:OpenCustomPostGui()
        end
    end)

    return customPost
end


--[[
    Opens a post and allows to update and save it
]]--
function CustomPost:SavePost()
    customPostsBackground.Visible = false
    createPost.Visible = true

    local selectedPostType : string = "post"
    createPostCreateButton.Text = "CREATE"

    -- displays the right post texts
    if self.currentPost then
        selectedPostType = self.currentPost.postType
        createPostCreateButton.Text = "SAVE"

        if selectedPostType == "post" then
            postMessage.Text = self.currentPost.text1
        elseif selectedPostType == "reply" then
            repliedPostMessage.Text = self.currentPost.text1
            replyPostMessage.Text = self.currentPost.text2
        else
            dialogPost1Message.Text = self.currentPost.text1
            dialogPost2Mesage.Text = self.currentPost.text2
        end
    end

    -- displays the right post type
    selectPostType(selectedPostType)

    local postTypeConnection : RBXScriptConnection
    local replyTypeConnection : RBXScriptConnection
    local dialogTypeConnection : RBXScriptConnection
    local createPostCancelConnection : RBXScriptConnection
    local createPostCreateConnection : RBXScriptConnection

    -- change the post type on click
    postTypeConnection = createPostPostType.MouseButton1Down:Connect(function()
        selectedPostType = "post"
        selectPostType(selectedPostType)
    end)

    replyTypeConnection = createPostReplyType.MouseButton1Down:Connect(function()
        selectedPostType = "reply"
        selectPostType(selectedPostType)
    end)

    dialogTypeConnection = createPostDialogType.MouseButton1Down:Connect(function()
        selectedPostType = "dialog"
        selectPostType(selectedPostType)
    end)

    -- on create click, update and save the post with the information entered
    createPostCreateConnection = createPostCreateButton.MouseButton1Down:Connect(function()

        local text1 : TextBox, text2 : TextBox
        if selectedPostType == "post" then
            text1 = postMessage
            text2 = postMessage
        elseif selectedPostType == "reply" then
            text1 = repliedPostMessage
            text2 = replyPostMessage
        else
            text1 = dialogPost1Message
            text2 = dialogPost2Mesage
        end

        -- can't create more than 10 custom posts
        if #self.posts >= 10 then
            self.utility.DisplayError("You can't create more than 10 Posts")
            return
        end

        -- can't create an empty post
        if text1.Text == "" or text2.Text == "" then
            self.utility.DisplayError("You can't create an empty post")
            return
        end

        -- can't create posts more than 200 characters long
        if #text1.Text >= 200 or #text2.Text >= 200 then
            self.utility.DisplayError("Your post length should not exceed 200 characters")
            return
        end

        -- fire the server to update and save the post
        local result : boolean
        if self.currentPost then
            result = SaveCustomPostRF:InvokeServer(selectedPostType, text1.Text, text2.Text, self.currentPost.id)
        else
            result = SaveCustomPostRF:InvokeServer(selectedPostType, text1.Text, text2.Text)
        end

        -- if there was an error saving the post
        if not result then
            if self.currentPost then
                self.utility.DisplayError("Sorry, your post could not be saved. Please try again later.")
            else
                self.utility.DisplayError("Sorry, your post could not be created. Please try again later.")
            end

            return
        end

        postTypeConnection:Disconnect()
        replyTypeConnection:Disconnect()
        dialogTypeConnection:Disconnect()
        createPostCreateConnection:Disconnect()
        createPostCancelConnection:Disconnect()

        Reset()
    end)

    createPostCancelConnection = createPostCancelButton.MouseButton1Down:Connect(function()
        postTypeConnection:Disconnect()
        replyTypeConnection:Disconnect()
        dialogTypeConnection:Disconnect()
        createPostCreateConnection:Disconnect()
        createPostCancelConnection:Disconnect()
        
        Reset()
    end)
end


function CustomPost:CloseCustomPostGui()
    self.utility.CloseGui(customPostsBackground)
end


--[[
    Opens the custom post gui
]]--
function CustomPost:OpenCustomPostGui()

    -- open the gui
    if self.utility.OpenGui(customPostsBackground) then

        -- if the player opened the custom post gui for the first time, set the thumbnail, display, guildname... for new post
        if not AlreadyOpenedOnce then
            AlreadyOpenedOnce = true
            LoadPlayerDetailsForPost()

            -- fire the server to tell it we are ready to receive events
            ListCustomPostsRE:FireServer()
        end
        
        local createPostConnection : RBXScriptConnection
        createPostConnection = customPostsCreatePostButton.MouseButton1Down:Connect(function()
            self.currentPost = nil
            self:SavePost()
        end)

        -- set the close gui connection (only do it if the gui was not already open, otherwise multiple connection exist and it is called multiple times)
        self.utility.SetCloseGuiConnection(customPostsCloseButton, function()
            createPostConnection:Disconnect()
            self:CloseCustomPostGui()
        end)
    end
end


--[[
    Resizes the given post from the custom posts list based on the screen size

    @param post : Frame, the post to resize
]]--
function CustomPost:ResizePost(post : Frame)
    local viewportSizeX : number = currentCamera.ViewportSize.X

    post.Size = UDim2.new(0.95, 0, 0, self.utility.GetNumberInRangeProportionallyDefaultWidth(viewportSizeX, 28, 57))
    post.PostText.TextSize = self.utility.GetNumberInRangeProportionallyDefaultWidth(viewportSizeX, 20, 34)

    local customPostsScrollingFramePostSpacing : number = -self.utility.GetNumberInRangeProportionallyDefaultWidth(viewportSizeX, 10, 24)
    post.PostDelete.Position = UDim2.new(1, customPostsScrollingFramePostSpacing, 0.5, 0)
    post.PostEdit.Position = UDim2.new(1, customPostsScrollingFramePostSpacing * 2 - post.PostDelete.AbsoluteSize.X, 0.5, 0)
    post.PostText.Size = UDim2.new(1, customPostsScrollingFramePostSpacing * 3 - post.PostDelete.AbsoluteSize.X * 2 - 10, 1, 0)
end


--[[
    Adds a post to the frame's list gui

    @param post : post, the post to add to the list
]]--
function CustomPost:AddPostFrameToList(post : post)
    local id : number = post.id

    local customPost = customPostTemplate:Clone()
    customPost.Id.Value = id
    customPost.PostText.Text = post.text1
    
    self.postListConnections[id] = {}
    table.insert(self.postListConnections[id], customPost.PostEdit.MouseButton1Down:Connect(function()
        self:EditPost(id)
    end))
    
    table.insert(self.postListConnections[id], customPost.PostDelete.MouseButton1Down:Connect(function()
        self:DeletePost(id)
    end))
    
    customPost.Parent = customPostsScrollingFrame
    self:ResizePost(customPost)
end


--[[
    Lists all the posts based on the last action the player did (create, delete...)

    @param type : string, the action the player last did
    @param id : number, the id of the post
    @param posts : {post}, a table of the posts to list
]]--
function CustomPost:ListAllPosts(type : string, id : number, posts : {post})
    
    -- remove the post corresponding to the given id
    if type == "delete" then
        for _,post : Frame | UIListLayout in ipairs(customPostsScrollingFrame:GetChildren()) do
            if post:IsA("Frame") and post.Id.Value == id then
                
                for i : number, post : post in pairs(self.posts) do
                    if post.id == id then
                        table.remove(self.posts, i)
                        break
                    end
                end

                post:Destroy()

                if self.postListConnections[id] then
                    self.postListConnections[id][1]:Disconnect()
                    self.postListConnections[id][2]:Disconnect()
                    self.postListConnections[id] = nil
                end
            end
        end

    -- add the created post to the list
    elseif type == "create" then
        if posts and posts.id and posts.id == id then
            table.insert(self.posts, posts)

            self:AddPostFrameToList(posts)
        end

    -- modify the post with the given id
    elseif type == "modify" then
        if posts and posts.id and posts.id == id then

            for _,post : post in pairs(self.posts) do
                if post.id == id then
                    post.postType = posts.postType
                    post.text1 = posts.text1
                    post.text2 = posts.text2
                    break
                end
            end

            local customPost
            for _,post : Frame | UIListLayout in ipairs(customPostsScrollingFrame:GetChildren()) do
                if post:IsA("Frame") and post.Id.Value == id then
                    customPost = post
                    break
                end
            end

            if customPost then
                customPost.PostText.Text = posts.text1
            end
        end

    -- list all posts
    else
        self.posts = posts

        -- destroy all the existing posts
        for _,post : Frame | UIListLayout in ipairs(customPostsScrollingFrame:GetChildren()) do
            if post:IsA("Frame") then
                post:Destroy()
            end
        end

        for _,post : post in pairs(posts) do
            self:AddPostFrameToList(post)
        end
    end

    customPostsCreatePostText.Text = "Create post (" .. tostring(#self.posts) .. "/10)"
end


--[[
    Edits the post with the given id

    @param id : number, the id of the post to edit
]]--
function CustomPost:EditPost(id : number)
    for _,post : post in pairs(self.posts) do
        if post.id == id then
            self.currentPost = post
            self:SavePost()
            break
        end
    end
end


--[[
    Deletes the post with the given it

    @param id : number, the id of the post to delete
]]--
function CustomPost:DeletePost(id : number)
    SaveCustomPostRF:InvokeServer(nil, nil, nil, id)
end


return CustomPost