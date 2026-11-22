extends Control

@export var music: = preload("res://Music/TitleScreen.ogg")

var didIntro: = false

var main_hover:Button

func _ready():
	if Global.controller_enabled:
		$CL/VBox/Start.grab_focus()
	Music.stream = music
	AudioServer.set_bus_effect_enabled(2,0, false)
	Global.currentLevel = LevelInfo.new("test","test")
	$CL/VBox.process_mode = Node.PROCESS_MODE_INHERIT
	$CL/LevelSelect.process_mode = Node.PROCESS_MODE_DISABLED
	if Time.get_date_dict_from_system().month == 12 and Time.get_date_dict_from_system().day > 16:
		$Snow.emitting = true
	elif Global.halloween:
		$Background/ParallaxLayer/BG.texture = load("res://Art/BGTitleHalloween.png")
	$CL/Version.text = str(Global.version)
	if not (Settings.skipMFGIntro or Global.seenMFGIntro):
		Global.seenMFGIntro = true
		await $CL/MFGIntro/AnimPlayer.animation_finished
	didIntro = true
	Music.begin()
	$CL/MFGIntro.queue_free()
	$CL/AnimPlayer.play("intro")
	$CL/SprayCan/AnimPlayer.play("anim")
	$CL/Title/Splash.play()
	$CL/SprayCan.show()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		if $CL/Socials/youtube.has_focus():
			main_hover.grab_focus()
	if Global.controller_enabled:
		var f = get_tree().root.gui_get_focus_owner()
		if not f or f == $CL/TitleButton:
			if $CL/VBox/Start.focus_mode == FocusMode.FOCUS_ALL:
				$CL/VBox/Start.grab_focus()

func SetLanguage(locale:String):
	TranslationServer.set_locale(locale)
	TranslationServer.clear()

func on_play_pressed() -> void:
	if didIntro:
		if Settings.marathonMode:
			Global.currentLevel = Global.levels.values()[1]
			Global.targetScenePath = Global.levels.values()[1].scene_paths[Global.currentLevel.starting_screen]
			var world = World.new()
			world.levels = Global.levels.values()
			world.name = "Marathon"
			world.identifier = "marathon"
			Global.currentWorld = world
			Global.levelIndex = 1
			Global.pausable = true
			get_tree().paused = false
			Global.checkpointPos = Vector2(0, 0)
			Cheats.noClip = false
			Global.camLimitX = Vector2i(-10000000, 10000000)
			Global.camLimitY = Vector2i(-10000000, 10000000)
			Global.levelFinished = false
			LevelStats.reset()
			LevelStats.ResetMarathon()
			#get_tree().change_scene_to_file("res://Scenes/loading_screen.tscn")
			Global.LoadScene()
			Global.LoadLevelPaths()
		$CL/LevelSelect.enabled = true
		#$CL/AnimPlayer.stop()
		$CL/AnimPlayer.play("level_select")
		$CL/Socials.hide()
		$CL/VBox/Start.focus_mode = FocusMode.FOCUS_NONE
		release_focus()
		$CL/TitleButton.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		$CL/LevelSelect.Refresh()
		$CL/LevelSelect.process_mode = Node.PROCESS_MODE_INHERIT
		$CL/VBox.process_mode = Node.PROCESS_MODE_DISABLED
		$CL/LevelSelect/AnimPlayer.play("enter")
		$CL/LevelSelect.show()
		#DiscordRPC.state = "In Menu"
		#DiscordRPC.details = "Level Select"
		#DiscordRPC.refresh()
		#Global.targetScenePath = "res://Scenes/test_zone3.tscn"
		#get_tree().change_scene_to_file("res://Scenes/loading_screen.tscn")

func on_options_pressed() -> void:
	$CL/Options.show()
	$CL/Options._ready()
	$Background.hide()
	$CL/VBox.process_mode = Node.PROCESS_MODE_DISABLED
	$CL/TitleButton.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	#DiscordRPC.state = "In Menu"
	#DiscordRPC.details = "Options"
	#DiscordRPC.refresh()
	#if Global.controller_enabled:
		#$CL/Options/TabContainer/Controls/VSplitContainer/Controls.mode = ControlsMenu.MODES.controller

func on_options_back_pressed() -> void:
	$CL/Options.hide()
	$Background.show()
	$CL/VBox/Options.grab_focus()
	$CL/VBox.process_mode = Node.PROCESS_MODE_INHERIT
	$CL/TitleButton.set_mouse_filter(Control.MOUSE_FILTER_PASS)
	#DiscordRPC.state = "In Menu"
	#DiscordRPC.details = "Title Screen"
	#DiscordRPC.refresh()

func on_level_select_back_pressed() -> void:
	$CL/LevelSelect.enabled = false
	$CL/VBox/Start.focus_mode = FocusMode.FOCUS_ALL
	$CL/AnimPlayer.stop()
	$CL/AnimPlayer.play("level_select_exit")
	$CL/LevelSelect/AnimPlayer.play("exit")
	$CL/LevelSelect.album_unselect(false)
	$CL/VBox.process_mode = Node.PROCESS_MODE_INHERIT
	$CL/VBox/Start.grab_focus()
	$CL/Socials.show()
	$CL/TitleButton.set_mouse_filter(Control.MOUSE_FILTER_PASS)
	await $CL/LevelSelect/AnimPlayer.animation_finished
	if not $CL/LevelSelect.enabled:
		$CL/LevelSelect.process_mode = Node.PROCESS_MODE_DISABLED
		$CL/LevelSelect.hide()
	#DiscordRPC.state = "In Menu"
	#DiscordRPC.details = "Title Screen"
	#DiscordRPC.refresh()

func on_leave_pressed() -> void:
	if OS.has_feature("web"):
		get_tree().paused = true
		JavaScriptBridge.eval("if(window.rsQuitToBrowser) window.rsQuitToBrowser();", true)
		return
	get_tree().quit()

func _on_twitter_pressed() -> void:
	$CL/Socials/twitter/AudioStreamPlayer.play()
	OS.shell_open("https://x.com/MaceFaceGames")

func _on_discord_pressed() -> void:
	$CL/Options/ControlTypeSwitch.play()
	OS.shell_open("https://discord.com/invite/tCym5ZKQaH")

func _on_youtube_pressed() -> void:
	$CL/Options/ControlTypeSwitch.play()
	OS.shell_open("https://www.youtube.com/@RetroCrowDev")

func _on_start_focus_entered() -> void:
	main_hover = $CL/VBox/Start

func _on_options_focus_entered() -> void:
	main_hover = $CL/VBox/Options

func _on_quit_focus_entered() -> void:
	main_hover = $CL/VBox/Quit

func _on_google_form_pressed() -> void:
	OS.shell_open("https://forms.gle/7X7pyWbYqUXVwsTg7")
