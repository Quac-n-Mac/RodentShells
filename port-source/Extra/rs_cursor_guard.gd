extends Node

var last_active = -1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	Settings.fullscreen = bool(JavaScriptBridge.eval("!!document.fullscreenElement", true))
	# Read real game state even while the pause tree is stopped.
	var level = Global.levelScene
	var active = is_instance_valid(level) and level.is_inside_tree()
	active = active and not (Global.paused or get_tree().paused or Global.loading or Global.levelFinished)
	active = active and Global.currentLevel != null and Global.levels.has(Global.currentLevel.identifier)
	var value = 1 if active else 0
	if value != last_active:
		last_active = value
		JavaScriptBridge.eval("if(window.rsSetGameplayCapture) window.rsSetGameplayCapture(" + ("true" if active else "false") + ");", true)
		if active and Settings.lockMouse:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		elif active:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
