pub const INP_ESCAPE = 0x00;
pub const INP_1 = 0x01;
pub const INP_2 = 0x02;
pub const INP_3 = 0x03;
pub const INP_4 = 0x04;
pub const INP_5 = 0x05;
pub const INP_6 = 0x06;
pub const INP_7 = 0x07;
pub const INP_8 = 0x08;
pub const INP_9 = 0x09;
pub const INP_0 = 0x0a;
pub const INP_MINUS = 0x0b; // - on main keyboard
pub const INP_EQUALS = 0x0c;
pub const INP_BACK = 0x0d; // backspace
pub const INP_TAB = 0x0e;
pub const INP_Q = 0x0f;
pub const INP_W = 0x10;
pub const INP_E = 0x11;
pub const INP_R = 0x12;
pub const INP_T = 0x13;
pub const INP_Y = 0x14;
pub const INP_U = 0x15;
pub const INP_I = 0x16;
pub const INP_O = 0x17;
pub const INP_P = 0x18;
pub const INP_LBRACKET = 0x19;
pub const INP_RBRACKET = 0x1a;
pub const INP_RETURN = 0x1b; // Enter on main keyboard
pub const INP_LCONTROL = 0x1c;
pub const INP_A = 0x1d;
pub const INP_S = 0x1e;
pub const INP_D = 0x1f;
pub const INP_F = 0x20;
pub const INP_G = 0x21;
pub const INP_H = 0x22;
pub const INP_J = 0x23;
pub const INP_K = 0x24;
pub const INP_L = 0x25;
pub const INP_SEMICOLON = 0x26;
pub const INP_APOSTROPHE = 0x27;
pub const INP_GRAVE = 0x28; // accent grave, tilde
pub const INP_LSHIFT = 0x29;
pub const INP_BACKSLASH = 0x2a;
pub const INP_Z = 0x2b;
pub const INP_X = 0x2c;
pub const INP_C = 0x2d;
pub const INP_V = 0x2e;
pub const INP_B = 0x2f;
pub const INP_N = 0x30;
pub const INP_M = 0x31;
pub const INP_COMMA = 0x32;
pub const INP_PERIOD = 0x33; // . on main keyboard
pub const INP_SLASH = 0x34; // / on main keyboard
pub const INP_RSHIFT = 0x35;
pub const INP_MULTIPLY = 0x36; // * on numeric keypad
pub const INP_LMENU = 0x37; // left Alt
pub const INP_SPACE = 0x38;
pub const INP_CAPITAL = 0x39;
pub const INP_F1 = 0x3a;
pub const INP_F2 = 0x3b;
pub const INP_F3 = 0x3c;
pub const INP_F4 = 0x3d;
pub const INP_F5 = 0x3e;
pub const INP_F6 = 0x3f;
pub const INP_F7 = 0x40;
pub const INP_F8 = 0x41;
pub const INP_F9 = 0x42;
pub const INP_F10 = 0x43;
pub const INP_NUMLOCK = 0x44;
pub const INP_SCROLL = 0x45; // Scroll Lock
pub const INP_NUMPAD7 = 0x46;
pub const INP_NUMPAD8 = 0x47;
pub const INP_NUMPAD9 = 0x48;
pub const INP_SUBTRACT = 0x49; // - on numeric keypad
pub const INP_NUMPAD4 = 0x4a;
pub const INP_NUMPAD5 = 0x4b;
pub const INP_NUMPAD6 = 0x4c;
pub const INP_ADD = 0x4d; // + on numeric keypad
pub const INP_NUMPAD1 = 0x4e;
pub const INP_NUMPAD2 = 0x4f;
pub const INP_NUMPAD3 = 0x50;
pub const INP_NUMPAD0 = 0x51;
pub const INP_DECIMAL = 0x52; // . on numeric keypad
pub const INP_OEM_102 = 0x55; // <> or \| on RT 102-key keyboard (Non-U.S.)
pub const INP_F11 = 0x56;
pub const INP_F12 = 0x57;
pub const INP_F13 = 0x63; //                     (NEC PC98)
pub const INP_F14 = 0x64; //                     (NEC PC98)
pub const INP_F15 = 0x65; //                     (NEC PC98)
pub const INP_KANA = 0x6f; // (Japanese keyboard)
pub const INP_ABNT_C1 = 0x72; // /? on Brazilian keyboard
pub const INP_CONVERT = 0x78; // (Japanese keyboard)
pub const INP_NOCONVERT = 0x7a; // (Japanese keyboard)
pub const INP_YEN = 0x7c; // (Japanese keyboard)
pub const INP_ABNT_C2 = 0x7d; // Numpad . on Brazilian keyboard
pub const INP_NUMPADEQUALS = 0x8c; // = on numeric keypad (NEC PC98)
pub const INP_PREVTRACK = 0x8f; // Previous Track (INP_CIRCUMFLEX on Japanese keyboard)
pub const INP_AT = 0x90; //                     (NEC PC98)
pub const INP_COLON = 0x91; //                     (NEC PC98)
pub const INP_UNDERLINE = 0x92; //                     (NEC PC98)
pub const INP_KANJI = 0x93; // (Japanese keyboard)
pub const INP_STOP = 0x94; //                     (NEC PC98)
pub const INP_AX = 0x95; //                     (Japan AX)
pub const INP_UNLABELED = 0x96; //                        (J3100)
pub const INP_NEXTTRACK = 0x98; // Next Track
pub const INP_NUMPADENTER = 0x9b; // Enter on numeric keypad
pub const INP_RCONTROL = 0x9c;
pub const INP_MUTE = 0x9f; // Mute
pub const INP_CALCULATOR = 0xa0; // Calculator
pub const INP_PLAYPAUSE = 0xa1; // Play / Pause
pub const INP_MEDIASTOP = 0xa3; // Media Stop
pub const INP_VOLUMEDOWN = 0xad; // Volume -
pub const INP_VOLUMEUP = 0xaf; // Volume +
pub const INP_WEBHOME = 0xb1; // Web home
pub const INP_NUMPADCOMMA = 0xb2; // , on numeric keypad (NEC PC98)
pub const INP_DIVIDE = 0xb4; // / on numeric keypad
pub const INP_SYSRQ = 0xb6;
pub const INP_RMENU = 0xb7; // right Alt
pub const INP_PAUSE = 0xc4; // Pause
pub const INP_HOME = 0xc6; // Home on arrow keypad
pub const INP_UP = 0xc7; // UpArrow on arrow keypad
pub const INP_PRIOR = 0xc8; // PgUp on arrow keypad
pub const INP_LEFT = 0xca; // LeftArrow on arrow keypad
pub const INP_RIGHT = 0xcc; // RightArrow on arrow keypad
pub const INP_END = 0xce; // End on arrow keypad
pub const INP_DOWN = 0xcf; // DownArrow on arrow keypad
pub const INP_NEXT = 0xd0; // PgDn on arrow keypad
pub const INP_INSERT = 0xd1; // Insert on arrow keypad
pub const INP_DELETE = 0xd2; // Delete on arrow keypad
pub const INP_LWIN = 0xda; // Left Windows key
pub const INP_RWIN = 0xdb; // Right Windows key
pub const INP_APPS = 0xdc; // AppMenu key
pub const INP_POWER = 0xdd; // System Power
pub const INP_SLEEP = 0xde; // System Sleep
pub const INP_WAKE = 0xe2; // System Wake
pub const INP_WEBSEARCH = 0xe4; // Web Search
pub const INP_WEBFAVORITES = 0xe5; // Web Favorites
pub const INP_WEBREFRESH = 0xe6; // Web Refresh
pub const INP_WEBSTOP = 0xe7; // Web Stop
pub const INP_WEBFORWARD = 0xe8; // Web Forward
pub const INP_WEBBACK = 0xe9; // Web Back
pub const INP_MYCOMPUTER = 0xea; // My Computer
pub const INP_MAIL = 0xeb; // Mail
pub const INP_MEDIASELECT = 0xec; // Media Select

