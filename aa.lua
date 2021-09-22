-- new script v0.0.1
-- ?
--
-- llllllll.co/t/?
--
--
--
--    ▼ instructions below ▼
--
-- ?

local keydown={}
local er=include("aa/lib/er")
local Lattice=require("lattice")
local MusicUtil=require("musicutil")

engine.name="Fm1"

function init()

  local divisions={1/32,1/16,1/8,1/4,1/2,1}
  note_root=60
  playing=false
  notework_pos=1
  notework_initialize(42)

  local lattice=Lattice:new{
    ppqn=96
  }
  for i,div in ipairs(divs) do
    local step=0
    lattice:new_pattern{
      action=function(t)
        step=step+1
        if playing then 
          for j,nw in ipairs(notework) do 
            if nw.div==div then 
              notework[j].pos=(step%#nw.er)+1
              -- emit if either...
              -- ...it is connected TO something
              -- ...it is armed
              if nw.er[notework[j].pos] then
                notework[j].iterated=true
                local to=notework_to(j)
                if (#to>0 or nw.armed) then 
                  notework[j].emitted=true
                  -- emit note 
                  engine.hz(MusicUtil.note_num_to_freq(note_root+nw.note))            

                  -- arm connected
                  for _,j2 in ipairs(to) do 
                    notework[j2].armed=true
                  end

                  -- disarm current
                  notework[j].armed=false
                else
                  notework[j].emitted=false
                end
              else
                notework[j].iterated=false
                notework[j].emitted=false
              end
            end
          end
        end
      end,
      division=div,
    }
  end
  lattice:start()

  -- -- define the chord lists
  -- chord_list={
  --   {2,2,0},
  --   {3,2,0},
  --   {3,2,0},
  --   {2,3,-1},
  -- }
  -- chord_current=1
  -- choice_chord_list={}
  -- for j=-2,2 do
  --   for i,c in ipairs({{2,2},{2,3},{3,2}}) do
  --     table.insert(choice_chord_list,{c[1],[c[2],j]})
  --   end
  -- end

  -- initialize metro for updating screen
  timer=metro.init()
  timer.time=1/15
  timer.count=-1
  timer.event=update_screen
  timer:start()
end

function notework_to(i)
  local to={}
  for i,v in ipairs(notework_connections) do
    if v[1]==i then 
      table.insert(to,v[2])
    end
  end
  return to
end

function notework_initialize(seed,preserve_connections)
  math.randomseed(seed)
  if notework==nil then
    notework={}
  end
  if not preserve_connections then 
    notework_connections={}
  end
  for i=1,64 do
    -- generate random notework lattice
    notework[i]={
      armed=false,
      er=er.random2(math.random(4,16)),
      pos=0,
      div=divisions[math.random(#divisions)],
      note=(i-1)%8,
      emitted=false,
      iterated=false,
    }
  end
end

function notework_connect()
  if keydown[k]==notework_pos or 
    math.floor(keydown[k])==math.floor(notework_pos) then 
    do return end 
  end 
  -- connect the first key to the second key
  table.insert(notework_connections,{keydown[k],notework_pos})
end

function update_screen()
  redraw()
end

function key(k,z)
  if z==1 then 
    keydown[k]=notework_pos
  else
    if z==0 and k==3 then
      notework_connect()
    end
    keydown[k]=nil
  end
  if keydown[1] then
    if k==1 then
    elseif k==2 then
    elseif k==3 then
    end
  else
    if k==1 then
    elseif k==2 then
    elseif k==3 then
    end
  end
end

function enc(k,d)
  if keydown[1] then
    if k==1 then
    elseif k==2 then
    else
    end
  else
    if k==1 then
    elseif k==2 then
      notework_pos_change(d*8)
    elseif k==3 then
      notework_pos_change(d)
    end
  end
end

function notework_pos_change(d)
  local pos=notework_pos
  pos=pos+d
  if pos >= 1 and pos <= 64 then 
    notework_pos=pos 
  end
end

function redraw()
  screen.clear()

  -- show the network topology
  -- using bezier curves
  -- where curving UP connects left to right
  -- and curving DOWN connects right to left
  for i,nw in ipairs(notework) do 
    local x1,y1=notework_coord(i)
    for _, j in ipairs(to) do
      local x2,y2=notework_coord(j)
      local d=distance_points(x1,y1,x2,y2)
      -- TODO: add a little lfo to the the point so they sway
      local p=perpendicular_points({x1,y1},{x2,y2},d/4)
      screen.level(15)
      screen.move(x1,y1)
      screen.curve(p[1],p[2],p[1],p[2],x2,y2)
      screen.stroke()
    end
  end

  -- show the notework dots
  for i,nw in ipairs(notework) do
    local x,y=notework_coord(i)
    -- erase the network topology directly around
    screen.level(0)
    screen.circle(x,y,notework_pos==i and 5 or 3)
    screen.fill()

    -- draw a different sized dot
    screen.level(nw.iterated and 15 or 2)
    screen.circle(x,y,nw.emitted and 3 or 2)
    screen.fill()
    if notework_pos==i then 
      screen.level(15)
      screen.circle(x,y,5)
      screen.stroke()      
    end
  end


  screen.update()
end

function notework_coord(i) 
  local tr={32,10}
  local spacing=8
  local row=8-(i%8-1)
  local col=1+math.floor(i/8)
  local x=col*spacing+tr[1]
  local y=row*spacing+tr[2]
  return x,y
end

function rerun()
  norns.script.load(norns.state.script)
end


function distance_points( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
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
  return p3[1],p3[2]
end