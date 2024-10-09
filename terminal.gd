class_name Terminal extends Panel

@export var _font: Font
@export var _font_size: int
@export var _font_color: Color
@export var _text_border_size_x: int
@export var _text_border_size_y: int

var _CHAR_WIDTH: float
var _CHAR_HEIGHT: float
const _CURSOR: String = "█"

var _buffer: Array
var _caps_lock_enabled: bool

var _cursor_right_limit: int
var _cursor_idx: int
var _start_line_idx: int

var _cmd_string
var _terminal_history: Array
var _last_cmd_idx: int


func get_num_window_rows() -> int:
	return floor(get_window_y() / _CHAR_HEIGHT) - 1


func get_window_x() -> int:
	return size.x - (_text_border_size_x * 2) - _CHAR_WIDTH


func get_window_y() -> int:
	return size.y - (_text_border_size_y * 2) - _CHAR_HEIGHT


func get_num_rows_in_buffer() -> int:
	var num_rows_in_buffer = 0
	var buffer_string = "".join(PackedStringArray(_buffer.slice(0, _buffer.size()-1)))
	for item in buffer_string.split("\n"):
		var tmp_rows = ceil((item.length() * _CHAR_WIDTH) / get_window_x())
		if item.begins_with("Lorem"):
			print("get_num_rows_in_buffer: num_chars=", item.length())
			print("get_num_rows_in_buffer: CHAR_WIDTH=", _CHAR_WIDTH)
			print("get_num_rows_in_buffer: size.x=", get_window_x())
			print("get_num_rows_in_buffer: raw_calc=", (item.length() * _CHAR_WIDTH) / get_window_x())
			print("get_num_rows_in_buffer: tmp_rows=", tmp_rows)
		num_rows_in_buffer += tmp_rows
	print("get_num_rows_in_buffer: ret=", num_rows_in_buffer)
	return num_rows_in_buffer


func _init() -> void:
	_buffer = [ null ]
	_cmd_string = null
	_terminal_history = [ "" ]
	
	print("init: font_size=", _font_size)
	
	_CHAR_HEIGHT = 16.0 # TODO: MOVE THIS
	_CHAR_WIDTH = 8.0 # TODO: MOVE THIS
	_caps_lock_enabled = false
	
	_cursor_idx = 0
	_cursor_right_limit = 0
	_last_cmd_idx = 0
	_start_line_idx = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grab_focus()
	print(size)
	
	write("> lorem\n")
	run_command("lorem")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _draw():
	var x_limit = get_window_x() + _text_border_size_x
	var y_limit = get_window_y() + _text_border_size_y
	
	var x_start = _text_border_size_x
	var y_start = _CHAR_HEIGHT + _text_border_size_y
	var char_pos = Vector2(x_start, y_start)
	
	var idx = 0
		
	var line_idx = 0
	var start_line_index = _start_line_idx
	var end_line_index = _start_line_idx + min(get_num_window_rows(), get_num_rows_in_buffer())
	
	print("draw: _cursor_idx=", _cursor_idx)
	print("draw: start_line_index=", start_line_index)
	print("draw: end_line_index=", end_line_index)
	print("draw: num_window_rows=", get_num_window_rows())
	print("draw: _num_rows_in_buffer=", get_num_rows_in_buffer())
	for key in _buffer:
		var idx_in_range = start_line_index <= line_idx and line_idx <= end_line_index
		
		if key != null:
			var draw_key = key
			
			if key == "\n":
				draw_key = " "
				
			if idx_in_range:
				draw_char(_font, char_pos, draw_key, _font_size, _font_color)
				char_pos.x += _CHAR_WIDTH
				
			if key == "\n" or char_pos.x >= x_limit:
				if idx_in_range:
					char_pos.x = _text_border_size_x
					char_pos.y += _CHAR_HEIGHT
				line_idx += 1
			
		if idx_in_range and idx == _cursor_idx:
			print("draw: drawing cursor on [", key, "]")
			draw_char(_font, char_pos, _CURSOR, _font_size, _font_color)
		
		idx += 1


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				print("event: wheel up")
				print(event)
				if get_num_rows_in_buffer() > get_num_window_rows():
					_start_line_idx = min(_start_line_idx + 1, get_num_rows_in_buffer() - get_num_window_rows())
				else:
					_start_line_idx = 0
				print("event: _start_line_idx=", _start_line_idx)
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				print("event: wheel down")
				print(event)
				_start_line_idx = max(0, _start_line_idx - 1)
				print("event: _start_line_idx=", _start_line_idx)
			queue_redraw()
	
	if event is InputEventKey and event.pressed and !event.is_echo():
		var c = event_to_char(event)
		if c != "":
			add_to_buffer(c, c=="\n")
			_cursor_idx = _buffer.size() - 1
		queue_redraw()
		
		if _cmd_string != null:
			print("input: _cmd_string=", _cmd_string)
			run_command(_cmd_string)
			queue_redraw()
			_cmd_string = null


