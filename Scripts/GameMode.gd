class_name GameMode extends Node2D
var savedCardDeck = [] #template deck
var cardDeck = [] #deck of cards in the round
var bigBlindIdx = 0 #idx of player with the big blind
var smallBlindIdx = 1 #idx of player with the small blind
var tableCards = [] #5 cards on the table
var gameUI

var playingPlayers = [] #players who are playing in the round
var players = [] #players who are sitting at the table
var actingPlayerIdx = 0 #player who's turn it is
var playerBets = [0,0,0,0,0] #amount each player bet
var phase = 0#phase is how many times a card(s) got revealed from the tablecards
var tempObjects = [] #these objects will be removed every round
var chipsRoundTotal #amounts of chips bet by all players

const playerLoc = [Vector2(450,-50),Vector2(330,180),Vector2(0,240),Vector2(-330,180),Vector2(-450,-50)] #player spawn loc
const tableCardsLoc = [Vector2(-100,0),Vector2(-50,0),Vector2(0,0),Vector2(50,0),Vector2(100,0)] #table cards spawn loc
enum PlayerStatus {pending, raised, folded, broke, allIn, checked}


	
# Called when the node enters the scene tree for the first time.
func _ready():
	Setup()

func Setup():
	SetupDeck()
	SetupPlayers()
	SetupDeck()
	SetupUI()
	StartRound()
	#DecideWinner()

func SetupTable():
	pass
func SetupPlayers():
	for i in 5:
		players.append(Player.new())
		players[i].Init(i, playerLoc[i], self)

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
	gameUI.ChangePlayer(actingPlayerIdx)
	if (playingPlayers[actingPlayerIdx].status == PlayerStatus.allIn): #skips the turn if player is allin
		EndTurn()
	for card in playingPlayers[actingPlayerIdx].hand:#show the cards of the player who's turn it is
			card.Reveal()


func EndTurn():
	var ShouldRevealCard = true#if true it will reveal the next card
	for player in playingPlayers:#hide all the cards of the players
		for card in player.hand:
			card.Hide()
		if(player.status !=PlayerStatus.checked):
			ShouldRevealCard = false
	if (ShouldRevealCard):#reveal the card according to the phase
		if (phase == 0):
			tableCards[0].Reveal()
			tableCards[1].Reveal()
			tableCards[2].Reveal()
		if (phase == 1):
			tableCards[3].Reveal()
		if (phase == 2):
			tableCards[4].Reveal()
		if (phase == 3):
			EndRound()
			return
		ResetPlayerStatuses()
		phase += 1
	actingPlayerIdx=IncrementInRange(actingPlayerIdx,0,playingPlayers.size())
	StartTurn()
	
func StartRound():
	#reset vars
	playingPlayers = []
	phase = 0
	playerBets = [0,0,0,0,0]
	cardDeck = savedCardDeck.duplicate()
	cardDeck.shuffle()
	var idx = 0
	for player in players: #adds the players to a new round
		if (player.chipsOwned != 0): #can the player play
			playingPlayers.append(player)
			player.hand = PickCardsFromDeck(2)
			#spawn cards with an offset from the player
			player.hand[0].SetupScene(playerLoc[idx]+Vector2(-50,-75), self)
			player.hand[1].SetupScene(playerLoc[idx]+Vector2(50,-75), self)
			idx += 1
	chipsRoundTotal = Chips.new()
	chipsRoundTotal.Init(Vector2(0,-150), 0,self)
	tempObjects.append(chipsRoundTotal.scene)
	#rotate blinds
	bigBlindIdx = IncrementInRange(bigBlindIdx,0,playingPlayers.size()-1)
	smallBlindIdx = IncrementInRange(smallBlindIdx,0,playingPlayers.size()-1)
	playingPlayers[smallBlindIdx].Raise(10)
	playingPlayers[bigBlindIdx].Raise(20)
	actingPlayerIdx=IncrementInRange(bigBlindIdx,0,playingPlayers.size()-1) #sets the player who starts, which is the one left from the big blind
	ResetPlayerStatuses()
	tableCards = PickCardsFromDeck(5) #gets 5 random card from the deck
	idx = 0
	for card in tableCards: #spawn cards on the table
		card.SetupScene(tableCardsLoc[idx],self)
		idx += 1
	if (playingPlayers.size() >= 2):#enough players to start a game?
		StartTurn()

