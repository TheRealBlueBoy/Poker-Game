class_name BigBlind extends Node2D

var scene

func Init(loc, gm):#spawns the card
	scene = preload("res://Scenes/Bb.tscn")
	scene = scene.instantiate()
	scene.position = loc
	gm.add_child(scene)

func Hide():
	scene.find_child("Sprite2D").set_visible(false)
	
func Show():
	scene.find_child("Sprite2D").set_visible(true)
