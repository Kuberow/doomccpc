local M={}
local function side(x,y,n)
  local dx=x-n.x; local dy=y-n.y
  return dx*n.dy-dy*n.dx < 0 and 0 or 1
end
function M.collect(map,x,y)
  local out={}
  local function walk(child)
    if child>=0x8000 then
      local ss=map.subsectors[child-0x8000+1]
      if ss then
        for i=0,ss.numsegs-1 do out[#out+1]=map.segs[ss.firstseg+i+1] end
      end
      return
    end
    local n=map.nodes[child+1]
    if not n then return end
    local front=side(x,y,n)
    walk(n.children[front+1])
    walk(n.children[2-front])
  end
  if #map.nodes>0 then walk(#map.nodes-1) else
    for _,s in ipairs(map.segs) do out[#out+1]=s end
  end
  return out
end
return M
