class_name Player extends Node2D
var hand = []
var playerName = ""
var chipsOwned = 100
var status = PlayerStatus.pending
var index
var child

enum PlayerStatus {pending, raised, folded, broke, allIn}

func Init(i):
	index = i 
	child = Node2D.new()
	
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
