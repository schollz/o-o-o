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

-- keep track of which keys are down
local keydown={}

-- import main libraries
local er=include("aa/lib/er")
local Lattice=require("lattice")
local MusicUtil=require("musicutil")

engine.name="Fm1"

function init()
  -- available divisions
  divisions={1/16,1/8,1/4,1/2,1}

  playing=false
  notework_pos=1
  generate_scale(24) -- generate scale starting with C
  notework_initialize(41)
  -- generate some test connections
  notework_connect(1,17)
  notework_connect(9,10)
  notework_connect(9,32)
  notework_connect(1,24)
  notework_connect(58,24)

  local lattice=Lattice:new{
    ppqn=96
  }
  for i,div in ipairs(divisions) do
    local step=-1
    lattice:new_pattern{
      action=function(t)
        step=step+1
        if div==1 then 
          if step%4==0 then 
              engine.attack(4)
              engine.decay(0.1)
              engine.hz(MusicUtil.note_num_to_freq(60+12))
              engine.hz(MusicUtil.note_num_to_freq(64+12))
              engine.hz(MusicUtil.note_num_to_freq(69+12))
          elseif step%4==1 then 
              engine.attack(4)
              engine.decay(0.1)
              engine.hz(MusicUtil.note_num_to_freq(60+12))
              engine.hz(MusicUtil.note_num_to_freq(65+12))
              engine.hz(MusicUtil.note_num_to_freq(69+12))
          elseif step%4==2 then 
              engine.attack(4)
              engine.decay(0.5)
              engine.hz(MusicUtil.note_num_to_freq(60+12))
              engine.hz(MusicUtil.note_num_to_freq(64+12))
              engine.hz(MusicUtil.note_num_to_freq(67+12))
          elseif step%4==3 then 
              engine.attack(4)
              engine.decay(0.5)
              engine.hz(MusicUtil.note_num_to_freq(59+12))
              engine.hz(MusicUtil.note_num_to_freq(62+12))
              engine.hz(MusicUtil.note_num_to_freq(67+12))
          end
        end
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
                -- only play if nothing is armed
                local none_armed=true
                for _, k in ipairs(to) do
                  if notework[k].armed then 
                    none_armed=false
                  end
                end
                if ((none_armed and #to>0) or nw.armed) then 
                  notework[j].emitted=true
                  -- emit note 
                  engine.attack(0.01)
                  engine.decay(1)
                  print(note_list[j])
                  if MusicUtil.note_num_to_name(note_list[j])~="B" then
                    engine.hz(MusicUtil.note_num_to_freq(note_list[j]+24))            
                  end

                  -- arm connected
                  for _,j2 in ipairs(to) do 
                    if not notework[j2].armed then
                      notework[j2].armed=true
                    end
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
  playing=true

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

function generate_scale(root)
  note_list={}
  for i=1,8 do 
    for _, note in ipairs(MusicUtil.generate_scale_of_length(root,1,8)) do
      table.insert(note_list,note)
    end
    root=note_list[#note_list-3] -- plonky type keyboard
    -- root=root+12
  end
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
      er=er.random(math.random(8,32)),
      pos=0,
      div=divisions[math.random(#divisions)],
      emitted=false,
      iterated=false,
    }
  end
end

function notework_connect(i,j)
  -- connect the first key to the second key
  -- if it isn't already connected
  if not notework_is_connected(i,j) then 
    table.insert(notework_connections,{i,j})
  end
end

function notework_is_connected(i,j) 
  for k,v in ipairs(notework_connections) do 
    if i==v[1] and j==v[2] then
      do return k end
    end
  end
end

function notework_disconnect(i,j)
  local ind=notework_is_connected(i,j)
  if ind then 
    table.remove(notework_connections,ind)
  end
end

function notework_to(i)
  local to={}
  for _,v in ipairs(notework_connections) do
    if v[1]==i then 
      table.insert(to,v[2])
    end
  end
  return to
end

function notework_pos_change(d)
  local pos=notework_pos
  pos=pos+d
  if pos >= 1 and pos <= 64 then 
    notework_pos=pos 
  end
end

function notework_coord(i) 
  local spacing=7
  local tr={39,1}
  local row=8-((i-1)%8)
  local col=1+math.floor((i-0.01)/8)
  local x=col*spacing+tr[1]
  local y=row*spacing+tr[2]
  return x,y
end

function update_screen()
  redraw()
end

function key(k,z)
  if z==1 then 
    keydown[k]=notework_pos
  else
    if z==0 and k==3 then
      notework_connect(keydown[k],notework_pos)
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

function redraw()
  screen.clear()

  -- show the network topology
  -- using bezier curves
  -- where curving UP connects left to right
  -- and curving DOWN connects right to left
  for i,nw in ipairs(notework) do 
    local x1,y1=notework_coord(i)
    local to=notework_to(i)
    if to then
      for _, j in ipairs(to) do
        local x2,y2=notework_coord(j)
        local d=distance_points(x1,y1,x2,y2)
        -- TODO: add a little lfo to the the point so they sway
        local p=perpendicular_points({x1,y1},{x2,y2},math.sqrt(d)*4)
        screen.level(15)
        screen.move(x1,y1)
        screen.curve(p[1],p[2],p[1],p[2],x2,y2)
        screen.stroke()
      end
    end
  end

  -- show the notework dots
  for i,nw in ipairs(notework) do
    local x,y=notework_coord(i)
    -- erase the network topology directly around
    screen.level(0)
    screen.circle(x,y,notework_pos==i and 5 or 2)
    screen.fill()

    -- draw a different sized dot
    screen.level(nw.iterated and 4 or 2)
    screen.circle(x,y,2)
    screen.fill()
    if nw.emitted then
      screen.level(4)
      screen.circle(x,y,3)
      screen.stroke()
    end
    if notework_pos==i then 
      screen.level(15)
      screen.circle(x,y,5)
      screen.stroke()      
    end
  end


  screen.update()
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
  return p3[2],p3[1]
end