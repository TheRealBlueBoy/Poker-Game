class_name Deck
var deck = []
func createCardDeck():
	addCardToDeck(2)
	addCardToDeck(3)
	addCardToDeck(4)
	addCardToDeck(5)
	addCardToDeck(6)
	addCardToDeck(7)
	addCardToDeck(8)
	addCardToDeck(9)
	addCardToDeck(10)
	addCardToDeck(11) #boer
	addCardToDeck(12) #queen
	addCardToDeck(13) #koning
	addCardToDeck(13) #ace
	return deck
	
	
func addCardToDeck(number): #adds card of every type for the number to the deck
	deck.append(StandardCard.new("h", number))
	deck.append(StandardCard.new("s", number))
	deck.append(StandardCard.new("d", number))
	deck.append(StandardCard.new("c", number))
	
	

	
