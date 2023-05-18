local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CustomPost = require(script.Parent.Parent:WaitForChild("CustomPost"))
local Utility = require(script.Parent.Parent:WaitForChild("Utility"))
local SaveCustomPostRF : RemoteFunction = ReplicatedStorage:WaitForChild("SaveCustomPost")
local DeleteDataTestRF : RemoteFunction = ReplicatedStorage:WaitForChild("DeleteDataTest")


Utility.new()


local function TableEqual(t1, t2)
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


local function testNoPosts()
    DeleteDataTestRF:InvokeServer("customPosts")
    local customPost = CustomPost.new(Utility)

    assert(TableEqual(customPost.posts, {}) == true, "customPost.posts should be empty but is equal to " .. tostring(customPost.posts))
end


local function testCreateOnePost()
    DeleteDataTestRF:InvokeServer("customPosts")
    local customPost = CustomPost.new(Utility)
    local result = SaveCustomPostRF:InvokeServer("post", "test2", "test2")

    local equalTo = {
        {id = 1, postType = "post", text1 = "test2", text2 = "test2"}
    }
    assert(result == true, "saveCustomPostRF returned false but should return true")
    assert(TableEqual(customPost.posts, equalTo) == true, "customPost.posts should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
end


local function testCreateMultiplePosts()
    DeleteDataTestRF:InvokeServer("customPosts")
    local customPost = CustomPost.new(Utility)
    local result = SaveCustomPostRF:InvokeServer("post", "test2", "test2")
    assert(result == true, "saveCustomPostRF returned false but should return true")

    result = SaveCustomPostRF:InvokeServer("dialog", "test3", "test3")
    assert(result == true, "saveCustomPostRF returned false but should return true")

    result = SaveCustomPostRF:InvokeServer("reply", "test4", "test4")
    assert(result == true, "saveCustomPostRF returned false but should return true")
    
    local equalTo = {
        {id = 2, postType = "post", text1 = "test2", text2 = "test2"},
        {id = 3, postType = "dialog", text1 = "test3", text2 = "test3"},
        {id = 4, postType = "reply", text1 = "test4", text2 = "test4"}
    }
    assert(TableEqual(customPost.posts, equalTo) == true, "customPost.posts should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
end


local function testModifyOnePost()
    DeleteDataTestRF:InvokeServer("customPosts")
    local customPost = CustomPost.new(Utility)
    local result = SaveCustomPostRF:InvokeServer("post", "test2", "test2")
    assert(result == true, "saveCustomPostRF returned false but should return true")

    result = SaveCustomPostRF:InvokeServer("dialog", "test3", "test3")
    assert(result == true, "saveCustomPostRF returned false but should return true")

    result = SaveCustomPostRF:InvokeServer("reply", "test4", "test4")
    assert(result == true, "saveCustomPostRF returned false but should return true")
    
    result = SaveCustomPostRF:InvokeServer("reply", "test5", "test5", 6)
    assert(result == true, "saveCustomPostRF returned false but should return true")

    local equalTo = {
        {id = 5, postType = "post", text1 = "test2", text2 = "test2"},
        {id = 6, postType = "reply", text1 = "test5", text2 = "test5"},
        {id = 7, postType = "reply", text1 = "test4", text2 = "test4"}
    }
    assert(TableEqual(customPost.posts, equalTo) == true, "customPost.posts should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
end


local function testModifyMultiplePosts()
    DeleteDataTestRF:InvokeServer("customPosts")
    local customPost = CustomPost.new(Utility)
    local result = SaveCustomPostRF:InvokeServer("post", "test2", "test2")
    assert(result == true, "saveCustomPostRF returned false but should return true")

    result = SaveCustomPostRF:InvokeServer("dialog", "test3", "test3")
    assert(result == true, "saveCustomPostRF returned false but should return true")

    result = SaveCustomPostRF:InvokeServer("reply", "test4", "test4")
    assert(result == true, "saveCustomPostRF returned false but should return true")
    
    result = SaveCustomPostRF:InvokeServer("reply", "test5", "test5", 9)
    assert(result == true, "saveCustomPostRF returned false but should return true")
    
    result = SaveCustomPostRF:InvokeServer("post", "test7", "test7", 8)
    assert(result == true, "saveCustomPostRF returned false but should return true")
    
    result = SaveCustomPostRF:InvokeServer("reply", "test6", "test5", 9)
    assert(result == true, "saveCustomPostRF returned false but should return true")

    local equalTo = {
        {id = 8, postType = "post", text1 = "test7", text2 = "test7"},
        {id = 9, postType = "reply", text1 = "test6", text2 = "test5"},
        {id = 10, postType = "reply", text1 = "test4", text2 = "test4"}
    }
    assert(TableEqual(customPost.posts, equalTo) == true, "customPost.posts should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
end


local function testDeleteOnePost()
    DeleteDataTestRF:InvokeServer("customPosts")
    local customPost = CustomPost.new(Utility)

    -- had to delete all the posts because can only have 10 on the server at once
    customPost:DeletePost(1)
    customPost:DeletePost(2)
    customPost:DeletePost(3)
    customPost:DeletePost(4)
    customPost:DeletePost(5)
    customPost:DeletePost(6)
    customPost:DeletePost(7)
    customPost:DeletePost(8)
    customPost:DeletePost(9)
    customPost:DeletePost(10)

    local result = SaveCustomPostRF:InvokeServer("post", "test2", "test2")
    assert(result == true, "saveCustomPostRF returned false but should return true")

    result = SaveCustomPostRF:InvokeServer("dialog", "test3", "test3")
    assert(result == true, "saveCustomPostRF returned false but should return true")

    result = SaveCustomPostRF:InvokeServer("reply", "test4", "test4")
    assert(result == true, "saveCustomPostRF returned false but should return true")

    customPost:DeletePost(12)

    local equalTo = {
        {id = 11, postType = "post", text1 = "test2", text2 = "test2"},
        {id = 13, postType = "reply", text1 = "test4", text2 = "test4"}
    }
    assert(TableEqual(customPost.posts, equalTo) == true, "customPost.posts should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
end


local function testDeleteMultiplePosts()
    DeleteDataTestRF:InvokeServer("customPosts")
    local customPost = CustomPost.new(Utility)
    local result = SaveCustomPostRF:InvokeServer("post", "test2", "test2")
    assert(result == true, "saveCustomPostRF returned false but should return true")

    result = SaveCustomPostRF:InvokeServer("dialog", "test3", "test3")
    assert(result == true, "saveCustomPostRF returned false but should return true")

    result = SaveCustomPostRF:InvokeServer("reply", "test4", "test4")
    assert(result == true, "saveCustomPostRF returned false but should return true")

    customPost:DeletePost(14)
    customPost:DeletePost(15)

    local equalTo = {
        {id = 16, postType = "reply", text1 = "test4", text2 = "test4"}
    }
    assert(TableEqual(customPost.posts, equalTo) == true, "customPost.posts should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
end


local function testMultipleOperations()
    DeleteDataTestRF:InvokeServer("customPosts")
    local customPost = CustomPost.new(Utility)

    -- had to delete all the posts because can only have 10 on the server at once
    customPost:DeletePost(11)
    customPost:DeletePost(12)
    customPost:DeletePost(13)
    customPost:DeletePost(14)
    customPost:DeletePost(15)
    customPost:DeletePost(16)

    local result = SaveCustomPostRF:InvokeServer("post", "test2", "test2")
    assert(result == true, "saveCustomPostRF returned false but should return true")

    result = SaveCustomPostRF:InvokeServer("dialog", "test3", "test3")
    assert(result == true, "saveCustomPostRF returned false but should return true")

    result = SaveCustomPostRF:InvokeServer("reply", "test4", "test4")
    assert(result == true, "saveCustomPostRF returned false but should return true")

    customPost:DeletePost(18)

    result = SaveCustomPostRF:InvokeServer("reply", "test2", "test2", 17)
    assert(result == true, "saveCustomPostRF returned false but should return true")

    result = SaveCustomPostRF:InvokeServer("reply", "test8", "test8 jdklfjqslfjqd flqm")
    assert(result == true, "saveCustomPostRF returned false but should return true")

    result = SaveCustomPostRF:InvokeServer("post", "test9", "test9")
    assert(result == true, "saveCustomPostRF returned false but should return true")

    customPost:DeletePost(19)

    local equalTo = {
        {id = 17, postType = "reply", text1 = "test2", text2 = "test2"},
        {id = 20, postType = "reply", text1 = "test8", text2 = "test8 jdklfjqslfjqd flqm"},
        {id = 21, postType = "post", text1 = "test9", text2 = "test9"}
    }
    assert(TableEqual(customPost.posts, equalTo) == true, "customPost.posts should be equal to " .. tostring(equalTo) .." but is equal to " .. tostring(customPost.posts))
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

    print("All tests passed !")
end

test()