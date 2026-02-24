@tool
class_name CandlestickMARes
extends Resource


## 均线名称
@export var label_name: String:
	set(value):
		label_name = value
		self.emit_changed()

## 周期
@export var period: int:
	set(value):
		period = value
		self.emit_changed()

## 线条颜色
@export var color: Color = Color(1, 0, 0):
	set(value):
		color = value
		self.emit_changed()


static func create(label_name: String, period: int, color: Color) -> CandlestickMARes:
	var res: CandlestickMARes = CandlestickMARes.new()
	res.label_name = label_name
	res.period = period
	res.color = color
	return res
