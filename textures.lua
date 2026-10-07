local M={}
local function u16(s,p)local a,b=s:byte(p,p+1);return a+b*256 end
local function s16(s,p)local n=u16(s,p);return n>=32768 and n-65536 or n end
local function u32(s,p)local a,b,c,d=s:byte(p,p+3);return a+b*256+c*65536+d*16777216 end
local function n8(s,p)return s:sub(p,p+7):gsub("%z+$",""):upper() end

function M.init(wad)
  local t={wad=wad,patches={},textures={},palette=nil,colormaps=nil}
  if wad:has("PLAYPAL") then
    local p=wad:lump("PLAYPAL"); t.palette=p:sub(1,768)
  end
  if wad:has("PNAMES") then
    local p=wad:lump("PNAMES"); local count=u32(p,1)
    for i=0,count-1 do t.patches[i]=n8(p,5+i*8) end
  end
  local function loadTextures(lump)
    if not wad:has(lump) then return end
    local d=wad:lump(lump); local count=u32(d,1)
    for i=0,count-1 do
      local q=5+i*4; local off=u32(d,q); local name=n8(d,off+1)
      local tx={name=name,width=u16(d,off+9),height=u16(d,off+11),patches={}}
      local pc=u16(d,off+21)
      for j=0,pc-1 do
        local p=off+23+j*10
        tx.patches[#tx.patches+1]={x=s16(d,p),y=s16(d,p+2),patch=u16(d,p+4)}
      end
      t.textures[name]=tx
    end
  end
  loadTextures("TEXTURE1"); loadTextures("TEXTURE2")
  return t
end

function M.patch(tex)
  local d=tex.wad:lump(tex.name)
  local w=u16(d,1); local h=u16(d,3); local cols={}
  for x=0,w-1 do
    local p=u32(d,9+x*4)+1; local posts={}
    while true do
      local top=d:byte(p); p=p+1
      if top==255 then break end
      local len=d:byte(p); local unused=d:byte(p+1); p=p+3
      local bytes=d:sub(p,p+len-1); p=p+len+1
      posts[#posts+1]={top=top,len=len,data=bytes}
    end
    cols[x]=posts
  end
  return {w=w,h=h,cols=cols}
end

function M.spritePatch(tex,name)
  if not tex.wad:has(name) then return nil end
  return M.patch({wad=tex.wad,name=name})
end
function M.buildPatch(tex,name)
  local tx=tex.textures[name]
  if not tx then return nil end
  local out={w=tx.width,h=tx.height,px={}}
  for y=1,tx.height do out.px[y]={} end
  for _,pr in ipairs(tx.patches) do
    local pn=tex.patches[pr.patch]
    if pn and tex.wad:has(pn) then
      local p=M.patch({wad=tex.wad,name=pn})
      for x=0,p.w-1 do
        local dx=pr.x+x+1
        if dx>=1 and dx<=tx.width then
          for _,post in ipairs(p.cols[x]) do
            for k=0,post.len-1 do
              local dy=pr.y+post.top+k+1
              if dy>=1 and dy<=tx.height then out.px[dy][dx]=post.data:byte(k+1) end
            end
          end
        end
      end
    end
  end
  return out
end
return M
