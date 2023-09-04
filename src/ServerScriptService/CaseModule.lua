local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
local Types = require(ServerScriptService:WaitForChild("Types"))

DataStore2.Combine("SMS", "cases")

local caseDetails : {[string] : caseDetail} = {
    Grey = {
        enabled = false,
        speedBoost = 0,
        price = 0,
        color = Color3.fromRGB(146, 145, 148),
        gradient = nil,
        imageUrl = ""
    },
    White = {
        enabled = true,
        speedBoost = 50,
        price = 100,
        color = Color3.fromRGB(255, 255, 255),
        gradient = nil,
        imageUrl = ""
    },
    Black = {
        enabled = true,
        speedBoost = 100,
        price = 250,
        color = Color3.fromRGB(0, 0, 0),
        gradient = nil,
        imageUrl = ""
    },
    Red = {
        enabled = true,
        speedBoost = 150,
        price = 500,
        color = Color3.fromRGB(255, 0, 0),
        gradient = nil,
        imageUrl = ""
    },
    Pink = {
        enabled = true,
        speedBoost = 200,
        price = 1_000,
        color = Color3.fromRGB(255, 66, 246),
        gradient = nil,
        imageUrl = ""
    },
    Orange = {
        enabled = true,
        speedBoost = 250,
        price = 2_500,
        color = Color3.fromRGB(255, 124, 17),
        gradient = nil,
        imageUrl = ""
    },
    Blue = {
        enabled = true,
        speedBoost = 300,
        price = 5_000,
        color = Color3.fromRGB(4, 175, 236),
        gradient = nil,
        imageUrl = ""
    },
    Green = {
        enabled = true,
        speedBoost = 350,
        price = 10_000,
        color = Color3.fromRGB(52, 142, 64),
        gradient = nil,
        imageUrl = ""
    },
    Yellow = {
        enabled = true,
        speedBoost = 400,
        price = 25_000,
        color = Color3.fromRGB(251, 255, 13),
        gradient = nil,
        imageUrl = ""
    },
    PurpleBlue = {
        enabled = true,
        speedBoost = 450,
        price = 50_000,
        color = Color3.fromRGB(151, 103, 247),
        gradient = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(232, 28, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(64, 201, 255))
        },
        imageUrl = ""
    },
    GreenBlue = {
        enabled = true,
        speedBoost = 500,
        price = 100_000,
        color = Color3.fromRGB(45, 239, 188),
        gradient = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 135)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(96, 239, 255))
        },
        imageUrl = ""
    },
    GreenRed = {
        enabled = true,
        speedBoost = 550,
        price = 250_000,
        color = Color3.fromRGB(216, 218, 139),
        gradient = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(178, 249, 162)),
            ColorSequenceKeypoint.new(0.389, Color3.fromRGB(208, 233, 150)),
            ColorSequenceKeypoint.new(0.554, Color3.fromRGB(247, 212, 134)),
            ColorSequenceKeypoint.new(0.713, Color3.fromRGB(244, 157, 129)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(242, 122, 125))
        },
        imageUrl = ""
    },
    Rainbow = {
        enabled = true,
        speedBoost = 600,
        price = 500_000,
        color = Color3.fromRGB(255, 255, 255),
        gradient = nil,
        imageUrl = ""
    },
    Neon = {
        enabled = true,
        speedBoost = 650,
        price = 1_000_000,
        color = Color3.fromRGB(255, 255, 255),
        gradient = nil,
        imageUrl = ""
    },
    Chess = {
        enabled = true,
        speedBoost = 700,
        price = 2_500_000,
        color = Color3.fromRGB(255, 255, 255),
        gradient = nil,
        imageUrl = ""
    },
    Money = {
        enabled = true,
        speedBoost = 750,
        price = 5_000_000,
        color = Color3.fromRGB(255, 255, 255),
        gradient = nil,
        imageUrl = ""
    },
    Animal = {
        enabled = true,
        speedBoost = 800,
        price = 10_000_000,
        color = Color3.fromRGB(255, 255, 255),
        gradient = nil,
        imageUrl = ""
    },
    Emoji = {
        enabled = true,
        speedBoost = 850,
        price = 25_000_000,
        color = Color3.fromRGB(255, 255, 255),
        gradient = nil,
        imageUrl = ""
    },
    Love = {
        enabled = true,
        speedBoost = 900,
        price = 50_000_000,
        color = Color3.fromRGB(255, 255, 255),
        gradient = nil,
        imageUrl = ""
    },
    Quote = {
        enabled = true,
        speedBoost = 950,
        price = 100_000_000,
        color = Color3.fromRGB(255, 255, 255),
        gradient = nil,
        imageUrl = ""
    },
    Nature = {
        enabled = true,
        speedBoost = 1000,
        price = 250_000_000,
        color = Color3.fromRGB(255, 255, 255),
        gradient = nil,
        imageUrl = ""
    },
    Space = {
        enabled = false,
        speedBoost = 2000,
        price = 0,
        color = Color3.fromRGB(13, 6, 52),
        gradient = nil,
        imageUrl = "http://www.roblox.com/asset/?id=14670945265"
    }
}


