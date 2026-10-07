local M={}
local defs={
 [1]={kind="player",sprite="PLAYA1",health=100,radius=16,speed=8,damage=10},
 [3001]={kind="monster",sprite="TROOA1",health=60,radius=20,speed=4,damage=10},
 [3004]={kind="monster",sprite="POSSA1",health=20,radius=20,speed=8,damage=3},
 [9]={kind="monster",sprite="SPOSA1",health=30,radius=20,speed=8,damage=15},
 [3002]={kind="monster",sprite="SARGA1",health=150,radius=30,speed=8,damage=20},
 [2001]={kind="weapon",sprite="SHOTWA0",amount=1},
 [2002]={kind="weapon",sprite="MGUNA0",amount=1},
 [2005]={kind="weapon",sprite="CSAWA0",amount=1},
 [2007]={kind="ammo",sprite="CLIPA0",amount=10},
 [2008]={kind="ammo",sprite="SHELA0",amount=4},
 [2011]={kind="ammo",sprite="ROCKA0",amount=1},
 [2012]={kind="ammo",sprite="STIMA0",amount=10},
 [2014]={kind="armor",sprite="BON2A0",amount=1},
 [2018]={kind="power",sprite="ARM1A0",amount=1},
 [2019]={kind="key",sprite="YKEYA0",amount=1},
 [2022]={kind="key",sprite="BSKUA0",amount=1},
 [2023]={kind="key",sprite="RKEYA0",amount=1,key="red"},
 [5]={kind="key",sprite="BKEYA0",amount=1,key="blue"},
 [6]={kind="key",sprite="YKEYA0",amount=1,key="yellow"},
 [13]={kind="key",sprite="RKEYA0",amount=1,key="red"},
 [38]={kind="key",sprite="RSKUA0",amount=1,key="red"},
 [39]={kind="key",sprite="YSKUA0",amount=1,key="yellow"},
 [40]={kind="key",sprite="BSKUA0",amount=1,key="blue"},
 [2047]={kind="health",sprite="STIMA0",amount=10},
 [2048]={kind="health",sprite="MEDIA0",amount=25},
 [2015]={kind="ammo",sprite="CLIPA0",amount=10},
}
function M.def(type) return defs[type] end
function M.spawn(map)
  local list={}
  for _,t in ipairs(map.things) do
    local d=defs[t.type]
    if d and d.kind~="player" then
      list[#list+1]={x=t.x,y=t.y,z=0,type=t.type,def=d,health=d.health or 1,angle=math.rad(t.angle),dead=false,attack=0}
    end
  end
  return list
end
function M.distance(a,b)local x=a.x-b.x;local y=a.y-b.y;return math.sqrt(x*x+y*y) end
function M.update(list,player,map,dt)
  player.ammo=player.ammo or 50
  for _,o in ipairs(list) do
    if not o.dead and o.def.kind~="monster" then
      if M.distance(o,player)<28 then
        if o.def.kind=="health" then player.health=math.min(100,(player.health or 100)+o.def.amount)
        elseif o.def.kind=="ammo" then player.ammo=(player.ammo or 0)+o.def.amount
        elseif o.def.kind=="armor" then player.armor=100
        elseif o.def.kind=="key" then player.keys=player.keys or {};player.keys[o.def.key]=true end
        o.dead=true
      end
    elseif not o.dead and o.def.kind=="monster" then
      local dx=player.x-o.x;local dy=player.y-o.y;local d=math.sqrt(dx*dx+dy*dy)
      if d<900 then
        o.angle=math.atan(dy,dx)
        if d>48 then
          local nx=o.x+math.cos(o.angle)*o.def.speed*dt*35
          local ny=o.y+math.sin(o.angle)*o.def.speed*dt*35
          local ok=true
          for _,l in ipairs(map.linedefs) do
            local vx=l.v2.x-l.v1.x;local vy=l.v2.y-l.v1.y;local ll=vx*vx+vy*vy
            local q=((nx-l.v1.x)*vx+(ny-l.v1.y)*vy)/ll;q=math.max(0,math.min(1,q))
            local px=l.v1.x+q*vx;local py=l.v1.y+q*vy
            if (nx-px)^2+(ny-py)^2<o.def.radius^2 and not l.left then ok=false;break end
          end
          if ok then o.x,o.y=nx,ny end
        elseif o.attack<=0 then
          player.health=math.max(0,(player.health or 100)-o.def.damage)
          o.attack=35
        end
      end
      if o.attack>0 then o.attack=o.attack-1 end
    end
  end
end
function M.shoot(list,player,angle)
  player.ammo=player.ammo or 50
  if player.ammo<=0 then return false end
  player.ammo=player.ammo-1
  local best=nil;local bd=1e9
  for _,o in ipairs(list) do
    if not o.dead and o.def.kind=="monster" then
      local dx=o.x-player.x;local dy=o.y-player.y;local d=math.sqrt(dx*dx+dy*dy)
      if d<bd then
        local da=math.atan(dy,dx)-angle
        while da>math.pi do da=da-2*math.pi end
        while da<-math.pi do da=da+2*math.pi end
        if math.abs(da)<math.rad(4) and d<1024 then best=o;bd=d end
      end
    end
  end
  if best then best.health=best.health-20;if best.health<=0 then best.dead=true end end
  return true
end
return M
