class_name GameMode extends Node2D
var savedCardDeck = []
var cardDeck = []
var bigBlind = 0
var smallBlind = 1
var tableCards = []
var gameUI

var playingPlayers = []
var players = []
var actingPlayerIdx = 0
var playerBets = [0,0,0,0,0]

const playerLoc = [Vector2(450,-140),Vector2(330,190),Vector2(0,240),Vector2(-330,190),Vector2(-450,-140)]
const tableCardsLoc = [Vector2(-100,0),Vector2(-50,0),Vector2(0,0),Vector2(50,0),Vector2(100,0)]
enum PlayerStatus {pending, raised, folded, broke, allIn, check}


	
# Called when the node enters the scene tree for the first time.
func _ready():
	Setup()

func Setup():
	SetupDeck()
	SetupPlayers()
	SetupDeck()
	SetupUI()
	#StartRound()
	DecideWinner()

func SetupTable():
	pass
func SetupPlayers():
	for i in 5:
		var player_scene = preload("res://Scenes/Player.tscn")
		player_scene = player_scene.instantiate()
		add_child(player_scene)
		players.append(Player.new())
		players[i].Init(i, playerLoc[i], player_scene, self)

func SetupDeck():
	savedCardDeck = Deck.new().createCardDeck()
	
func SetupUI():
	gameUI = preload("res://Scenes/UI_Game.tscn")
	gameUI = gameUI.instantiate()
	add_child(gameUI)
	gameUI = gameUI.find_child("Control")
	gameUI.Init(self)


	
#gamecycle
func StartTurn():
	actingPlayerIdx=IncrementInRange(actingPlayerIdx,0,playingPlayers.size()-1)
	gameUI.ChangePlayer(actingPlayerIdx)
	if (playingPlayers[actingPlayerIdx].status == PlayerStatus.allIn): #skips the turn if player is allin
		EndTurn()
	
func EndTurn():
	pass
	
func StartRound():
	cardDeck = savedCardDeck
	cardDeck.shuffle()
	for player in players: #adds the players to a new round
		if (player.chipsOwned != 0): #can the player play
			playingPlayers.append(player)
			player.status = PlayerStatus.pending
	#rotate blinds
	bigBlind = IncrementInRange(bigBlind,0,playingPlayers.size()-1)
	smallBlind = IncrementInRange(smallBlind,0,playingPlayers.size()-1)
	players[smallBlind].Raise(10)
	players[bigBlind].Raise(20)
	actingPlayerIdx=DecreaseInRange(smallBlind,0,playingPlayers.size()-1) #sets the player who starts 
	tableCards = PickCardsFromDeck(5) #gets 5 random card from the deck
	var idx = 0
	for card in tableCards: #spawn cards on the table
		card.SetupScene(tableCardsLoc[idx],self)
		idx += 1
		
	if (playingPlayers.size() != 0):#if no players are able to play then don't start 
		StartTurn()

func EndRound():
	cardDeck = savedCardDeck
	cardDeck.randomize()
	pass
func RevealCard():
	pass


var allCardsPH = [] #a placeholder for the allcards array
var finalCardsPH = [] #a placeholder for the finalCards array]\
var winner

