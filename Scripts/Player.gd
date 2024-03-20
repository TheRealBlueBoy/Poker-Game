class_name Player extends Node2D
var hand = []
var playerName = ""
var chipsOwned = 100
var status = PlayerStatus.pending
var index
var child
var gamemode

#temp vars for decide winner 
var allCards = []
var finalCards = []
var finalScore #integer which gives a score to specific hands, used to decide a winner

enum PlayerStatus {pending, raised, folded, broke, allIn, checked}

func Init(i, loc, c, gm):#calls when made
	child = c
	child.position = loc
	index = i 
	gamemode = gm
	
	
func Call(amount):
	status = PlayerStatus.checked
	
func Check():
	status = PlayerStatus.checked
	
func Fold():
	status = PlayerStatus.folded

func Raise(amount):
	gamemode.ResetPlayerStatuses()
	status = PlayerStatus.checked

func AllIn():
	gamemode.ResetPlayerStatuses()
	status = PlayerStatus.checked
