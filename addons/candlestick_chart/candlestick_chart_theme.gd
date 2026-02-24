@tool
class_name CandlestickChartTheme
extends Resource


## 枚举：图例位置
enum LegendPosition {
	## 图例在上方
	TOP,
	## 图例在下方
	BOTTOM
}


## 背景颜色
@export var background_color: Color = Color(1, 1, 1, 1.0):
	set(value):
		background_color = value
		self.emit_changed()


@export_group("Chart", "chart")

## 图表背景颜色
@export var chart_background_color: Color = Color(1, 1, 1, 0.0):
	set(value):
		chart_background_color = value
		self.emit_changed()

@export_subgroup("Margins", "chart_margin")

## 图表外边距-左
@export var chart_margin_left: float = 0.0:
	set(value):
		chart_margin_left = value
		self.emit_changed()

## 图表外边距-右
@export var chart_margin_right: float = 0.0:
	set(value):
		chart_margin_right = value
		self.emit_changed()

## 图表外边距-上
@export var chart_margin_top: float = 0.0:
	set(value):
		chart_margin_top = value
		self.emit_changed()

## 图表外边距-下
@export var chart_margin_bottom: float = 0.0:
	set(value):
		chart_margin_bottom = value
		self.emit_changed()


@export_group("Candlestick", "candlestick")

## 阳线颜色
@export var candlestick_color_up: Color = Color(0.05490196, 0.84705883, 0.05490196):
	set(value):
		candlestick_color_up = value
		self.emit_changed()

## 阴线颜色
@export var candlestick_color_down: Color = Color(0.9098039, 0.1254902, 0.1254902):
	set(value):
		candlestick_color_down = value
		self.emit_changed()

## 是否阳线空心
@export var candlestick_hollow_when_up: bool = false:
	set(value):
		candlestick_hollow_when_up = value
		self.emit_changed()

## 是否自动计算蜡烛图厚度（根据数据点数量和可用宽度），如果为 true，则忽略 candlestick_wick_thickness、candlestick_border_thickness 和 candlestick_body_width_ratio 的设置
@export var candlestick_auto_thickness: bool = true:
	set(value):
		candlestick_auto_thickness = value
		self.notify_property_list_changed()
		self.emit_changed()

## 蜡烛图的影线宽度（当 candlestick_auto_thickness 为 false 时生效）
@export var candlestick_wick_thickness: float = 1.0:
	set(value):
		candlestick_wick_thickness = value
		self.emit_changed()

## 蜡烛图的边框宽度（当 candlestick_auto_thickness 为 false 时生效）
@export var candlestick_border_thickness: float = 1.0:
	set(value):
		candlestick_border_thickness = value
		self.emit_changed()

## 蜡烛图实体宽度占单个数据点宽度的比例（0.0 - 1.0），当 candlestick_auto_thickness 为 false 时生效
@export var candlestick_body_width_ratio: float = 0.8:
	set(value):
		candlestick_body_width_ratio = value
		self.emit_changed()

## 最小实体宽度（像素），当 candlestick_auto_thickness 为 true 时生效
@export var candlestick_min_body_width: float = 1.0:
	set(value):
		candlestick_min_body_width = value
		self.emit_changed()

# Grid appearance and behaviour
@export_group("Grid", "grid")

## 显示纵向网格线
@export var grid_show_y: bool = true:
	set(value):
		grid_show_y = value
		self.emit_changed()

## 显示横向网格线
@export var grid_show_x: bool = true:
	set(value):
		grid_show_x = value
		self.emit_changed()

## 网格线颜色
@export var grid_color: Color = Color(0.8, 0.8, 0.8, 0.5):
	set(value):
		grid_color = value
		self.emit_changed()

## 网格线间距（像素）
@export var grid_spacing: float = 50.0:
	set(value):
		grid_spacing = value
		self.emit_changed()

# Y axis appearance and labels
@export_group("Y Axis", "y_axis")

## 显示纵坐标轴
@export var y_axis_show: bool = true:
	set(value):
		y_axis_show = value
		self.emit_changed()

## 纵坐标轴背景颜色
@export var y_axis_background_color: Color = Color(1, 1, 1, 0.0):
	set(value):
		y_axis_background_color = value
		self.emit_changed()