func DecideWinner():
	for player in players:
		playingPlayers.append(player)
	playingPlayers[0].hand.append(StandardCard.new("s", 2))
	playingPlayers[0].hand.append(StandardCard.new("s", 3))
	playingPlayers[1].hand.append(StandardCard.new("h", 3))
	playingPlayers[1].hand.append(StandardCard.new("h", 4))
	playingPlayers[2].hand.append(StandardCard.new("h", 6))
	playingPlayers[2].hand.append(StandardCard.new("h", 7))
	playingPlayers[3].hand.append(StandardCard.new("h", 8))
	playingPlayers[3].hand.append(StandardCard.new("h", 9))
	playingPlayers[4].hand.append(StandardCard.new("h", 10))
	playingPlayers[4].hand.append(StandardCard.new("h", 11))
	tableCards.append(StandardCard.new("s", 4))
	tableCards.append(StandardCard.new("s", 6))
	tableCards.append(StandardCard.new("d", 5))
	tableCards.append(StandardCard.new("s", 8))
	tableCards.append(StandardCard.new("h", 2))
	
	for player in playingPlayers:
		player.finalScore = 0
		player.allCards.append_array(tableCards)
		player.allCards.append_array(player.hand)
		player.allCards.sort_custom(SortDescendingCard)
		allCardsPH = player.allCards
		
		if StraightFlushChecker().size() == 5:
			player.finalScore = 8
			print(player.finalScore)
		elif FourOfAKindChecker().size() == 4:
			player.finalScore = 7
			print(player.finalScore)
		elif FullHouseChecker().size() == 5:
			player.finalScore = 6
			print(player.finalScore)
		elif FlushChecker().size() == 5:
			player.finalScore = 5
			print(player.finalScore)
		elif StraightChecker().size() == 5:
			player.finalScore = 4
			print(player.finalScore)
		elif ThreeOfAKindChecker().size() == 3:
			player.finalScore = 3
			print(player.finalScore)
		elif TwoPairChecker().size() == 4:
			player.finalScore = 2
			print(player.finalScore)
		elif OnePairChecker().size() == 2:
			player.finalScore = 1
			print(player.finalScore)
		print(player.finalScore)
		player.finalCards = finalCardsPH
		for card in player.finalCards:
			print(card.type)
	playingPlayers.sort_custom(SortDescendingPlayer)
	var tiedPlayers = []
	if playingPlayers[0].finalScore == playingPlayers[1].finalScore:
		if playingPlayers[1].finalScore == playingPlayers[2].finalScore:
			if playingPlayers[2].finalScore == playingPlayers[3].finalScore:
				if playingPlayers[3].finalScore == playingPlayers[4].finalScore:
					print("tie between all 5 players")
				tiedPlayers.append(playingPlayers[0].index)
				tiedPlayers.append(playingPlayers[1].index)
				tiedPlayers.append(playingPlayers[2].index)
				tiedPlayers.append(playingPlayers[3].index)
				print("tie between player x, x, x and x")
			tiedPlayers.append(playingPlayers[0].index)
			tiedPlayers.append(playingPlayers[1].index)
			tiedPlayers.append(playingPlayers[2].index)
			print("tie between player x, x and x")
		tiedPlayers.append(playingPlayers[0].index)
		tiedPlayers.append(playingPlayers[1].index)
		print("tie between player x and x")
	winner = playingPlayers[0].index
	print(winner)
	

func DealCards():
	for player in playingPlayers:
		player.hand = PickCardsFromDeck(2) #cards

func SortDescendingCard(a, b):
	if a.number > b.number:
		return true
	return false
	
func SortDescendingPlayer(a, b):
	if a.finalScore > b.finalScore:
		return true
	return false

func StraightFlushChecker():
	var temporaryCards = []
	for i in 3:
		if allCardsPH[i].number - 1 == allCardsPH[i+1].number:
			if allCardsPH[i+1].number - 1 == allCardsPH[i+2].number:
				if allCardsPH [i+2].number - 1 == allCardsPH[i+3].number:
					if allCardsPH[i+3].number - 1 == allCardsPH[i+4].number:
						temporaryCards.append(allCardsPH[i])
						temporaryCards.append(allCardsPH[i+1])
						temporaryCards.append(allCardsPH[i+2])
						temporaryCards.append(allCardsPH[i+3])
						temporaryCards.append(allCardsPH[i+4])
	var heartCards = []
	var spadeCards = []
	var clubCards = []
	var diamondCards = []
	for card in temporaryCards:
		if card.type == "h":
			heartCards.append(card)
		if card.type == "s":
			spadeCards.append(card)
		if card.type == "s":
			clubCards.append(card)
		if card.type == "d":
			diamondCards.append(card)
	if heartCards.size() >= 5:
		finalCardsPH.append_array(heartCards)
	if spadeCards.size() >= 5:
		finalCardsPH.append_array(spadeCards)
	if clubCards.size() >= 5:
		finalCardsPH.append_array(clubCards)
	if diamondCards.size() >= 5:
		finalCardsPH.append_array(diamondCards)
	return finalCardsPH