func clear_current_line() -> void:
	while _cursor_idx > _cursor_right_limit:
		_buffer.remove_at(_cursor_right_limit)
		_cursor_idx -= 1
		


func add_to_buffer(text: String, append_to_buffer: bool = false) -> void:
	assert(text.length() == 1, "add_to_buffer: should only add char (input text len=" + str(text.length()) + ")")
	
	#print("add: _cursor_idx=", _cursor_idx, " _buffer.size=", _buffer.size())
	if append_to_buffer:
		print("add: _cursor_idx=", _cursor_idx, " _buffer.size=", _buffer.size())
		print("add: replacing character: ", _buffer[_buffer.size() - 1], " with ", text)
		_buffer.insert(_buffer.size() - 1, text)
	else:
		_buffer.insert(_cursor_idx, text)
	
	if _buffer[-1] != null:
		_buffer.append(null)
	_cursor_idx += 1


func write(text: String) -> void:
	var char_row_count = int(size.x / _CHAR_WIDTH)
	for c in text:
		add_to_buffer(c)
	_cursor_right_limit = _cursor_idx
	print("write: max=", get_num_rows_in_buffer() - get_num_window_rows())
	_start_line_idx = max(0, get_num_rows_in_buffer() - get_num_window_rows())
	print("write: _start_line_idx=", _start_line_idx)
	queue_redraw()


func run_command(cmd_string: String) -> void:
	print("run: cmd_string=", cmd_string)
	match cmd_string:
		"whoami":
			write("a1rship\n")
		"pwd": 
			write("/home/a1rsh1p\n")
		"lorem":
			write("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n")
		_:
			write("command not found\n")
	write("> ")


func get_cmd_string() -> String:
	return "".join(PackedStringArray(_buffer.slice(_cursor_right_limit, _buffer.size()-1)))


