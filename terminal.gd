class_name Terminal extends Panel

const CHAR_WIDTH: int = 8
const CHAR_HEIGHT: int = 16
const CURSOR: String = "█"

var font: Font
var _font_size: int
var _color: Color
@export var _text_border_size_x: int
@export var _text_border_size_y: int

var _buffer: Array
var caps_lock_enabled: bool

var cursor_right_limit: int
var cursor_idx: int
var _start_line_idx: int

var _cmd_string
var _cmd_strings: Array
var _last_cmd_idx: int


func _init(theme_name: String = "") -> void:
	if theme_name != "":
		theme = load(theme_name)
	font = preload("res://fonts/SFMonoMedium.otf")# TODO - move this into constructor
	_buffer = [ null ]
	caps_lock_enabled = false
	cursor_idx = 0
	cursor_right_limit = 0
	_cmd_strings = [ "" ]
	_last_cmd_idx = 0
	_cmd_string = null
	_start_line_idx = 0
	
	_font_size = 16 # TODO - move this into constructor
	_color = Color8(57, 255, 20, 255) # TODO - move this into constructor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grab_focus()
	print(size)
	
	write("WELCOME TO TELCO 1\nTYPE 'HELP' TO BEGIN\n")
	for i in range(64):
		write(str(i) + "\n")
	write("> ")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _draw():
	var x_limit = size.x - CHAR_WIDTH
	var y_limit = size.y - CHAR_HEIGHT
	
	var x_start = _text_border_size_x
	var y_start = CHAR_HEIGHT + _text_border_size_y
	var char_pos = Vector2(x_start, y_start)
	var char_row_count = int(size.x / CHAR_WIDTH)
	
	var idx = 0
	var line_idx = 0
	var start_line_index = _start_line_idx
	var end_line_index = floor((size.y - (_text_border_size_y * 2)) / CHAR_HEIGHT) - 1
	print("draw: cursor_idx=", cursor_idx)
	for key in _buffer:
		if key != null:
			var draw_key = key
			if key == "\n":
				draw_key = " "
			if start_line_index <= line_idx and line_idx <= end_line_index:
				draw_char(font, char_pos, draw_key, _font_size, _color)
			
		if idx == cursor_idx:
			print("draw: drawing cursor on [", key, "]")
			draw_char(font, char_pos, CURSOR, _font_size, _color)
		
		char_pos.x += CHAR_WIDTH
		idx += 1
		
		if key == "\n" or char_pos.x >= x_limit:
			char_pos.x = _text_border_size_x
			char_pos.y += CHAR_HEIGHT
			line_idx += 1


func _gui_input(event: InputEvent) -> void:
	print(event)
	if event is InputEventKey and event.pressed and !event.is_echo():
		var c = event_to_char(event)
		if c != "":
			add_to_buffer(c, c=="\n")
			cursor_idx = _buffer.size() - 1
		queue_redraw()
		
		if _cmd_string != null:
			print("input: _cmd_string=", _cmd_string)
			run_command(_cmd_string)
			queue_redraw()
			_cmd_string = null


func clear_current_line() -> void:
	while cursor_idx > cursor_right_limit:
		_buffer.remove_at(cursor_right_limit)
		cursor_idx -= 1
		


func add_to_buffer(text: String, append_to_buffer: bool = false) -> void:
	assert(text.length() == 1, "add_to_buffer: should only add char (input text len=" + str(text.length()) + ")")
	
	#print("add: cursor_idx=", cursor_idx, " _buffer.size=", _buffer.size())
	if append_to_buffer:
		print("add: cursor_idx=", cursor_idx, " _buffer.size=", _buffer.size())
		print("add: replacing character: ", _buffer[_buffer.size() - 1], " with ", text)
		_buffer.insert(_buffer.size() - 1, text)
	else:
		_buffer.insert(cursor_idx, text)
	
	if _buffer[-1] != null:
		_buffer.append(null)
	cursor_idx += 1


func write(text: String) -> void:
	var char_row_count = int(size.x / CHAR_WIDTH)
	for c in text:
		add_to_buffer(c)
	cursor_right_limit = cursor_idx
	print("write: ", _buffer[cursor_idx])
	print("write: ", type_string(typeof(_buffer[cursor_idx])))
	queue_redraw()


func run_command(cmd_string: String) -> void:
	print("run: cmd_string=", cmd_string)
	match cmd_string:
		"whoami":
			write("a1rship\n")
		"pwd": 
			write("/home/a1rsh1p\n")
		_:
			write("command not found\n")
	write("> ")


func get_cmd_string() -> String:
	return "".join(PackedStringArray(_buffer.slice(cursor_right_limit, _buffer.size()-1)))