func FourOfAKindChecker():
	for i in 4:
		if allCardsPH[i].number == allCardsPH[i+1].number:
				if allCardsPH [i+1].number == allCardsPH[i+2].number:
						if allCardsPH[i+2].number == allCardsPH[i+3].number:
							finalCardsPH.append(allCardsPH[i])
							finalCardsPH.append(allCardsPH[i+1])
							finalCardsPH.append(allCardsPH[i+2])
							finalCardsPH.append(allCardsPH[i+3])
	return finalCardsPH
	
func FullHouseChecker():
	#still need to make logic
	return finalCardsPH

func FlushChecker():
	var heartCards = []
	var spadeCards = []
	var clubCards = []
	var diamondCards = []
	for card in allCardsPH:
		if card.type == "h":
			heartCards.append(card)
		if card.type == "s":
			spadeCards.append(card)
		if card.type == "s":
			clubCards.append(card)
		if card.type == "d":
			diamondCards.append(card)
	if heartCards.size() >= 5:
		finalCardsPH.append_array(heartCards)
	if spadeCards.size() >= 5:
		finalCardsPH.append_array(spadeCards)
	if clubCards.size() >= 5:
		finalCardsPH.append_array(clubCards)
	if diamondCards.size() >= 5:
		finalCardsPH.append_array(diamondCards)
	return finalCardsPH

func StraightChecker():
	for i in 3:
		if allCardsPH[i].number - 1 == allCardsPH[i+1].number:
			if allCardsPH[i+1].number - 1 == allCardsPH[i+2].number:
				if allCardsPH [i+2].number - 1 == allCardsPH[i+3].number:
					if allCardsPH[i+3].number - 1 == allCardsPH[i+4].number:
						finalCardsPH.append(allCardsPH[i])
						finalCardsPH.append(allCardsPH[i+1])
						finalCardsPH.append(allCardsPH[i+2])
						finalCardsPH.append(allCardsPH[i+3])
						finalCardsPH.append(allCardsPH[i+4])
	return finalCardsPH

func ThreeOfAKindChecker():
	for i in 5:
		if allCardsPH[i].number == allCardsPH[i+1].number:
				if allCardsPH [i+1].number == allCardsPH[i+2].number:
						finalCardsPH.append(allCardsPH[i])
						finalCardsPH.append(allCardsPH[i+1])
						finalCardsPH.append(allCardsPH[i+2])
	return finalCardsPH

func TwoPairChecker():
	#still need to make logic
	return finalCardsPH

func OnePairChecker():
	for i in 6:
		if allCardsPH[i].number == allCardsPH[i+1].number:
			finalCardsPH.append(allCardsPH[i])
			finalCardsPH.append(allCardsPH[i+1])
	return finalCardsPH

func GetAllPlayerStatuses():
	var array
	for player in playingPlayers:
		array.append(player.status)
	print(array)
	return array

func PickCardsFromDeck(amount):
	var idx = 0
	var pickedCards = []
	while (amount > idx):
		pickedCards.append(cardDeck[0])
		cardDeck.pop_at(0)#removes the card from carddeck and adds it to pickedcards
		idx += 1
	return pickedCards

func IncrementInRange(number,min, max):
	if (number+1 >= max):
		return min
	else:
		return (number+1)
		
func DecreaseInRange(number,min, max):
	if (number-1 <= min):
		return max
	else:
		return (number-1)
