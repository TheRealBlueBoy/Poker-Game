class_name GameMode
var savedCardDeck
var cardDeck
var bigBlind = 0
var smallBlind = 1
var tableCards

var allCards
var finalHand
var finalScore
var heartCards
var spadeCards
var clubCards
var diamondCards
var index

var playingPlayers
var players
var actingPlayerIdx
var playerBets

enum PlayerStatus {pending, raised, folded, broke, allIn, check}


	
# Called when the node enters the scene tree for the first time.
func _ready():
	Setup()

func Setup():
	SetupDeck()
	SetupPlayers()
	SetupDeck()
	StartRound()

func SetupTable():
	pass
func SetupPlayers():
	pass
func SetupDeck():
	savedCardDeck = Deck.new().createCardDeck()

#gamecycle
func StartTurn():
	actingPlayerIdx=IncrementInRange(actingPlayerIdx,0,playingPlayers.length)
	if (playingPlayers[actingPlayerIdx].status == PlayerStatus.allIn): #skips the turn if player is allin
		EndTurn()
	
func EndTurn():
	pass
func StartRound():

	for player in players:
		if (player.ChipsOwned != 0): #can the player play
			playingPlayers.append(player)
	#rotate blinds
	bigBlind = IncrementInRange(bigBlind,0,playingPlayers.length)
	smallBlind = IncrementInRange(smallBlind,0,playingPlayers.length)
	players[smallBlind].Raise()
	players[bigBlind].Raise()
	actingPlayerIdx=DecreaseInRange(smallBlind,0,playingPlayers.length)
	tableCards = PickCardsFromDeck(5)
	StartTurn()

func EndRound():
	cardDeck = savedCardDeck
	cardDeck.randomize()
	pass
func RevealCard():
	pass
func DecideWinner():
	for player in playingPlayers:
		finalScore = 0
		allCards.append_array(tableCards)
		allCards.append_array(player.hand)
		allCards.sort_custom(SortAscending)
		
func DealCards():
	for player in playingPlayers:
		player.hand = PickCardsFromDeck(2) #cards

func SortAscending(a, b):
	if a.card.number < b.card.number:
		return true
	return false

func StraightChecker():
	if allCards[0].number + 1 == allCards[1].number:
		if allCards[1].number + 1 == allCards[2].number:
			if allCards [2].number + 1 == allCards[3].number:
				if allCards[3].number + 1 == allCards[4].number:
					return true
	if allCards[1].number + 1 == allCards[2].number:
		if allCards[2].number + 1 == allCards[3].number:
			if allCards [3].number + 1 == allCards[4].number:
				if allCards[4].number + 1 == allCards[5].number:
					return true
	if allCards[2].number + 1 == allCards[3].number:
		if allCards[3].number + 1 == allCards[4].number:
			if allCards [4].number + 1 == allCards[5].number:
				if allCards[5].number + 1 == allCards[6].number:
					return true
	return false

func TypeChecker():
	heartCards = 0
	spadeCards = 0
	clubCards = 0
	diamondCards = 0
	for card in allCards:
		if card.type == "h":
			heartCards += 1
		if card.type == "s":
			spadeCards += 1
		if card.type == "s":
			clubCards += 1
		if card.type == "d":
			diamondCards += 1


func PickCardsFromDeck(amount):
	var idx
	var pickedCards
	while (amount < idx):
		pickedCards.append(cardDeck.pop_at(0))#removes the card from carddeck and adds it to pickedcards
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
