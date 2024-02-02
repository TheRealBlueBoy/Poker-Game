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
func DecideWinner():
	pass
func DealCards():
	for player in playingPlayers:
		player.hand = PickCardsFromDeck(2) #cards







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