## 纵坐标宽度
@export var y_axis_width: float = 50.0:
	set(value):
		y_axis_width = value
		self.emit_changed()

## 纵坐标自动刻度
@export var y_axis_auto_ticks: bool = true:
	set(value):
		y_axis_auto_ticks = value
		self.notify_property_list_changed()
		self.emit_changed()

## 纵坐标刻度数量（当 y_axis_auto_ticks 为 false 时生效）
@export var y_axis_tick_count: int = 5:
	set(value):
		y_axis_tick_count = value
		self.emit_changed()

## 纵坐标轴颜色
@export var y_axis_color: Color = Color(0.2, 0.2, 0.2):
	set(value):
		y_axis_color = value
		self.emit_changed()

## 纵坐标刻度长度
@export var y_axis_tick_length: float = 6.0:
	set(value):
		y_axis_tick_length = value
		self.emit_changed()

## 纵坐标轴厚度
@export var y_axis_thickness: float = 1.0:
	set(value):
		y_axis_thickness = value
		self.emit_changed()

## 纵坐标刻度值与轴线之间的额外间距百分比（0.0 - 1.0），用于避免刻度值过于靠近轴线
@export var y_axis_scale_value_padding_pct: float = 0.05:
	set(value):
		y_axis_scale_value_padding_pct = value
		self.emit_changed()

## 显示纵坐标标签
@export var y_axis_show_labels: bool = true:
	set(value):
		y_axis_show_labels = value
		self.notify_property_list_changed()
		self.emit_changed()

@export_subgroup("Labels", "y_axis_label")

## 纵坐标标签颜色
@export var y_axis_label_color: Color = Color(0.2, 0.2, 0.2):
	set(value):
		y_axis_label_color = value
		self.emit_changed()

## 纵坐标标签字体
@export var y_axis_label_font: Font = null:
	set(value):
		y_axis_label_font = value
		self.emit_changed()

## 纵坐标标签字体大小
@export var y_axis_label_size: int = 16:
	set(value):
		y_axis_label_size = value
		self.emit_changed()

## 纵坐标标签精度（小数位数）
@export var y_axis_label_precision: int = 2:
	set(value):
		y_axis_label_precision = value
		self.emit_changed()


# X axis extras: 可配置的刻度数量与像素间距（由 _draw 传入）
@export_group("X Axis", "x_axis")

## 显示横坐标轴
@export var x_axis_show: bool = true:
	set(value):
		x_axis_show = value
		self.emit_changed()

## 横坐标轴背景颜色
@export var x_axis_background_color: Color = Color(1, 1, 1, 0.0):
	set(value):
		x_axis_background_color = value
		self.emit_changed()

## 横坐标高度
@export var x_axis_height: float = 30.0:
	set(value):
		x_axis_height = value
		self.emit_changed()

## 横坐标刻度数量
@export var x_axis_tick_count: int = 5:
	set(value):
		x_axis_tick_count = value
		self.emit_changed()

## 横坐标轴颜色
@export var x_axis_color: Color = Color(0.2, 0.2, 0.2):
	set(value):
		x_axis_color = value
		self.emit_changed()

## 横坐标刻度长度
@export var x_axis_tick_length: float = 6.0:
	set(value):
		x_axis_tick_length = value
		self.emit_changed()

## 被省略的横坐标刻度的长度比例（0.0 - 1.0），当标签被省略时使用
@export var x_axis_omitted_tick_ratio: float = 0.5:
	set(value):
		x_axis_omitted_tick_ratio = clamp(value, 0.0, 1.0)
		self.emit_changed()

## 横坐标轴厚度
@export var x_axis_thickness: float = 1.0:
	set(value):
		x_axis_thickness = value
		self.emit_changed()

## 显示横坐标标签
@export var x_axis_show_labels: bool = true:
	set(value):
		x_axis_show_labels = value
		self.notify_property_list_changed()
		self.emit_changed()

@export_subgroup("Labels", "x_axis_label")

## 横坐标标签颜色
@export var x_axis_label_color: Color = Color(0.2, 0.2, 0.2):
	set(value):
		x_axis_label_color = value
		self.emit_changed()

## 横坐标标签字体
@export var x_axis_label_font: Font = null:
	set(value):
		x_axis_label_font = value
		self.emit_changed()

