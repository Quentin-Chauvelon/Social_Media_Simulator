export type PlayerModule = {
	player : Player,
    isLoaded : boolean,
    isPremium : boolean,
	followers : number,
	nextFollowerGoal : number,
	coins : number,
	followersMultiplier : number,
	coinsMultiplier : number,
    lastPlayed : number,
	alreadyPlayedToday : boolean,
	totalTimePlayed : number,
    getXFollowersQuest : (followers : number) -> nil | nil,
    getXCoinsQuest : (coins : number) -> nil | nil,
	plotModule : PlotModule,
	postModule : PostModule,
	upgradeModule : UpgradeModule,
	customPosts : CustomPost,
	playTimeRewards : PlayTimeRewards,
	rebirthModule : RebirthModule,
	caseModule : CaseModule,
	potionModule : PotionModule,
	petModule : PetModule,
    friendsModule : FriendsModule,
	groupModule : GroupModule,
    questModule : QuestModule,
	gamepassModule : GamepassModule,
    spinningWheelModule : SpinningWheelModule,
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
    popSound : Sound,
	new : () -> PlotModule,
	AssignPlayerToPlot : (self : PlotModule, playerName : string) -> boolean,
	AssignPlot : (self : PlotModule, plr : Player) -> boolean,
	OnLeave : (self : PlotModule) -> nil
}

export type PostModule = {
    nextAutoPost : number,
	nextClickPost : number,
	autoPostInterval : number,
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
    autoClickerPromise : Promise,
    postXTimesQuest : () -> nil | nil,
	new : (plr : Player) -> PostModule,
	GenerateDialog : (self : PostModule, p : PlayerModule, tableToUse : string) -> nil,
    Post : (self : PostModule, p : PlayerModule) -> nil,
    PlayerClicked : (self : PostModule, p : PlayerModule) -> nil,
    GenerateStateMachine : (self : PostModule) -> nil,
    StartAutoClicker : (self : PostModule, p : PlayerModule) -> nil,
    OnLeave : (self : PostModule) -> nil
}

export type UpgradeModule = {
    upgrades : {upgrade},
    firstFire : boolean?,
    new : (plr : Player) -> UpgradeModule,
	followersMultiplier : number,
    coinsMultiplier : number,
    upgradeOnceQuest : () -> nil | nil,
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
    gamePasses : GamePasses,
    ownedGamePasses : {[GamePasses] : ownedGamePass},
    new : () -> GamepassModule,
    PlayerBoughtGamePass : (self : GamepassModule, gamePassId : number, p : PlayerModule) -> nil,
    UserOwnsGamePass : (self : GamepassModule, gamePassId : number) -> (boolean, boolean),
    PlayerOwnsGamePass : (self : GamepassModule, gamePassId : number) -> boolean,
    LoadOwnedGamePasses : (self : GamepassModule) -> nil,
    GetCoinsMultiplier : (self : GamepassModule) -> number,
    GetFollowersMultiplier : (self : GamepassModule) -> number,
    OnLeave : (self : GamepassModule) -> nil
}

type GamePasses = {
    SpaceCase : number,
    Open3Eggs : number,
    Open6Eggs : number,
    EquipFourMorePets : number,
    PlusHundredAndFiftyInventoryCapacity : number
}

type ownedGamePass = {
    loaded : boolean,
    owned : boolean
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
    AutoPostSpeed : number,
    FollowersCoins : number
}


export type PetModule = {
    ownedPets : {pet},
    followersMultiplier : number,
    currentlyEquippedPets : number,
    maxEquippedPets : number,
    inventoryCapacity : number,
    nextId : number,
    luck : number,
    magicUpgradePetId : number,
    plr : Player,
    openOneEggQuest : () -> nil | nil,
    getARarePetQuest : () -> nil | nil,
    craftOnePetIntoBigQuest : () -> nil | nil,
    craftOnePetIntoHugeQuest : () -> nil | nil,
    upgradeOnePetToShinyQuest : () -> nil | nil,
    upgradeOnePetToRainbowQuest : () -> nil | nil,
    new : (plr : Player) -> PetModule,
    IsPetInventoryFull : (self : PetModule) -> boolean,
    AddPetToInventory : (self : PetModule, pet : pet) -> nil,
    CreatePetAttachments : (self : PetModule) -> nil,
    RotateAttachmentsTowardsPlayer : (self : PetModule, target : Vector3) -> nil,
    GetPetFromPetId : (self : PetModule, petId : number) -> pet?,
    OpenEgg : (self : PetModule, eggId : number) -> pet,
    OpenEggs : (self : PetModule, p : PlayerModule, eggId : number, numberOfEggsToOpen : number) -> pet,
    CanEquipPet : (self : PetModule) -> boolean,
    EquipPet : (self : PetModule, id : number, updateFollowersMultiplier : boolean) -> (boolean, boolean),
    AddPetToCharacter : (self : PetModule, pet : pet) -> nil,
    RemovePetFromCharacter : (self : PetModule, pet : pet) -> nil,
    LoadEquippedPets : (self : PetModule) -> nil,
    EquipBest : (self : PetModule) -> {number},
    UnequipAllPets : (self : PetModule) -> nil,
    DeletePet : (self : PetModule, id : number) -> boolean,
    DeleteUnequippedPets : (self : PetModule) -> {pet},
    CraftPet : (self : PetModule, id : number) -> boolean,
    UpgradePet : (self : PetModule, pet : pet, upgradeType : number, numberOfPetsInMachine : number) -> boolean,
    MagicUpgradePet : (self : PetModule) -> boolean,
    CalculateActiveBoost : (self : PetModule, pet : pet) -> number,
    UpdateFollowersMultiplier : (self : PetModule) -> nil
}

