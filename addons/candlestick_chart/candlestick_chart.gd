@tool
class_name CandlestickChart
extends Control


#region Exported Properties

## 数据列表
@export var data: Array[CandlestickDataRes] = []:
	set(value):
		if data != null and data.size() > 0:
			for d: CandlestickDataRes in data:
				if d != null and d.changed.is_connected(self._on_data_changed):
					d.changed.disconnect(self._on_data_changed)
		if value != null and value.size() > 0:
			for d: CandlestickDataRes in value:
				if d == null:
					continue
				d.changed.connect(self._on_data_changed)
		data = value
		self._vilid_data.clear()
		for vd: CandlestickDataRes in data:
			if vd != null:
				self._vilid_data.append(vd)
		self._cur_display_data_count = self.default_display_data_count
		self._on_data_changed()

## 均线列表（周期），例如 [5, 10, 20] 表示绘制5日、10日和20日均线
@export var moving_averages: Array[CandlestickMARes] = []:
	set(value):
		if moving_averages != null and moving_averages.size() > 0:
			for ma: CandlestickMARes in moving_averages:
				if ma != null and ma.changed.is_connected(self._on_moving_average_changed):
					ma.changed.disconnect(self._on_moving_average_changed)
		if value != null and value.size() > 0:
			for ma: CandlestickMARes in value:
				if ma == null:
					continue
				ma.changed.connect(self._on_moving_average_changed)
		moving_averages = value
		self._on_moving_average_changed()

## 默认展示的数据数量
@export var default_display_data_count: int = 30:
	set(value):
		default_display_data_count = max(1, value)
		self._cur_display_data_count = default_display_data_count

## 是否开启交互
@export var interactive: bool = true

## 缩放步长（每次放大/缩小改变的数据数量）
@export var zoom_step: int = 5:
	set(value):
		zoom_step = max(1, value)

@export var custom_theme: CandlestickChartTheme = CandlestickChartTheme.new():
	set(value):
		if custom_theme != null and custom_theme.changed.is_connected(self._on_custom_theme_changed):
			custom_theme.changed.disconnect(self._on_custom_theme_changed)
		if value == null:
			value = CandlestickChartTheme.new()
		custom_theme = value
		custom_theme.changed.connect(self._on_custom_theme_changed)
		self._on_custom_theme_changed()

@export_group("Theme Overrides")

#endregion

var _vilid_data: Array[CandlestickDataRes] = []
var _cur_display_data: Array[CandlestickDataRes] = []
var _sma_dictionary: Dictionary[String, Array] = {}
var _cur_display_data_count: int = self.default_display_data_count:
	set(value):
		_cur_display_data_count = clamp(value, 1, self._vilid_data.size())
		self._cur_display_data = self._vilid_data.slice(
			max(0, self._vilid_data.size() - self._cur_display_data_count),
			self._vilid_data.size()
		)
		self.queue_redraw()


func _ready() -> void:
	self.clip_contents = true


func get_vilid_data() -> Array:
	return self._vilid_data


#region Draw Functions

