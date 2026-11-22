extends VBoxContainer

var getting: = true

func _ready() -> void:
	if OS.has_feature("web"):
		process_mode = Node.PROCESS_MODE_ALWAYS
		$Fullscreen.show()
	get_values()
	set_values(null)

func get_values():
	getting = true
	$VSync.button_pressed = Settings.VSync
	$Fullscreen.button_pressed = Settings.fullscreen
	if Settings.MaxFPS < 1:
		$FPS/HSlider.value = 61
		$FPS/Percent.text = "∞"
	else:
		$FPS/HSlider.value = (Settings.MaxFPS / 2.0)
		$FPS/Percent.text = str(Settings.MaxFPS)
	$LowDetail.button_pressed = Settings.lowDetail
	$ConRumble.button_pressed = Settings.conRumble
	$ScreenShake/HSlider.value = (Settings.screenShake * 8)
	$ScreenShake/Percent.text = str(int(Settings.screenShake * 100), "%")
	$LockMouse.button_pressed = Settings.lockMouse
	$SkipMFG.button_pressed = Settings.skipMFGIntro
	$RepeatStory.button_pressed = Settings.repeatStory
	$RepeatLvlName.button_pressed = Settings.repeatLvlName
	$Leaderboard.button_pressed = Settings.leaderboard
	$SpeedrunTimer.button_pressed = Settings.speedrunTimer
	$OldUI.button_pressed = Settings.oldUI
	$GhostVisibility/HSlider.value = (Settings.ghostVisibility * 8)
	$GhostVisibility/Percent.text = str(int(Settings.ghostVisibility * 100), "%")
	getting = false

func set_values(value):
	if not getting:
		if value is bool:
			if value:
				$"../../../../CheckboxOn".play()
			else:
				$"../../../../CheckboxOff".play()
		Settings.VSync = $VSync.button_pressed
		Settings.fullscreen = $Fullscreen.button_pressed
		if $FPS/HSlider.value > 60:
			Settings.MaxFPS = 0
			$FPS/Percent.text = "∞"
		else:
			Settings.MaxFPS = ($FPS/HSlider.value * 2.0)
			$FPS/Percent.text = str(Settings.MaxFPS)
		Settings.lowDetail = $LowDetail.button_pressed
		Settings.conRumble = $ConRumble.button_pressed
		Settings.screenShake = float($ScreenShake/HSlider.value / 8.0)
		$ScreenShake/Percent.text = str(int(Settings.screenShake * 100), "%")
		Settings.lockMouse = $LockMouse.button_pressed
		Settings.skipMFGIntro = $SkipMFG.button_pressed
		Settings.repeatStory = $RepeatStory.button_pressed
		Settings.repeatLvlName = $RepeatLvlName.button_pressed
		Settings.leaderboard = $Leaderboard.button_pressed
		Settings.speedrunTimer = $SpeedrunTimer.button_pressed
		Settings.oldUI = $OldUI.button_pressed
		if Settings.oldUI:
			Global.uiTheme = "res://Scenes/UI Themes/uitheme_old.tscn"
		else:
			Global.uiTheme = "res://Scenes/UI Themes/uitheme_default.tscn"
		Settings.ghostVisibility = float($GhostVisibility/HSlider.value / 8.0)
		$GhostVisibility/Percent.text = str(int(Settings.ghostVisibility * 100), "%")
		if Settings.VSync:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		else:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		if Settings.fullscreen:
			if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_MAXIMIZED and DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		Engine.max_fps = Settings.MaxFPS
		#if Global.inLevel:
			#Global.player.update_options()

# Reflect browser fullscreen changes without emitting another toggle action.
func _process(_delta: float) -> void:
	if OS.has_feature("web") and is_visible_in_tree():
		$Fullscreen.show()
		var actual = bool(JavaScriptBridge.eval("!!document.fullscreenElement", true))
		Settings.fullscreen = actual
		$Fullscreen.set_pressed_no_signal(actual)
