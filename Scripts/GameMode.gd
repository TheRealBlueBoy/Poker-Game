class_name GameMode
var savedCardDeck
var cardDeck
var bigBlind = 0
var smallBlind = 1
var tableCards


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

var allCards #array which stores the open cards on the table and the cards in the players hand
var finalScore #integer which gives a score to specific hands, used to decide a winner
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
	for i in 3:
		if allCards[i].number + 1 == allCards[i+1].number:
			if allCards[i+1].number + 1 == allCards[i+2].number:
				if allCards [i+2].number + 1 == allCards[i+3].number:
					if allCards[i+3].number + 1 == allCards[i+4].number:
						return true
	return false

func PairChecker():
	var pairScore = 0
	for i in 6:
		if allCards[i].number + 1 == allCards[i+1].number:
			pairScore = 2
			if i <= 4:
				if allCards [i+1].number + 1 == allCards[i+2].number:
					pairScore = 3
					if i <= 3:
						if allCards[i+2].number + 1 == allCards[i+3].number:
							pairScore = 4
	return pairScore

#the number of cards of the same type
var heartCards = 0
var spadeCards = 0
var clubCards = 0
var diamondCards = 0

func TypeChecker():
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