func _draw() -> void:
	if self.custom_theme == null:
		return
	
	# ========== 计算数值 ==========
	self._compute_all_sma()
	# ============================
	
	# ========== 计算区域 ==========
	var rect: Rect2 = self.get_rect()
	var legend_at_top: bool = self.custom_theme.legend_position == CandlestickChartTheme.LegendPosition.TOP
	var top_offset: float = \
			self.custom_theme.legend_height + self.custom_theme.legend_margin_top + self.custom_theme.legend_margin_bottom \
			if legend_at_top else 0.0
	var chart_left: float = self.custom_theme.y_axis_width + self.custom_theme.chart_margin_left
	var chart_right: float = rect.size.x - self.custom_theme.chart_margin_right
	var chart_width: float = max(0.0, chart_right - chart_left)
	var chart_height: float = rect.size.y - self.custom_theme.x_axis_height - self.custom_theme.legend_height \
			- self.custom_theme.chart_margin_top - self.custom_theme.chart_margin_bottom \
			- self.custom_theme.legend_margin_top - self.custom_theme.legend_margin_bottom
	var chart_top: float = top_offset
	var chart_bottom: float = chart_top + chart_height + self.custom_theme.chart_margin_bottom

	# 图表绘图区域（考虑外边距和 Y 轴宽度），X 轴在绘图区下方对齐
	var chart_rect: Rect2 = Rect2(Vector2(chart_left, chart_top), Vector2(chart_width, max(0.0, chart_height)))
	# Y 轴区域（宽度为主题里设置的 y_axis_width）
	var y_axis_rect: Rect2 = \
		Rect2(Vector2(0.0, chart_top), Vector2(self.custom_theme.y_axis_width, max(0.0, chart_height)))
	# X 轴区域
	var x_axis_rect: Rect2 = Rect2(
		Vector2(chart_left, chart_bottom),
		Vector2(chart_width, self.custom_theme.x_axis_height)
	)
	
	var legend_top: float = 0.0 if legend_at_top else chart_bottom + self.custom_theme.x_axis_height
	
	# 图例区域
	var legend_rect: Rect2 = Rect2(
		Vector2(
			self.custom_theme.legend_margin_left,
			legend_top + self.custom_theme.legend_margin_top
		),
		Vector2(
			rect.size.x - self.custom_theme.legend_margin_left - self.custom_theme.legend_margin_right,
			self.custom_theme.legend_height
		)
	)
	# ============================
	
	self.draw_rect(Rect2(Vector2.ZERO, self.size), self.custom_theme.background_color, true)
	self.draw_rect(chart_rect, self.custom_theme.chart_background_color, true)
	
	
	# ========== 绘制图例 ==========
	self._draw_legend(legend_rect)
	# ============================
	
	# ========== 绘制网格和Y轴 ==========
	# Y轴刻度数量：如果自动，则根据绘图区高度和目标像素间距计算；否则使用主题里指定的数量，且至少为2（保证有起止两个刻度）
	var y_tick_count: int = max(2, self.custom_theme.y_axis_tick_count)
	if self.custom_theme.y_axis_auto_ticks:
		var target_pixels_per_tick: float = self.custom_theme.grid_spacing
		y_tick_count = int(clamp(round(chart_rect.size.y / max(1.0, target_pixels_per_tick)), 2, 50))
	var grid_spacing: float = chart_rect.size.y / float(max(1, y_tick_count - 1))
	self._draw_grid(chart_rect, self.custom_theme.grid_color, grid_spacing, grid_spacing)
	self._draw_y_axis(y_axis_rect, chart_rect, y_tick_count)
	# ============================
	
	# ========== 绘制X轴 ==========
	var x_tick_count = clamp(self.custom_theme.x_axis_tick_count, 2, self._cur_display_data_count)
	self._draw_x_axis(x_axis_rect, chart_rect, x_tick_count)
	# ============================
	
	self._draw_candlesticks(chart_rect)
	# 绘制均线
	for ma: CandlestickMARes in self.moving_averages:
		self._draw_moving_average(chart_rect, ma)


func _draw_grid(
	plot_rect: Rect2,
	grid_color: Color = Color(0.8, 0.8, 0.8, 0.5),
	y_grid_spacing: float = 50.0,
	x_grid_spacing: float = 50.0,
) -> void:
	var y: float = plot_rect.position.y
	while y <= plot_rect.position.y + plot_rect.size.y + 0.001:
		if not self.custom_theme.grid_show_y or y_grid_spacing <= 0:
			break
		self.draw_line(Vector2(plot_rect.position.x, y), Vector2(plot_rect.position.x + plot_rect.size.x, y), grid_color)
		y += y_grid_spacing
	var x: float = plot_rect.position.x
	while x < plot_rect.position.x + plot_rect.size.x:
		if not self.custom_theme.grid_show_x or x_grid_spacing <= 0:
			break
		self.draw_line(Vector2(x, plot_rect.position.y), Vector2(x, plot_rect.position.y + plot_rect.size.y), grid_color)
		x += x_grid_spacing


