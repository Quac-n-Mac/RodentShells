#@icon ("res://addons/at-icons/node/globe.svg")
extends Node
var Steam = preload("res://Extra/steam_stub.gd").new()
##The script where data relavent to gameplay is stored between scenes


##All the different rank types
enum RANKS {
	##Best rank
	PERFECT,
	##2nd best rank
	GOLD,
	##2nd worst rank
	SILVER,
	##Worst rank
	BRONZE
	}
##The file icons (always add new ones after old ones or itll mess up saves)
enum FILE_ICONS{
	SWISS,
	GOUDA,
	KRAFT,
	NINEMIL,
	KNIFE,
	MAGNUM,
	GUTTER,
	GOLDEN_GUTTER,
	UFO,
	MASK,
	TRASH_GUY,
	CIGS,
	BABY,
	HAT,
	SPRAY_CAN,
	BALL,
	SKATEBOARD,
	RECORD,
	WALKMAN,
	CIGAR,
	TAMAGO,
	BLUE,
	TURD
	
}
var save_button:bool:
	set(value):
		save()
#region Registries
#Add worlds to here
##[World] registry
var worlds : Array[World] = [ #STEAMDEMO - add "demo" to the end of world1 (example: preload("res://Resources/worlds/world1demo.tres") )
	preload("res://Resources/worlds/world1demo.tres"),
	preload("res://Resources/worlds/world2.tres"), #STEAMDEMO remove any non steam demo content from this world
	preload("res://Resources/worlds/world3.tres"),
	#preload("res://Resources/worlds/bonus_world.tres"), this doesnt mean there will be a bonus world thatkid

	]

#Add level_info resources to here
##[LevelInfo] registry
var levels : Dictionary[StringName,LevelInfo] = { #STEAMDEMO - Comment out all levels past laundromanic, add in &"smoked_gouda_demo":preload("res://Resources/levels/level3demo.tres"),
	&"tutorial":preload("res://Resources/levels/tutorial.tres"),
	&"2010":preload("res://Resources/levels/level1.tres"),
	&"laundromanic":preload("res://Resources/levels/level2.tres"),
	&"smoked_gouda_demo":preload("res://Resources/levels/level3demo.tres"),
	#&"smoked_gouda":preload("res://Resources/levels/level3.tres"),
	#&"circuit_breaker":preload("res://Resources/levels/level4.tres"),
	#&"boss1":preload("res://Resources/levels/level5.tres"),
	#&"ratlabor":preload("res://Resources/levels/level7.tres"),
}
var controller_packs : Dictionary[String,ControllerButtonPack] = {
	"xbox":preload("res://Resources/controller_packs/xbox.tres"),
	"switch":preload("res://Resources/controller_packs/switch.tres"),
	"switch_joycons":preload("res://Resources/controller_packs/switch_jc.tres"),
	"switch_single_joycon":preload("res://Resources/controller_packs/switch_sjc.tres"),
	"playstation":preload("res://Resources/controller_packs/ps.tres")
	}
	
var default_save : Dictionary
#endregion

#region Save data (and closely related variables to save data)
##Total money collected on the save
var money:int = 0
##Total time played on save
var saveTime:float = 0.0
##The player's currently selected UI Theme
var uiTheme: = "res://Scenes/UI Themes/uitheme_default.tscn"
##If the player has viewed the license menu on the save
var seenLicenceMenu:bool = false
##If the player has viewed the popup notice on first load
var seenIntro:bool = false
##If the player has killed a pig and seen the tutorial tip on how they work
var killedPig:bool = false
##The players in game time when they first beat the game
var firstClear:float = -1.0
var fileIcon : FILE_ICONS
var unlockedIcons : Array[bool]
#endregion

#region Non Save Data
#region Steamworks
##Whether or not steamworks is enabled
var steam_enabled:bool = false
##Game id for steam
var steam_id:int #STEAMDEMO Set the correct steam ID in the project settings
#endregion
##Current version of the game
var version:String = "BROWSER DEMO VER. 1.42"
var controller_enabled : bool = false
var cur_controller : int = -1
var halloween : bool = false
##If the game is paused
var paused:bool = false
##If the game can be paused
var pausable:bool = true
##If the level timer is paused
var timePaused:bool = true
var canDie:bool = true
var cutscene:bool = true
##If the player has done the intro pose
var didPlayerIntro:bool = false
##Current level index of the world. Use [method World.GetLevel] and [method World.GetNextLevel] using this as the parameter
var levelIndex : int = 0
##The [LevelInfo] of the current level.
var currentLevel: LevelInfo = LevelInfo.new("Test","Test")
##The current [World]
var currentWorld: World
##The current screen of the level, used for the replay ghost to only display on the right screen
var currentScreen : int
##If the level is finished
var levelFinished:bool = false
##If the player is using cheats
var usedCheats:bool = false
##If the player has seen the intro
var seenMFGIntro:bool = false
##If the player used an alternate level entrance
var useAltEnterance:bool = false
##The target scene path. Must be a path to a [PackedScene]
var loading: = false
var targetScenePath:String = "res://Scenes/Levels/tutorial.tscn"
var blackLoading: = false
##The [TileMapLayer] that contains all the level tiles
var tileSet:TileMapLayer
##The colour of the rocks from breakable tiles and such
var rockColour: = Color("8175bdff")
##The [TileMapLayer] that contains the breakable tiles
var tileProperties:TileMapLayer
##Refrence to the [Player] in the current scene
var player : Player
var levelScene : LevelBase
var loadedLevelScenes:Array[PackedScene] = [null]