//  Alternate names for keys, to facilitate transition from DOS.
pub const INP_BACKSPACE = INP_BACK; // backspace
pub const INP_NUMPADSTAR = INP_MULTIPLY; // * on numeric keypad
pub const INP_LALT = INP_LMENU; // left Alt
pub const INP_CAPSLOCK = INP_CAPITAL; // CapsLock
pub const INP_NUMPADMINUS = INP_SUBTRACT; // - on numeric keypad
pub const INP_NUMPADPLUS = INP_ADD; // + on numeric keypad
pub const INP_NUMPADPERIOD = INP_DECIMAL; // . on numeric keypad
pub const INP_NUMPADSLASH = INP_DIVIDE; // / on numeric keypad
pub const INP_RALT = INP_RMENU; // right Alt
pub const INP_UPARROW = INP_UP; // UpArrow on arrow keypad
pub const INP_PGUP = INP_PRIOR; // PgUp on arrow keypad
pub const INP_LEFTARROW = INP_LEFT; // LeftArrow on arrow keypad
pub const INP_RIGHTARROW = INP_RIGHT; // RightArrow on arrow keypad
pub const INP_DOWNARROW = INP_DOWN; // DownArrow on arrow keypad
pub const INP_PGDN = INP_NEXT; // PgDn on arrow keypad
pub const INP_TILDE =
    INP_GRAVE; // Because nobody knows what an "INP_GRAVE" is.