func _draw_y_axis(
	plot_rect: Rect2,
	chart_rect: Rect2,
	y_tick_count: int,
) -> void:
	if self.custom_theme.y_axis_show == false:
		return
	
	self.draw_rect(plot_rect, self.custom_theme.y_axis_background_color, true)
	
	var axis_x: float = plot_rect.position.x + plot_rect.size.x
	var axis_color: Color = self.custom_theme.y_axis_color
	var axis_thickness: float = self.custom_theme.y_axis_thickness
	self.draw_line(
		Vector2(axis_x, plot_rect.position.y - axis_thickness / 2),
		Vector2(axis_x, plot_rect.position.y + plot_rect.size.y),
		axis_color, axis_thickness
	)

	var tick_length: float = self.custom_theme.y_axis_tick_length
	var max_value: float = self._compute_value_range()[1]
	var value_range: float = self._compute_value_range()[2]
	var font: Font = self.get_theme_default_font()
	if self.custom_theme != null and self.custom_theme.y_axis_label_font != null:
		font = self.custom_theme.y_axis_label_font
	var y_tick_spacing: float = chart_rect.size.y / float(max(1, y_tick_count - 1))
	for i: int in range(y_tick_count):
		var y: float = plot_rect.position.y + float(i) * y_tick_spacing
		# 绘制刻度线
		self.draw_line(Vector2(axis_x, y), Vector2(axis_x - tick_length, y), axis_color, axis_thickness)

		# 绘制标签（在刻度线左侧），若无字体或无数据或被禁用则跳过文本绘制
		if not (self._cur_display_data != null and self._cur_display_data.size() > 0 and self.custom_theme.y_axis_show_labels):
			continue
		
		var t: float = float(i) / float(max(1, y_tick_count - 1))
		var value_at_tick: float = max_value - t * value_range
		var precision: int = self.custom_theme.y_axis_label_precision
		var fmt: String = "%0." + str(precision) + "f"
		var label_text: String = fmt % value_at_tick
		# 计算文本宽度
		var measured_x: float = font.get_string_size(label_text).x
		var label_color: Color = self.custom_theme.y_axis_label_color
		var label_size: int = self.custom_theme.y_axis_label_size

		# 优先将标签放在绘图区左侧，若超出则回退到轴线左侧，且不越过 y_axis 的最左边界
		var preferred_x: float = chart_rect.position.x - 4.0 - measured_x
		var fallback_x: float = axis_x - tick_length - 4.0 - measured_x
		var left_limit: float = plot_rect.position.x + 2.0
		var text_x: float = clamp(preferred_x, left_limit, fallback_x)
		var text_y: float = y + (font.get_height() * 0.5)
		self.draw_string(font, Vector2(text_x, text_y), label_text, 0, -1, label_size, label_color)


