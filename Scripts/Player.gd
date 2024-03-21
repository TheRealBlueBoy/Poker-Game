class_name Player extends Node2D
var hand = []
var playerName = ""
var chipsOwned = 500
var status = PlayerStatus.pending
var index
var scene
var gamemode
const playerTextures = [preload("res://Assets/PlayerSprites/Player_builder.png"),preload("res://Assets/PlayerSprites/Player_cowboy.png"),preload("res://Assets/PlayerSprites/Player_frog.png"),preload("res://Assets/PlayerSprites/Player_propellorhat.png"),preload("res://Assets/PlayerSprites/Player_unicorn.png")]
var maxBet = 0
#temp vars for decide winner 
var allCards = []
var finalCards = []
var finalScore #integer which gives a score to specific hands, used to decide a winner
var chipsScript

enum PlayerStatus {pending, raised, folded, broke, allIn, checked}

func Init(i, loc, gm):#calls when made
	var scene = preload("res://Scenes/Player.tscn")
	index = i 
	gamemode = gm
	scene = scene.instantiate()
	gamemode.add_child(scene)
	scene.position = loc
	scene.find_child("PlayerSprite").texture = playerTextures[index]
	chipsScript = Chips.new()
	chipsScript.Init(scene.position + Vector2(50,-10), chipsOwned, gamemode)
#InterpolateLocation(scene.position, Vector2(0,0),0.35)

func InterpolateLocation(loc1, loc2, f):
	return (loc1 + f*(loc2-loc1))
	
	
func Call(amount):
	chipsOwned -= amount
	chipsScript.UpdateAmount(chipsOwned)
	gamemode.playerBets[gamemode.actingPlayerIdx] += amount
	var totalBets = 0
	for betAmount in gamemode.playerBets:
		totalBets += betAmount
	gamemode.chipsRoundTotal.UpdateAmount(totalBets)
	status = PlayerStatus.checked
	
func Check():
	status = PlayerStatus.checked
	
func Fold():
	status = PlayerStatus.folded


func Raise(amount):
	chipsOwned -= amount
	chipsScript.UpdateAmount(chipsOwned)
	gamemode.playerBets[gamemode.actingPlayerIdx] += amount
	var totalBets = 0
	for betAmount in gamemode.playerBets:
		totalBets += betAmount
	gamemode.chipsRoundTotal.UpdateAmount(totalBets)
	status = PlayerStatus.checked
	gamemode.ResetPlayerStatuses()
	status = PlayerStatus.checked

func AllIn():
	var totalBets = 0
	for betAmount in gamemode.playerBets:
		totalBets += betAmount
	chipsOwned = 0
	chipsScript.UpdateAmount(chipsOwned)
	gamemode.chipsRoundTotal.UpdateAmount(totalBets)
	gamemode.ResetPlayerStatuses()
	status = PlayerStatus.allIn
	
