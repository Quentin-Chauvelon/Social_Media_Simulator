local ServerScriptService = game:GetService("ServerScriptService")
local CustomPost = require(ServerScriptService:WaitForChild("CustomPost"))
local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))

local plr = game:GetService("Players").PlayerAdded:Wait()


local function TableEqual(t1, t2)
    if not t1 or not t2 or typeof(t1) ~= "table" or typeof(t2) ~= "table" then
        return false
    end

    if #t1 ~= #t2 then
        return false
    end

    for i,_ in pairs(t1) do
        if typeof(t1[i]) == "table" then
            if not TableEqual(t1[i], t2[i]) then
                return false
            end
        else
            if t1[i] ~= t2[i] then
                return false
            end
        end
    end

    return true
end


-- assert(TableEqual({}, {}) == true, "compare tables didn't work")
-- assert(TableEqual({1}, {1}) == true, "compare tables didn't work")
-- assert(TableEqual({1, 4, 6, 9}, {1, 4, 6, 9}) == true, "compare tables didn't work")
-- assert(TableEqual({1, 4, 6, 9}, {1, 4, 8, 9}) == false, "compare tables didn't work")
-- assert(TableEqual({1, 4, 6, 9}, {1, 4, 9}) == false, "compare tables didn't work")
-- assert(TableEqual({{id = 2}}, {{id = 1}}) == false, "compare tables didn't work")
-- assert(TableEqual({{id = 2}}, {{id = 2}}) == true, "compare tables didn't work")
-- assert(TableEqual({{id = 2, test = 3}, {id = 5, test = 8}}, {{id = 2, test = 3}, {id = 5, test = 8}}) == true, "compare tables didn't work")
-- assert(TableEqual({{id = 2, test = 3}, {id = 5, test = 8}}, {{id = 2, test = 3}, {id = 6, test = 8}}) == false, "compare tables didn't work") 


local function testNoPosts()
    DataStore2("customPosts", plr):Set(nil)
    local customPost = CustomPost.new(plr)

    assert(TableEqual(customPost.posts, {}) == true, "customPost.posts should be empty but is equal to " .. tostring(customPost.posts))
end


