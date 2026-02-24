@tool
class_name CandlestickDataRes
extends Resource

@export var timestamp: String:
	set(value):
		timestamp = value
		self.emit_changed()

@export var open: float:
	set(value):
		open = value
		self.emit_changed()

@export var close: float:
	set(value):
		close = value
		self.emit_changed()

@export var high: float:
	set(value):
		high = value
		self.emit_changed()

@export var low: float:
	set(value):
		low = value
		self.emit_changed()


static func create(timestamp: String , open: float, close: float, high: float, low: float) -> CandlestickDataRes:
	var res: CandlestickDataRes = CandlestickDataRes.new()
	res.timestamp = timestamp
	res.open = open
	res.close = close
	res.high = high
	res.low = low
	return res