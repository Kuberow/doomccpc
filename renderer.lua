local M={}
function M.new(w,h)
  local r={w=w,h=h,buf={}}
  for y=1,h do r.buf[y]={} for x=1,w do r.buf[y][x]=0 end end
  return r
end
function M.clear(r,c)
  for y=1,r.h do local row=r.buf[y]; for x=1,r.w do row[x]=c end end
end
local function project(r,px,py,ang,x,y)
  local dx=x-px; local dy=y-py
  local ca=math.cos(ang); local sa=math.sin(ang)
  local vx=dx*ca+dy*sa
  local vy=-dx*sa+dy*ca
  if vx<=1 then return nil end
  local f=r.w*0.86
  return r.w/2 + (vy/vx)*f, vx
end
function M.walls(r,map,px,py,ang)
  local segs={}
  for _,l in ipairs(map.linedefs) do
    local x1,d1=project(r,px,py,ang,l.v1.x,l.v1.y)
    local x2,d2=project(r,px,py,ang,l.v2.x,l.v2.y)
    if x1 and x2 then
      if x1>x2 then x1,x2=x2,x1;d1,d2=d2,d1 end
      if x2>=1 and x1<=r.w then
        local d=math.max(1,(d1+d2)*0.5)
        local h=math.max(1,math.min(r.h*2,18000/d))
        local ya=math.floor(r.h/2-h/2)
        local yb=math.floor(r.h/2+h/2)
        segs[#segs+1]={x1=math.max(1,math.floor(x1)),x2=math.min(r.w,math.floor(x2)),ya=ya,yb=yb,d=d}
      end
    end
  end
  table.sort(segs,function(a,b)return a.d>b.d end)
  for _,s in ipairs(segs) do
    for x=s.x1,s.x2 do
      local row=r.buf
      local shade=math.max(32,math.min(255,math.floor(255-s.d*0.012)))
      for y=1,math.max(1,s.ya) do if row[y][x]==0 then row[y][x]=math.floor(shade*0.20) end end
      for y=math.max(1,s.ya),math.min(r.h,s.yb) do row[y][x]=shade end
      for y=math.min(r.h,s.yb)+1,r.h do if row[y][x]==0 then row[y][x]=math.floor(shade*0.12) end end
    end
  end
end
function M.present(r)
  local pal={"000000","202020","404040","606060","808080","a0a0a0","c0c0c0","e0e0e0"}
  local sx=math.max(1,math.floor(256/8))
  for y=1,r.h do
    local line={}
    for x=1,r.w do
      local v=r.buf[y][x] or 0
      line[x]=pal[math.min(8,math.floor(v/32)+1)]
    end
  end
end
return M
