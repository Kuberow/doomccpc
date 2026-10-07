local M={}
function M.build(raw)
  local b={originx=raw.originx,originy=raw.originy,width=raw.width,height=raw.height,cells={}}
  for y=0,b.height-1 do
    b.cells[y]={}
    for x=0,b.width-1 do
      local i=y*b.width+x+1
      local off=raw.offsets[i]
      local list={}
      if off then
        local p=off*2+1
        while p<=#raw.data do
          local n=raw.u16(raw.data,p);p=p+2
          if n==65535 then break end
          list[#list+1]=n
        end
      end
      b.cells[y][x]=list
    end
  end
  return b
end
function M.attach(raw,data,u16)
  raw.data=data;raw.u16=u16
  return M.build(raw)
end
function M.query(b,x,y,r)
  local out={};local seen={}
  local minx=math.floor((x-r-b.originx)/128);local maxx=math.floor((x+r-b.originx)/128)
  local miny=math.floor((y-r-b.originy)/128);local maxy=math.floor((y+r-b.originy)/128)
  minx=math.max(0,minx);miny=math.max(0,miny);maxx=math.min(b.width-1,maxx);maxy=math.min(b.height-1,maxy)
  for cy=miny,maxy do for cx=minx,maxx do
    local cell=b.cells[cy][cx]
    for _,i in ipairs(cell) do if not seen[i] then seen[i]=true;out[#out+1]=i end end
  end end
  return out
end
return M