func _draw_x_axis(
	plot_rect: Rect2,
	chart_rect: Rect2,
	x_tick_count: int = 5,
) -> void:
	if self.custom_theme.x_axis_show == false:
		return
	
	self.draw_rect(plot_rect, self.custom_theme.x_axis_background_color, true)
	
	# 绘制 X 轴的基线、刻度和可选标签；基线与绘图区底部对齐，标签在 plot_rect 区域内居中
	var axis_color: Color = self.custom_theme.x_axis_color
	var axis_thickness: float = self.custom_theme.x_axis_thickness
	self.draw_line(
		Vector2(plot_rect.position.x, plot_rect.position.y),
		Vector2(plot_rect.position.x + chart_rect.size.x, plot_rect.position.y),
		axis_color, axis_thickness
	)

	# 如果没有数据，仅绘制基线
	if self._cur_display_data == null or self._cur_display_data.size() == 0:
		return

	# 计算数据点横向分布（基于绘图区）
	var data_count: int = self._cur_display_data.size()
	# 宽度按数据点分配，用于将刻度与数据对齐
	var slot_w_data: float = chart_rect.size.x / float(max(1, data_count))
	var tick_length: float = self.custom_theme.x_axis_tick_length
	var label_size: int = self.custom_theme.x_axis_label_size
	var label_color: Color = self.custom_theme.x_axis_label_color
	var font: Font = self.get_theme_default_font()
	if self.custom_theme != null and self.custom_theme.y_axis_label_font != null:
		font = self.custom_theme.y_axis_label_font

	# 将传入的 x_tick_count 解读为希望显示的标签数量（label_count）
	var label_count: int = max(1, int(x_tick_count))
	var effective_label_count: int = clamp(label_count, 1, data_count)
	var label_positions: Array = []
	if effective_label_count >= data_count:
		for j in range(data_count):
			label_positions.append(j)
	elif effective_label_count <= 1:
		label_positions.append(0)
	else:
		for j in range(effective_label_count):
			var idx: int = int(round(j * float(data_count - 1) / float(max(1, effective_label_count - 1))))
			label_positions.append(idx)

	var label_set: Dictionary = {}
	for p in label_positions:
		label_set[p] = true

	# 在每个数据点上绘制刻度线；对于不在 label_set 的位置绘制短刻度
	for i: int in range(data_count):
		var x: float = chart_rect.position.x + slot_w_data * (i + 0.5)
		var label_shown: bool = label_set.has(i)
		# 省略刻度长度按主题中配置的比例决定，做防守性 clamping
		var ratio: float = 0.5
		if self.custom_theme != null:
			ratio = clamp(self.custom_theme.x_axis_omitted_tick_ratio, 0.0, 1.0)
		var current_tick_length: float = tick_length if label_shown else tick_length * ratio
		self.draw_line(
			Vector2(x, plot_rect.position.y),
			Vector2(x, plot_rect.position.y + current_tick_length),
			axis_color, axis_thickness
		)
		if not label_shown:
			continue
		if i < 0 or i >= data_count or self._cur_display_data[i] == null:
			continue
		var ts_label: String = str(self._cur_display_data[i].timestamp)
		var measured_x: float = font.get_string_size(ts_label).x
		var text_x: float = clamp(
			x - measured_x * 0.5,
			chart_rect.position.x,
			chart_rect.position.x + chart_rect.size.x - measured_x
		)
		var text_y: float = plot_rect.position.y + current_tick_length + font.get_ascent(label_size)
		self.draw_string(font, Vector2(text_x, text_y), ts_label, 0, -1, label_size, label_color)


