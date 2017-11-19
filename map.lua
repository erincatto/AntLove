RIGHT_EDGE = 56
LEFT_EDGE = 0
FLOOR_COUNT = 32

LIST_START = 1
LIST_END = 32

-- Floor elevations
FZ = 50 --  low
F0 = 46 --   ^
F1 = 42 --   |
F2 = 38 --   |
F3 = 34 --   |
F4 = 30 --   |
F5 = 26 --   v
F6 = 22 --  high

RAID_FLAG    = 0xFF  -- RAID flag, 2 raid and sod segments
PIT_FLAG     = 0xFE  -- PIT flag, 12 pit segments
SPRAY_FLAG   = 0xFD  -- SPRAY flag, 1 sod and launch spray
ROCK_FLAG    = 0xFC  -- ROCK flag, rock boss
SHOE_FLAG    = 0xFB  -- SHOE flag, shoe boss
FACE_FLAG    = 0xFA  -- FACE flag, face boss
MAN_FLAG     = 0xF9  -- MAN flag, man boss
SOD_FLAG     = 0xF8  -- sod
NONE_FLAG	 = 0xF7  -- no floor

-- FLOORDATA table holds all the data and special codes for obstacles
-- the first byte of the instruction byte contains the floor elevation
-- the second byte contains the horizontal length or an obstacle flag
-- which is handled in the routine NEWFLOOR

local RDB = RAID_FLAG  -- abreviate flags for data list
local PTB = PIT_FLAG
local SPB = SPRAY_FLAG
local RKB = ROCK_FLAG
local SHB = SHOE_FLAG
local FCB = FACE_FLAG
local MNB = MAN_FLAG

map = {}

