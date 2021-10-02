function sign(x)
  if x<0 then
    return-1
  end
  return 1
end

function distance_points(x1,y1,x2,y2)
  local dx=x1-x2
  local dy=y1-y2
  return math.sqrt (dx*dx+dy*dy)
end

-- https://math.stackexchange.com/a/995675
function perpendicular_points(p1,p2,d)
  local p3={{0,0},{0,0}}
  for i=1,2 do
    p3[1][i]=(p1[i]+p2[i])/2
    p3[2][i]=(p1[i]+p2[i])/2
  end
  local factor=d/math.sqrt((p2[2]-p1[2])^2+(p2[1]-p1[1])^2)
  local i=1
  p3[i][1]=p3[i][1]+factor*(p1[2]-p2[2])
  p3[i][2]=p3[i][2]+factor*(p2[1]-p1[1])
  i=2
  factor=factor*-1
  p3[i][1]=p3[i][1]+factor*(p1[2]-p2[2])
  p3[i][2]=p3[i][2]+factor*(p2[1]-p1[1])
  return p3[2],p3[1]
end

function is_dir(path)
  local f=io.open(path,"r")
  local ok,err,code=f:read(1)
  f:close()
  return code==21
end

-- transpose_to_rate tranposes note1 to note2 as intonation
function transpose_to_intonation(note1,note2)
  -- transpose note1 into note2 using rates
  local rate=1

  -- https://github.com/monome/norns/blob/main/lua/lib/intonation.lua#L16
  local ints={1/1,16/15,9/8,6/5,5/4,4/3,45/32,3/2,8/5,5/3,16/9,15/8}

  while note2-note1>11 or note1>note2 do
    if note1<note2 then
      rate=rate*2
      note1=note1+12
    elseif note1>note2 then
      rate=rate*0.5
      note1=note1-12
    end
  end
  return rate*ints[note2-note1+1]
end
