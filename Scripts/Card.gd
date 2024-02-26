class_name Card

var cardFrontTexture = preload("res://Assets/CardImg/StandardCard.jpg")
var cardBackTexture = preload("res://Assets/CardImg/CardBack.jpg")
var scene

func SetupScene(loc, gm):#spawns the card
	scene = preload("res://Scenes/Card/Card.tscn")
	scene = scene.instantiate()
	scene.position = loc
	scene.find_child("Sprite").texture = cardBackTexture
	gm.add_child(scene)
	
func Reveal():
	scene.find_child("Sprite").texture = cardFrontTexture
func Hide():
	scene.find_child("Sprite").texture = cardBackTexture
