class_name StandardCard extends Card

var number
var type

func _init(Itype, Inumber):
	number = Inumber
	type = Itype
	if (type == "h"): #sets the image depending on the type
		cardFrontTexture = preload("res://Assets/CardImg/Hearts.jpg")
	elif (type == "d"):
		cardFrontTexture = preload("res://Assets/CardImg/daimonds.jpg")
	elif (type == "c"):
		cardFrontTexture = preload("res://Assets/CardImg/Clover.jpg")
	elif (type == "s"):
		cardFrontTexture = preload("res://Assets/CardImg/Spades.jpg")


func SetupScene(loc, gm):
	scene = preload("res://Scenes/Card/StandardCard.tscn")
	scene = scene.instantiate()
	scene.position = loc
	scene.find_child("Sprite").texture = cardBackTexture
	scene.find_child("number").text = NumberToText(number)
	gm.add_child(scene)
	
func NumberToText(n):
	const Text = {11: "J", 12:"Q",13:"K",14:"A"}
	if (n < 11):
		return str(n)
	return Text[n]
	
func Hide():
	super.Hide()
	scene.find_child("number").visible = false
	
func Reveal():
	super.Reveal()
	scene.find_child("number").visible = true
	
