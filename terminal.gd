class_name Terminal extends Panel

const CHAR_WIDTH: int = 8
const CHAR_HEIGHT: int = 16
const CURSOR: String = "█"

var font: Font
var _buffer: Array
var caps_lock_enabled: bool

var cursor_idx: int


func _init() -> void:
	font = preload("res://fonts/SFMonoMedium.otf")
	_buffer = []
	caps_lock_enabled = false
	cursor_idx = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grab_focus()
	print(size)
	
	write("WELCOME TO TELCO 1\nTYPE 'HELP' TO BEGIN\n")
	write("> ")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _draw():
	var x_limit = size.x - CHAR_WIDTH
	var y_limit = size.y - CHAR_HEIGHT
	
	var x = 0
	var y = CHAR_HEIGHT
	
	for key in _buffer:
		print(x, ",", y)
		match key:
			"\n":
				x = 0
				y += CHAR_HEIGHT
				continue
			_:
				draw_char(font, Vector2(x, y), key)
		
		x += CHAR_WIDTH
		
		if x >= x_limit:
			x = 0
			y += CHAR_HEIGHT
	
	var cursor_pos = Vector2(
		cursor_idx % int(size.x),
		floor(cursor_idx / size.x)
	)
	
	draw_char(font, cursor_pos, CURSOR)


func write(text: String) -> void:
	for c in text:
		if c == "\n":
			cursor_idx += size.x
		else:
			cursor_idx += CHAR_WIDTH
		_buffer.append(c)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and !event.is_echo():
		var c = event_to_char(event)
		if c != "":
			_buffer.append(c)
			queue_redraw()


func event_to_char(event: InputEventKey) -> String:
	var keycode = event.keycode
	var keycode_string = OS.get_keycode_string(event.get_keycode_with_modifiers())
	var c = ""
	
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
			c = "\n"
		_:
			c = ""
	
	if c.length() > 0:
		if c == "\n":
			cursor_idx += size.x
		else:
			cursor_idx += CHAR_WIDTH
	
	return c