local function testCreateOnePost()
    DataStore2("customPosts", plr):Set(nil)
    local customPost = CustomPost.new(plr)
    customPost:CreatePost("post", "test2", "test2")

    local equalTo = {
        {id = 1, postType = "post", text1 = "test2", text2 = "test2"}
    }
    assert(TableEqual(customPost.posts, equalTo) == true, "customPost.posts should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
    assert(TableEqual(DataStore2("customPosts", plr):Get(nil), equalTo) == true, "DataStore2('customPost') should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
end


local function testCreateMultiplePosts()
    DataStore2("customPosts", plr):Set(nil)
    local customPost = CustomPost.new(plr)
    customPost:CreatePost("post", "test2", "test2")
    customPost:CreatePost("dialog", "test3", "test3")
    customPost:CreatePost("reply", "test4", "test4")

    local equalTo = {
        {id = 1, postType = "post", text1 = "test2", text2 = "test2"},
        {id = 2, postType = "dialog", text1 = "test3", text2 = "test3"},
        {id = 3, postType = "reply", text1 = "test4", text2 = "test4"}
    }
    assert(TableEqual(customPost.posts, equalTo) == true, "customPost.posts should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
    assert(TableEqual(DataStore2("customPosts", plr):Get(nil), equalTo) == true, "DataStore2('customPost') should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
end


local function testModifyOnePost()
    DataStore2("customPosts", plr):Set(nil)
    local customPost = CustomPost.new(plr)
    customPost:CreatePost("post", "test2", "test2")
    customPost:CreatePost("dialog", "test3", "test3")
    customPost:CreatePost("reply", "test4", "test4")
    customPost:SavePost(2, "reply", "test5", "test5")

    local equalTo = {
        {id = 1, postType = "post", text1 = "test2", text2 = "test2"},
        {id = 2, postType = "reply", text1 = "test5", text2 = "test5"},
        {id = 3, postType = "reply", text1 = "test4", text2 = "test4"}
    }
    assert(TableEqual(customPost.posts, equalTo) == true, "customPost.posts should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
    assert(TableEqual(DataStore2("customPosts", plr):Get(nil), equalTo) == true, "DataStore2('customPost') should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
end


local function testModifyMultiplePosts()
    DataStore2("customPosts", plr):Set(nil)
    local customPost = CustomPost.new(plr)
    customPost:CreatePost("post", "test2", "test2")
    customPost:CreatePost("dialog", "test3", "test3")
    customPost:CreatePost("reply", "test4", "test4")
    customPost:SavePost(2, "reply", "test5", "test5")
    customPost:SavePost(1, "post", "test7", "test7")
    customPost:SavePost(2, "reply", "test6", "test5")

    local equalTo = {
        {id = 1, postType = "post", text1 = "test7", text2 = "test7"},
        {id = 2, postType = "reply", text1 = "test6", text2 = "test5"},
        {id = 3, postType = "reply", text1 = "test4", text2 = "test4"}
    }
    assert(TableEqual(customPost.posts, equalTo) == true, "customPost.posts should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
    assert(TableEqual(DataStore2("customPosts", plr):Get(nil), equalTo) == true, "DataStore2('customPost') should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
end


local function testDeleteOnePost()
    DataStore2("customPosts", plr):Set(nil)
    local customPost = CustomPost.new(plr)
    customPost:CreatePost("post", "test2", "test2")
    customPost:CreatePost("dialog", "test3", "test3")
    customPost:CreatePost("reply", "test4", "test4")
    customPost:DeletePost(2)

    local equalTo = {
        {id = 1, postType = "post", text1 = "test2", text2 = "test2"},
        {id = 3, postType = "reply", text1 = "test4", text2 = "test4"}
    }
    assert(TableEqual(customPost.posts, equalTo) == true, "customPost.posts should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
    assert(TableEqual(DataStore2("customPosts", plr):Get(nil), equalTo) == true, "DataStore2('customPost') should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
end


local function testDeleteMultiplePosts()
    DataStore2("customPosts", plr):Set(nil)
    local customPost = CustomPost.new(plr)
    customPost:CreatePost("post", "test2", "test2")
    customPost:CreatePost("dialog", "test3", "test3")
    customPost:CreatePost("reply", "test4", "test4")
    customPost:DeletePost(2)
    customPost:DeletePost(1)

    local equalTo = {
        {id = 3, postType = "reply", text1 = "test4", text2 = "test4"}
    }
    assert(TableEqual(customPost.posts, equalTo) == true, "customPost.posts should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
    assert(TableEqual(DataStore2("customPosts", plr):Get(nil), equalTo) == true, "DataStore2('customPost') should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
end


local function testMultipleOperations()
    DataStore2("customPosts", plr):Set(nil)
    local customPost = CustomPost.new(plr)
    customPost:CreatePost("post", "test2", "test2")
    customPost:CreatePost("dialog", "test3", "test3")
    customPost:CreatePost("reply", "test4", "test4")
    customPost:DeletePost(2)
    customPost:SavePost(1, "reply", "test2", "test2")
    customPost:CreatePost("reply", "test8", "test8 jdklfjqslfjqd flqm")
    customPost:CreatePost("post", "test9", "test9")
    customPost:DeletePost(3)

    local equalTo = {
        {id = 1, postType = "reply", text1 = "test2", text2 = "test2"},
        {id = 4, postType = "reply", text1 = "test8", text2 = "test8 jdklfjqslfjqd flqm"},
        {id = 5, postType = "post", text1 = "test9", text2 = "test9"}
    }
    assert(TableEqual(customPost.posts, equalTo) == true, "customPost.posts should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
    assert(TableEqual(DataStore2("customPosts", plr):Get(nil), equalTo) == true, "DataStore2('customPost') should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
    assert(customPost.nextId == 6, "customPost.nextId should be equal to 6 but is equal to " .. customPost.nextId)
end


local function testLoadingNextId()
    DataStore2("customPosts", plr):Set(nil)
    local customPost = CustomPost.new(plr)
    customPost:CreatePost("post", "test2", "test2")
    customPost:CreatePost("dialog", "test3", "test3")
    customPost:CreatePost("reply", "test4", "test4")
    customPost:DeletePost(2)
    customPost:SavePost(1, "reply", "test2", "test2")
    customPost:CreatePost("reply", "test8", "test8 jdklfjqslfjqd flqm")
    customPost:CreatePost("post", "test9", "test9")
    customPost:DeletePost(3)

    local customPost2 = CustomPost.new(plr)
    assert(customPost2.nextId == 6, "customPost2.nextId should be equal to 6 but is equal to " .. customPost2.nextId)
end


local function test()
    testNoPosts()
    testCreateOnePost()
    testCreateMultiplePosts()
    testModifyOnePost()
    testModifyMultiplePosts()
    testDeleteOnePost()
    testDeleteMultiplePosts()
    testMultipleOperations()
    testLoadingNextId()

    print("All tests passed !")
end

test()