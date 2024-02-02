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
var finalCards #stores the final 5 cards of a "hand"

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

var temporaryCards
func StraightflushChecker():
	StraightCheckerTemplate(temporaryCards, false)
	TypeChecker(temporaryCards)
	if heartCards >= 5:
		finalCards.append_array(heartCards)
		return true
	if spadeCards >= 5:
		finalCards.append_array(spadeCards)
		return true
	if clubCards >= 5:
		finalCards.append_array(clubCards)
		return true
	if diamondCards >= 5:
		finalCards.append_array(diamondCards)
		return true
	return false

func FourOfAKindChecker():
	if PairChecker("four") == 4:
		return true
	return false
	
func FullHouseChecker():
	#still need to make logic
	return false

func FlushChecker():
	TypeChecker(allCards)
	if heartCards >= 5:
		finalCards.append_array(heartCards)
		return true
	if spadeCards >= 5:
		finalCards.append_array(spadeCards)
		return true
	if clubCards >= 5:
		finalCards.append_array(clubCards)
		return true
	if diamondCards >= 5:
		finalCards.append_array(diamondCards)
		return true
	return false

func StraightChecker():
	StraightCheckerTemplate(finalCards, true)

func ThreeOfAKindChecker():
	if PairChecker("three") == 3:
		return true
	return false

func TwoPairChecker():
	#still need to make logic
	return false

func OnePairChecker():
	if PairChecker("twoo") == 2:
		return true
	return false

func StraightCheckerTemplate(saver, end):
	for i in 3:
		if allCards[i].number + 1 == allCards[i+1].number:
			if allCards[i+1].number + 1 == allCards[i+2].number:
				if allCards [i+2].number + 1 == allCards[i+3].number:
					if allCards[i+3].number + 1 == allCards[i+4].number:
						saver.append(allCards[i])
						saver.append(allCards[i+1])
						saver.append(allCards[i+2])
						saver.append(allCards[i+3])
						saver.append(allCards[i+4])
						if end == true:
							return true
	if end == true:
		return false


func PairChecker(string):
	var pairScore = 0
	for i in 6:
		if allCards[i].number == allCards[i+1].number:
			pairScore = 2
			if string.to_lower() == "two":
				finalCards.append(allCards[i])
				finalCards.append(allCards[i+1])
			if i <= 4:
				if allCards [i+1].number == allCards[i+2].number:
					pairScore = 3
					if string.to_lower() == "three":
						finalCards.append(allCards[i])
						finalCards.append(allCards[i+1])
						finalCards.append(allCards[i+2])
					if i <= 3:
						if allCards[i+2].number == allCards[i+3].number:
							pairScore = 4
							if string.to_lower() == "four":
								finalCards.append(allCards[i])
								finalCards.append(allCards[i+1])
								finalCards.append(allCards[i+2])
								finalCards.append(allCards[i+3])
	return pairScore

#array of cards of the same type
var heartCards
var spadeCards
var clubCards
var diamondCards

func TypeChecker(set):
	for card in set:
		if card.type == "h":
			heartCards.append(card)
		if card.type == "s":
			spadeCards.append(card)
		if card.type == "s":
			clubCards.append(card)
		if card.type == "d":
			diamondCards.append(card)


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