func EndRound():
	DecideWinner()
	DevideSpoils()
	for obj in tempObjects:
		obj.queue_free() #removes all the temp objects from the scene
	tempObjects = []
	StartRound()
	


var allCardsPH = [] #a placeholder for the allcards array
var finalCardsPH = [] #a placeholder for the finalCards array
var winners = []

func DecideWinner():
	for player in playingPlayers:
		finalCardsPH = []
		allCardsPH = []
		player.allCards = []
		player.finalScore = 0
		player.allCards.append_array(tableCards)
		player.allCards.append_array(player.hand)
		player.allCards.sort_custom(SortDescendingCard)
		allCardsPH = player.allCards.duplicate()
		
		if StraightFlushChecker().size() == 5:
			player.finalScore = 8
		elif FourOfAKindChecker().size() == 4:
			player.finalScore = 7
		elif FullHouseChecker().size() == 5:
			player.finalScore = 6
		elif FlushChecker().size() >= 5:
			player.finalScore = 5
		elif StraightChecker().size() == 5:
			player.finalScore = 4
		elif ThreeOfAKindChecker().size() == 3:
			player.finalScore = 3
		elif TwoPairChecker().size() == 4:
			player.finalScore = 2
		elif OnePairChecker().size() == 2:
			player.finalScore = 1
		player.finalCards = finalCardsPH.duplicate()
	playingPlayers.sort_custom(SortDescendingPlayer)
	var tiedPlayers = []
	var winningPlayers = []
	tiedPlayers = []
	winners = []
	if playingPlayers[0].finalScore == playingPlayers[1].finalScore:
		if playingPlayers[1].finalScore == playingPlayers[2].finalScore:
			if playingPlayers[2].finalScore == playingPlayers[3].finalScore:
				tiedPlayers.append(playingPlayers[0])
				tiedPlayers.append(playingPlayers[1])
				tiedPlayers.append(playingPlayers[2])
				tiedPlayers.append(playingPlayers[3])
				winningPlayers = highcardChecker(tiedPlayers, 4).duplicate()
				if winningPlayers.size() == 4:
					winners.append_array(winningPlayers)
					print(winners)
					return winners
				if winningPlayers.size() == 3:
					winners.append_array(winningPlayers)
					print(winners)
					return winners
				if winningPlayers.size() == 2:
					winners.append_array(winningPlayers)
					print(winners)
					return winners
				if winningPlayers.size() == 1:
					winners.append_array(winningPlayers)
					print(winners)
					return winners
			tiedPlayers.append(playingPlayers[0])
			tiedPlayers.append(playingPlayers[1])
			tiedPlayers.append(playingPlayers[2])
			winningPlayers = highcardChecker(tiedPlayers, 3).duplicate()
			if winningPlayers.size() == 3:
				winners.append_array(winningPlayers)
				print(winners)
				return winners
			if winningPlayers.size() == 2:
				winners.append_array(winningPlayers)
				print(winners)
				return winners
			if winningPlayers.size() == 1:
				winners.append_array(winningPlayers)
				print(winners)
				return winners
		tiedPlayers.append(playingPlayers[0])
		tiedPlayers.append(playingPlayers[1])
		winningPlayers = highcardChecker(tiedPlayers, 2).duplicate()
		if winningPlayers.size() == 2:
			winners.append_array(winningPlayers)
			print(winners)
			return winners
		if winningPlayers.size() == 1:
			winners.append_array(winningPlayers)
			print(winners)
			return winners
	winners.append(playingPlayers[0].index)
	print(winners)
	return winners
	
func DevideSpoils():
	pass
	
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

