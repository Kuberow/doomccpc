local M={}
local function near(x,y,l)
  local dx=l.v2.x-l.v1.x;local dy=l.v2.y-l.v1.y;local q=((x-l.v1.x)*dx+(y-l.v1.y)*dy)/(dx*dx+dy*dy)
  q=math.max(0,math.min(1,q));local px=l.v1.x+q*dx;local py=l.v1.y+q*dy
  return (x-px)^2+(y-py)^2
end
function M.use(map,player)
  for _,l in ipairs(map.linedefs) do
    if l.special and l.special~=0 and near(player.x,player.y,l)<48*48 then
      local a=l.right and l.right.sector and map.sectors[l.right.sector+1]
      local b=l.left and l.left.sector and map.sectors[l.left.sector+1]
      local s=a or b
      if l.special==11 or l.special==51 or l.special==52 then l.special=0; return "exit",l.special end
      local need=({[26]="blue",[27]="yellow",[28]="red"})[l.special]
      if need and not (player.keys and player.keys[need]) then return "locked" end
      if s then
        if l.special==1 or l.special==26 or l.special==27 or l.special==28 or l.special==31 or l.special==32 or l.special==33 or l.special==34 then
          if not s.open then s.closedCeiling=s.ceiling;s.open=true;s.ceiling=s.floor+128 end
        elseif l.special==11 or l.special==51 then
          s.floor=s.floor+24
        elseif l.special==2 or l.special==3 or l.special==4 then
          s.floor=s.floor+24
        end
      end
      l.special=0
      return true
    end
  end
  return false
end
function M.tick(map)
  for _,s in ipairs(map.sectors) do
    if s.open and s.ceiling>s.floor+128 then s.ceiling=s.floor+128 end
  end
end
return M
