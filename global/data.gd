extends Node

enum CharacterStyle {CHARACTER, BLOND, PLAYER, GREEN, FIRE, GRASS, ICE, PURPLE, STRAW, BOY, GIRL}
enum Location {OVERWORLD, HOUSE, HOSPITAL, GRASS_ARENA, FIRE_ARENA}
enum Monster {SPARCHU, ATROX, JACANA, CINDRILL, CLEAF, DRAEM, FINIETTE, FINSTA, FRIOLERA, GULFIN, IVIERON, LARVEA, PLUMA, PLUMETTE, POUCH, VULKEO}
enum Element {FIRE, WATER, PLANT}
enum Attack {CLAW, FIRE, ICE, WATER, HEAL, EXPLOSION}
enum MenuState {MAIN, ATTACK, DEFEND, SWAP, CATCH, SELECT}
enum Biome {GRASS, DESERT, ICE}

const ANIMATION_SPEED = 6
const TILE_ANIMATION_SPEED = 2
const character_view_directions = {
	Vector2i.DOWN: 0, 
	Vector2i.LEFT: 1, 
	Vector2i.RIGHT: 2, 
	Vector2i.UP: 3,
	Vector2i.ZERO: 0,
	Vector2i(1,1) : 2, # down right
	Vector2i(1,-1) : 2, # up right
	Vector2i(-1,1) : 1, # down left
	Vector2i(-1,-1) : 1, # up left
		}
const character_texture_data = {
	CharacterStyle.PLAYER: "res://graphics/characters/player.png",
	CharacterStyle.GREEN: "res://graphics/characters/green.png",
	CharacterStyle.BLOND: "res://graphics/characters/blond.png",
	CharacterStyle.CHARACTER: "res://graphics/characters/character.png",
	CharacterStyle.FIRE: "res://graphics/characters/fire_boss.png",
	CharacterStyle.GRASS: "res://graphics/characters/grass_boss.png",
	CharacterStyle.ICE: "res://graphics/characters/ice_boss.png",
	CharacterStyle.STRAW: "res://graphics/characters/straw.png",
	CharacterStyle.PURPLE: "res://graphics/characters/purple.png",
	CharacterStyle.BOY: "res://graphics/characters/young_boy.png",
	CharacterStyle.GIRL: "res://graphics/characters/young_girl.png",
	}