type pet = {
	identifier : string,
    name : string,
    rarity : number,
    size : number,
    upgrade : number,
    baseBoost : number,
    activeBoost : number,
    equipped : boolean
}


export type FriendsModule = {
    numberOfFriendsOnline : number,
    followersMultiplier : number,
    coinsMultiplier : number,
    plr : Player,
    new : (plr : Player) -> FriendsModule,
    FriendJoined : (self : FriendsModule) -> nil,
    FriendLeft : (self : FriendsModule) -> nil,
    GetOnlineFriends : (self : FriendsModule) -> {string},
    OnLeave : (self : FriendsModule) -> nil
}


export type GroupModule = {
    hasCollectedRewardChest : boolean,
    isInGroupLoaded : boolean,
    isInGroup : boolean,
    plr : Player,
    new : (p : PlayerModule) -> GroupModule,
    CanCollectRewardChest : (self : GroupModule) -> boolean,
    CollectRewardChest : (self : GroupModule, p : PlayerModule) -> nil,
    IsInGroup : (self : GroupModule) -> boolean,
    OnLeave : (self : GroupModule) -> nil
}


export type QuestModule = {
    quests : {Quest},
    questStreak : QuestStreak,
    averageFollowersPerSecond : number,
    averageCoinsPerSecond : number,
    playedTodayPromise : Promise,
    updateUIProgress : boolean,
    plr : Player,
    new : (p : PlayerModule) -> QuestModule,
    LoadQuests : (self : QuestModule, p : PlayerModule) -> nil,
    SaveQuests : (self : QuestModule, plr : Player) -> nil,
    CreateQuest : (self : QuestModule, p : PlayerModule) -> Quest,
    AddQuestsListeners : (self : QuestModule, p : PlayerModule, quest : Quest) -> Quest,
    DeleteQuest : (self : QuestModule, p : PlayerModule, id : number) -> nil,
    DeleteAllQuests : (self : QuestModule, p : PlayerModule) -> nil,
    IsCompleted : (self : QuestModule, id : number) -> boolean,
    AreAllQuestsCompleted : (self : QuestModule) -> boolean,
    CompleteQuest : (self : QuestModule, p : PlayerModule, id : number) -> nil,
    HasClaimedReward : (self : QuestModule, id : number) -> boolean,
    ClaimReward : (self : QuestModule, p : PlayerModule, id : number) -> boolean,
    AreAllQuestsClaimed : (self : QuestModule) -> boolean,
    GetPositionOfQuestWithId : (self : QuestModule, id : number) -> number,
    FollowersToCoins : (self : QuestModule, followers : number) -> number,
    CoinsToFollowers : (self : QuestModule, coins : number) -> number,
    AbbreviateNumber : (self : QuestModule, number : number) -> number,
    OnLeave : (self : QuestModule) -> nil
}

type Quest = {
    id : number,
    name : string,
    questType : QuestType,
    progress : number,
    target : number,
    status : QuestStatus,
    rewardValue : number,
    rewardType : QuestRewardType
}

type QuestType = {
    GetXFollowers : number,
    GetXCoins : number,
    UpgradeOnce : number,
    PlayXMinutesToday : number,
    OpenOneEgg : number,
    GetARarePet : number,
    PostXTimes : number,
    CraftOnePetIntoBig : number,
    CraftOnePetIntoHuge : number,
    UpgradeOnePetToShiny : number,
    UpgradeOnePetToRainbow : number
}

type QuestRewardType = {
    Followers : number,
    Coins : number
}

type QuestStatus = {
    Pending : number,
    Completed : number,
    Claimed : number
}

type QuestStreak = {
    lastDayCompleted : number,
    streak : number
}


type Event = {
    id : number,
    name : string,
    duration : number,
    startEvent : () -> nil,
    backgroundColor : Color3,
    borderColor : Color3,
    progressBarColor : Color3,
    eventIcon : string
}

export type EventsModule = {
    eventInProgress : boolean,
    nextEvent : Event,
    timeBeforeNextEvent : number,
    rewards : {[string] : number},
    eventsLoopPromise : Promise,
    new : () -> EventsModule,
    StartEventsLoop : () -> nil,
    GetNextEvent : () -> Event,
    SpawnCoin : (coin : Part) -> nil,
    CollectedCoin : (plr : Player) -> nil,
    StartRainEvent : (coin : Part) -> nil,
    StartFollowersRain : () -> nil,
    StartCoinsRain : () -> nil
}


type WheelReward = {
    id : number,
    petId : number,
    probability : number
}

type Wheel = {
    id : number,
    rewards : {WheelReward},
}

export type SpinningWheelModule = {
    spinning : boolean,
    currentWheel : Wheel,
    nextReward : WheelReward?,
    normalFreeSpinsLeft : number,
    crazyFreeSpinsLeft : number,
    crazyFreeSpinsUsed : number,
    plr : Player,
    new : (plr : Player) -> SpinningWheelModule,
    GetRandomReward : (self: SpinningWheelModule) -> WheelReward,
    SpinWheel : (self: SpinningWheelModule) -> boolean,
    WheelSpinEnded : (self: SpinningWheelModule, p : PlayerModule) -> nil,
    SwitchWheel : (self: SpinningWheelModule, wheel : string) -> nil,
    FreeSpinWheel : (self: SpinningWheelModule) -> nil,
    HasFreeSpin : (self: SpinningWheelModule) -> boolean,
    GiveFreeSpin : (self: SpinningWheelModule, wheel : string) -> nil,
    UseFreeSpin : (self: SpinningWheelModule) -> nil,
}

return nil