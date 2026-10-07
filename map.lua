local wadlib=dofile("wad.lua")
local M={}
function M.build(wad,mapname)
  local id=assert(wad:find(mapname),mapname.." not found")
  local function get(name)
    local i=assert(wad:find(name), "missing "..name)
    assert(i>id,name.." is not after "..mapname)
    return wad:lump(i)
  end
  local v=wadlib.parseVertexes(get("VERTEXES"))
  local ld=wadlib.parseLinedefs(get("LINEDEFS"))
  local sd=wadlib.parseSidedefs(get("SIDEDEFS"))
  local sec=wadlib.parseSectors(get("SECTORS"))
  local th=wadlib.parseThings(get("THINGS"))
  local out={vertices=v,linedefs=ld,sidedefs=sd,sectors=sec,things=th}
  for _,l in ipairs(ld) do
    l.v1=v[l.v1+1]; l.v2=v[l.v2+1]
    l.right=sd[l.right+1]
    if l.left~=65535 then l.left=sd[l.left+1] end
  end
  local p
  for _,t in ipairs(th) do if t.type==1 then p=t;break end end
  assert(p,"no player start")
  out.player=p
  return out
end
return M
