export type PlayerModule = {
	player : Player,
	followers : number,
	nextFollowerGoal : number,
	coins : number,
	followersMultiplier : number,
	coinsMultiplier : number,
	plotModule : PlotModule,
	postModule : PostModule,
	upgradeModule : UpgradeModule,
	customPosts : CustomPost,
	playTimeRewards : PlayTimeRewards,
	rebirthModule : RebirthModule,
	caseModule : CaseModule,
	potionModule : PotionModule,
	gamepassModule : GamepassModule,
	maid : Maid,
	new : (plr : Player) -> PlayerModule,
	UpdateFollowersMultiplier : (self : PlayerModule) -> nil,
	UpdateCoinsMultiplier : (self : PlayerModule) -> nil,
	HasEnoughFollowers : (self : PlayerModule, amount : number) -> boolean,
	UpdateFollowersAmount : (self : PlayerModule, amount : number) -> nil,
	SetFollowersAmount : (self : PlayerModule, amount : number) -> nil,
	HasEnoughCoins : (self : PlayerModule, amount : number) -> boolean,
	UpdateCoinsAmount : (self : PlayerModule, amount : number) -> nil,
	SetCoinsAmount : (self : PlayerModule, amount : number) -> nil,
	UpdateAutopostInterval : (self : PlayerModule) -> nil,
	OnLeave : (self : PlayerModule) -> nil
}

export type PlotModule = {
	phone : Model,
	screen : Frame,
	followerGoal : Frame,
	new : () -> PlotModule,
	AssignPlayerToPlot : (self : PlotModule, playerName : string) -> boolean,
	AssignPlot : (self : PlotModule, plr : Player) -> boolean,
	OnLeave : (self : PlotModule) -> nil
}

export type PostModule = {
    nextAutoPost : number,
	nextClickPost : number,
	autoPostInverval : number,
	clickPostInterval : number,
	dialog : {},
	currentState : string,
	level : number,
	postedLastTime : boolean,
	postStates : {},
	posts : {(number) -> string},
	dialogs : {(number) -> (string, {string})},
	replies : {(number) -> (string, {string})},
	numberOfPosts : number,
	numberOfDialogs : number,
	numberOfReplies : number,
	new : (plr : Player) -> PostModule,
	GenerateDialog : (self : PostModule, p : PlayerModule, tableToUse : string) -> nil,
    Post : (self : PostModule, p : PlayerModule) -> nil,
    PlayerClicked : (self : PostModule, p : PlayerModule) -> nil,
    GenerateStateMachine : (self : PostModule) -> nil,
    OnLeave : (self : PostModule) -> nil
}

export type UpgradeModule = {
    upgrades : {upgrade},
    firstFire : boolean?,
    new : (plr : Player) -> UpgradeModule,
	followersMultiplier : number,
    coinsMultiplier : number,
    CanUpgrade : (self : UpgradeModule, p : PlayerModule, upgrade : upgrade, id : number) -> boolean,
    ApplyUpgrade : (self : UpgradeModule, p : PlayerModule, upgrade : upgrade) -> nil,
    ApplyUpgrades : (self : UpgradeModule, p : PlayerModule) -> nil,
    Upgrade : (self : UpgradeModule, p : PlayerModule, id : number) -> {upgrade} | upgrade | nil,
    GetUpgradeWithId : (self : UpgradeModule, id : number) -> upgrade?,
    OnLeave : (self : UpgradeModule) -> nil
}

type upgrade = {
    id : number,
    level : number,
    maxLevel : number,
    baseValue : number,
    upgradeValues : {number},
    costs : {number}
}

