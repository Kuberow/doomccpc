-- DOOMCCPC
-- First engine milestone: native CraftOS-PC WAD loading.
-- Put your legally obtained DOOM1.WAD beside this file.
-- Audio is intentionally not implemented.

local wadlib = dofile("wad.lua")
local WAD_PATH = "DOOM1.WAD"

local wad = wadlib.open(WAD_PATH)

local function printf(...)
  print(string.format(...))
end

term.clear()
term.setCursorPos(1,1)
print("DOOMCCPC")
print("--------")
printf("WAD: %s", wad.ident)
printf("Lumps: %d", #wad.lumps)

local map = "E1M1"
local mapid = wad:find(map)
assert(mapid, map.." not found")

-- DOOM map lumps are stored consecutively after the map marker.
local wanted = {
  "THINGS", "LINEDEFS", "SIDEDEFS", "VERTEXES",
  "SEGS", "SSECTORS", "NODES", "SECTORS", "REJECT", "BLOCKMAP"
}

local mapdata = {}
for i,name in ipairs(wanted) do
  local id = wad:find(name)
  assert(id, "missing lump "..name)
  assert(id > mapid, name.." is not after "..map)
  mapdata[name] = wad:lump(id)
end

local vertices = wadlib.parseVertexes(mapdata.VERTEXES)
local lines = wadlib.parseLinedefs(mapdata.LINEDEFS)
local sides = wadlib.parseSidedefs(mapdata.SIDEDEFS)
local sectors = wadlib.parseSectors(mapdata.SECTORS)
local things = wadlib.parseThings(mapdata.THINGS)

print("")
printf("%s loaded.", map)
printf("Vertices: %d", #vertices)
printf("Linedefs: %d", #lines)
printf("Sidedefs: %d", #sides)
printf("Sectors: %d", #sectors)
printf("Things: %d", #things)

local player
for _,thing in ipairs(things) do
  if thing.type == 1 then player=thing break end
end

assert(player, "E1M1 has no player start")
printf("Player start: %d, %d angle %d", player.x, player.y, player.angle)

print("")
print("WAD parser online.")
print("Next engine stage: BSP renderer + DOOM fixed-point math.")
