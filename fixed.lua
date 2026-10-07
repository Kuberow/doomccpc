-- DOOM fixed-point arithmetic (16.16)
local M={}
M.FRACBITS=16
M.FRACUNIT=65536
function M.mul(a,b)
  local n=a*b
  if n>=0 then return math.floor(n/65536) else return math.ceil(n/65536) end
end
function M.div(a,b)
  assert(b~=0,"fixed divide by zero")
  local n=a*65536/b
  return n>=0 and math.floor(n) or math.ceil(n)
end
function M.fromInt(n) return n*65536 end
function M.toInt(n) return math.floor(n/65536) end
function M.abs(n) return n<0 and -n or n end
return M
