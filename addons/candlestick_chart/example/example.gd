extends Control


@export var data_point_count: int = 60


func _ready() -> void:
	$CandlestickChart.data = self._get_data_list()
	


func _get_data_list() -> Array:
	randomize()
	var data_list: Array[CandlestickDataRes] = []
	
	# 使用有偏随机游走模拟更现实的股票序列
	var days := self.data_point_count
	var start_price: float = 150.0
	var prev_close: float = start_price

	var daily_drift: float = 0.001 # ~+0.1% 每日平均微幅上升（中等）
	var intraday_vol: float = 0.015 # 日内波动幅度（约±1.5%）
	var gap_vol: float = 0.005 # 隔夜跳空波动（约±0.5%）
	var gap_bias: float = 0.0008 # 隔夜跳空的微小正向偏置

	var end_year := 1969
	var end_month := 12
	var end_day := 31

	# 计算起始日期（结束日期向前 days-1 天）
	var start_date := _sub_days_from_date(end_year, end_month, end_day, days - 1)
	var start_year: int = int(start_date[0])
	var start_month: int = int(start_date[1])
	var start_day: int = int(start_date[2])

	for i in range(days):
		# 过夜小跳空并带有微小的向上偏置
		var gap_pct: float = randf_range(-gap_vol, gap_vol) + gap_bias
		var open: float = prev_close * (1.0 + gap_pct)
		# 日内变动：用明确概率决定方向，以实现可控的向上偏置
		var up_prob: float = 0.55 # 平均约 65% 的交易日为上涨日
		var is_up: bool = randf() < up_prob
		# 幅度在 0 到 intraday_vol 之间采样，并有一定的变异
		var mag: float = randf_range(0.0, intraday_vol)
		var rand_component: float = 0.0
		if is_up:
			# 上涨日平均波动稍小
			mag *= randf_range(0.5, 1.0)
			rand_component = mag
		else:
			# 下跌日有时可能更剧烈
			mag *= randf_range(0.7, 1.2)
			rand_component = -mag
		# 应用漂移项与带符号的日内分量
		var close: float = open * (1.0 + daily_drift + rand_component)
		# 最高/最低在开盘/收盘的基础上延伸，幅度大约 0.5%~1.5%
		var upper_ext: float = randf_range(0.002, 0.015)
		var lower_ext: float = randf_range(0.002, 0.012)
		var high: float = max(open, close) * (1.0 + upper_ext)
		var low: float = min(open, close) * (1.0 - lower_ext)
		# 防止价格变为负值
		low = max(low, 0.01)
		# 更新 prev_close 供下一日使用
		prev_close = close

		# 生成日历日期字符串（YYYY-MM-DD）作为时间戳
		var date_arr := _add_days_to_date(start_year, start_month, start_day, i)
		var cy: int = int(date_arr[0])
		var cm: int = int(date_arr[1])
		var cd: int = int(date_arr[2])
		var timestamp: String = "%04d-%02d-%02d" % [cy, cm, cd]

		var data: CandlestickDataRes = CandlestickDataRes.create(timestamp, open, close, high, low)
		data_list.append(data)
	return data_list


func _is_leap_year(y: int) -> bool:
	return (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)


func _days_in_month(y: int, m: int) -> int:
	var md := [31,28,31,30,31,30,31,31,30,31,30,31]
	if m == 2 and _is_leap_year(y):
		return 29
	return md[m - 1]


func _add_days_to_date(year: int, month: int, day: int, add: int) -> Array:
	var y := year
	var m := month
	var d := day
	for i in range(add):
		d += 1
		var dim := _days_in_month(y, m)
		if d > dim:
			d = 1
			m += 1
			if m > 12:
				m = 1
				y += 1
	return [y, m, d]


func _sub_days_from_date(year: int, month: int, day: int, sub: int) -> Array:
	var y := year
	var m := month
	var d := day
	for i in range(sub):
		d -= 1
		if d < 1:
			m -= 1
			if m < 1:
				m = 12
				y -= 1
			d = _days_in_month(y, m)
	return [y, m, d]
