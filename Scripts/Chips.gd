class_name Chips extends Node

var chip1Texture = preload("res://Assets/Chips/Chip1.png")
var chip2Texture = preload("res://Assets/Chips/Chip2.png")
var chip3Texture = preload("res://Assets/Chips/Chip3.png")
var amount
var scene

func Init(loc, a, gm):#spawns the card
	scene = preload("res://Scenes/Chips.tscn")
	scene = scene.instantiate()
	scene.position = loc
	UpdateAmount(a)
	gm.add_child(scene)

func UpdateAmount(a):
	amount = a
	scene.find_child("Label").text = str(amount)
	if (amount < 50):
		scene.find_child("Sprite").texture = chip3Texture
	if (amount < 100):
		scene.find_child("Sprite").texture = chip2Texture
	else:
		scene.find_child("Sprite").texture = chip1Texture
	
