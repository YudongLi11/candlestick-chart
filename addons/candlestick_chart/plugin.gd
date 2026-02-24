@tool
extends EditorPlugin


func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	var script = load("res://addons/candlestick_chart/candlestick_chart.gd")
	var icon = load("res://addons/candlestick_chart/icon.svg")
	self.add_custom_type("CandlestickChart", "Control", script, icon)


func _exit_tree() -> void:
	self.remove_custom_type("CandlestickChart")
