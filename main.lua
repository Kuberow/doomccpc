-- DOOMCCPC native CraftOS-PC entry point
local wadlib=dofile("wad.lua")
local maplib=dofile("map.lua")
local renderlib=dofile("renderer.lua")
local gamelib=dofile("game.lua")

local wad=wadlib.open("DOOM1.WAD")
local map=maplib.build(wad,"E1M1")
local W,H=term.getSize(2)
assert(term.setGraphicsMode(2),"CraftOS-PC graphics mode 2 is required")
term.setFrozen(true)

local r=renderlib.new(W,H)
local game=gamelib.new(map)
local keysDown={}
local running=true
local timer=os.startTimer(1/35)

local function frame()
  renderlib.clear(r,0)
  renderlib.walls(r,map,game.x,game.y,game.angle)
  if term.drawPixels then term.drawPixels(r.buf) end
end

frame()
while running do
  local e,a=os.pullEvent()
  if e=="key" then
    if a==keys.q or a==keys.escape then running=false
    elseif a==keys.w then game.buttons.w=true
    elseif a==keys.s then game.buttons.s=true
    elseif a==keys.a then game.buttons.a=true
    elseif a==keys.d then game.buttons.d=true
    elseif a==keys.left then game.buttons.left=true
    elseif a==keys.right then game.buttons.right=true end
  elseif e=="key_up" then
    if a==keys.w then game.buttons.w=nil
    elseif a==keys.s then game.buttons.s=nil
    elseif a==keys.a then game.buttons.a=nil
    elseif a==keys.d then game.buttons.d=nil
    elseif a==keys.left then game.buttons.left=nil
    elseif a==keys.right then game.buttons.right=nil end
  elseif e=="timer" and a==timer then
    game:think(1/35)
    frame()
    timer=os.startTimer(1/35)
  end
end
term.setFrozen(false)
term.setGraphicsMode(0)
