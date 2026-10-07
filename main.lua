-- DOOMCCPC native CraftOS-PC entry point
local wadlib=dofile("wad.lua")
local maplib=dofile("map.lua")
local renderlib=dofile("renderer.lua")

local wad=wadlib.open("DOOM1.WAD")
local map=maplib.build(wad,"E1M1")
local W,H=term.getSize(2)
assert(term.setGraphicsMode(2),"CraftOS-PC graphics mode 2 is required")
term.setFrozen(true)

local r=renderlib.new(W,H)
local px,py=map.player.x,map.player.y
local angle=math.rad(map.player.angle)

local function frame()
  renderlib.clear(r,0)
  renderlib.walls(r,map,px,py,angle)
  if term.drawPixels then
    term.drawPixels(r.buf)
  end
end

local function move(dx,dy)
  local c,s=math.cos(angle),math.sin(angle)
  px=px+dx*c-dy*s
  py=py+dx*s+dy*c
end

frame()
while true do
  local e,a=coroutine.yield()
  if e=="key" then
    if a==keys.w then move(8,0)
    elseif a==keys.s then move(-8,0)
    elseif a==keys.a then move(0,-8)
    elseif a==keys.d then move(0,8)
    elseif a==keys.left then angle=angle-math.rad(5)
    elseif a==keys.right then angle=angle+math.rad(5)
    elseif a==keys.q or a==keys.escape then break end
    frame()
  end
end
term.setFrozen(false)
term.setGraphicsMode(0)