## 横坐标标签字体大小
@export var x_axis_label_size: int = 16:
	set(value):
		x_axis_label_size = value
		self.emit_changed()

@export_group("Legend", "legend")

## 图例背景颜色
@export var legend_background_color: Color = Color(1, 1, 1, 0.0):
	set(value):
		legend_background_color = value
		self.emit_changed()

## 图例区域高度
@export var legend_height: float = 20.0:
	set(value):
		legend_height = value
		self.emit_changed()

## 图例位置
@export var legend_position: LegendPosition = LegendPosition.TOP:
	set(value):
		legend_position = value
		self.emit_changed()

@export_subgroup("Margins", "legend_margin")

## 图例左边距
@export var legend_margin_left: float = 0.0:
	set(value):
		legend_margin_left = value
		self.emit_changed()

## 图例右边距
@export var legend_margin_right: float = 0.0:
	set(value):
		legend_margin_right = value
		self.emit_changed()

## 图例上边距
@export var legend_margin_top: float = 0.0:
	set(value):
		legend_margin_top = value
		self.emit_changed()

## 图例下边距
@export var legend_margin_bottom: float = 0.0:
	set(value):
		legend_margin_bottom = value
		self.emit_changed()

@export_subgroup("Padding", "legend_padding")

@export var legend_padding_left: float = 0.0:
	set(value):
		legend_padding_left = value
		self.emit_changed()

@export var legend_padding_right: float = 0.0:
	set(value):
		legend_padding_right = value
		self.emit_changed()

@export var legend_padding_top: float = 0.0:
	set(value):
		legend_padding_top = value
		self.emit_changed()

@export var legend_padding_bottom: float = 0.0:
	set(value):
		legend_padding_bottom = value
		self.emit_changed()

@export_subgroup("Spacing", "legend_spacing")

## 图例水平间距
@export var legend_spacing_horizontal: float = 10.0:
	set(value):
		legend_spacing_horizontal = value
		self.emit_changed()

## 图例垂直间距
@export var legend_spacing_vertical: float = 5.0:
	set(value):
		legend_spacing_vertical = value
		self.emit_changed()

@export_subgroup("Label", "legend_label")

## 图例标签大小
@export var legend_label_size: float = 14.0:
	set(value):
		legend_label_size = value
		self.emit_changed()

## 图例字体
@export var legend_label_font: Font = null:
	set(value):
		legend_label_font = value
		self.emit_changed()

## 图例字号
@export var legend_label_font_size: int = 14:
	set(value):
		legend_label_font_size = value
		self.emit_changed()

## 图例字体颜色
@export var legend_label_font_color: Color = Color(0.2, 0.2, 0.2):
	set(value):
		legend_label_font_color = value
		self.emit_changed()

## 图例标签精度（小数位数）
@export var legend_label_precision: int = 2:
	set(value):
		legend_label_precision = value
		self.emit_changed()

## 图例标签与文本之间的间距
@export var legend_label_spacing: float = 5.0:
	set(value):
		legend_label_spacing = value
		self.emit_changed()

@export_group("MA", "ma")

## 显示均线
@export var ma_show: bool = true:
	set(value):
		ma_show = value
		self.emit_changed()

## 均线宽度
@export var ma_thickness: float = 2.0:
	set(value):
		ma_thickness = value
		self.emit_changed()


func _validate_property(property: Dictionary) -> void:
	if property.name == "candlestick_wick_thickness" and self.candlestick_auto_thickness:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "candlestick_border_thickness" and self.candlestick_auto_thickness:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "y_axis_tick_count" and self.y_axis_auto_ticks:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "y_axis_label_color" and not self.y_axis_show_labels:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "y_axis_label_font" and not self.y_axis_show_labels:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "y_axis_label_size" and not self.y_axis_show_labels:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "y_axis_label_precision" and not self.y_axis_show_labels:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "x_axis_label_color" and not self.x_axis_show_labels:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "x_axis_label_font" and not self.x_axis_show_labels:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "x_axis_label_size" and not self.x_axis_show_labels:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "x_axis_label_precision" and not self.x_axis_show_labels:
		property.usage = PROPERTY_USAGE_NO_EDITOR
