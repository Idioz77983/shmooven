extends Node

var LocalPlayerName : String = "Blobert"
var LocalPlayerId : int
var IsHost : bool = false
var HasTraitOn : bool = false
var RoundTime : int = 0

var equiped_things = []

var Traits = [
	"Grapple",
	"Parry"
]
var Weapons = [
	"Sword",
	"Scythe",
	"Bow"
]


## Settings stuff ##
var default_FOV : float = 90
