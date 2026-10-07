local wadlib=dofile("wad.lua")
local M={}
function M.build(wad,mapname)
  local id=assert(wad:find(mapname),mapname.." not found")
  local function get(name)
    local i=assert(wad:find(name),"missing "..name)
    assert(i>id,name.." is not after "..mapname)
    return wad:lump(i)
  end
  local v=wadlib.parseVertexes(get("VERTEXES"))
  local ld=wadlib.parseLinedefs(get("LINEDEFS"))
  local sd=wadlib.parseSidedefs(get("SIDEDEFS"))
  local sec=wadlib.parseSectors(get("SECTORS"))
  local th=wadlib.parseThings(get("THINGS"))
  local segs=wadlib.parseSegs(get("SEGS"))
  local ssectors=wadlib.parseSubsectors(get("SSECTORS"))
  local nodes=wadlib.parseNodes(get("NODES"))
  local blockmap=wadlib.parseBlockmap(get("BLOCKMAP"))
  local out={vertices=v,linedefs=ld,sidedefs=sd,sectors=sec,things=th,segs=segs,subsectors=ssectors,nodes=nodes,blockmap=blockmap}
  for _,l in ipairs(ld) do
    l.v1=v[l.v1+1]; l.v2=v[l.v2+1]
    l.right=sd[l.right+1]
    if l.left~=65535 then l.left=sd[l.left+1] end
  end
  for _,s in ipairs(segs) do
    s.v1=v[s.v1+1]; s.v2=v[s.v2+1]
    s.line=ld[s.linedef+1]
    s.side=s.side==0 and s.line.right or s.line.left
    s.frontsector=s.side and sec[s.side.sector+1] or nil
    local back=(s.side==s.line.right) and s.line.left or s.line.right
    s.backsector=back and sec[back.sector+1] or nil
  end
  local p
  for _,t in ipairs(th) do if t.type==1 then p=t;break end end
  assert(p,"no player start")
  for _,t in ipairs(th) do if t.type==1 then
    for _,l in ipairs(ld) do if l.right and l.right.sector and sec[l.right.sector+1] then p.sector=l.right.sector+1; break end end
    break
  end end
  out.player=p
  return out
end
return M