var loadingScreen:LoadingScreen
##Reference to the [DialogueBox] in the current scene
var dialogueBox:DialogueBox
##The x camera limits (x = left,y = right)
var camLimitX:= Vector2i(-10000000,100000000)
##The y camera limits (x = up,y = down)
var camLimitY:= Vector2i(-10000000,10000000)
##The zoom of the camera
var camZoom:Vector2 = Vector2(1,1)
##The spawn position of the player after death
var checkpointPos:Vector2
##Ammo that gets gotten at checkpoint
var checkpointAmmo:int = 2
var checkpointCamLimitX: = Vector2()
var checkpointCamLimitY: = Vector2()
##Whether or not the [Player] can be controlled
var inControl:bool = false
##loading transition
var loadTrans:String = "clear"
##If the player is using a custom checkpoint through the check command
var canHitChPoint:bool = true
##Master audio bus index
var busMaster:int = AudioServer.get_bus_index("Master")
##SFX audio bus index
var busSFX:int = AudioServer.get_bus_index("SFX")
##Music audio bus index
var busMusic:int = AudioServer.get_bus_index("Music")
##Ambience audio bus index
var busAmbience:int = AudioServer.get_bus_index("Ambience")
##Currently loaded mods
var mods: Array[Mod]
var controllerFocus: = preload("res://Extra/controller_focus.tres")
var mod_world = preload("res://Resources/worlds/mod_world.tres")
@onready var rng = RandomNumberGenerator.new()

##Timer for recording and playback of [GhostData]
@onready var ghost_timer = Timer.new()
##Current set of the [GhostData]
var ghost_step : int
var ghost_paused : bool = true
#endregion

#region Global Signals
signal checkHit()
signal purchased
signal transition(animName, nextAnim)
##emits every time [member ghost_timer] counts down
signal ghost_tick(step:int)
##emits when the level scene is ready
signal level_ready(l:LevelBase)
##emits when the player is ready
signal player_ready(p:Player)
##emits when the ghost reaches the end of its data
signal ghost_wins
##emits when the controller changes
signal controller_change
signal skip_cutscene()
signal toggled_freeze(active: bool)
#endregion

func _ready() -> void:
	_rs_web_setup()
	if OS.has_feature("web"):
		var cursor_guard = Node.new()
		cursor_guard.set_script(load("res://Extra/rs_cursor_guard.gd"))
		add_child(cursor_guard)
	_rs_prewarm()
	_rs_framelog_start()
	TranslationServer.set_locale("en_US")
	unlockedIcons.resize(FILE_ICONS.size())
	unlockedIcons[0] = true
	generateDefaultSave()
	controller_enabled = Input.get_connected_joypads().size() > 0
	if controller_enabled:
			cur_controller = 0
			var a = InputEventJoypadButton.new() 
			a.button_index = JOY_BUTTON_A
			a.device = -1
			var b = InputEventJoypadButton.new()
			b.button_index = JOY_BUTTON_B 
			b.device = -1
			if GetControllerPack().switch_a_and_b:
				if not InputMap.action_has_event("ui_accept",b):
					InputMap.action_add_event("ui_accept",b)
					if InputMap.action_has_event("ui_accept",a):
						InputMap.action_erase_event("ui_accept",a)
				if not InputMap.action_has_event("ui_cancel",a):
					InputMap.action_add_event("ui_cancel",a)
					if InputMap.action_has_event("ui_cancel",b):
						InputMap.action_erase_event("ui_cancel",b)
			else:
				if not InputMap.action_has_event("ui_accept",a):
					InputMap.action_add_event("ui_accept",a)
					if InputMap.action_has_event("ui_accept",b):
						InputMap.action_erase_event("ui_accept",b)
				if not InputMap.action_has_event("ui_cancel",b):
					InputMap.action_add_event("ui_cancel",b)
					if InputMap.action_has_event("ui_cancel",a):
						InputMap.action_erase_event("ui_cancel",a)
	if not mod_world.levels.is_empty():
		worlds.append(mod_world)
	add_child(ghost_timer)
	ghost_timer.wait_time = 1.0/60.0
	ghost_timer.paused = true
	Settings.loadsave()
	loadsave()
	Settings.update_all()
	halloween = Time.get_date_dict_from_system().month == 10 and Time.get_date_dict_from_system().day > 26 and Settings.seasonal
	ghost_timer.timeout.connect(GhostTick)
	if not FileAccess.file_exists("user://rat_names.txt"):
		var file = FileAccess.open("user://rat_names.txt",FileAccess.WRITE)
		if file:
			file.store_string("")
	if seenIntro:
		targetScenePath = "res://Scenes/title_screen.tscn"


func isEnglish()->bool:
	return TranslationServer.get_locale().get_slice("_",0)=="en"
func freeze_frame(time: float):
	if get_tree().paused: return
	pausable = false
	Engine.time_scale = 0.001
	toggled_freeze.emit(true)
	if time == 0.0:
		await get_tree().physics_frame
	else:
		await get_tree().create_timer(time, true, false, true).timeout
	Engine.time_scale = 1.0
	toggled_freeze.emit(false)
	pausable = true

func player_stop():
	player.state = player.States.IDLE
	player.animPlayer.play("idle")
	player.get_up()
	player.inputHori = 0
	player.stop_sparks()
	player.velocity.x = 0.0
	inControl = false
	player.sprite.scale = Vector2(1.0,1.0)
	await get_tree().physics_frame
	player.sprite.scale = Vector2(1.0,1.0)

func LoadScene(target:String=""):
	if not loadingScreen:
		loading = true
		loadingScreen = preload("res://Scenes/loading_screen.tscn").instantiate()
		loadingScreen.loaded = true
		loadingScreen.doing = true
		get_tree().root.add_child(loadingScreen)
	var cur_scene = get_tree().current_scene
	get_tree().current_scene = loadingScreen
	if target.is_empty():
		loadingScreen.set_target_scene(targetScenePath)
	else:
		loadingScreen.set_target_scene(target)
	cur_scene.queue_free()

func LoadLevelPaths():
	loadedLevelScenes.clear()
	loadedLevelScenes.resize(currentLevel.scene_paths.size())
	currentScreen = currentLevel.starting_screen
	loadingScreen.preload_levels = true
	for path in currentLevel.scene_paths:
		var s = ResourceLoader.load_threaded_get_status(path)
		if s == 0:
			ResourceLoader.load_threaded_request(path)
