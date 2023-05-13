local Types = {}

-- type Impl = {
-- 	__index: Impl,
-- 	new: (name: string, balance: number) -> Account,
-- 	deposit: (self: Account, credit: number) -> (),
-- 	withdraw: (self: Account, debit: number) -> (),
-- 	name: string,
-- 	balance: number
-- }


-- local Account : Impl = {}
-- Account.__index = Account

-- export type Account = typeof(setmetatable({}, {}))

-- function Account.new(name: string, balance: number)
-- 	local self = setmetatable({}, Account)
-- 	self.name = name
-- 	self.balance = balance
-- 	return self
-- end

-- function Account:withdraw(debit)
-- 	self.balance -= debit
-- end

-- function Account:deposit(credit)
-- 	self.balance += credit
-- end

-- return Account


-- export type Account = {
-- 	__index: Account,
-- 	new: (name: string, balance: number) -> Account,
-- 	deposit: (self: Account, credit: number) -> (),
-- 	withdraw: (self: Account, debit: number) -> (),
-- 	name: string,
-- 	balance: number
-- }

-- export type Maid = {
-- 	_tasks : {},
-- 	new : () -> Maid,
-- 	isMaid : (any) -> boolean,
-- 	__index : (any) -> any,
-- 	__newindex : (any, any) -> nil,
-- 	GiveTask : (any) -> number,
-- 	GivePromise : (Promise) -> Promise,
-- 	DoCleaning : () -> nil,
-- 	Destroy : () -> nil
-- }

-- export type Promise = {
-- 	_thread : any,
-- 	_source : any,
-- 	_status : any,
-- 	_values : any,
-- 	_valuesLength : any,
-- 	_unhandledRejection : any,
-- 	_queuedResolve : any,
-- 	_queuedReject : any,
-- 	_queuedFinally : any,
-- 	_cancellationHook : any,
-- 	_parent : any,
-- 	_consumers : any,
-- 	new : (any) -> Promise,
-- 	__tostring : (any) -> string,
-- 	defer : (any) -> Promise,
-- 	resolve : (any) -> Promise,
-- 	reject : (any) -> Promise,
-- 	_try : (any) -> Promise,
-- 	try : (any) -> Promise,
-- 	_all : (any) -> Promise,
-- 	all : (any) -> Promise,
-- 	fold : (any) -> any,
-- 	some : (any) -> Promise,
-- 	any : (any) -> Promise,
-- 	any : (any) -> Promise,
-- 	allSettled : (any) -> Promise,
-- 	race : (any) -> Promise,
-- 	each : (any) -> Promise,
-- 	is : (any) -> boolean,
-- 	promisify : (any) -> Promise,
-- 	delay : (number) -> any,
-- 	each : (any) -> Promise,
-- 	retry : (any) -> Promise,
-- 	retryWithDelay : (any) -> Promise,
-- 	fromEvent : (any) -> Promise,
-- 	onUnhandledRejection : (any) -> (() -> ()),
-- }


-- export type PlayerModule = {

-- }


-- export type PostModule = {
--     nextAutoPost : number,
-- 	nextClickPost : number,
-- 	autoPostInverval : number,
-- 	clickPostInterval : number,
-- 	dialog : {},
-- 	currentState : string,
-- 	level : number,
-- 	postedLastTime : boolean,
-- 	postStates : {},
-- 	posts : {(number) -> string},
-- 	dialogs : {(number) -> string},
-- 	replies : {(number) -> string},
-- 	numberOfPosts : number,
-- 	numberOfDialogs : number,
-- 	numberOfReplies : number,
-- 	GenerateDialog : (PlayerModule, string) -> nil,
--  Post : (PlayerModule) -> nil,
--  PlayerClicked : (PlayerModule) -> nil,
--  GenerateStateMachine : () -> nil,
--  OnLeave : () -> nil
-- }


-- export type PlayTimeRewards = {
-- 	lastDayPlayed : number,
-- 	timePlayedToday : number,
-- 	nextRewards : {number},
-- 	rewardToCollect : number,
-- 	plr : Player,
-- 	new : (Player) -> PlayTimeRewards,
-- 	GetDataToSave : () -> PlayTimeRewardsStats,
-- 	LoadData : () -> nil,
-- 	StartTimer : () -> nil,
-- 	CollectReward : () -> PlayTimeReward,
-- 	OnLeave : () -> nil
-- }

-- export type PlayTimeRewardsStats = {
-- 	lastDayPlayed : number,
-- 	timePlayedToday : number
-- }

-- export type PlayTimeReward = {
-- 	[string] : string | number
-- }

-- export type CustomPostType = {
-- 	__index : CustomPostType,
-- 	player : Player,
-- 	nextId : number,
-- 	-- posts : {post},
-- 	-- postModule : PostModule,
-- 	listCustomPostConnection : {RBXScriptSignal},
--     new : (plr : Player, postModule : {}) -> CustomPostType,
-- 	CreatePost : (self : CustomPostType, postType : string, text1 : string, text2 : string) -> (),
-- }


-- export type CustomPostImpl = {
-- 	__index : CustomPostImpl,
--     new : (plr : Player, postModule : {}) -> CustomPostType,
-- 	CreatePost : (self : CustomPostType, postType : string, text1 : string, text2 : string) -> (),
-- }

-- export type CustomPostProto = {
-- 	player : Player,
-- 	nextId : number,
-- 	-- posts : {post},
-- 	-- postModule : PostModule,
-- 	listCustomPostConnection : {RBXScriptSignal},
-- }

-- export type CustomPostType = typeof(setmetatable({} :: CustomPostProto, {} :: CustomPostImpl))


-- export type post = {
--     id : number,
--     postType : string,
--     text1 : string,
--     text2 : string
-- }

-- https://devforum.roblox.com/t/object-oriented-programming-with-luau-in-2023/2135043
return nil