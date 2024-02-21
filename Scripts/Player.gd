class_name Player extends Node2D
var hand = []
var playerName = ""
var chipsOwned = 100
var status = PlayerStatus.pending
var index
var child
var gamemode
var allCards = []
var finalCards = []
var finalScore #integer which gives a score to specific hands, used to decide a winner

enum PlayerStatus {pending, raised, folded, broke, allIn}

func Init(i, loc, c, gm):
	child = c
	child.position = loc
	index = i 
	gamemode = gm
	
	
func _ready():
	pass
	
func Call(amount):
	pass
func Check():
	pass
func Fold():
	pass
func Raise(amount):
	pass
func AllIn():
	pass