func ChangeLevelScreen(index:int):
	if index >=0 and index < currentLevel.scene_paths.size():
		var cur_scene = get_tree().current_scene
		get_tree().current_scene = loadingScreen
		loadingScreen.show()
		cur_scene.queue_free()
		if levelScene:
			levelScene.queue_free()
		
		if loadedLevelScenes[index]:
			var s = loadedLevelScenes[index].instantiate()
			loadingScreen.call_deferred("ChangeScene",s)
				
		else:
			loadingScreen.scene = currentLevel.scene_paths[index]
			loadingScreen.doing = false
			loadingScreen.loaded = false
		
	else:
		push_warning("non existent screen index")
##returns [LevelInfo] based on identifier
func GetLevel(identifier:StringName) -> LevelInfo:
	if levels.has(identifier):
		return levels[identifier]
	return null
func AddLevel(level_info:LevelInfo):
	if levels.has(level_info.identifier):
		push_warning("Tried adding level with identifier ", level_info.identifier,", but there is already a level with that identifier.")
		return
	levels[level_info.identifier] = level_info
func AddWorld(world:World):
	if worlds.has(world):
		push_warning("Tried to add duplicate world of identifier ", world.identifier,".")
		return
	worlds.append(world)
func GetSteamHandle()->int:
	var steam_handles : Array = Steam.getConnectedControllers()
	for h in steam_handles:
		var os_id = Steam.getGamepadIndexForController(h)
		if os_id == cur_controller:
			return h
	return -1

func GetControllerPack()-> ControllerButtonPack:
	#if steam_enabled:
		#var steam_cotroller = GetSteamHandle()
		#match Steam.getInputTypeForHandle(steam_cotroller):
			#Steam.INPUT_TYPE_PS3_CONTROLLER,Steam.INPUT_TYPE_PS4_CONTROLLER,Steam.INPUT_TYPE_PS5_CONTROLLER:
				#return controller_packs["playstation"]
			#Steam.INPUT_TYPE_SWITCH_PRO_CONTROLLER:
				#return controller_packs["switch"]
			#Steam.INPUT_TYPE_SWITCH_JOYCON_SINGLE:
				#return controller_packs["switch_single_joycon"]
			#Steam.INPUT_TYPE_SWITCH_JOYCON_PAIR:
				#return controller_packs["switch_joycons"]
	#else:
		var device_name = Input.get_joy_name(cur_controller)
		#print(device_name)
		match device_name:
			"Switch","Nintendo Switch Pro Controller":
				return controller_packs["switch"]
			"Nintendo Switch Joy-Con (L/R)":
				return controller_packs["switch_joycons"]
			"Nintendo Switch Joy-Con (L)", "Nintendo Switch Joy-Con (R)":
				return controller_packs["switch_single_joycon"]
			"Sony DualSense", "PS5 Controller", "PS4 Controller", \
			"Nacon Revolution Unlimited Pro Controller", "HORI Fighting Commander 4":
				return controller_packs["playstation"]
		return controller_packs["xbox"]

##returns [World] based on identifier
func GetWorld(identifier:StringName) -> World:
	for w in worlds:
		if w.identifier == identifier:
			return w
	return null

func generateDefaultSave():
	var saveData : Dictionary = {
		"money" : money,
		"levelStats" : {},
		"worldsUnlocked" : {},
		"saveTime" : saveTime,
		"seenLicenceMenu" : seenLicenceMenu,
		"seenIntro" : seenIntro,
		"killedPig" : killedPig,
		"firstClear" : firstClear,
		"fileIcon" : fileIcon,
		"unlockedIcons" : unlockedIcons
	}
	var ghostData : Dictionary ={}
	for l in levels.values():
		var data = {
			"money":l.money,
			"time":l.time,
			"deaths":l.deaths,
			"rank":l.rank,
			"locked":l.locked,
			"dare":l.dared,
			"wallets":l.stolen_wallets
			}
		saveData["levelStats"][l.identifier] = data
	for w in worlds:
		saveData["worldsUnlocked"][w.identifier] = w.locked
	default_save = saveData
	
func create_file(save:int):
	var file
	file = FileAccess.open(str("user://SaveFile", Settings.saveFile, ".dat"),FileAccess.WRITE)
	var data = default_save.duplicate(true)
	data["fileIcon"] = save-1
	data["unlockedIcons"][save-1] = true
	file.store_var(data,true)
	file.store_var({},true)
	file.close()

##Saves data to file
func save(save:int = 0) -> void:
	var file
	if save != 0:
		file = FileAccess.open(str("user://SaveFile", save, ".dat"),FileAccess.WRITE)
	else:
		file = FileAccess.open(str("user://SaveFile", Settings.saveFile, ".dat"),FileAccess.WRITE)
	var saveData : Dictionary = {
		"money" : money,
		"levelStats" : {},
		"worldsUnlocked" : {},
		"saveTime" : saveTime,
		"seenLicenceMenu" : seenLicenceMenu,
		"seenIntro" : seenIntro,
		"killedPig" : killedPig,
		"firstClear" : firstClear,
		"fileIcon" : fileIcon,
		"unlockedIcons" : unlockedIcons
		
}
	var ghostData:Dictionary
	for l in levels.values():
		var data = {
			"money":l.money,
			"time":l.time,
			"deaths":l.deaths,
			"rank":l.rank,
			"locked":l.locked,
			
			"dare":l.dared,
			"wallets":l.stolen_wallets
			}
		ghostData[l.identifier] = var_to_str(l.ghost_data)
		saveData["levelStats"][l.identifier] = data
	for w in worlds:
		saveData["worldsUnlocked"][w.identifier] = w.locked
	file.store_var(saveData,true)
	file.store_var(ghostData,true)
	file.close()

