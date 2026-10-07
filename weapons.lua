local M={}
M.defs={
 pistol={ammo="bullets",cost=1,damage=20,cooldown=14},
 shotgun={ammo="shells",cost=1,damage=50,cooldown=54},
 chaingun={ammo="bullets",cost=1,damage=20,cooldown=4}
}
function M.new()
 return {name="pistol",cooldown=0,ammo={bullets=50,shells=0},flash=0}
end
function M.select(w,name) if M.defs[name] then w.name=name;w.cooldown=0 end end
function M.canFire(w)
 local d=M.defs[w.name];return d and w.cooldown<=0 and (w.ammo[d.ammo] or 0)>=d.cost
end
function M.fire(w,mobs,player,angle)
 local d=M.defs[w.name]
 if not M.canFire(w) then return false end
 w.ammo[d.ammo]=w.ammo[d.ammo]-d.cost;w.cooldown=d.cooldown;w.flash=3
 local hits=0
 for _,o in ipairs(mobs) do
  if not o.dead and o.def.kind=="monster" then
   local dx=o.x-player.x;local dy=o.y-player.y;local dist=math.sqrt(dx*dx+dy*dy)
   local da=math.atan(dy,dx)-angle
   while da>math.pi do da=da-2*math.pi end
   while da<-math.pi do da=da+2*math.pi end
   if dist<1024 and math.abs(da)<math.rad(5) then
    o.health=o.health-d.damage;hits=hits+1
    if o.health<=0 then o.dead=true end
    break
   end
  end
 end
 return true,hits
end
function M.tick(w) if w.cooldown>0 then w.cooldown=w.cooldown-1 end;if w.flash>0 then w.flash=w.flash-1 end end
return M
