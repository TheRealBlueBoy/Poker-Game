class_name Player extends Node2D
var hand = []
var playerName = ""
var chipsOwned = 100
var status = PlayerStatus.pending
var index

enum PlayerStatus {pending, raised, folded, broke, allIn}

func _init(i):
	index = i 
	
func _ready():
	pass
	
func Pass():
	pass
func Call():
	pass
func Check():
	pass
func Fold():
	pass
func Raise():
	pass