func _draw_candlesticks(plot_rect: Rect2) -> void:
	if self._cur_display_data.size() <= 0:
		return
	
	# 计算最大/最小价并添加少量 padding，防止图形贴边
	var min_v: float = self._cur_display_data[0].low
	var max_v: float = self._cur_display_data[0].high
	for candlestick_data: CandlestickDataRes in self._cur_display_data:
		if candlestick_data == null:
			continue
		if candlestick_data.low < min_v:
			min_v = candlestick_data.low
		if candlestick_data.high > max_v:
			max_v = candlestick_data.high
	var padding: float = (max_v - min_v) * self.custom_theme.y_axis_scale_value_padding_pct
	min_v -= padding
	max_v += padding

	var value_range: float = max_v - min_v
	if value_range == 0.0:
		value_range = 1.0

	# 每根蜡烛横向分配宽度与实体宽度
	var count: int = self._cur_display_data.size()
	var slot_w: float = plot_rect.size.x / float(max(1, count))
	var candlestick_min_body_width: float = self.custom_theme.candlestick_min_body_width
	# 使用 theme 中的 candlestick_body_width_ratio（0..1）来计算每根蜡烛的实体宽度占 slot 的比例，
	# 并保证不会小于最小像素宽度 candlestick_min_body_width
	var candlestick_body_ratio: float = clamp(self.custom_theme.candlestick_body_width_ratio, 0.01, 1.0)
	var body_w: float = max(candlestick_min_body_width, slot_w * candlestick_body_ratio)

	# 绘制每根蜡烛
	for i: int in range(count):
		var candlestick_data: CandlestickDataRes = self._cur_display_data[i]
		if candlestick_data == null:
			continue
		var cx: float = plot_rect.position.x + slot_w * (i + 0.5)
		var y_open: float = self._map_value_to_y(candlestick_data.open, plot_rect, max_v, value_range)
		var y_close: float = self._map_value_to_y(candlestick_data.close, plot_rect, max_v, value_range)
		var y_high: float = self._map_value_to_y(candlestick_data.high, plot_rect, max_v, value_range)
		var y_low: float = self._map_value_to_y(candlestick_data.low, plot_rect, max_v, value_range)
		
		var is_up: bool = candlestick_data.close >= candlestick_data.open
		var fill_color: Color = self.custom_theme.candlestick_color_up if is_up else self.custom_theme.candlestick_color_down

		# 先计算实体矩形（用于决定影线是否穿过实体）
		var top: float = min(y_open, y_close)
		var height: float = max(1.0, abs(y_close - y_open))
		var body_rect: Rect2 = Rect2(Vector2(cx - body_w * 0.5, top), Vector2(body_w, height))
		
		# 计算本根蜡烛应使用的粗细：如果开启自动，则根据 body_w 计算，否则使用导出变量
		var wick_thickness_used: float = self.custom_theme.candlestick_wick_thickness
		var border_thickness_used: float = self.custom_theme.candlestick_border_thickness
		if self.custom_theme.candlestick_auto_thickness:
			var auto_thick: float = max(1.0, round(body_w * 0.08))
			auto_thick = clamp(auto_thick, 0.0, body_w * 0.5)
			border_thickness_used = auto_thick
			wick_thickness_used = auto_thick
		
		# 绘制影线：若为空心上涨，分段绘制影线以避开实体内部；否则绘制整根影线
		if is_up and self.custom_theme.candlestick_hollow_when_up:
			if y_high < body_rect.position.y:
				self.draw_line(Vector2(cx, y_high), Vector2(cx, body_rect.position.y), fill_color, wick_thickness_used)
			if y_low > body_rect.position.y + body_rect.size.y:
				var from: Vector2 = Vector2(cx, body_rect.position.y + body_rect.size.y)
				self.draw_line(from, Vector2(cx, y_low), fill_color, wick_thickness_used)
		else:
			self.draw_line(Vector2(cx, y_high), Vector2(cx, y_low), fill_color, wick_thickness_used)

		# 绘制实体
		self._draw_rect_outline(body_rect, fill_color, border_thickness_used)
		if not  (is_up and self.custom_theme.candlestick_hollow_when_up):
			self.draw_rect(body_rect, fill_color, true)


func _draw_moving_average(plot_rect: Rect2, ma_res: CandlestickMARes) -> void:
	if ma_res == null or not self.custom_theme.ma_show:
		return
	
	var period: int = ma_res.period
	var color: Color = ma_res.color
	var thickness: float = self.custom_theme.ma_thickness
	var visible: bool = true

	if not visible or self._cur_display_data == null or self._cur_display_data.size() == 0 or period <= 0:
		return

	# 计算绘图所需的值范围（复用已有函数）
	var max_v: float = self._compute_value_range()[1]
	var value_range: float = self._compute_value_range()[2]

	# 计算每个数据点的 X 位置（与蜡烛对齐）
	var slot_w: float = plot_rect.size.x / float(max(1, self._cur_display_data.size()))
	var positions: Array[Vector2] = []
	var sma_values: Array = self._sma_dictionary[ma_res.label_name]
	var display_start_idx: int = max(0, self._vilid_data.size() - self._cur_display_data_count)
	var display_end_idx: int = display_start_idx + self._cur_display_data_count - 1

	for i in range(sma_values.size()):
		var sma: float = sma_values[i]
		var data_idx: int = i + period - 1
		if data_idx < display_start_idx or data_idx > display_end_idx:
			continue
		var slot_index: int = data_idx - display_start_idx
		var pos_x: float = plot_rect.position.x + slot_w * (slot_index + 0.5)
		positions.append(Vector2(pos_x, self._map_value_to_y(sma, plot_rect, max_v, value_range)))
	for i in range(1, positions.size()):
		self.draw_line(positions[i - 1], positions[i], color, thickness, true)


