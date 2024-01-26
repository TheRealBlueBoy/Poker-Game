class_name GameMode
var cardDeck
var players
var betPerPlayer
var bigBlind
var smallBlind
var actingPlayer

enum PlayerStatus {pending, raised, folded, broke, allIn}
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # 
func Setup():
	pass
func SetupTable():
	pass
func SetupPlayers():
	pass
func SetupDeck():
	pass

#gamecycle
func StartTurn():
	pass
func EndTurn():
	pass
func StartRound():
	pass
func EndRound():
	pass
func RevealCard():
	pass
func DecideWinner():
	pass
func DealCards():
	pass
func ShuffleDeck():
	pass
