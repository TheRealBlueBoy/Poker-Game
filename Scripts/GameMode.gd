class_name GameMode extends Node2D
var savedCardDeck = [] #template deck
var cardDeck = [] #deck of cards in the round
var bigBlindIdx = 1 #idx of player with the big blind
var smallBlindIdx = 0 #idx of player with the small blind
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


	
# Called when the node enters the scene tree for the first time.
func _ready():
	Setup()

func Setup():
	SetupDeck()
	SetupPlayers()
	SetupDeck()
	SetupUI()
	StartRound()


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
	if (playingPlayers[actingPlayerIdx].status == playingPlayers[actingPlayerIdx].PlayerStatus.allIn): #skips the turn if player is allin
		EndTurn()
		return
	for card in playingPlayers[actingPlayerIdx].hand:#show the cards of the player who's turn it is
		card.Reveal()


func EndTurn():
	var ShouldRevealCard = true#if true it will reveal the next card
	for player in playingPlayers:#hide all the cards of the players
		for card in player.hand:
			card.Hide()
		if((player.status == playingPlayers[actingPlayerIdx].PlayerStatus.checked) or (player.status == playingPlayers[actingPlayerIdx].PlayerStatus.allIn)):
			pass
		else:
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
		ResetPlayerStatusesInPhase()
		phase += 1
	if (playingPlayers.size() == 1):
		EndRound()
	actingPlayerIdx=IncrementInRange(actingPlayerIdx,0,playingPlayers.size()-1)
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
	ResetPlayerStatuses()
	chipsRoundTotal = Chips.new()
	chipsRoundTotal.Init(Vector2(0,-150), 0,self)
	tempObjects.append(chipsRoundTotal.scene)
	if (playingPlayers.size() < 2):#enough players to start a game?
		gameUI.set_visible(false)
		return
	#rotate blinds
	bigBlindIdx = IncrementInRange(bigBlindIdx,0,playingPlayers.size()-1)
	smallBlindIdx = IncrementInRange(smallBlindIdx,0,playingPlayers.size()-1)
	for player in players:
		player.HideBs()
	playingPlayers[smallBlindIdx].SB()
	playingPlayers[bigBlindIdx].BB()
	playingPlayers[smallBlindIdx].Raise(10)
	playingPlayers[bigBlindIdx].Raise(20)
	actingPlayerIdx=IncrementInRange(bigBlindIdx,0,playingPlayers.size()-1) #sets the player who starts, which is the one left from the big blind
	tableCards = PickCardsFromDeck(5) #gets 5 random card from the deck
	idx = 0
	for card in tableCards: #spawn cards on the table
		card.SetupScene(tableCardsLoc[idx],self)
		idx += 1
	StartTurn()

func EndRound():
	OpenUp()
	gameUI.set_visible(false)
	await get_tree().create_timer(5).timeout #pauses the game for 5 seconds
	gameUI.set_visible(true)
	DevideSpoils(DecideWinner())
	for obj in tempObjects:
		obj.queue_free() #removes all the temp objects from the scene
	tempObjects = []
	StartRound()
	


var allCardsPH = [] #a placeholder for the allcards array
var finalCardsPH = [] #a placeholder for the finalCards array
var winners = []

func DecideWinner():
	for player in playingPlayers:
		finalCardsPH = [] #finalcards placeholder
		allCardsPH = [] #allcards placeholder
		player.allCards = []
		player.finalScore = 0 #resets finalscore of player
		player.allCards.append_array(tableCards) #adds the table cards to allcards of one player
		player.allCards.append_array(player.hand) #adds the players hand to allcards of one player
		player.allCards.sort_custom(SortDescendingCard) #sorts the cards from highest to lowest number
		allCardsPH = player.allCards.duplicate() #sets the allcards placeholder to allcards
		
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
	playingPlayers.sort_custom(SortDescendingPlayer) #sorts the playing players array by final score
	var tiedPlayers = [] #holds the tied players of combination checks
	var winningPlayers = [] #holds the tied player(s) of the highcardchecker
	winners = [] #resets winner array
	for player in playingPlayers:#checks if the highgest scores are the same
		if (playingPlayers.find(player) != playingPlayers.size()-1): #is the next player a valid index
			if (player.finalScore == playingPlayers[playingPlayers.find(player)+1].finalScore): #same score?
				tiedPlayers.append(player)
	if (tiedPlayers.size() == 0):#if not a tie, player [0] wins
		winningPlayers = [playingPlayers[0]]
	else: #check highest card 
		winningPlayers = highcardChecker(tiedPlayers, (tiedPlayers.size()-1)).duplicate()
	for player in winningPlayers: #convert players to idx
		winningPlayers[winningPlayers.find(player)] = player.index
	winners = winningPlayers.duplicate()
	print(winners)
	return(winners)

func OpenUp():
	for player in playingPlayers:
		for card in player.hand:
			card.Reveal()