##loads data from file
func loadsave():
	var loadFile = FileAccess.open(str("user://SaveFile", Settings.saveFile, ".dat"),FileAccess.READ)
	var loadData : Dictionary
	var ghostData : Dictionary
	if FileAccess.file_exists(str("user://SaveFile", Settings.saveFile, ".dat")):
		var fd = loadFile.get_var(true)
		var gd = loadFile.get_var(true)
		if fd is Dictionary:
			loadData = fd
		if gd is Dictionary:
			ghostData = gd
	else:
		return
	SetVar(loadData,"money")
	SetVar(loadData,"saveTime")
	SetVar(loadData,"seenLicenceMenu")
	SetVar(loadData,"seenIntro")
	SetVar(loadData,"killedPig")
	SetVar(loadData,"firstClear")
	SetVar(loadData,"fileIcon")
	SetVar(loadData,"unlockedIcons")
	#wipe data
	for l in Global.levels.values():
		l.ghost_data = null
		var data = default_save["levelStats"][l.identifier]
		l.deaths = data["deaths"]
		l.rank = data["rank"]
		l.time = data["time"]
		l.money = data["money"]
		l.locked = data["locked"]
		l.dared = data["dare"]
		l.stolen_wallets = data["wallets"]
	#overrwrite data
	if loadData.has("levelStats"):
		for id in loadData["levelStats"].keys():
			var l = GetLevel(id)
			if l:
				var data = loadData["levelStats"][id]
				l.deaths = data["deaths"]
				l.rank = data["rank"]
				l.time = data["time"]
				l.money = data["money"]
				l.locked = data["locked"]
				l.dared = data["dare"]
				l.stolen_wallets = data["wallets"]

	if ghostData:

		for id in ghostData.keys():
			var l = GetLevel(id)
			if l:
				if not ghostData[id] is String:
					continue
				l.ghost_data = str_to_var(ghostData[id])
	if loadData.has("worldsUnlocked"):
		for id in loadData["worldsUnlocked"].keys():
			var w = GetWorld(id)
			if w:
				w.locked = loadData["worldsUnlocked"][id]
					
	unlockedIcons.resize(FILE_ICONS.size())
func get_level_percentage(level:LevelInfo):
	var levWallets = int(level.stolen_wallets.count(true))
	var percent = int(54 - (int(level.rank) * 12) + (levWallets * 12) + (int(level.dared )* 10))
	if level.time <= 0.0:
		percent = 0
	else:
		if not level.hasWallets:
			percent += 36
		if level.dare == "":
			percent += 10
	return percent


##Sets variable if it exists
func SetVar(dict:Dictionary,variable:StringName):
	if dict.has(variable):
		set(variable,dict[variable])
func GetFileIcon(icon:FILE_ICONS)->FileIcon:
	var node : FileIcon= null
	match icon:
		FILE_ICONS.SWISS:
			node = preload("res://Scenes/FileIcons/cheese_icon.tscn").instantiate()
		FILE_ICONS.GOUDA:
			node = preload("res://Scenes/FileIcons/gouda_cheese_icon.tscn").instantiate()
		FILE_ICONS.KRAFT:
			node = preload("res://Scenes/FileIcons/kraft_cheese_icon.tscn").instantiate()
		FILE_ICONS.NINEMIL:
			node = preload("res://Scenes/FileIcons/9mm_icon.tscn").instantiate()
		FILE_ICONS.KNIFE:
			node = preload("res://Scenes/FileIcons/knife_icon.tscn").instantiate()
		FILE_ICONS.MAGNUM:
			node = preload("res://Scenes/FileIcons/magnum_icon.tscn").instantiate()
		FILE_ICONS.GUTTER:
			node = preload("res://Scenes/FileIcons/gutter_icon.tscn").instantiate()
		FILE_ICONS.GOLDEN_GUTTER:
			node = preload("res://Scenes/FileIcons/golden_gutter_icon.tscn").instantiate()
		FILE_ICONS.UFO:
			node = preload("res://Scenes/FileIcons/ufo_icon.tscn").instantiate()
		#FILE_ICONS.MASK: #STEAMDEMO Comment this
			#node = preload("res://Scenes/FileIcons/mask_icon.tscn").instantiate()
		FILE_ICONS.TRASH_GUY:
			node = preload("res://Scenes/FileIcons/trash_guy_icon.tscn").instantiate()
		FILE_ICONS.CIGS:
			node = preload("res://Scenes/FileIcons/cigs_icon.tscn").instantiate()
		FILE_ICONS.BABY:
			node = preload("res://Scenes/FileIcons/baby_icon.tscn").instantiate()
		FILE_ICONS.SPRAY_CAN:
			node = preload("res://Scenes/FileIcons/spray_icon.tscn").instantiate()
		FILE_ICONS.BALL:
			node = preload("res://Scenes/FileIcons/ball_icon.tscn").instantiate()
		FILE_ICONS.BLUE:
			node = preload("res://Scenes/FileIcons/blue_cheese_icon.tscn").instantiate()
		FILE_ICONS.TAMAGO:
			node = preload("res://Scenes/FileIcons/tamago_icon.tscn").instantiate()
		FILE_ICONS.RECORD:
			node = preload("res://Scenes/FileIcons/record_icon.tscn").instantiate()
		FILE_ICONS.WALKMAN:
			node = preload("res://Scenes/FileIcons/walkman_icon.tscn").instantiate()
		FILE_ICONS.TURD:
			node = preload("res://Scenes/FileIcons/turd_icon.tscn").instantiate()
		_:
			node = preload("res://Scenes/FileIcons/error_icon.tscn").instantiate()
	return node

##Call this to reset and start the ghost timer and ticking
func GhostStart():
	if currentLevel.identifier == "tutorial" or not LevelStats.ghostData:
		return
	ghost_step = 0
	ghost_paused = false
	#GhostTick()

##to end the ghost ticking 
##set [member Global.ghost_timer.paused] to false to pause the ghost timer
func GhostStop():
	ghost_paused = true
	ghost_step = 0
