-- DOOM-style player movement and line collision.
local M={}
local RADIUS=16
local blocklib=dofile("blockmap.lua")
local function side(x,y,l)
  return (x-l.v1.x)*(l.v2.y-l.v1.y)-(y-l.v1.y)*(l.v2.x-l.v1.x)
end
local function closest(x,y,l)
  local dx=l.v2.x-l.v1.x; local dy=l.v2.y-l.v1.y
  local ll=dx*dx+dy*dy
  local t=((x-l.v1.x)*dx+(y-l.v1.y)*dy)/ll
  if t<0 then t=0 elseif t>1 then t=1 end
  local qx=l.v1.x+dx*t; local qy=l.v1.y+dy*t
  local ax=x-qx; local ay=y-qy
  return qx,qy,ax*ax+ay*ay
end
local function blocked(map,x,y)
  local candidates=nil
  if map.blockmap then candidates=blocklib.query(blocklib.build(map.blockmap),x,y,RADIUS) end
  local lines=map.linedefs
  if candidates then lines={};for _,i in ipairs(candidates) do lines[#lines+1]=map.linedefs[i+1] end end
  for _,l in ipairs(lines) do
    local _,_,d2=closest(x,y,l)
    if d2<RADIUS*RADIUS then
      if not l.left then return true end
      local a=l.right and l.right.sector
      local b=l.left and l.left.sector
      local sa=a and map.sectors[a+1]
      local sb=b and map.sectors[b+1]
      if sa and sb and math.min(sa.ceiling,sb.ceiling)-math.max(sa.floor,sb.floor)<56 then return true end
    end
  end
  return false
end
function M.new(map)
  local p=map.player
  local g={x=p.x,y=p.y,angle=math.rad(p.angle),speed=0,strafe=0,turn=0,buttons={}}
  function g:think(dt)
    local move=(self.buttons.w and 1 or 0)-(self.buttons.s and 1 or 0)
    local strafe=(self.buttons.d and 1 or 0)-(self.buttons.a and 1 or 0)
    local turn=(self.buttons.right and 1 or 0)-(self.buttons.left and 1 or 0)
    self.angle=self.angle+turn*math.rad(5)*dt*35
    local c,s=math.cos(self.angle),math.sin(self.angle)
    local dx=(move*c-strafe*s)*8*dt*35
    local dy=(move*s+strafe*c)*8*dt*35
    if not blocked(map,self.x+dx,self.y) then self.x=self.x+dx end
    if not blocked(map,self.x,self.y+dy) then self.y=self.y+dy end
  end
  return g
end
return M