func event_to_char(event: InputEventKey) -> String:
	var keycode = event.keycode
	var keycode_string = OS.get_keycode_string(event.get_keycode_with_modifiers())
	var c = ""
	
	print("event: ", keycode_string)
	
	match keycode_string:
		"A" when caps_lock_enabled:
			c = "A"
		"A":
			c = "a"
		"Shift+A":
			c = "A"
		"B" when caps_lock_enabled:
			c = "B"
		"B":
			c = "b"
		"Shift+B":
			c = "B"
		"C" when caps_lock_enabled:
			c = "C"
		"C":
			c = "c"
		"Shift+C":
			c = "C"
		"D" when caps_lock_enabled:
			c = "D"
		"D":
			c = "d"
		"Shift+D":
			c = "D"
		"E" when caps_lock_enabled:
			c = "E"
		"E":
			c = "e"
		"Shift+E":
			c = "E"
		"F" when caps_lock_enabled:
			c = "F"
		"F":
			c = "f"
		"Shift+F":
			c = "F"
		"G" when caps_lock_enabled:
			c = "G"
		"G":
			c = "g"
		"Shift+G":
			c = "G"
		"H" when caps_lock_enabled:
			c = "H"
		"H":
			c = "h"
		"Shift+H":
			c = "H"
		"I" when caps_lock_enabled:
			c = "I"
		"I":
			c = "i"
		"Shift+I":
			c = "I"
		"J" when caps_lock_enabled:
			c = "J"
		"J":
			c = "j"
		"Shift+J":
			c = "J"
		"K" when caps_lock_enabled:
			c = "K"
		"K":
			c = "k"
		"Shift+K":
			c = "K"
		"L" when caps_lock_enabled:
			c = "L"
		"L":
			c = "l"
		"Shift+L":
			c = "L"
		"M" when caps_lock_enabled:
			c = "M"
		"M":
			c = "m"
		"Shift+M":
			c = "M"
		"N" when caps_lock_enabled:
			c = "N"
		"N":
			c = "n"
		"Shift+N":
			c = "N"
		"O" when caps_lock_enabled:
			c = "O"
		"O":
			c = "o"
		"Shift+O":
			c = "O"
		"P" when caps_lock_enabled:
			c = "P"
		"P":
			c = "p"
		"Shift+P":
			c = "P"
		"Q" when caps_lock_enabled:
			c = "Q"
		"Q":
			c = "q"
		"Shift+Q":
			c = "Q"
		"R" when caps_lock_enabled:
			c = "R"
		"R":
			c = "r"
		"Shift+R":
			c = "R"
		"S" when caps_lock_enabled:
			c = "S"
		"S":
			c = "s"
		"Shift+S":
			c = "S"
		"T" when caps_lock_enabled:
			c = "T"
		"T":
			c = "t"
		"Shift+T":
			c = "T"
		"U" when caps_lock_enabled:
			c = "U"
		"U":
			c = "u"
		"Shift+U":
			c = "U"
		"V" when caps_lock_enabled:
			c = "V"
		"V":
			c = "v"
		"Shift+V":
			c = "V"
		"W" when caps_lock_enabled:
			c = "W"
		"W":
			c = "w"
		"Shift+W":
			c = "W"
		"X" when caps_lock_enabled:
			c = "X"
		"X":
			c = "x"
		"Shift+X":
			c = "X"
		"Y" when caps_lock_enabled:
			c = "Y"
		"Y":
			c = "y"
		"Shift+Y":
			c = "Y"
		"Z" when caps_lock_enabled:
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
			caps_lock_enabled = !caps_lock_enabled
		"Enter":
			_cmd_string = get_cmd_string()
			if _cmd_string != _cmd_strings[_cmd_strings.size() - 2]:
				_cmd_strings[-1] = _cmd_string
				_cmd_strings.append("")
			_last_cmd_idx = _cmd_strings.size() - 1
			print("event: cmd_string=", _cmd_string)
			c = "\n"
		"Left": 
			print("event: cursor_right_limit=", cursor_right_limit, " cursor_idx=", cursor_idx)
			cursor_idx = max(cursor_right_limit, cursor_idx - 1)
			while cursor_idx > cursor_right_limit and _buffer[cursor_idx] == "\n":
				cursor_idx = cursor_idx - 1
		"Right": 
			cursor_idx = min(cursor_idx + 1, _buffer.size() - 1)
			while cursor_idx < _buffer.size() and _buffer[cursor_idx] == "\n":
				cursor_idx = cursor_idx + 1
		"Up": 
			print("event: _last_cmd_idx=", _last_cmd_idx)
			if _cmd_strings.size() > 0 and _last_cmd_idx > -1:
				clear_current_line()
				_last_cmd_idx = max(0, _last_cmd_idx - 1)
				var last_cmd = _cmd_strings[_last_cmd_idx]
				print("event: last_cmd=", last_cmd)
				for _c in last_cmd:
					add_to_buffer(_c)
		"Down": 
			print("event: _last_cmd_idx=", _last_cmd_idx)
			if _cmd_strings.size() > 0 and _last_cmd_idx < _cmd_strings.size()-1:
				clear_current_line()
				_last_cmd_idx = min(_last_cmd_idx + 1, _cmd_strings.size() - 1)
				var last_cmd = _cmd_strings[_last_cmd_idx]
				print("event: last_cmd=", last_cmd)
				for _c in last_cmd:
					add_to_buffer(_c)
		"Backspace":
			if cursor_idx > cursor_right_limit:
				_buffer.remove_at(cursor_idx - 1)
				cursor_idx -= 1
		_:
			c = ""
	
	return c
