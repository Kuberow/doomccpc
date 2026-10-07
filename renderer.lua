local M={}
local bsp=dofile("bsp.lua")
local texlib=dofile("textures.lua")
local moblib=dofile("mobj.lua")
function M.new(w,h,tex)
  local r={w=w,h=h,buf={},tex=tex,cache={}}
  for y=1,h do r.buf[y]={} for x=1,w do r.buf[y][x]=0 end end
  return r
end
function M.palette(r)
  if not r.tex or not r.tex.palette then return end
  for i=0,255 do local p=i*3+1; if p+2<=#r.tex.palette then term.setPaletteColor(i,r.tex.palette:byte(p)/255,r.tex.palette:byte(p+1)/255,r.tex.palette:byte(p+2)/255) end end
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
  for _,seg in ipairs(bsp.collect(map,px,py)) do
    local x1,d1=project(r,px,py,ang,seg.v1.x,seg.v1.y)
    local x2,d2=project(r,px,py,ang,seg.v2.x,seg.v2.y)
    if x1 and x2 then
      if x1>x2 then x1,x2=x2,x1;d1,d2=d2,d1 end
      if x2>=1 and x1<=r.w then
        local d=math.max(1,(d1+d2)*0.5)
        local h=math.max(1,math.min(r.h*2,18000/d))
        local ya=math.floor(r.h/2-h/2)
        local yb=math.floor(r.h/2+h/2)
        segs[#segs+1]={x1=math.max(1,math.floor(x1)),x2=math.min(r.w,math.floor(x2)),ya=ya,yb=yb,d=d,tex=seg.side and seg.side.middle}
      end
    end
  end
  table.sort(segs,function(a,b)return a.d>b.d end)
  for _,s in ipairs(segs) do
    for x=s.x1,s.x2 do
      local row=r.buf
      local shade=math.max(32,math.min(255,math.floor(255-s.d*0.012)))
      local tx=s.tex and r.tex and r.tex.textures[s.tex]
      if tx then
        local pic=r.cache[s.tex]
        if not pic then pic=texlib.buildPatch(r.tex,s.tex); r.cache[s.tex]=pic end
        if pic then
          local u=(x-s.x1)/math.max(1,s.x2-s.x1)
          local col=math.floor(u*(pic.w-1))+1
          for y=math.max(1,s.ya),math.min(r.h,s.yb) do
            local v=(y-s.ya)/math.max(1,s.yb-s.ya)
            local py=math.floor(v*(pic.h-1))+1
            row[y][x]=pic.px[py][col] or shade
          end
        end
      else
        for y=1,math.max(1,s.ya) do if row[y][x]==0 then row[y][x]=math.floor(shade*0.20) end end
        for y=math.max(1,s.ya),math.min(r.h,s.yb) do row[y][x]=shade end
        for y=math.min(r.h,s.yb)+1,r.h do if row[y][x]==0 then row[y][x]=math.floor(shade*0.12) end end
      end
    end
  end
end
function M.objects(r,map,objects,px,py,ang)
  local list={}
  for _,o in ipairs(objects) do
    if not o.dead then
      local dx=o.x-px; local dy=o.y-py; local ca=math.cos(ang); local sa=math.sin(ang)
      local vx=dx*ca+dy*sa; local vy=-dx*sa+dy*ca
      if vx>8 then
        local sx=r.w/2+(vy/vx)*r.w*0.86
        local size=math.max(2,math.min(r.h*2,3000/vx))
        list[#list+1]={o=o,sx=sx,size=size,vx=vx}
      end
    end
  end
  table.sort(list,function(a,b)return a.vx>b.vx end)
  for _,q in ipairs(list) do
    local name=q.o.def.sprite
    local pic=r.cache[name]
    if not pic then pic=texlib.buildPatch(r.tex,name);r.cache[name]=pic end
    if pic then
      local x0=math.floor(q.sx-q.size/2);local x1=math.floor(q.sx+q.size/2)
      for x=x0,x1 do if x>=0 and x<r.w then local u=(x-x0)/math.max(1,x1-x0);local col=math.floor(u*(pic.w-1))+1
        for y=math.max(1,math.floor(r.h/2-q.size)),math.min(r.h,math.floor(r.h/2+q.size)) do local v=(y-(r.h/2-q.size))/math.max(1,2*q.size);local py=math.floor(v*(pic.h-1))+1;local c=pic.px[py][col];if c then r.buf[y][x]=c end end
      end end
    end
  end
end
function M.present(r)
  term.drawPixels(0,0,r.buf,r.w,r.h)
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
