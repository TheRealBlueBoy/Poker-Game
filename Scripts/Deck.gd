class_name Deck
var deck
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
	deck.append(Card.new("h", number))
	deck.append(Card.new("s", number))
	deck.append(Card.new("d", number))
	deck.append(Card.new("c", number))
	
	
	