func _draw_legend(plot_rect: Rect2) -> void:
	if self.moving_averages == null or self.moving_averages.size() == 0:
		return
	
	self.draw_rect(plot_rect, self.custom_theme.legend_background_color, true)
	
	plot_rect = Rect2(
		plot_rect.position + Vector2(self.custom_theme.legend_padding_left, self.custom_theme.legend_padding_top),
		plot_rect.size - Vector2(self.custom_theme.legend_padding_left + self.custom_theme.legend_padding_right,
				self.custom_theme.legend_padding_top + self.custom_theme.legend_padding_bottom)
	)
	
	var font: Font = self.get_theme_default_font()
	if self.custom_theme != null and self.custom_theme.legend_label_font != null:
		font = self.custom_theme.legend_label_font
	var font_size: int = self.custom_theme.legend_label_font_size
	var font_color: Color = self.custom_theme.legend_label_font_color
	var font_height: float = font.get_height(font_size)
	var label_size: float = self.custom_theme.legend_label_size

	var line_content_height: float = max(font_height, label_size)
	var per_line_total: float = line_content_height + self.custom_theme.legend_spacing_vertical
	if per_line_total <= 0.0:
		per_line_total = 1.0
	var max_lines: int = int(floor((plot_rect.size.y + self.custom_theme.legend_spacing_vertical) / per_line_total))

	var current_line: int = 0
	var x_cursor: float = plot_rect.position.x
	# 遍历均线
	for ma: CandlestickMARes in self.moving_averages:
		if not self.custom_theme.ma_show:
			break
		if ma == null:
			continue
		
		var sma_value: float = 0.0
		if self._sma_dictionary.has(ma.label_name) and self._sma_dictionary[ma.label_name].size() > 0:
			sma_value = self._sma_dictionary[ma.label_name][-1]
		var text: String = ma.label_name + ":" + String.num(sma_value, self.custom_theme.legend_label_precision)
		
		var text_w: float = font.get_string_size(text, 0, -1, font_size).x
		var item_w: float = label_size + self.custom_theme.legend_label_spacing + text_w

		# 处理换行
		if x_cursor + item_w > plot_rect.position.x + plot_rect.size.x:
			current_line += 1
			if current_line >= max_lines:
				break
			x_cursor = plot_rect.position.x

		# 当前行的垂直定位：每行的内容顶部
		var line_top: float = plot_rect.position.y + current_line * per_line_total
		# 将方块与文字在内容高度内垂直居中
		var box_top: float = line_top + (line_content_height - label_size) * 0.5
		var box_rect: Rect2 = Rect2(Vector2(x_cursor, box_top), Vector2(label_size, label_size))
		self.draw_rect(box_rect, ma.color, true)

		# 绘制文本：使用以内容中线为基准的基线计算，保证垂直居中
		var text_x: float = x_cursor + label_size + self.custom_theme.legend_label_spacing
		var center_y: float = line_top + line_content_height * 0.5
		var text_y: float = center_y - (font.get_height(font_size) * 0.5) + font.get_ascent(font_size)
		self.draw_string(font, Vector2(text_x, text_y), text, 0, -1, font_size, font_color)

		# 移动 cursor 到下一项位置
		x_cursor += item_w + self.custom_theme.legend_spacing_horizontal

#endregion


#region Interaction

func _gui_input(event: InputEvent) -> void:
	if not self.interactive:
		return
	
	var action: String = ""
	if InputMap.has_action("candlestick_chart_zoom_in"):
		if event.is_action_pressed("candlestick_chart_zoom_in"):
			# 放大逻辑：可以根据需要调整缩放级别、重新计算绘图参数等；这里仅打印日志示例
			action = "zoom_in"
	else:
		if event is InputEventMouseButton and event.pressed \
				and (event as InputEventMouseButton).button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			action = "zoom_in"
	
	if InputMap.has_action("candlestick_chart_zoom_out"):
		if event.is_action_pressed("candlestick_chart_zoom_out"):
			# 缩小逻辑：可以根据需要调整缩放级别、重新计算绘图参数等；这里仅打印日志示例
			action = "zoom_out"
	else:
		if event is InputEventMouseButton and event.pressed \
				and (event as InputEventMouseButton).button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			action = "zoom_out"
	
	match action:
		"zoom_in": self._cur_display_data_count -= self.zoom_step
		"zoom_out": self._cur_display_data_count += self.zoom_step


