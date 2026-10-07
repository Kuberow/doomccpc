local M={}
function M.draw(r,map,player)
  local scale=2
  local minx,miny=1e9,1e9;local maxx,maxy=-1e9,-1e9
  for _,v in ipairs(map.vertices) do minx=math.min(minx,v.x);miny=math.min(miny,v.y);maxx=math.max(maxx,v.x);maxy=math.max(maxy,v.y) end
  local sx=(r.w-20)/math.max(1,maxx-minx);local sy=(r.h-20)/math.max(1,maxy-miny);scale=math.min(sx,sy)
  for _,l in ipairs(map.linedefs) do
    local x1=10+(l.v1.x-minx)*scale;local y1=10+(maxy-l.v1.y)*scale
    local x2=10+(l.v2.x-minx)*scale;local y2=10+(maxy-l.v2.y)*scale
    local n=math.max(math.abs(x2-x1),math.abs(y2-y1))
    for i=0,n do local t=n==0 and 0 or i/n;local x=math.floor(x1+(x2-x1)*t)+1;local y=math.floor(y1+(y2-y1)*t)+1;if x>=1 and x<=r.w and y>=1 and y<=r.h then r.buf[y][x]=128 end end
  end
  local x=math.floor(10+(player.x-minx)*scale)+1;local y=math.floor(10+(maxy-player.y)*scale)+1
  for yy=-2,2 do for xx=-2,2 do if x+xx>=1 and x+xx<=r.w and y+yy>=1 and y+yy<=r.h then r.buf[y+yy][x+xx]=255 end end end
end
return M