//Joystick buttons
// Annoyingly there are a billion joystick buttons that have no spot, so I'm just going to cram them
// into this table whereever there are spaces.
pub const INP_JOY1 = 0x58;
pub const INP_JOY2 = 0x59;
pub const INP_JOY3 = 0x5a;
pub const INP_JOY4 = 0x5b;
pub const INP_JOY5 = 0x5c;
pub const INP_JOY6 = 0x5d;
pub const INP_JOY7 = 0x5e;
pub const INP_JOY8 = 0x5f;
pub const INP_JOY9 = 0x60;
pub const INP_JOY10 = 0x61;

pub const INP_JOY11 = 0x7d;
pub const INP_JOY12 = 0x7e;
pub const INP_JOY13 = 0x7f;
pub const INP_JOY14 = 0x80;
pub const INP_JOY15 = 0x81;
pub const INP_JOY16 = 0x82;
pub const INP_JOY17 = 0x83;
pub const INP_JOY18 = 0x84;
pub const INP_JOY19 = 0x85;
pub const INP_JOY20 = 0x86;
pub const INP_JOY21 = 0x87;
pub const INP_JOY22 = 0x88;
pub const INP_JOY23 = 0x89;
pub const INP_JOY24 = 0x8a;
pub const INP_JOY25 = 0x57; // ok technically directX can handle 31 button joysticks, but I'm gonna say 24 is enough

// pov[0]
pub const INP_JOYPAD_UP = 0xb7;
pub const INP_JOYPAD_DOWN = 0xb8;
pub const INP_JOYPAD_LEFT = 0xb9;
pub const INP_JOYPAD_RIGHT = 0xba;

// pov[1] - pov[3]
pub const INP_POV1_UP = 0x65;
pub const INP_POV1_DOWN = 0x66;
pub const INP_POV1_LEFT = 0x67;
pub const INP_POV1_RIGHT = 0x6f;

pub const INP_POV2_UP = 0x70;
pub const INP_POV2_DOWN = 0x72;
pub const INP_POV2_LEFT = 0x73;
pub const INP_POV2_RIGHT = 0x74;

