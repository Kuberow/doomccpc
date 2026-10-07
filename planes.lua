local M={}
local cache={}
function M.load(wad,name)
  if not wad:has(name) then return nil end
  local d=wad:lump(name)
  if #d<4096 then return nil end
  local p={}
  for y=1,64 do p[y]={}; for x=1,64 do p[y][x]=d[(y-1)*64+x]:byte() end end
  return p
end
function M.draw(r,wad,name,px,py,ang,top)
  local p=cache[name]
  if not p then p=M.load(wad,name);cache[name]=p end
  if not p then return end
  local ca,sa=math.cos(ang),math.sin(ang)
  local horizon=math.floor(r.h/2)
  local plane=top and 120 or -120
  for y=1,r.h do
    local dy=y-horizon
    if (top and dy<0) or ((not top) and dy>0) then
      local dist=math.abs(plane*math.max(1,64/dy))
      local step=dist/r.w
      for x=1,r.w do
        local sx=(px+ca*dist+(-sa)*(x-r.w/2)*step)%64
        local sy=(py+sa*dist+ca*(x-r.w/2)*step)%64
        local c=p[math.floor(sy)+1][math.floor(sx)+1]
        if r.buf[y][x]==0 then r.buf[y][x]=c end
      end
    end
  end
end
return M
