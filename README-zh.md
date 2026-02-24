[🇺🇸 English](README.md) | 🇨🇳 **中文**

# Candlestick Chart — Godot 插件

这是一个为 Godot 4.5+ 提供的 K 线（蜡烛图）控件插件，可直接作为自定义节点使用。支持 OHLC 数据源、可配置的均线（MA）、主题定制与基本交互（滚轮缩放 / 可绑定快捷键）。

---

## 主要特性

- 可在场景中以自定义节点 `CandlestickChart` 插入并渲染蜡烛图。
- 支持资源化的数据点（`CandlestickDataRes`）和均线资源（`CandlestickMARes`）。
- 可通过 `CandlestickChartTheme` 自定义配色、网格、轴与图例样式。
- 支持交互缩放（鼠标滚轮或自定义 InputMap 动作）。
- 提供 `example` 场景与脚本用于快速预览和参考。

---

## 截图

<div style="display:flex;gap:20px;align-items:flex-start;">
	<img src="image/1.png" alt="" style="height:220px; object-fit:contain;">
	<img src="image/2.png" alt="" style="height:220px; object-fit:contain;">
	<img src="image/3.png" alt="" style="height:220px; object-fit:contain;">
</div>

---

## 安装

1. 将整个 `addons/candlestick_chart` 目录复制到你的项目 `res://addons/` 下。
2. 打开 Godot 编辑器，进入 Project -> Project Settings -> Plugins，启用 `CandlestickChart` 插件。
3. 插入节点：同其他原生的`Control`节点一样，你可以在场景树中直接添加 `CandlestickChart`，或者通过脚本实例化。

---

## 快速开始

以下示例适用于 Godot 4.5+，可直接复制到任意场景节点的脚本 `_ready()` 中运行：

```gdscript
# 在运行时创建并显示简单的蜡烛图
func _ready() -> void:
	var chart: CandlestickChart = CandlestickChart.new()
	chart.size = Vector2(600, 400)
	add_child(chart)
	# 创建示例数据并赋值
	chart.data = [
		CandlestickDataRes.create("1970-01-01", 100.0, 105.0, 110.0, 95.0),
		CandlestickDataRes.create("1970-01-02", 105.0, 102.0, 108.0, 100.0),
		CandlestickDataRes.create("1970-01-03", 102.0, 108.0, 112.0, 101.0)
	]
	chart.default_display_data_count = 3
```

或者，直接打开自带示例场景：

- 打开 `res://addons/candlestick_chart/example/example.tscn` 并运行，你将看到 `example.gd` 自动生成并填充随机的样例数据。

---

## 重要 API 概览（导出属性）

- CandlestickChart（自定义节点，脚本位于 `addons/candlestick_chart/candlestick_chart.gd`）
  - `data: Array[CandlestickDataRes]` — 数据数组；每项是 `CandlestickDataRes` 资源（timestamp/open/close/high/low）。
  - `moving_averages: Array[CandlestickMARes]` — 均线资源数组，支持多条均线绘制。
  - `default_display_data_count: int` — 默认显示的数据点数量（初始窗口）。
  - `interactive: bool` — 是否启用交互（默认为 true）。
  - `zoom_step: int` — 缩放步长（每次放大/缩小改变的数据点数）。
  - `custom_theme: CandlestickChartTheme` — 主题资源，若为 null 会创建默认主题。

- CandlestickDataRes（资源类）
  - `timestamp: String` — 时间戳字符串（显示在 X 轴），建议格式 `YYYY-MM-DD`。
  - `open: float`, `close: float`, `high: float`, `low: float` — OHLC 值。
  - 静态构造器：`CandlestickDataRes.create(timestamp, open, close, high, low)`。

- CandlestickMARes（资源类）
  - `label_name: String` — 均线在图例中的显示名。
  - `period: int` — 均线周期（例如 5、10、20）。
  - `color: Color` — 均线颜色。
  - 静态构造器：`CandlestickMARes.create(label_name, period, color)`。

- CandlestickChartTheme（资源类，位于 `candlestick_chart_theme.gd`）
  - 主题通过 `CandlestickChartTheme` 的可导出属性控制；可在脚本或 Inspector 中创建并保存为 `.tres` 以复用。

---

## 示例：使用均线（MA）和自定义主题

在脚本中创建并设置多条均线和一个主题示例：

```gdscript
func _ready() -> void:
	var chart: CandlestickChart = CandlestickChart.new()
	chart.size = Vector2(600, 300)
	# 创建并设置均线
	var ma5 := CandlestickMARes.create("MA5", 5, Color8(0,200,0))
	var ma20 := CandlestickMARes.create("MA20", 20, Color8(0,0,200))

	chart.moving_averages = [ma5, ma20]

	# 创建并应用自定义主题
	var t := CandlestickChartTheme.new()
	t.candlestick_color_up = Color8(14,216,14)
	t.candlestick_color_down = Color8(232,32,32)
	t.grid_color = Color(0.8,0.8,0.8,0.3)
	chart.custom_theme = t
	add_child(chart)
```

---

## 交互与输入绑定

- 插件会优先响应 `candlestick_chart_zoom_in` / `candlestick_chart_zoom_out`（Input Map）绑定的快捷键以触发缩放；
- 若未绑定，插件默认响应鼠标滚轮事件进行缩放：向上滚动放大、向下滚动缩小。

---

## 示例场景说明

- `addons/candlestick_chart/example/example.tscn`：示例场景，内置 `example.gd` 会随机生成一组带时间戳的 OHLC 数据并赋值到图表节点上，便于快速预览效果。
- 如果想复用示例脚本的生成逻辑，可将 `example.gd` 的代码复制到你的场景脚本并把 `$CandlestickChart` 指向你的图表节点路径。
- 示例脚本中的生成逻辑相关代码由AI辅助生成，主要用于演示数据结构和赋值方式，编码风格可能与插件其他部分略有不同，但功能上是兼容的。

---

## 常见问题与调试建议

- 自定义节点不可见或插件未列出：确认 `res://addons/candlestick_chart` 路径正确且在 Project Settings -> Plugins 中启用；必要时重启编辑器。
- 图表为空或无数据：检查 `data` 是否为非空数组，且项为 `CandlestickDataRes`，可以在运行时 `print($CandlestickChart.get_vilid_data().size())` 验证。
- 均线未显示：确认 `moving_averages` 非空、每条 `period` 合理（小于或等于数据长度），并且主题的 `ma_show` 为 true（默认通常开启）。
- 主题修改无效：确认你修改的是 `custom_theme` 的属性，且该资源已正确赋值给图表节点；如果在编辑器中修改，确保修改后的资源被保存并重新加载。
- 缩放/快捷键无效：若你自定义了 `candlestick_chart_zoom_in`/`candlestick_chart_zoom_out`，请在 Project Settings -> Input Map 中检查绑定；若没绑定，使用鼠标滚轮测试。

---

## 贡献与许可

- MIT 许可证，详见 LICENSE 文件。
- 欢迎提交 Pull Request 或 Issues 以改进功能、修复 bug 或提供使用反馈。