--
function map.init()

	-- print("map.init")

	-- The current state of the map
	map.state =
	{
		-- Index into floor data
		dataIndex = -1,

		-- Checkpoint data index
		checkpoint = -1,
		
		-- Elevation of the new sod
		elevation = 0xFE,

		-- The remaing number of sod chunks to be deployed (wpar2)
		sodCount = 0,

		-- Image index of current sod
		sodIndex = 1,

		-- Obstacle code (wpar2)
		code = SOD_FLAG,

		-- Index into floor loop
		loopIndex = 32
	}

	-- Holds the current floor elevations for 32 * 4 pixel segments = 128 pixels
	map.loop = {}
	for i = 1, 32 do
		map.loop[i] = {elevation = F0, code = NONE_FLAG, sodIndex = 1}
	end

	map.data =
	{
		-- F0, 31, F0, MNB,

		-- F0, 8,   F1, 4,   F6, 6,
		-- F0, 4,   F1, 4,   F2, 4,   F3, 4,   F4, 4,
		-- F5, 4,   F6, 8,   F6, FCB,

		-- F1, 31, F1, RKB,
		-- F1, 31, F1, SHB,

		F0, RDB, F0, 10,
		F1, 4,   F2, 4,   F3, 4,   F4, 4,   F5, 4,
		F6, 8,   F0, PTB, F6, 8,   F5, 4,   F4, 4,
		F3, 4,   F2, 4,   F1, 16,  F1, SPB, F3, 5,
		F3, RDB, F3, 8,   F2, 16,  F0, PTB, F2, 4,
		F1, 4,   F1, RDB, F1, 6,   F1, RDB, F1, 6,
		F2, 10,  F2, 6,   F0, PTB, F2, 4,   F3, 4,
		F4, 3,   F4, SPB, F5, 4,   F6, 8,   F5, RDB,
		FZ, PTB, F1, 6,   F1, 28,  F2, 4,   F2, RKB,
		F4, 4,   F0, PTB, F5, 5,   F6, 4,   F0, PTB,
		F2, 8,   F2, RDB, F2, RDB, F5, 4,   F6, 8,
		F6, SPB, F0, PTB,  F6, 8,   F0, PTB, F6, 4,
		F0, PTB, F6, 3,   F0, PTB, F6, 4,   F6, SPB,
		F0, PTB, F2, 8,   F0, 6,   F1, 4,   F2, 4,
		F3, 4,   F4, 4,   F5, 4,   F6, 4,   FZ, RDB,
		FZ, RDB, FZ, RDB, FZ, RDB, F0, 8,   F4, 4,
		F3, 4,   F2, 4,   F1, 4,   FZ, PTB, F0, 4,
		F0, SPB, F1, 4,   F6, 3,   F1, 28,  F2, 4,
		F2, SHB, FZ, PTB, F1, 4,   F2, 4,   F3, 4,
		F4, 4,   F5, 4,   F6, 4,   F4, RDB, F2, RDB,
		F0, RDB, F2, 4,   F4, 4,   FZ, PTB, F6, 3,
		FZ, PTB, F4, 3,   FZ, PTB, F6, 3,   F6, SPB,
		FZ, PTB, F4, 3,   FZ, PTB, F6, 3,   F0, RDB,
		F0, RDB, F0, RDB, F0, 8,   F1, 4,   F6, 6,
		F0, 4,   F1, 4,   F2, 4,   F3, 4,   F4, 4,
		F5, 4,   F6, 8,   F6, FCB, F0, 4,   F0, SPB,
		F3, 3,   F4, 4,   F0, 2,   F2, 2,   F6, 3,
		F5, 2,   F2, 5,
		F2, RDB, F0, 6,   F5, 3,   F4, 3,   F3, 6,
		F2, 4,   F2, SPB, F6, 6,   FZ, PTB, FZ, RDB,
		F0, 6,   F5, 3,   F6, 3,   F4, 2,   F3, 2,
		F2, 6,   F5, 4,   F4, 6,   F4, SPB, FZ, PTB,
		F2, 4,   F6, 3,   F3, 3,   F5, 5,   F5, RDB,
		F6, 3,   F6, SPB, F0, 6,   F4, 2,   F5, 2,
		F6, 4,   FZ, PTB, F4, 4,   F4, SPB, F0, 8,
		F0, RDB, F1, 6,   F6, 4,   F5, 1,   F6, 1,
		F5, 1,   F6, 1,   F5, 1,   F6, 1,   F5, 1,
		F6, 1,   F5, 1,   F6, 1,   F5, 1,   F6, 1,
		F5, 1,   F6, 1,   F5, 1,   F6, 1,   F5, 1,
		F6, 1,   F5, 1,   F6, 1,   F5, 1,   F6, 1,
		F5, 1,   F6, 4,   F5, 4,   F5, SPB, F6, 4,
		FZ, PTB, FZ, RDB, F0, 5,   F1, 2,   F2, 3,
		F3, 2,   F4, 3,   F5, 2,   F6, 3,   F5, 2,
		F4, RDB, F0, 6,   F3, 2,   F6, 8,   F6, SPB,
		F0, PTB, F6, 3,   F0, PTB,   F6, 3,   F0, PTB,
		F6, 3,   F0, PTB,   F6, 3,   F6, RDB, F6, 2,
		F0, PTB,   F6, 3,   F4, PTB, F5, 5,   F4, 4,
		F3, 3,   F2, 2,   F1, 1,   F0, 5,   F0, RDB,
		F1, 4,   F0, 4,   F0, RDB, F3, 4,   F0, 5,
		F1, RDB, F0, 6,   F0, RDB, F0, 5,   F0, RDB,
		F0, 5,   F0, RDB, F1, 4,   FZ, PTB, F0, 3,
		F0, SPB, F0, RDB, F5, 4,   F4, PTB, F5, 4,
		F0, 34,  F0, MNB
	}
end

-- Returns the height field data at a given x coordinate
function map.getFloor(x)
	local index = x / 4 + 1;
	assert(1 <= index and index <= 32)
	return map.loop[index];
end
