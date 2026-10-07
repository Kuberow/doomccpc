-- DOOMCCPC native CraftOS-PC entry point
local wadlib=dofile("wad.lua")
local maplib=dofile("map.lua")
local renderlib=dofile("renderer.lua")
local gamelib=dofile("game.lua")
local moblib=dofile("mobj.lua")
local hudlib=dofile("hud.lua")
local texlib=dofile("textures.lua")
local planelib=dofile("planes.lua")
local speciallib=dofile("specials.lua")
local automaplib=dofile("automap.lua")
local weaponlib=dofile("weapons.lua")

local wad=wadlib.open("DOOM1.WAD")
local map=maplib.build(wad,"E1M1")
local textures=texlib.init(wad)
local W,H=term.getSize(2)
assert(term.setGraphicsMode(2),"CraftOS-PC graphics mode 2 is required")
term.setFrozen(true)

local r=renderlib.new(W,H,textures)
renderlib.palette(r)
local game=gamelib.new(map)
game.health=100
game.ammo=50
local objects=moblib.spawn(map)
local weapon=weaponlib.new()
local mapname="E1M1"
local function loadMap(name)
  if not wad:has(name) then return false end
  map=maplib.build(wad,name); mapname=name
  game=gamelib.new(map); game.health=100; game.ammo=50
  objects=moblib.spawn(map); weapon=weaponlib.new()
  return true
end
local keysDown={}
local running=true
local automap=false
local dead=false
local deadTimer=0
local timer=os.startTimer(1/35)

local function frame()
  renderlib.clear(r,0)
  if dead then
    for y=1,H do for x=1,W do if y>H/2 then r.buf[y][x]=math.floor((y/H)*64) else r.buf[y][x]=0 end end end
    if term.drawPixels then term.drawPixels(0,0,r.buf,W,H) end
    return
  end
  if automap then automaplib.draw(r,map,game); return end
  local sec=map.sectors[map.player.sector or 1]
  if sec then planelib.draw(r,wad,sec.floorpic,game.x,game.y,game.angle,false); planelib.draw(r,wad,sec.ceilingpic,game.x,game.y,game.angle,true) end
  renderlib.walls(r,map,game.x,game.y,game.angle)
  renderlib.objects(r,map,objects,game.x,game.y,game.angle)
  hudlib.draw(r,game,weapon.ammo.bullets or 0,game.health)
  if term.drawPixels then term.drawPixels(0,0,r.buf,W,H) end
end

frame()
while running do
  local e,a=os.pullEvent()
  if e=="key" then
    if dead then if a==keys.enter or a==keys.space then loadMap(mapname); dead=false; frame() end
    elseif
    if a==keys.q or a==keys.escape then running=false
    elseif a==keys.w then game.buttons.w=true
    elseif a==keys.s then game.buttons.s=true
    elseif a==keys.a then game.buttons.a=true
    elseif a==keys.d then game.buttons.d=true
    elseif a==keys.left then game.buttons.left=true
    elseif a==keys.right then game.buttons.right=true
    elseif a==keys.space then weaponlib.fire(weapon,objects,game,game.angle)
    elseif a==keys.e then speciallib.use(map,game)
    elseif a==keys.tab then automap=not automap
    elseif a==keys.f1 then loadMap("E1M1")
    elseif a==keys.f2 then loadMap("E1M2")
    elseif a==keys.f3 then loadMap("E1M3")
    elseif a==keys.f4 then loadMap("E1M4")
    elseif a==keys.f5 then loadMap("E1M5")
    elseif a==keys.f6 then loadMap("E1M6")
    elseif a==keys.f7 then loadMap("E1M7")
    elseif a==keys.f8 then loadMap("E1M8")
    elseif a==keys.f9 then loadMap("E1M9") end
  elseif e=="key_up" and not dead then
    if a==keys.w then game.buttons.w=nil
    elseif a==keys.s then game.buttons.s=nil
    elseif a==keys.a then game.buttons.a=nil
    elseif a==keys.d then game.buttons.d=nil
    elseif a==keys.left then game.buttons.left=nil
    elseif a==keys.right then game.buttons.right=nil end
  elseif e=="timer" and a==timer then
    if not dead then
      game:think(1/35)
      weaponlib.tick(weapon)
    moblib.update(objects,game,map,1/35)
      speciallib.tick(map)
        if game.health<=0 then dead=true;deadTimer=0 end
      frame()
    end
    timer=os.startTimer(1/35)
  end
end
term.setFrozen(false)
term.setGraphicsMode(0)
