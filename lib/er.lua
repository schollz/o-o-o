--- Euclidean rhythm (http://en.wikipedia.org/wiki/Euclidean_Rhythm)
-- @module lib.er
-- recklessly edited by infinitedigits

er={}
--- gen
-- @tparam number k : number of pulses
-- @tparam number n : total number of steps
-- @tparam number w : shift amount
-- @treturn table
function er.gen(n,k,w)
  w=w or 0
  -- results array, intially all zero
  local r={}
  for i=1,n do r[i]=false end

  if k<1 then return r end

  -- using the "bucket method"
  -- for each step in the output, add K to the bucket.
  -- if the bucket overflows, this step contains a pulse.
  local b=n
  for i=1,n do
    if b>=n then
      b=b-n
      local j=i+w
      while (j>n) do j=j-n end
      while (j<1) do j=j+n end
r[j]=true
    end
    b=b+k
  end
  return r
end

function er.num_empty(r)
  local n=0
  for _,v in ipairs(r) do
    if not v then
      n=n+1
    end
  end
  return n
end

function er.fill_empty(r,r2)
  local j=0
  for i,v in ipairs(r) do
    if not v then
      j=j+1
      if j<=#r2 then
        r[i]=r2[j]
      end
    end
  end
  return r
end

function er.print(r)
  for i,v in ipairs(r) do
    print(i,v)
  end
end

function er.random(n,density)
  local k=math.random(1,math.floor(n*density))
  local w=math.random(0,n-1)
  return er.gen(n,k,w)
end

function er.random2(n,density)
  local r=er.random(n,density)
  local n2=er.num_empty(r)
  if n2>0 then
    local k2=math.random(0,n2>2 and 3 or 1)
    local w2=math.random(0,n2>2 and 2 or 1)
    local r2=er.gen(n2,k2,w2)
    r=er.fill_empty(r,r2)
  end
  return r
end

-- local r=er.gen(16,4,1)
-- er.print(r)
-- print(er.num_empty(r))
-- local r2=er.gen(er.num_empty(r),er.num_empty(r)/2,2)
-- local r3=er.fill_empty(r,r2)
-- er.print(r3)

return er