func _physics_process(delta: float) -> void:
	if not ghost_paused and not Global.timePaused:
		GhostTick()

#every 1/60 of a second
##Called every timeout of the [member ghost_timer]
func GhostTick():
	if currentLevel.identifier == "tutorial" or not player: return
	LevelStats.ghostData.AddStep(player.global_position,currentScreen,player.sprite.flip_h,player.sprite.frame,player.sprite.transform)
	ghost_tick.emit(ghost_step)
	if currentLevel and currentLevel.ghost_data:
		if currentLevel.ghost_data.positions.size()-1==ghost_step:
			ghost_wins.emit()
	ghost_step += 1

# ____________________________________ #
# |            CHEAT SHEET           | #
# |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~| #
# |Tile types: 1-Tar, 2-Taggable Wall| #
# |__________________________________| #

# ---------------------------------------------------------------------------
# RodentShells web save transfer (web only).
# SAVE button downloads rodentshells-save.txt: every user:// file, JSON-packed,
# XOR-obfuscated and base64'd with a trailing SHA-256 integrity check.
# LOAD button reads it back, verifies the checksum, restores files, reloads.
# This deters casual save editing; it is not real security.
# ---------------------------------------------------------------------------
const RS_OBF_KEY := "RODENTSHELLS-OBF-v1"
var _rs_cb_export = null
var _rs_cb_import = null
const RS_INJECT_JS := """
(function(){
if (window.__rsSaveBar) return;
window.__rsSaveBar = true;
var bar = document.createElement('div');
bar.style.cssText = 'position:fixed;right:8px;top:8px;z-index:9999;display:flex;gap:6px;';
function mk(t,fn){var b=document.createElement('button');b.textContent=t;
 b.style.cssText='font:12px monospace;padding:6px 10px;background:#111;color:#f7a8d8;border:2px solid #f7a8d8;border-radius:6px;cursor:pointer;';
 b.onclick=fn;return b;}
var inp = document.createElement('input');
inp.type='file'; inp.accept='.txt'; inp.style.display='none';
inp.onchange=function(){var f=inp.files[0];if(!f)return;var r=new FileReader();
 r.onload=function(){if(window.rsImport)window.rsImport(r.result);};
 r.readAsText(f); inp.value='';};
bar.appendChild(mk('SAVE',function(){if(window.rsExport)window.rsExport();}));
bar.appendChild(mk('LOAD',function(){inp.click();}));
bar.appendChild(inp);
function add(){if(document.body){document.body.appendChild(bar);}else{setTimeout(add,200);}}
add();
})();
"""

func _rs_web_setup() -> void:
	if not OS.has_feature("web"):
		return
	JavaScriptBridge.eval(RS_INJECT_JS, true)
	var win = JavaScriptBridge.get_interface("window")
	_rs_cb_export = JavaScriptBridge.create_callback(_rs_on_export)
	_rs_cb_import = JavaScriptBridge.create_callback(_rs_on_import)
	win.rsExport = _rs_cb_export
	win.rsImport = _rs_cb_import

func _rs_scan(path: String, out: Dictionary) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var n := dir.get_next()
	while n != "":
		if n != "." and n != "..":
			var p := path.path_join(n)
			if p.begins_with("user://logs"):
				n = dir.get_next()
				continue
			if dir.current_is_dir():
				_rs_scan(p, out)
			else:
				var f := FileAccess.open(p, FileAccess.READ)
				if f:
					out[p] = Marshalls.raw_to_base64(f.get_buffer(f.get_length()))
		n = dir.get_next()
	dir.list_dir_end()

func _rs_sha256(b: PackedByteArray) -> PackedByteArray:
	var h := HashingContext.new()
	h.start(HashingContext.HASH_SHA256)
	h.update(b)
	return h.finish()

func _rs_obf(b: PackedByteArray) -> PackedByteArray:
	var k := RS_OBF_KEY.to_utf8_buffer()
	for i in b.size():
		b[i] = b[i] ^ k[i % k.size()]
	return b

func _rs_on_export(_args) -> void:
	var payload := JSON.stringify(_rs_collect()).to_utf8_buffer()
	var data := _rs_obf(payload)
	var box := data + _rs_sha256(data)
	JavaScriptBridge.download_buffer(Marshalls.raw_to_base64(box).to_utf8_buffer(), "rodentshells-save.txt", "text/plain")

func _rs_collect() -> Dictionary:
	var out := {}
	_rs_scan("user://", out)
	return out

func _rs_on_import(args) -> void:
	if args.size() < 1:
		return
	var box := Marshalls.base64_to_raw(str(args[0]).strip_edges())
	if box.size() < 33:
		JavaScriptBridge.eval("alert('That save file is not valid.');", true)
		return
	var data := box.slice(0, box.size() - 32)
	var sig := box.slice(box.size() - 32)
	if _rs_sha256(data) != sig:
		JavaScriptBridge.eval("alert('That save file failed its integrity check (edited or corrupt). Not loading it.');", true)
		return
	var text := _rs_obf(data).get_string_from_utf8()
	var dict = JSON.parse_string(text)
	if typeof(dict) != TYPE_DICTIONARY:
		JavaScriptBridge.eval("alert('That save file is not valid.');", true)
		return
	for p in dict.keys():
		var path := str(p)
		if not path.begins_with("user://"):
			continue
		DirAccess.make_dir_recursive_absolute(path.get_base_dir())
		var f := FileAccess.open(path, FileAccess.WRITE)
		if f:
			f.store_buffer(Marshalls.base64_to_raw(str(dict[p])))
			f.close()
	JavaScriptBridge.eval("alert('Save imported - reloading.'); location.reload();", true)

