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

func get_current_bet():
	# Calculate the current bet by finding the maximum bet among all players
	for bet in gamemode.playerBets:
		if bet > maxBet:
			maxBet = bet
			return maxBet

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
	var currentBet = get_current_bet()
	var player = gamemode.playerbets[gamemode.actingPlayerIdx]

	if player.chipsOwned >= currentBet - gamemode.playerbets[gamemode.actingPlayerIdx]: # Check if the player has enough chips to call
		var amountToCall = currentBet - gamemode.playerbets[gamemode.actingPlayerIdx]
		player.chipsOwned -= amountToCall
		gamemode.playerbets[gamemode.actingPlayerIdx] += amountToCall
		# EndTurn()
		print(currentBet)
		return true
	else:
		return false

	status = PlayerStatus.checked
	
func Check():
	status = PlayerStatus.checked
	
func Fold():
	status = PlayerStatus.folded


func Raise(amount: int):
	gamemode.ResetPlayerStatuses()
	
	var currentBet = get_current_bet()
	# var player = gamemode.playerbets[gamemode.actingPlayerIdx]
	
	if player.chipsOwned > currentBet - gamemode.playerbets[gamemode.actingPlayerIdx]:  # Check if the player has enough chips to raise
		var amountToCall = currentBet - gamemode.playerbets[gamemode.actingPlayerIdx]
		player.chipsOwned -= amountToCall
		gamemode.playerbets[gamemode.actingPlayerIdx] += amountToCall
		# EndTurn()
		print(currentBet)
		return true
	else:
		return false

	status = PlayerStatus.checked

func AllIn():
	gamemode.ResetPlayerStatuses()
	status = PlayerStatus.checked
