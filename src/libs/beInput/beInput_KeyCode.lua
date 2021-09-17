--[[
A top-down action game made with Bitty Engine

Copyright (C) 2021 Tony Wang, all rights reserved

Engine page: https://paladin-t.github.io/bitty/
  Game page: https://paladin-t.github.io/games/hb/
]]

--[[
Key code.
]]

local function asc(s)
	return string.byte(s, 1)
end

local function toKeycode(k)
	return (1 << 30) | k
end

local KeyCode = {
	Return = 13,
	Esc = 27,
	Backspace = 8,
	Tab = 9,
	Space = asc(' '),

	Exclaim = asc('!'),
	DoubleQuote = 34,
	Hash = asc('#'),
	Percent = asc('%'),
	Dollar = asc('$'),
	Ampersand = asc('&'),
	Quote = asc('\''),
	LeftParenthesis = asc('('),
	RightParenthesis = asc(')'),
	Asterisk = asc('*'),
	Plus = asc('+'),
	Comma = asc(','),
	Minus = asc('-'),
	Period = asc('.'),
	Slash = asc('/'),
	CapsLock = toKeycode(57),

	Num0 = asc('0'),
	Num1 = asc('1'),
	Num2 = asc('2'),
	Num3 = asc('3'),
	Num4 = asc('4'),
	Num5 = asc('5'),
	Num6 = asc('6'),
	Num7 = asc('7'),
	Num8 = asc('8'),
	Num9 = asc('9'),

	Colon = asc(':'),
	Semicolon = asc(';'),
	Less = asc('<'),
	Equals = asc('='),
	Greater = asc('>'),
	Question = asc('?'),
	At = asc('@'),
	LeftBracket = asc('['),
	Backslash = asc('\\'),
	RightBracket = asc(']'),
	Caret = asc('^'),
	Underscore = asc('_'),
	Backquote = asc('`'),

	A = asc('a'),
	B = asc('b'),
	C = asc('c'),
	D = asc('d'),
	E = asc('e'),
	F = asc('f'),
	G = asc('g'),
	H = asc('h'),
	I = asc('i'),
	J = asc('j'),
	K = asc('k'),
	L = asc('l'),
	M = asc('m'),
	N = asc('n'),
	O = asc('o'),
	P = asc('p'),
	Q = asc('q'),
	R = asc('r'),
	S = asc('s'),
	T = asc('t'),
	U = asc('u'),
	V = asc('v'),
	W = asc('w'),
	X = asc('x'),
	Y = asc('y'),
	Z = asc('z'),

	F1 = toKeycode(58),
	F2 = toKeycode(59),
	F3 = toKeycode(60),
	F4 = toKeycode(61),
	F5 = toKeycode(62),
	F6 = toKeycode(63),
	F7 = toKeycode(64),
	F8 = toKeycode(65),
	F9 = toKeycode(66),
	F10 = toKeycode(67),
	F11 = toKeycode(68),
	F12 = toKeycode(69),

	PrintScreen = toKeycode(70),
	ScrollLock = toKeycode(71),
	Pause = toKeycode(72),
	Insert = toKeycode(73),
	Home = toKeycode(74),
	PageUp = toKeycode(75),
	Delete = 127,
	End = toKeycode(77),
	PageDown = toKeycode(78),
	Right = toKeycode(79),
	Left = toKeycode(80),
	Down = toKeycode(81),
	Up = toKeycode(82),

	NumLockClear = toKeycode(83),
	KeypadDivide = toKeycode(84),
	KeypadMultiply = toKeycode(85),
	KeypadMinus = toKeycode(86),
	KeypadPlus = toKeycode(87),
	KeypadEnter = toKeycode(88),
	Keypad1 = toKeycode(89),
	Keypad2 = toKeycode(90),
	Keypad3 = toKeycode(91),
	Keypad4 = toKeycode(92),
	Keypad5 = toKeycode(93),
	Keypad6 = toKeycode(94),
	Keypad7 = toKeycode(95),
	Keypad8 = toKeycode(96),
	Keypad9 = toKeycode(97),
	Keypad0 = toKeycode(98),
	KeypadPeriod = toKeycode(99),

	LCtrl = toKeycode(224),
	LShift = toKeycode(225),
	LAlt = toKeycode(226),
	LGui = toKeycode(227),
	RCtrl = toKeycode(228),
	RShift = toKeycode(229),
	RAlt = toKeycode(230),
	RGui = toKeycode(231)
}

--[[
Exporting.
]]

return {
	KeyCode = KeyCode
}