# ---------------------------------------------------------------------------
# RodentShells web shader/asset prewarm (web only).
# Instantiates one of every enemy/effect/particle/animated scene, every
# material, shader and SpriteFrames resource for a few frames behind a
# "Compiling shaders..." overlay so GL programs compile before gameplay.
# Skip with ?noprewarm in the URL (used for before/after measurement).
# ---------------------------------------------------------------------------
var _rs_prewarm_cache = []
var _rs_prewarm_done = false
const RS_PREWARM_KEYS := ["enemy", "enemies", "effect", "particle", "vfx", "explos", "muzzle", "flash", "smoke", "spark", "blood", "debris", "bullet", "projectile", "weapon", "boss", "impact", "trail", "laser", "gore", "splat", "casing", "animated", "critter", "monster", "alien", "ghost", "fx", "gun"]

func _rs_prewarm() -> void:
	if not OS.has_feature("web"):
		return
	var q = JavaScriptBridge.eval("String(window.location.search||'')", true)
	if q != null and "autotest" in str(q):
		call_deferred("_rs_autotest")
	if q != null and "noprewarm" in str(q):
		print("RS prewarm: skipped via ?noprewarm")
		_rs_prewarm_done = true
		return
	call_deferred("_rs_prewarm_run")

# Headless test hook (web only, ?autotest in URL): press the first-boot Done
# button twice so scripted runs reach gameplay without pixel clicks.
func _rs_autotest() -> void:
	var tree = get_tree()
	for w in range(7200):
		if _rs_prewarm_done:
			break
		await tree.process_frame
	for tries in range(40):
		await tree.create_timer(0.75).timeout
		var nodes = tree.root.find_children("*", "Node2D", true, false)
		for n in nodes:
			if n.has_method("_on_done_pressed"):
				print("RS autotest: pressing done x2 paused=",tree.paused," scale=",Engine.time_scale)
				n._on_done_pressed()
				print("RS autotest: first done returned")
				await tree.create_timer(3.0).timeout
				n._on_done_pressed()
				print("RS autotest: done")
				if "testpillar" in str(JavaScriptBridge.eval("String(location.search)", true)):
					call_deferred("_rs_test_pillar")
				if "rsmeasure" in str(JavaScriptBridge.eval("String(location.search)", true)):
					call_deferred("_rs_measure_actions")
				return
	print("RS autotest: setup screen not found")

func _rs_scan_ext(path: String, exts: Array, out: Array) -> void:
	var d = DirAccess.open(path)
	if d == null:
		return
	d.list_dir_begin()
	var n = d.get_next()
	while n != "":
		if not n.begins_with("."):
			var p = path.path_join(n)
			if d.current_is_dir():
				_rs_scan_ext(p, exts, out)
			else:
				var lower = n.to_lower()
				for e in exts:
					if e == "*" or lower.ends_with(e) or lower.ends_with(e + ".remap"):
						out.append(p.trim_suffix(".remap").trim_suffix(".remap"))
						break
		n = d.get_next()
	d.list_dir_end()

func _rs_pw_load(p):
	var r = ResourceLoader.load(p)
	if r != null:
		_rs_prewarm_cache.append(r)
	return r

# Collect render/audio resources from packed scene data, without instantiating
# gameplay nodes or running _ready(), signals, collisions, or interactions.
var _rs_seen_resources = {}
var _rs_warm_resources = []
func _rs_collect_visual(value, depth = 0):
	if depth > 12: return
	if value is Resource:
		var id = value.get_instance_id()
		if _rs_seen_resources.has(id): return
		_rs_seen_resources[id] = true
		if value is Script: return
		if value is Texture2D or value is Material or value is AudioStream or value is SpriteFrames:
			_rs_warm_resources.append(value)
		if value is PackedScene:
			var state = value.get_state()
			for i in state.get_node_count():
				_rs_collect_visual(state.get_node_instance(i), depth + 1)
				for j in state.get_node_property_count(i):
					_rs_collect_visual(state.get_node_property_value(i, j), depth + 1)
		elif not value is Texture2D:
			for prop in value.get_property_list():
				if prop.usage & PROPERTY_USAGE_STORAGE:
					_rs_collect_visual(value.get(prop.name), depth + 1)
	elif value is Array:
		for entry in value: _rs_collect_visual(entry, depth + 1)
	elif value is Dictionary:
		for entry in value.values(): _rs_collect_visual(entry, depth + 1)