func DevideSpoils(winners):
	var totalBets = 0
	var winnersAmount = winners.size()
	chipsRoundTotal.UpdateAmount(totalBets)
	for betAmount in playerBets:
		totalBets += betAmount
	if (winnersAmount == 1):#if only one player won
		players[winners[0]].chipsOwned += totalBets
	else:
		for player in winners:
			player.chipsOwned += (totalBets/winnersAmount)
	for player in players:
		player.chipsScript.UpdateAmount(player.chipsOwned)
	
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
	
func highcardChecker(tied, amount): #checks hand for highcards
	var tiedPlayers = []
	tied.sort_custom(SortDescendingPlayerHand) #sorts array given by first and second card numbers
	for player1 in tied:
		if (tiedPlayers.find(player1) != tiedPlayers.size()-1): #is the next player a valid index
			var player2 = tiedPlayers[tiedPlayers.size()-1]
			#checks if the numbers of the cards are the same in each players hands
			if (player1.hand[0] == player2.hand[0]):
				if (tiedPlayers.has(player1) != true):#is player1 already in tiedplayers (prevents duplicates of players)
					tiedPlayers.append(player1)
				tiedPlayers.append(player2)
			elif(player1.hand[1] == player2.hand[1]):
				if (tiedPlayers.has(player1) != true):#is player1 already in tiedplayers (prevents duplicates of players)
					tiedPlayers.append(player1)
				tiedPlayers.append(player2)
	if (tiedPlayers.size() == 0):
		tiedPlayers.append(tied[0])
	return tiedPlayers
						
			

func StraightFlushChecker():
	var temporaryCards = []
	for i in 3: #checks for straight
		if allCardsPH[i].number - 1 == allCardsPH[i+1].number:
			if allCardsPH[i+1].number - 1 == allCardsPH[i+2].number:
				if allCardsPH [i+2].number - 1 == allCardsPH[i+3].number:
					if allCardsPH[i+3].number - 1 == allCardsPH[i+4].number:
						temporaryCards.append(allCardsPH[i])
						temporaryCards.append(allCardsPH[i+1])
						temporaryCards.append(allCardsPH[i+2])
						temporaryCards.append(allCardsPH[i+3])
						temporaryCards.append(allCardsPH[i+4])
	var heartCards = [] #checks for flush
	var spadeCards = []
	var clubCards = []
	var diamondCards = []
	for card in temporaryCards: #checks if type is the same
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
		if allCardsPH[i].number == allCardsPH[i+1].number: #checks if 4 numbers are the same
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
	for i in 4: #Checks for three of a kind
		if allCardsPH[i].number == allCardsPH[i+1].number:
			if allCardsPH [i+1].number == allCardsPH[i+2].number:
				finalCardsPH.append(allCardsPH[i])
				finalCardsPH.append(allCardsPH[i+1])
				finalCardsPH.append(allCardsPH[i+2])
				temporaryCards.remove_at(i)
				temporaryCards.remove_at(i+1)
				temporaryCards.remove_at(i+2)
	if finalCardsPH.size() == 3:
		for i in 3: #checks for pair
			if temporaryCards[i].number == temporaryCards[i+1].number:
				finalCardsPH.append(temporaryCards[i])
				finalCardsPH.append(temporaryCards[i+1])
	return finalCardsPH
	
func FlushChecker():
	var heartCards = []
	var spadeCards = []
	var clubCards = []
	var diamondCards = []
	for card in allCardsPH: #checks if type is the same
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
		if allCardsPH[i].number == allCardsPH[i+1].number: #checks if 3 numbers are the same
				if allCardsPH [i+1].number == allCardsPH[i+2].number:
						finalCardsPH.append(allCardsPH[i])
						finalCardsPH.append(allCardsPH[i+1])
						finalCardsPH.append(allCardsPH[i+2])
	return finalCardsPH

func TwoPairChecker():
	var temporaryCards = []
	temporaryCards = allCardsPH.duplicate()
	for i in 6: #checks for first pair
		if finalCardsPH.size() == 0:
			if allCardsPH[i].number == allCardsPH[i+1].number:
				finalCardsPH.append(allCardsPH[i])
				finalCardsPH.append(allCardsPH[i+1])
				temporaryCards.remove_at(i)
				temporaryCards.remove_at(i+1)
	if finalCardsPH.size() == 2:
		for i in 4: #checks for second pair
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
		player.status = playingPlayers[actingPlayerIdx].PlayerStatus.pending

func ResetPlayerStatusesInPhase():
	for player in playingPlayers:
		if (player.status != playingPlayers[actingPlayerIdx].PlayerStatus.allIn):
			player.status = playingPlayers[actingPlayerIdx].PlayerStatus.pending
		
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
	if (number+1 > max):
		return min
	else:
		return (number+1)
		
func DecreaseInRange(number,min, max):
	if (number-1 < min):
		return max
	else:
		return (number-1)