local defaultSavedCases : savedCases = {
    equippedCase = "Grey",
    ownedCases = {
        Grey = true,
        White = false,
        Black = false,
        Red = false,
        Pink = false,
        Orange = false,
        Blue = false,
        Green = false,
        Yellow = false,
        PurpleBlue = false,
        GreenBlue = false,
        GreenRed = false,
        Rainbow = false,
        Neon = false,
        Chess = false,
        Money = false,
        Animal = false,
        Emoji = false,
        Love = false,
        Quote = false,
        Nature = false,
        Space = false
    }
}


export type CaseModule = {
    equippedCase : string,
    speedBoost : number,
    ownedCases : {[string] : boolean},
    dataSent : boolean,
    new : (plr : Player) -> CaseModule,
    EquipCase : (self : CaseModule, p : Types.PlayerModule, color : string?) -> nil,
    ApplySpeedBoost : (self : CaseModule, p : Types.PlayerModule) -> nil,
    UpdatePhoneColor : (self : CaseModule, p : Types.PlayerModule) -> nil,
    BuyCase : (self : CaseModule, color : string, p : Types.PlayerModule) -> boolean,
    GetOwnedCases : (self : CaseModule) -> savedCases
}

type savedCases = {
    equippedCase : string,
    ownedCases : {
        [string] : boolean
    }
}

type caseDetail = {
    enabled : boolean, -- false if players aren't suppose to buy it
    speedBoost : number,
    price : number,
    color : Color3,
    gradient : ColorSequence?,
    imageUrl : string
}


local CaseModule : CaseModule = {}
CaseModule.__index = CaseModule


function CaseModule.new(plr : Player)
    local caseModule : CaseModule = {}

    local savedCases : savedCases = DataStore2("cases", plr):Get(defaultSavedCases)
    caseModule.equippedCase = savedCases.equippedCase
    caseModule.speedBoost = 0
    caseModule.ownedCases = savedCases.ownedCases
    caseModule.dataSent = false

    return setmetatable(caseModule, CaseModule)
end


--[[
    Called when the player wants to buy a case. Buys the case and equips it

    @param color : string, the color of the case the player wants to buy
    @param p : PlayerModule, the player object representing the player
    @return boolean, true if the purchase was successful, false otherwise
]]--
function CaseModule:BuyCase(color : string, p : Types.PlayerModule) : boolean
    -- validate the color input
    if color and typeof(color) == "string" then

        local caseColorDetails : caseDetail = caseDetails[color]
        -- if the details were found for the given color
        if caseColorDetails then

            -- if the player already owns the case
            if self.ownedCases[color] == true then
                self:EquipCase(p, color)

                return true
            end

            -- if the player has enough folowers to buy the case
            if p.followers >= caseColorDetails.price then

                -- remove the followers from the player
                p:UpdateFollowersAmount(-caseColorDetails.price)

                self.ownedCases[color] = true

                self:EquipCase(p, color)

                return true
            end
        end
    end

    return false
end


--[[
    Returns the equipped and owned cases of the player

    @return savedCases, a table containing information such as the equipped and owned cases
]]--
function CaseModule:GetOwnedCases() : savedCases
    return {
        equippedCase = self.equippedCase,
        ownedCases = self.ownedCases
    }
end


--[[
    Equips a case. Applies the speed boost of the case and changes the phone color

    @param p : PlayerModule, the player object representing the player
    @param color : string, the color of the case the player wants to equip
]]--
function CaseModule:EquipCase(p : Types.PlayerModule, color : string?)
    color = color or self.equippedCase or "Grey"

    if self.ownedCases[color] ~= nil and self.ownedCases[color] == true then
        self.equippedCase = color
        self.speedBoost = caseDetails[color].speedBoost

        -- save the bought case
        DataStore2("cases", p.player):Set({
            equippedCase = self.equippedCase,
            ownedCases = self.ownedCases
        })

        self:ApplySpeedBoost(p)

        self:UpdatePhoneColor(p)
    end
end


--[[
    Applies the speed boost from the case the player has equipped

    @param p : PlayerModule, the player object representing the player
]]--
function CaseModule:ApplySpeedBoost(p : Types.PlayerModule)
    p:UpdateAutopostInterval()
end


--[[
    Updates the phone color to match the equipped case

    @param p : PlayerModule, the player object representing the player
    @param color : string, the color of the case the player has equipped
]]--
function CaseModule:UpdatePhoneColor(p : Types.PlayerModule, color : string?)
    color = color or self.equippedCase or "Grey"

    local backColor : Color3 = caseDetails[color].color
    for _,backPart : BasePart in ipairs(p.plotModule.phone.PhoneModel.Back:GetChildren()) do
        backPart.Color = backColor
    end

    -- if the case has a gradient, display it on the frame
    local gradient : ColorSequence? = caseDetails[color].gradient
    local phoneUIGradientFrame : Frame = p.plotModule.phone.PhoneModel.Case.SurfaceGui.CaseGradient
    if gradient then
        phoneUIGradientFrame.UIGradient.Color = gradient
        phoneUIGradientFrame.Visible = true
    else
        phoneUIGradientFrame.Visible = false
    end

    -- if the case has an image, display it on the frame
    local imageUrl : string = caseDetails[color].imageUrl
    local phoneUIImageFrame : Frame = p.plotModule.phone.PhoneModel.Case.SurfaceGui.CaseImage
    if imageUrl ~= "" then
        phoneUIImageFrame.Image = imageUrl
        phoneUIImageFrame.Visible = true
    else
        phoneUIImageFrame.Visible = false
    end
end


return CaseModule