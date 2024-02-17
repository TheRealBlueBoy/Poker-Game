extends Control
var updateRaiseBarBool = false
var raiseBarMax_yPosition
var raiseBarMin_yPosition
var gameMode
var actingPlayerIdx = 0

var raiseBar
var raiseBarInteractable
var foldButton
var call_checkButton
var raiseButton
# Called when the node enters the scene tree for the first time.
	
func Init(gm):
	gameMode = gm
	raiseBar = find_child("RaiseBar")
	raiseBarInteractable = find_child("RaiseBarInteractable")
	raiseBarMin_yPosition = raiseBar.position.y
	raiseBarMax_yPosition = raiseBar.position.y + raiseBar.size.y - raiseBarInteractable.size.y
	foldButton = find_child("FoldButton")
	call_checkButton = find_child("Check_CallButton")
	raiseButton = find_child("RaiseButton")

	
func _process(delta):
	if (updateRaiseBarBool):
		updateRaiseBar()
	
func Hide():
	visible = false

func Show():
	visible = true
	
func ChangePlayer(newIdx):
	SetRaiseBarVisibility(false)
	actingPlayerIdx = newIdx
	if(gameMode.playerBets.max() == gameMode.playerBets[actingPlayerIdx]):
		call_checkButton.text = "check"
	elif((gameMode.playerBets.max()-gameMode.playerBets[actingPlayerIdx]) < gameMode.playingPlayers[actingPlayerIdx].chipsOwned):#does player have enough chips to call?
		call_checkButton.text = ("call(%d)"%(gameMode.playerBets.max()-gameMode.playerBets[actingPlayerIdx]))#shows the amount you need to add to go even with the raised amount
	else:
		call_checkButton.text = ("allin(%d)"%(gameMode.playingPlayers[actingPlayerIdx].chipsOwned))#shows the amount you need to add to go even with the raised amount
		raiseButton.visible = false

	


#buttons
func _on_raise_bar_interactable_button_down():
	updateRaiseBarBool = true

func _on_raise_bar_interactable_button_up():
	updateRaiseBarBool = false
	
func updateRaiseBar():
	var mousePos = get_viewport().get_mouse_position().y
	var newPosition = clamp(mousePos, raiseBarMin_yPosition, raiseBarMax_yPosition) #makes sure the new position isn't out of bounds
	var percantage = (raiseBarMax_yPosition-newPosition)/(raiseBarMax_yPosition-raiseBarMin_yPosition)
	raiseBarInteractable.position.y = newPosition
	raiseBar.value = percantage

func _on_fold_button_pressed():
	gameMode.playingPlayers[actingPlayerIdx].Fold()

func _on_check_call_button_pressed():
	if(gameMode.playerBets.max() == gameMode.playerBets[actingPlayerIdx]):
		gameMode.playingPlayers[actingPlayerIdx].Check()
	elif((gameMode.playerBets.max()-gameMode.playerBets[actingPlayerIdx]) < gameMode.playingPlayers[actingPlayerIdx].chipsOwned):#does player have enough chips to call?
		gameMode.playingPlayers[actingPlayerIdx].AllIn()
	else:
		gameMode.playingPlayers[actingPlayerIdx].Call(gameMode.playingPlayers[actingPlayerIdx].chipsOwned)#shows the amount you need to add to go even with the raised amount

func _on_raise_button_pressed():
	if(raiseBar.visible):
		gameMode.playingPlayers[actingPlayerIdx].Raise(raiseBar.value * gameMode.playingPlayers[actingPlayerIdx].chipsOwned)
	else:
		SetRaiseBarVisibility(true)
	

func SetRaiseBarVisibility(b):
	raiseBar.value = raiseBar.min_value #resets past value
	raiseBarInteractable.position.y = raiseBarMax_yPosition #resets past location
	raiseBar.visible = b
	raiseBarInteractable.visible = b