func event_to_char(event: InputEventKey) -> String:
	var keycode = event.keycode
	var keycode_string = OS.get_keycode_string(event.get_keycode_with_modifiers())
	var c = ""
	
	print("event: ", keycode_string)
	
	match keycode_string:
		"A" when _caps_lock_enabled:
			c = "A"
		"A":
			c = "a"
		"Shift+A":
			c = "A"
		"B" when _caps_lock_enabled:
			c = "B"
		"B":
			c = "b"
		"Shift+B":
			c = "B"
		"C" when _caps_lock_enabled:
			c = "C"
		"C":
			c = "c"
		"Shift+C":
			c = "C"
		"D" when _caps_lock_enabled:
			c = "D"
		"D":
			c = "d"
		"Shift+D":
			c = "D"
		"E" when _caps_lock_enabled:
			c = "E"
		"E":
			c = "e"
		"Shift+E":
			c = "E"
		"F" when _caps_lock_enabled:
			c = "F"
		"F":
			c = "f"
		"Shift+F":
			c = "F"
		"G" when _caps_lock_enabled:
			c = "G"
		"G":
			c = "g"
		"Shift+G":
			c = "G"
		"H" when _caps_lock_enabled:
			c = "H"
		"H":
			c = "h"
		"Shift+H":
			c = "H"
		"I" when _caps_lock_enabled:
			c = "I"
		"I":
			c = "i"
		"Shift+I":
			c = "I"
		"J" when _caps_lock_enabled:
			c = "J"
		"J":
			c = "j"
		"Shift+J":
			c = "J"
		"K" when _caps_lock_enabled:
			c = "K"
		"K":
			c = "k"
		"Shift+K":
			c = "K"
		"L" when _caps_lock_enabled:
			c = "L"
		"L":
			c = "l"
		"Shift+L":
			c = "L"
		"M" when _caps_lock_enabled:
			c = "M"
		"M":
			c = "m"
		"Shift+M":
			c = "M"
		"N" when _caps_lock_enabled:
			c = "N"
		"N":
			c = "n"
		"Shift+N":
			c = "N"
		"O" when _caps_lock_enabled:
			c = "O"
		"O":
			c = "o"
		"Shift+O":
			c = "O"
		"P" when _caps_lock_enabled:
			c = "P"
		"P":
			c = "p"
		"Shift+P":
			c = "P"
		"Q" when _caps_lock_enabled:
			c = "Q"
		"Q":
			c = "q"
		"Shift+Q":
			c = "Q"
		"R" when _caps_lock_enabled:
			c = "R"
		"R":
			c = "r"
		"Shift+R":
			c = "R"
		"S" when _caps_lock_enabled:
			c = "S"
		"S":
			c = "s"
		"Shift+S":
			c = "S"
		"T" when _caps_lock_enabled:
			c = "T"
		"T":
			c = "t"
		"Shift+T":
			c = "T"
		"U" when _caps_lock_enabled:
			c = "U"
		"U":
			c = "u"
		"Shift+U":
			c = "U"
		"V" when _caps_lock_enabled:
			c = "V"
		"V":
			c = "v"
		"Shift+V":
			c = "V"
		"W" when _caps_lock_enabled:
			c = "W"
		"W":
			c = "w"
		"Shift+W":
			c = "W"
		"X" when _caps_lock_enabled:
			c = "X"
		"X":
			c = "x"
		"Shift+X":
			c = "X"
		"Y" when _caps_lock_enabled:
			c = "Y"
		"Y":
			c = "y"
		"Shift+Y":
			c = "Y"
		"Z" when _caps_lock_enabled:
			c = "Z"
		"Z":
			c = "z"
		"Shift+Z":
			c = "Z"
		"0":
			c = "0"
		"Shift+0":
			c = ")"
		"1":
			c = "1"
		"Shift+1":
			c = "!"
		"2":
			c = "2"
		"Shift+2":
			c = "@"
		"3":
			c = "3"
		"Shift+3":
			c = "#"
		"4":
			c = "4"
		"Shift+4":
			c = "$"
		"5":
			c = "5"
		"Shift+5":
			c = "%"
		"6":
			c = "6"
		"Shift+6":
			c = "^"
		"7":
			c = "7"
		"Shift+7":
			c = "&"
		"8":
			c = "8"
		"Shift+8":
			c = "*"
		"9":
			c = "9"
		"Shift+9":
			c = "("
		"QuoteLeft":
			c = "`"
		"Shift+QuoteLeft":
			c = "~"
		"Minus":
			c = "-"
		"Shift+Minus":
			c = "_"
		"Equal":
			c = "="
		"Shift+Equal":
			c = "+"
		"BracketLeft":
			c = "["
		"Shift+BracketLeft":
			c = "{"
		"BracketRight":
			c = "]"
		"Shift+BracketRight":
			c = "}"
		"BackSlash":
			c = "\\"
		"Shift+BackSlash":
			c = "|"
		"Semicolon":
			c = ";"
		"Shift+Semicolon":
			c = ":"
		"Apostrophe":
			c = "'"
		"Shift+Apostrophe":
			c = '"'
		"Comma":
			c = ","
		"Shift+Comma":
			c = "<"
		"Period":
			c = "."
		"Shift+Period":
			c = ">"
		"Slash":
			c = "/"
		"Shift+Slash":
			c = "?"
		"Space":
			c = " "
		"CapsLock":
			_caps_lock_enabled = !_caps_lock_enabled
		"Enter":
			_cmd_string = get_cmd_string()
			if _cmd_string != _terminal_history[_terminal_history.size() - 2]:
				_terminal_history[-1] = _cmd_string
				_terminal_history.append("")
			_last_cmd_idx = _terminal_history.size() - 1
			print("event: cmd_string=", _cmd_string)
			c = "\n"
		"Left": 
			print("event: _cursor_right_limit=", _cursor_right_limit, " _cursor_idx=", _cursor_idx)
			_cursor_idx = max(_cursor_right_limit, _cursor_idx - 1)
			while _cursor_idx > _cursor_right_limit and _buffer[_cursor_idx] == "\n":
				_cursor_idx = _cursor_idx - 1
		"Right": 
			_cursor_idx = min(_cursor_idx + 1, _buffer.size() - 1)
			while _cursor_idx < _buffer.size() and _buffer[_cursor_idx] == "\n":
				_cursor_idx = _cursor_idx + 1
		"Up": 
			print("event: _last_cmd_idx=", _last_cmd_idx)
			if _terminal_history.size() > 0 and _last_cmd_idx > -1:
				clear_current_line()
				_last_cmd_idx = max(0, _last_cmd_idx - 1)
				var last_cmd = _terminal_history[_last_cmd_idx]
				print("event: last_cmd=", last_cmd)
				for _c in last_cmd:
					add_to_buffer(_c)
		"Down": 
			print("event: _last_cmd_idx=", _last_cmd_idx)
			if _terminal_history.size() > 0 and _last_cmd_idx < _terminal_history.size()-1:
				clear_current_line()
				_last_cmd_idx = min(_last_cmd_idx + 1, _terminal_history.size() - 1)
				var last_cmd = _terminal_history[_last_cmd_idx]
				print("event: last_cmd=", last_cmd)
				for _c in last_cmd:
					add_to_buffer(_c)
		"Backspace":
			if _cursor_idx > _cursor_right_limit:
				_buffer.remove_at(_cursor_idx - 1)
				_cursor_idx -= 1
		_:
			c = ""
	
	_start_line_idx = max(0, get_num_rows_in_buffer() - get_num_window_rows())
	
	return c