const LEVEL_PATHS = {
	Location.OVERWORLD: "res://scenes/levels/overworld.tscn",
	Location.HOUSE: "res://scenes/levels/house.tscn",
	Location.HOSPITAL: "res://scenes/levels/hospital.tscn",
	Location.GRASS_ARENA: "res://scenes/levels/plant_arena.tscn",
	Location.FIRE_ARENA: "res://scenes/levels/fire_arena.tscn"
}
const monster_data = {
	Monster.SPARCHU: {
		'name': 'Sparchu', 
		'battle texture': "res://graphics/battle sprites/Sparchu.png",
		'icon texture': "res://graphics/menu sprites/Sparchu.png",
		'stats': {'max hp': 10, 'max ep': 2, 'speed': 1},
		'attacks': {0: Attack.CLAW, 12: Attack.FIRE, 24: Attack.HEAL, 30: Attack.EXPLOSION},
		'element': Element.FIRE},
	Monster.CINDRILL: {
		'name': 'Cindrill', 
		'battle texture': "res://graphics/battle sprites/Cindrill.png",
		'icon texture': "res://graphics/menu sprites/Cindrill.png",
		'stats': {'max hp': 14, 'max ep': 12, 'speed': 1},
		'attacks': {0: Attack.CLAW, 12: Attack.FIRE, 24: Attack.HEAL, 30: Attack.EXPLOSION},
		'element': Element.FIRE},
	Monster.VULKEO: {
		'name': 'Vulkeo', 
		'battle texture': "res://graphics/battle sprites/Vulkeo.png",
		'icon texture': "res://graphics/menu sprites/Vulkeo.png",
		'stats': {'max hp': 17, 'max ep': 14, 'speed': 1,},
		'attacks': {0: Attack.CLAW, 12: Attack.FIRE, 24: Attack.HEAL, 30: Attack.EXPLOSION},
		'element': Element.FIRE},
	Monster.GULFIN: {
		'name': 'Gulfin', 
		'battle texture': "res://graphics/battle sprites/Gulfin.png",
		'icon texture': "res://graphics/menu sprites/Gulfin.png",
		'stats': {'max hp': 9, 'max ep': 8, 'speed': 0.8},
		'attacks': {0: Attack.CLAW, 12: Attack.FIRE, 24: Attack.HEAL, 30: Attack.EXPLOSION},
		'element': Element.WATER},
	Monster.ATROX: {
		'name': 'Atrox', 
		'battle texture': "res://graphics/battle sprites/Atrox.png",
		'icon texture': "res://graphics/menu sprites/Atrox.png",
		'stats': {'max hp': 12, 'max ep': 8, 'speed': 2},
		'attacks': {0: Attack.CLAW, 12: Attack.FIRE, 24: Attack.HEAL, 30: Attack.EXPLOSION},
		'element': Element.FIRE,},
	Monster.JACANA: {
		'name': 'Jacana', 
		'battle texture': "res://graphics/battle sprites/Jacana.png",
		'icon texture': "res://graphics/menu sprites/Jacana.png",
		'stats': {'max hp': 3,'max ep': 0.4, 'speed': 4},
		'attacks': {0: Attack.CLAW, 12: Attack.FIRE, 24: Attack.HEAL, 30: Attack.EXPLOSION},
		'element': Element.FIRE},
	
	
	}
const attack_data = {
	Attack.CLAW:  {
		'name': 'Claw', 
		'offensive': true, 
		'cost': 10, 
		'amount': 10, 
		'element': Element.PLANT,
		'texture': "res://graphics/attack effects/attack7.png",
		'sound': "res://audio/scratch.mp3"},
	Attack.FIRE:  {
		'name': 'Fire', 
		'offensive': true, 
		'cost': 12, 
		'amount': 15, 
		'element': Element.FIRE,
		'texture': "res://graphics/attack effects/attack5.png",
		'sound': "res://audio/fire.wav"},
	Attack.WATER: {
		'name': 'Splash', 
		'offensive': true, 
		'cost': 9, 
		'amount': 11, 
		'element': Element.WATER,
		'texture': "res://graphics/attack effects/attack3.png",
		'sound': "res://audio/splash.wav"},
	Attack.ICE: {
		'name': 'Ice shards', 
		'offensive': true, 
		'cost': 13, 
		'amount': 20, 
		'element': Element.WATER,
		'texture': "res://graphics/attack effects/attack1.png",
		'sound': "res://audio/ice.mp3"},
	Attack.EXPLOSION: {
		'name': 'Explode', 
		'offensive': true, 
		'cost': 20, 
		'amount': 100, 
		'element': Element.FIRE,
		'texture': "res://graphics/attack effects/attack4.png",
		'sound': "res://audio/explosion.mp3"},
	Attack.HEAL:   {
		'name': 'Heal', 
		'offensive': false, 
		'cost': 15, 
		'amount': -30, 
		'element': Element.PLANT,
		'texture': "res://graphics/attack effects/attack6.png",
		'sound': "res://audio/green.wav"}}
const element_modifier = {
	Element.FIRE: {Element.FIRE: 1, Element.WATER: 0.5, Element.PLANT: 2},
	Element.WATER: {Element.FIRE: 2, Element.WATER: 1, Element.PLANT: 0.5},
	Element.PLANT: {Element.FIRE: 0.5, Element.WATER: 2, Element.PLANT: 1}}

var current_char: Character
var current_loc: Data.Location
var char_data = {
	
}
