import string

def print_line(key, val):
	print(f'\t\t"{key}":')
	print(f'\t\t\tc = "{val}"')

def print_caps_lock_line(key, val):
	print(f'\t\t"{key}" when caps_lock_enabled:')
	print(f'\t\t\tc = "{val}"')
	
def print_shift_line(key, val):
	print(f'\t\t"Shift+{key}":')
	print(f'\t\t\tc = "{val}"')

print("\tmatch keycode_string:")
for capital in list(string.ascii_uppercase):
	print_caps_lock_line(capital, capital)
	print_line(capital, capital.lower())
	print_shift_line(capital, capital)

num_to_spec = {
	"0": ")",
	"1": "!",
	"2": "@",
	"3": "#",
    "4": "$",
	"5": "%",
	"6": "^",
	"7": "&",
	"8": "*",
	"9": "(",
}

for number in list(string.digits):
    print_line(number, number)
    print_shift_line(number, num_to_spec[number])

print_line("QuoteLeft", "`")
print_shift_line("QuoteLeft", "~")

print_line("Minus", "-")
print_shift_line("Minus", "_")

print_line("Equal", "=")
print_shift_line("Equal", "+")

print_line("BracketLeft", "[")
print_shift_line("BracketLeft", "{")

print_line("BracketRight", "]")
print_shift_line("BracketRight", "}")

print_line("BackSlash", "\\\\")
print_shift_line("BackSlash", "|")

print_line("Semicolon", ";")
print_shift_line("Semicolon", ":")

print_line("Apostrophe", "'")
print(f'\t\t"Shift+Apostrophe":')
print(f'\t\t\tc = \'"\'')

print_line("Comma", ",")
print_shift_line("Comma", "<")

print_line("Period", ".")
print_shift_line("Period", ">")

print_line("Slash", "/")
print_shift_line("Slash", "?")

print_line("Space", " ")

print('\t\t_:')
print('\t\t\tc = ""')