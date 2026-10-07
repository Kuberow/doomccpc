-- DOOMCCPC WAD loader
-- GPL-derived engine work; game data remains separate.
local M = {}

local function le16(s, p)
  local a,b = s:byte(p,p+1)
  if not a or not b then error("WAD: truncated u16") end
  return a + b*256
end

local function le32(s, p)
  local a,b,c,d = s:byte(p,p+3)
  if not d then error("WAD: truncated u32") end
  local n = a + b*256 + c*65536 + d*16777216
  if n >= 2147483648 then n = n - 4294967296 end
  return n
end

local function name8(s, p)
  return (s:sub(p,p+7):gsub("%z+$","")):upper()
end

function M.open(path)
  local f = assert(fs.open(path, "rb"), "cannot open "..path)
  local data = f.readAll()
  f.close()

  assert(#data >= 12, "invalid WAD: header too small")
  local ident = data:sub(1,4)
  assert(ident == "IWAD" or ident == "PWAD", "invalid WAD identification: "..ident)

  local count = le32(data, 5)
  local dir = le32(data, 9)
  assert(count >= 0 and dir >= 1 and dir + count*16 - 1 <= #data, "invalid WAD directory")

  local lumps = {}
  local byName = {}

  for i=0,count-1 do
    local p = dir + i*16
    local pos, size = le32(data,p), le32(data,p+4)
    local name = name8(data,p+8)
    assert(pos >= 0 and size >= 0 and pos + size <= #data, "invalid lump "..name)
    local lump = {index=i, name=name, pos=pos, size=size}
    lumps[#lumps+1] = lump
    byName[name] = i
  end

  local wad = {ident=ident, data=data, lumps=lumps, byName=byName}

  function wad:find(name)
    return self.byName[name:upper()]
  end

  function wad:lump(id)
    if type(id) == "string" then id = self:find(id) end
    assert(id ~= nil, "WAD lump not found")
    local l = self.lumps[id+1]
    return self.data:sub(l.pos+1, l.pos+l.size)
  end

  function wad:size(id)
    if type(id) == "string" then id = self:find(id) end
    return self.lumps[id+1].size
  end

  function wad:has(name)
    return self:find(name) ~= nil
  end

  return wad
end

function M.u16(s,p) return le16(s,p) end
function M.s16(s,p) local n=le16(s,p); return n>=32768 and n-65536 or n end
function M.u32(s,p) return le32(s,p) end
function M.s32(s,p) return le32(s,p) end

function M.parseVertexes(data)
  assert(#data % 4 == 0, "VERTEXES has invalid size")
  local t={}
  for p=1,#data,4 do
    t[#t+1]={x=M.s16(data,p),y=M.s16(data,p+2)}
  end
  return t
end

function M.parseThings(data)
  assert(#data % 10 == 0, "THINGS has invalid size")
  local t={}
  for p=1,#data,10 do
    t[#t+1]={
      x=M.s16(data,p), y=M.s16(data,p+2),
      angle=M.u16(data,p+4), type=M.u16(data,p+6), flags=M.u16(data,p+8)
    }
  end
  return t
end

function M.parseSectors(data)
  assert(#data % 26 == 0, "SECTORS has invalid size")
  local t={}
  for p=1,#data,26 do
    t[#t+1]={
      floor=M.s16(data,p), ceiling=M.s16(data,p+2),
      floorpic=data:sub(p+5,p+12):gsub("%z+$",""):upper(),
      ceilingpic=data:sub(p+14,p+21):gsub("%z+$",""):upper(),
      light=M.s16(data,p+22), special=M.u16(data,p+24), tag=M.u16(data,p+26)
    }
  end
  return t
end

function M.parseLinedefs(data)
  assert(#data % 14 == 0, "LINEDEFS has invalid size")
  local t={}
  for p=1,#data,14 do
    t[#t+1]={
      v1=M.u16(data,p), v2=M.u16(data,p+2),
      flags=M.u16(data,p+4), special=M.u16(data,p+6), tag=M.u16(data,p+8),
      right=M.u16(data,p+10), left=M.u16(data,p+12)
    }
  end
  return t
end

function M.parseSidedefs(data)
  assert(#data % 30 == 0, "SIDEDEFS has invalid size")
  local t={}
  for p=1,#data,30 do
    local function tex(o) return data:sub(p+o,p+o+7):gsub("%z+$",""):upper() end
    t[#t+1]={
      xoff=M.s16(data,p), yoff=M.s16(data,p+2),
      upper=tex(4), lower=tex(12), middle=tex(20),
      sector=M.u16(data,p+28)
    }
  end
  return t
end

return M
