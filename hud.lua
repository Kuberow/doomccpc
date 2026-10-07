local M={}
function M.draw(r,player,ammo,health)
  local h=32
  local y0=r.h-h
  for y=y0,r.h-1 do for x=0,r.w-1 do r.buf[y+1][x+1]=0 end end
  local function bar(x,y,w,v,max)
    local n=math.max(0,math.min(w,math.floor(w*v/max)))
    for yy=y,y+5 do for xx=x,x+w-1 do r.buf[yy+1][xx+1]=(xx-x<n) and 96 or 32 end end
  end
  bar(8,y0+8,90,health or 0,100)
  bar(r.w-98,y0+8,90,ammo or 0,50)
  local cx=math.floor(r.w/2);local cy=math.floor((y0)/2)
  for i=-4,4 do if cx+i>=0 and cx+i<r.w then r.buf[cy+1][cx+i+1]=255 end end
  for i=-4,4 do if cy+i>=0 and cy+i<r.h then r.buf[cy+i+1][cx+1]=255 end end
end
return M