pub const INP_POV3_UP = 0x75;
pub const INP_POV3_DOWN = 0x78;
pub const INP_POV3_LEFT = 0x7a;
pub const INP_POV3_RIGHT = 0x8c;

// XY axis
pub const INP_JOYSTICK1_UP = 0xbb;
pub const INP_JOYSTICK1_DOWN = 0xbc;
pub const INP_JOYSTICK1_LEFT = 0xbd;
pub const INP_JOYSTICK1_RIGHT = 0xbe;

// Z, Zrot Axis
pub const INP_JOYSTICK2_UP = 0xa3;
pub const INP_JOYSTICK2_DOWN = 0xa4;
pub const INP_JOYSTICK2_LEFT = 0xa5;
pub const INP_JOYSTICK2_RIGHT = 0xa6;

// Xrot, Yrot Axis
pub const INP_JOYSTICK3_UP = 0x8d;
pub const INP_JOYSTICK3_DOWN = 0x96;
pub const INP_JOYSTICK3_LEFT = 0x98;
pub const INP_JOYSTICK3_RIGHT = 0x99;

pub const INP_KEY_LAST = 0xeb;

// Mouse buttons
//	Although DirectX 8.1 returns 256 key scan codes, only 237 keys are defined.
//	This map the mouse buttons to right after INP_MEDIASELECT.  The only purpose
//	is so that the keybinding system can use an array of 256 elements to bind
//	both keyboard and mouse commands.
//
pub const INP_MOUSE_BUTTONS = 0xed;
pub const INP_LBUTTON = INP_MOUSE_BUTTONS + 0;
pub const INP_MBUTTON = INP_MOUSE_BUTTONS + 1;
pub const INP_RBUTTON = INP_MOUSE_BUTTONS + 2;
pub const INP_BUTTON4 = INP_MOUSE_BUTTONS + 3;
pub const INP_BUTTON5 = INP_MOUSE_BUTTONS + 4;
pub const INP_BUTTON6 = INP_MOUSE_BUTTONS + 5;
pub const INP_BUTTON7 = INP_MOUSE_BUTTONS + 6;
pub const INP_BUTTON8 = INP_MOUSE_BUTTONS + 7;
pub const INP_MOUSEWHEEL = INP_MOUSE_BUTTONS + 8;

pub const INP_MOUSE_CHORD = INP_MOUSE_BUTTONS + 9;

// mouse wheel, drags, and clicks will send additional signals for fine tuning of input with binds
pub const INP_LCLICK = INP_MOUSE_BUTTONS + 10;
pub const INP_MCLICK = INP_MOUSE_BUTTONS + 11;
pub const INP_RCLICK = INP_MOUSE_BUTTONS + 12;
pub const INP_LDRAG = INP_MOUSE_BUTTONS + 13;
pub const INP_MDRAG = INP_MOUSE_BUTTONS + 14;
pub const INP_RDRAG = INP_MOUSE_BUTTONS + 15;
pub const INP_MOUSEWHEEL_FORWARD = INP_MOUSE_BUTTONS + 16; // <--0xfe, end of array
pub const INP_MOUSEWHEEL_BACKWARD = 0x52; // we hit end of 256 array
pub const INP_LDBLCLICK = 0x53; // so now annoyingly I have to jump to new empty spot in table
pub const INP_MDBLCLICK = 0x76;
pub const INP_RDBLCLICK = 0x9c; // Note to self every thing before 0x9C is taken so if I need to
// find another empty sopt start form there
pub const INP_VIRTUALKEY_LAST = INP_MOUSEWHEEL_FORWARD;

// Special aliases
// These are only meaningful for use with inpLevel() and inpEdge().
pub const INP_SPECIAL_ALIASES = 0x800;
pub const INP_CONTROL = INP_SPECIAL_ALIASES + 1;
pub const INP_SHIFT = INP_SPECIAL_ALIASES + 2;
pub const INP_ALT = INP_SPECIAL_ALIASES + 3;
