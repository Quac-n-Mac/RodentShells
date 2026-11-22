extends Control
class_name LoadingScreen
var scene: = ""
var progress: = []
var sceneLoadStatus: = 0
var doing: = false
var loaded = false
var preload_levels = false
var delay:float = 0
var time:float = 0.0

var request_started = false
var request_serial = 0
var transition_start = 0

signal instantiated

func _ready():
	Global.loadingScreen = self
	RenderingServer.set_default_clear_color(Color.BLACK)
	$TextureRect/Pattern.position.x = randf_range(0, -600)
	set_target_scene(Global.targetScenePath)

func set_target_scene(target:String):
	loaded = false
	request_started = false
	request_serial += 1
	progress.clear()
	sceneLoadStatus = 0
	scene = target
	doing = false
	show()
	time = 0.0
	transition_start = Time.get_ticks_msec()
	_rs_request_after_paint(request_serial)

func _rs_request_after_paint(serial):
	# A web export can do expensive resource work on the browser main thread.
	# Present the loading screen before allowing that work to begin.
	while OS.has_feature("web") and not Global._rs_prewarm_done:
		await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	if serial != request_serial: return
	var error = ResourceLoader.load_threaded_request(scene)
	request_started = error == OK
	if not request_started:
		push_error("Unable to load scene: " + scene)
		$Percent.text = "Load failed"
func _process(delta):
	if loaded:
		if preload_levels and Global.currentLevel:
			var index = 0
			var complete = 0
			for i in Global.currentLevel.scene_paths:
				if Global.loadedLevelScenes[index]: 
					complete += 1
					index += 1
					continue
				var stat = ResourceLoader.load_threaded_get_status(i)
				if stat == ResourceLoader.THREAD_LOAD_LOADED:
					Global.loadedLevelScenes[index] = ResourceLoader.load_threaded_get(i)
				index += 1
			if complete == index:
				preload_levels = false
	else:
		if not request_started: return
		time += delta
		sceneLoadStatus = ResourceLoader.load_threaded_get_status(scene,progress)
		if not progress.is_empty():
			$Percent.text = str(int(progress[0] * 100), "%")
		if sceneLoadStatus == ResourceLoader.THREAD_LOAD_LOADED:
			if not doing:
				doing = true
				loaded = true
				Global.loading = false
				#$TextureRect/AnimPlayer.play("fade")
				#await $TextureRect/AnimPlayer.animation_finished
				var p =  ResourceLoader.load_threaded_get(scene)
				if Global.currentLevel:
					Global.loadedLevelScenes[Global.currentLevel.starting_screen] = p
				# Paint the completed loading state before scene instantiation.
				await get_tree().process_frame
				await RenderingServer.frame_post_draw
				var s = p.instantiate()
				call_deferred("ChangeScene",s)
				#var p = ResourceLoader.load_threaded_get(scene)
				
				#WorkerThreadPool.add_task(func():
					#var s = p.instantiate()
					#call_deferred("ChangeScene",s)
					#)
			
func ChangeScene(scene:Node):
	if delay > 0:
		var t = max(delay - time,0.0)
		if t>0.0:
			await get_tree().create_timer(t).timeout
	delay = 0.0
	hide()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	Global.loading = false
	print("RS transition ready ", scene.scene_file_path, " elapsed_ms=", Time.get_ticks_msec() - transition_start)
	#print("hi")