export type CustomPost = {
	__index : CustomPost,
	player : Player,
	nextId : number,
	posts : {post},
	postModule : PostModule,
	listCustomPostConnection : {RBXScriptSignal}?,
    new : (plr : Player, postModule : PostModule) -> CustomPost,
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

export type PlayTimeRewards = {
	lastDayPlayed : number,
	timePlayedToday : number,
	nextRewards : {number},
	rewardToCollect : number,
	promise : Promise,
	plr : Player,
	new : (Player) -> PlayTimeRewards,
	GetDataToSave : (self : PlayTimeRewards) -> PlayTimeRewardsStats,
	LoadData : (self : PlayTimeRewards) -> nil,
	StartTimer : (self : PlayTimeRewards) -> nil,
	CollectReward : (self : PlayTimeRewards, p : PlayerModule) -> PlayTimeReward,
	OnLeave : (self : PlayTimeRewards) -> nil
}

type PlayTimeRewardsStats = {
	lastDayPlayed : number,
	timePlayedToday : number
}

type PlayTimeReward = {
	reward : string,
	value : number | string | potion
}

export type RebirthModule = {
    rebirthLevel : number,
    followersMultiplier : number,
    followersNeededToRebirth : number,
    new : (plr : Player) -> RebirthModule,
    TryRebirth : (self : RebirthModule, followers : number, plr : Player) -> boolean,
    Rebirth : (self : RebirthModule, plr : Player) -> boolean,
    UpdateFollowersNeededToRebirth : () -> number
}

export type CaseModule = {
    equippedCase : string,
    speedBoost : number,
    ownedCases : {[string] : boolean},
    dataSent : boolean,
    new : (plr : Player) -> CaseModule,
    EquipCase : (self : CaseModule, p : PlayerModule, color : string?) -> nil,
    ApplySpeedBoost : (self : CaseModule, p : PlayerModule) -> nil,
    UpdatePhoneColor : (self : CaseModule, p : PlayerModule) -> nil,
    BuyCase : (self : CaseModule, color : string, followers : number) -> boolean,
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

export type GamepassModule = {
    boughtCoinsMultiplier : boolean,
    boughtFollowersMultiplier : boolean,
    new : () -> GamepassModule,
    GetCoinsMultiplier : () -> number,
    GetFollowersMultiplier : () -> number,
    OnLeave : (self : GamepassModule) -> nil
}

export type Maid = {
	_tasks : {},
	new : () -> Maid,
	isMaid : (any) -> boolean,
	__index : (any) -> any,
	__newindex : (any, any) -> nil,
	GiveTask : (self : Maid, any) -> number,
	GivePromise : (self : Maid, {}) -> {},
	DoCleaning : (self : Maid) -> nil,
	Destroy : (self : Maid) -> nil
}

export type Promise = {
	_thread : any,
	_source : any,
	_status : any,
	_values : any,
	_valuesLength : any,
	_unhandledRejection : any,
	_queuedResolve : any,
	_queuedReject : any,
	_queuedFinally : any,
	_cancellationHook : any,
	_parent : any,
	_consumers : any,
	new : (any) -> Promise,
	__tostring : (any) -> string,
	defer : (any) -> Promise,
	resolve : (any) -> Promise,
	reject : (any) -> Promise,
	_try : (any) -> Promise,
	try : (any) -> Promise,
	_all : (any) -> Promise,
	all : (any) -> Promise,
	fold : (any) -> any,
	some : (any) -> Promise,
	any : (any) -> Promise,
	any : (any) -> Promise,
	allSettled : (any) -> Promise,
	race : (any) -> Promise,
	each : (any) -> Promise,
	is : (any) -> boolean,
	promisify : (any) -> Promise,
	delay : (number) -> any,
	each : (any) -> Promise,
	retry : (any) -> Promise,
	retryWithDelay : (any) -> Promise,
	fromEvent : (any) -> Promise,
	onUnhandledRejection : (any) -> (() -> ()),
}


export type PotionModule = {
    potionTypes : potionTypes,
    plr : Player,
    activePotions : {potion},
    potionsTimeLeft : Promise,
    followersMultiplier : number,
    coinsMultiplier : number,
    speedBoost : number,
    potionTypes : number,
    new : () -> PotionModule,
    UsePotion : (self : PotionModule, potion : potion, p : PlayerModule) -> nil,
    UseAllActivePotions : (self : PotionModule) -> nil,
    CreatePotion : (self : PotionModule, type : number, value : number, duration : number) -> potion,
    CreateAndUsePotion : (self : PotionModule, type : number, value : number, duration : number, p : PlayerModule) -> nil,
    ApplyPotionsBoosts : (self : PotionModule, type : number, p : PlayerModule) -> nil
}

export type potion = {
    type : number,
    value : number,
    duration : number,
    timeLeft : number
}

type potionTypes = {
    Followers : number,
    Coins : number,
    AutoPostSpeed : number
}

return nil