func SortDescendingPlayerHand(a, b):
	if a.hand[0].number > b.hand[0].number:
		return true
	elif a.hand[0].number == b.hand[0].number:
		if a.hand[1].number > b.hand[1].number:
			return true
	return false
	
func highcardChecker(tied, amount):
	var tiedPlayers = []
	tied.sort_custom(SortDescendingPlayerHand)
	if tied[0].hand[0].number == tied[1].hand[0].number:
		if amount >= 3:
			if tied[1].hand[0].number == tied[2].hand[0].number:
				if amount >= 4:
					if tied[2].hand[0].number == tied[3].hand[0].number:
						if tied[0].hand[1].number == tied[1].hand[1].number:
							if tied[1].hand[1].number == tied[2].hand[1].number:
								if tied[2].hand[1].number == tied[3].hand[1].number:
									tiedPlayers.append(tied[0].index)
									tiedPlayers.append(tied[1].index)
									tiedPlayers.append(tied[2].index)
									tiedPlayers.append(tied[3].index)
								tiedPlayers.append(tied[0].index)
								tiedPlayers.append(tied[1].index)
								tiedPlayers.append(tied[2].index)
							tiedPlayers.append(tied[0].index)
							tiedPlayers.append(tied[1].index)
						tiedPlayers.append(tied[0].index)
				if tied[0].hand[1].number == tied[1].hand[1].number:
					if tied[1].hand[1].number == tied[2].hand[1].number:
						tiedPlayers.append(tied[0].index)
						tiedPlayers.append(tied[1].index)
						tiedPlayers.append(tied[2].index)
					tiedPlayers.append(tied[0].index)
					tiedPlayers.append(tied[1].index)
				tiedPlayers.append(tied[0].index)
			if tied[0].hand[1].number == tied[1].hand[1].number:
				tiedPlayers.append(tied[0].index)
				tiedPlayers.append(tied[1].index)
			tiedPlayers.append(tied[0].index)
	tiedPlayers.append(tied[0].index)
	return tiedPlayers

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
	var temporaryCards = []
	temporaryCards = allCardsPH.duplicate()
	for i in 4:
		if allCardsPH[i].number == allCardsPH[i+1].number:
			if allCardsPH [i+1].number == allCardsPH[i+2].number:
				finalCardsPH.append(allCardsPH[i])
				finalCardsPH.append(allCardsPH[i+1])
				finalCardsPH.append(allCardsPH[i+2])
				temporaryCards.remove_at(i)
				temporaryCards.remove_at(i+1)
				temporaryCards.remove_at(i+2)
	if finalCardsPH.size() == 3:
		for i in 3:
			if temporaryCards[i].number == temporaryCards[i+1].number:
				finalCardsPH.append(temporaryCards[i])
				finalCardsPH.append(temporaryCards[i+1])
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
	var temporaryCards = []
	temporaryCards = allCardsPH.duplicate()
	for i in 6:
		if finalCardsPH.size() == 0:
			if allCardsPH[i].number == allCardsPH[i+1].number:
				finalCardsPH.append(allCardsPH[i])
				finalCardsPH.append(allCardsPH[i+1])
				temporaryCards.remove_at(i)
				temporaryCards.remove_at(i+1)
	if finalCardsPH.size() == 2:
		for i in 4:
			if temporaryCards[i].number == temporaryCards[i+1].number:
				finalCardsPH.append(temporaryCards[i])
				finalCardsPH.append(temporaryCards[i+1])
	return finalCardsPH

func OnePairChecker():
	for i in 5:
		if allCardsPH[i].number == allCardsPH[i+1].number:
			finalCardsPH.append(allCardsPH[i])
			finalCardsPH.append(allCardsPH[i+1])
	return finalCardsPH
	
func ResetPlayerStatuses():
	for player in playingPlayers:
		player.status = PlayerStatus.pending
		
func GetAllPlayerStatuses():
	var array
	for player in playingPlayers:
		array.append(player.status)
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