#endregion


#region Helper Functions

# 将价格映射到绘图区 Y 坐标的辅助函数
func _map_value_to_y(value: float, plot_rect: Rect2, max_v: float, value_range: float) -> float:
	return plot_rect.position.y + (max_v - value) / value_range * plot_rect.size.y


# 绘制矩形描边：改为向内扩展的填充边框，避免在拐角处留缝隙
func _draw_rect_outline(rect: Rect2, color: Color, thickness: float) -> void:
	if thickness <= 0.0:
		return
	var w: float = rect.size.x
	var h: float = rect.size.y
	# 限制边框厚度为矩形最小半边，保证内部矩形尺寸非负
	var t: float = min(thickness, w * 0.5, h * 0.5)
	# 顶部边框
	var top_rect: Rect2 = Rect2(rect.position, Vector2(w, t))
	# 底部边框
	var bottom_rect: Rect2 = Rect2(Vector2(rect.position.x, rect.position.y + h - t), Vector2(w, t))
	# 左侧边框（排除上下角已被 top/bottom 填充的部分）
	var left_rect: Rect2 = Rect2(Vector2(rect.position.x, rect.position.y + t), Vector2(t, h - 2.0 * t))
	# 右侧边框
	var right_rect: Rect2 = Rect2(Vector2(rect.position.x + w - t, rect.position.y + t), Vector2(t, h - 2.0 * t))
	# 画填充矩形（使用 true 以填充）
	if top_rect.size.x > 0.0 and top_rect.size.y > 0.0:
		self.draw_rect(top_rect, color, true)
	if bottom_rect.size.x > 0.0 and bottom_rect.size.y > 0.0:
		self.draw_rect(bottom_rect, color, true)
	if left_rect.size.x > 0.0 and left_rect.size.y > 0.0:
		self.draw_rect(left_rect, color, true)
	if right_rect.size.x > 0.0 and right_rect.size.y > 0.0:
		self.draw_rect(right_rect, color, true)


# 计算数据的 min/max/value_range 工具函数，供多处复用
func _compute_value_range() -> Array:
	var min_v: float = 0.0
	var max_v: float = 0.0
	if self._cur_display_data == null or self._cur_display_data.size() == 0:
		return [min_v, max_v, 1.0]
	min_v = self._cur_display_data[0].low
	max_v = self._cur_display_data[0].high
	for candlestick_data in self._cur_display_data:
		if candlestick_data == null:
			continue
		if candlestick_data.low < min_v:
			min_v = candlestick_data.low
		if candlestick_data.high > max_v:
			max_v = candlestick_data.high
	var padding: float = (max_v - min_v) * self.custom_theme.y_axis_scale_value_padding_pct
	min_v -= padding
	max_v += padding
	var value_range: float = max_v - min_v
	if value_range == 0.0:
		value_range = 1.0
	return [min_v, max_v, value_range]

# 计算SMA的工具函数，供均线绘制使用
func _compute_sma(values: Array[float]) -> float:
	var sum: float = 0.0
	var count: int = 0
	for value in values:
		if value != null:
			sum += float(value)
			count += 1
	if count == 0:
		return 0.0
	return sum / float(count)


func _compute_all_sma() -> void:
	for ma_res in self.moving_averages:
		if ma_res == null:
			continue
		var period: int = ma_res.period
		var close_values: Array[float] = []
		for i in range(self.data.size()):
			if self.data[i] != null:
				close_values.append(float(self.data[i].close))
		var sma_values: Array[float] = []
		for i in range(max(0, close_values.size() - period + 1)):
			var sma: float = self._compute_sma(close_values.slice(i, i + period))
			sma_values.append(sma)
		self._sma_dictionary[ma_res.label_name] = sma_values


func _on_data_changed() -> void:
	self.queue_redraw()

func _on_moving_average_changed() -> void:
	self.queue_redraw()

func _on_custom_theme_changed() -> void:
	self.queue_redraw()

#endregion