func _rs_prewarm_run() -> void:
	var t_start = Time.get_ticks_msec()
	var tree = get_tree()
	var overlay = CanvasLayer.new()
	overlay.layer = 128
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	tree.root.add_child(overlay)
	var bg = ColorRect.new()
	bg.color = Color(0.02, 0.02, 0.05, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(bg)
	var lbl = Label.new()
	lbl.text = "STARTUP CHECK\nReading object resources..."
	lbl.add_theme_font_size_override("font_size", 28)
	lbl.add_theme_color_override("font_color", Color(0.97, 0.66, 0.85))
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bg.add_child(lbl)
	var bar = ProgressBar.new()
	bar.position = Vector2(340, 470)
	bar.size = Vector2(600, 28)
	bar.show_percentage = true
	bg.add_child(bar)
	var stage_layer = CanvasLayer.new()
	stage_layer.layer = 127
	stage_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	tree.root.add_child(stage_layer)
	var stage = Node2D.new()
	stage.position = Vector2(100,100)
	stage_layer.add_child(stage)
	await tree.process_frame
	await RenderingServer.frame_post_draw
	var paths = ["res://Scenes/Levels/tutorial.tscn", "res://Scenes/pillar.tscn",
		"res://Scenes/player.tscn",
		"res://Scenes/FX/fxdust.tscn", "res://Scenes/FX/fxdust2.tscn",
		"res://Scenes/FX/fxgunshot.tscn", "res://Scenes/FX/fxgunshot2.tscn",
		"res://Scenes/FX/fxboost.tscn", "res://Scenes/FX/fxhit2.tscn",
		"res://Scenes/FX/fxslice.tscn", "res://Scenes/FX/crack.tscn",
		"res://Scenes/bullet_casing.tscn", "res://Scenes/player_bullet.tscn",
		"res://Scenes/bullet.tscn", "res://Scenes/bullet2.tscn", "res://Scenes/bullet3.tscn",
		"res://Scenes/bullet_aim.tscn"]
	paths.sort()
	# Cache objects, not every whole level. PackedScene.get_state is data only.
	for i in paths.size():
		var res = _rs_pw_load(paths[i])
		_rs_collect_visual(res)
		lbl.text = "STARTUP CHECK\nObject definitions " + str(i+1) + "/" + str(paths.size())
		bar.value = 25.0 * (i+1) / max(1,paths.size())
		await tree.process_frame
	var files = []
	_rs_scan_ext("res://", [".tres", ".material", ".gdshader"], files)
	files = files.filter(func(p): return not ("/palettes/" in p.to_lower() or "/addons/" in p.to_lower() or "/Mods/" in p))
	files.sort()
	for i in files.size():
		_rs_collect_visual(_rs_pw_load(files[i]))
		bar.value = 25.0 + 20.0 * (i+1) / max(1,files.size())
		lbl.text = "STARTUP CHECK\nReading graphics and audio " + str(i+1) + "/" + str(files.size())
		if i % 8 == 0: await tree.process_frame
	print("RS warm collected objects=",paths.size()," files=",files.size()," resources=",_rs_warm_resources.size()," ms=",Time.get_ticks_msec()-t_start)
	var img = Image.create(8,8,false,Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	var white = ImageTexture.create_from_image(img)
	var slots = []
	for j in range(8):
		var spr = Sprite2D.new()
		spr.scale = Vector2(0.01,0.01)
		stage.add_child(spr)
		var part = GPUParticles2D.new()
		part.amount = 8
		part.lifetime = 0.1
		part.texture = white
		part.visibility_rect = Rect2(-100,-100,200,200)
		stage.add_child(part)
		slots.append([spr,part])
	var counts = {"textures":0,"materials":0,"particles":0,"sounds":0,"frames":0}
	var _frames_drawn = 0
	for i in _rs_warm_resources.size():
		var r = _rs_warm_resources[i]
		var sprite = slots[i % 8][0]
		var particles = slots[i % 8][1]
		sprite.material = null
		sprite.texture = white
		particles.emitting = false
		if r is Texture2D:
			sprite.texture = r
			counts.textures += 1
		elif r is ParticleProcessMaterial:
			# Retain definitions only. Live particle tests remain unsafe on WebGL.
			counts.particles += 1
		elif r is Material:
			sprite.material = r
			counts.materials += 1
		elif r is SpriteFrames:
			for an in r.get_animation_names():
				for f in r.get_frame_count(an):
					var tx = r.get_frame_texture(an,f)
					if tx == null: continue
					sprite.texture = tx
					_frames_drawn += 1
					if _frames_drawn % 8 == 0:
						await tree.process_frame
						await RenderingServer.frame_post_draw
			counts.frames += 1
		elif r is AudioStreamOggVorbis or r is AudioStreamWAV or r is AudioStreamMP3:
			# Decode a short buffer offline. Never route test sounds to a bus.
			var playback = r.instantiate_playback()
			if playback != null:
				playback.start(0.0)
				playback.mix_audio(1.0,512)
				playback.stop()
			counts.sounds += 1
		lbl.text = "STARTUP CHECK\nGraphics / particle / audio test " + str(i+1) + "/" + str(_rs_warm_resources.size())
		bar.value = 45.0 + 50.0 * (i+1) / max(1,_rs_warm_resources.size())
		if i % 20 == 0: print("RS warm test ",i,"/",_rs_warm_resources.size()," ",r.resource_path)
		if i % 8 == 7 or i == _rs_warm_resources.size()-1:
			await tree.process_frame
			await RenderingServer.frame_post_draw
	# Narrow pillar-only render test: native particles built from scene data.
	# No gameplay instantiation, scripts, signals, sub-emitters, or force_draw.
	lbl.text = "STARTUP CHECK\nTesting pillar debris..."
	var pillar_scene = load("res://Scenes/pillar.tscn")
	var state = pillar_scene.get_state()
	var pillar_parts = []
	for n in state.get_node_count():
		if state.get_node_type(n) != &"GPUParticles2D": continue
		var gp = GPUParticles2D.new()
		gp.process_mode = Node.PROCESS_MODE_ALWAYS
		for j in state.get_node_property_count(n):
			var key = state.get_node_property_name(n,j)
			if key in [&"texture",&"amount",&"lifetime",&"one_shot",&"explosiveness",&"process_material",&"visibility_rect"]:
				gp.set(key,state.get_node_property_value(n,j))
		stage.add_child(gp)
		gp.restart()
		gp.emitting = true
		pillar_parts.append(gp)
		await tree.process_frame
		await RenderingServer.frame_post_draw
	await tree.create_timer(0.15).timeout
	for gp in pillar_parts: gp.queue_free()
	await tree.process_frame
	print("RS pillar debris warm done count=",pillar_parts.size())
	# First-use warmup for the common player actions (shoot/jump/slide):
	# instantiate each tiny FX scene once behind the overlay and render it,
	# so scene setup, animation players, materials and particles are ready.
	lbl.text = "STARTUP CHECK\nTesting action effects..."
	var fx_paths = ["res://Scenes/FX/fxdust.tscn", "res://Scenes/FX/fxdust2.tscn",
		"res://Scenes/FX/fxgunshot.tscn", "res://Scenes/FX/fxgunshot2.tscn",
		"res://Scenes/FX/fxboost.tscn", "res://Scenes/FX/fxhit2.tscn",
		"res://Scenes/FX/fxslice.tscn", "res://Scenes/bullet_casing.tscn"]
	for pth in fx_paths:
		var ps = load(pth)
		if ps == null: continue
		var inst = ps.instantiate()
		stage.add_child(inst)
		if inst.has_method("do_fx"):
			inst.do_fx(false)
		await tree.process_frame
		await RenderingServer.frame_post_draw
		if is_instance_valid(inst): inst.queue_free()
		await tree.process_frame
	print("RS action fx warm done")
	# Route every collected sound through the real audio path once, inaudibly,
	# so the first in-game play does not initialise the playback pipeline.
	lbl.text = "STARTUP CHECK\nTesting audio playback..."
	var audio_players = []
	for j in range(4):
		var ap = AudioStreamPlayer.new()
		ap.volume_db = -80.0
		stage.add_child(ap)
		audio_players.append(ap)
	var snd_idx = 0
	for r in _rs_warm_resources:
		if not (r is AudioStream): continue
		if r.get_length() > 4.0: continue
		var ap2 = audio_players[snd_idx % 4]
		ap2.stop()
		ap2.stream = r
		ap2.play()
		snd_idx += 1
		if snd_idx % 16 == 0: print("RS audio warm ",snd_idx)
		if snd_idx % 4 == 0:
			await tree.process_frame
			await RenderingServer.frame_post_draw
	await tree.process_frame
	await RenderingServer.frame_post_draw
	for ap3 in audio_players:
		ap3.stop()
		ap3.queue_free()
	print("RS audio playback warm done count=",snd_idx)
	# Stage shaders use natural draws. No force_draw and no gameplay instancing.
	for slot in slots: slot[1].emitting = false
	lbl.text = "STARTUP CHECK\nPreparing first level..."
	bar.value = 96
	bar.value = 100
	await tree.process_frame
	stage_layer.queue_free()
	overlay.queue_free()
	_rs_prewarm_done = true
	print("RS prewarm done in ",Time.get_ticks_msec()-t_start,"ms categories=",counts)

func _rs_wake_particles(node: Node) -> void:
	if node is GPUParticles2D or node is CPUParticles2D:
		node.process_mode = Node.PROCESS_MODE_ALWAYS
		node.emitting = true
	for c in node.get_children():
		_rs_wake_particles(c)

# Frame-time logger for headless before/after lag measurement (web only).
var _rs_ft = []
var _rs_ft_t0 := 0
var _rs_ft_elapsed := 0.0
var _rs_ft_dumps := 0

func _rs_framelog_start() -> void:
	if not OS.has_feature("web"):
		return
	_rs_ft_t0 = Time.get_ticks_msec()

func _process(delta: float) -> void:
	if _rs_ft_t0 == 0 or _rs_ft_dumps >= 8:
		return
	_rs_ft.append(delta)
	_rs_ft_elapsed += delta
	if _rs_ft_elapsed >= 15.0:
		_rs_ft_elapsed = 0.0
		_rs_ft_dumps += 1
		var over25 := 0
		var over50 := 0
		var over100 := 0
		var mx := 0.0
		var spike_sum := 0.0
		for d in _rs_ft:
			var ms = d * 1000.0
			if ms > mx:
				mx = ms
			if ms > 25.0:
				over25 += 1
				spike_sum += ms
			if ms > 50.0:
				over50 += 1
			if ms > 100.0:
				over100 += 1
		print("RSFRAMELOG t=", Time.get_ticks_msec() - _rs_ft_t0, " frames=", _rs_ft.size(), " over25ms=", over25, " over50ms=", over50, " over100ms=", over100, " max_ms=", snapped(mx, 0.1), " spike_ms=", snapped(spike_sum, 0.1))
		_rs_ft.clear()

func _rs_test_pillar():
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(levelScene) and levelScene.has_method("skip_cutscene"):
		levelScene.skip_cutscene()
		print("RS test cutscene skipped")
	await get_tree().create_timer(2.0).timeout
	var p = load("res://Scenes/pillar.tscn").instantiate()
	p.position = player.position + Vector2(100,0)
	get_tree().current_scene.add_child(p)
	await get_tree().create_timer(1.0).timeout
	var t = Time.get_ticks_msec()
	p.destroy()
	var call_ms = Time.get_ticks_msec()-t
	await RenderingServer.frame_post_draw
	print("RS PILLAR first break call_ms=",call_ms," draw_ms=",Time.get_ticks_msec()-t)
	await get_tree().create_timer(3.0).timeout
	p.queue_free()

# Headless first-use lag measurement (web only, ?autotest&rsmeasure in URL).
# Calls each player action twice, logging call time and the next 3 rendered
# frame times, so first-use spikes can be compared before/after changes.
func _rs_measure_actions():
	var tree = get_tree()
	await tree.create_timer(2.0).timeout
	if is_instance_valid(levelScene) and levelScene.has_method("skip_cutscene"):
		levelScene.skip_cutscene()
		print("RSMEASURE cutscene skipped")
	for i in range(1200):
		await tree.process_frame
		if is_instance_valid(player):
			break
	# Headless intro does not grant control; force the post-intro state.
	inControl = true
	didPlayerIntro = true
	await tree.create_timer(1.0).timeout
	print("RSMEASURE begin player_valid=", is_instance_valid(player), " inControl=", inControl)
	if not is_instance_valid(player):
		print("RSMEASURE aborted: no player")
		return
	var seq = [["jump",0],["slide",1],["shoot",2],["jump",0],["slide",1],["shoot",2]]
	var n = 0
	for a in seq:
		n += 1
		var t0 = Time.get_ticks_usec()
		match a[1]:
			0: player.jump()
			1: player.slide(false)
			2: player.shoot(false,false)
		var call_ms = (Time.get_ticks_usec()-t0)/1000.0
		var frames = []
		for k in range(3):
			var f0 = Time.get_ticks_usec()
			await RenderingServer.frame_post_draw
			frames.append((Time.get_ticks_usec()-f0)/1000.0)
		print("RSMEASURE n=",n," action=",a[0]," call_ms=",snapped(call_ms,0.01)," f1_ms=",snapped(frames[0],0.01)," f2_ms=",snapped(frames[1],0.01)," f3_ms=",snapped(frames[2],0.01))
		await tree.create_timer(1.2).timeout
	print("RSMEASURE end")
