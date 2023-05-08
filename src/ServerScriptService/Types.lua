export type PlayerModule = {

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
	dialogs : {(number) -> string},
	replies : {(number) -> string},
	numberOfPosts : number,
	numberOfDialogs : number,
	numberOfReplies : number,
	GenerateDialog : (PlayerModule, string) -> nil,
    Post : (PlayerModule) -> nil,
    PlayerClicked : (PlayerModule) -> nil,
    GenerateStateMachine : () -> nil,
    OnLeave : () -> nil
}

export type CustomPost = {

}

export type post = {
    id : number,
    postType : string,
    text1 : string,
    text2 : string
}

return nil