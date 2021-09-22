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
                if (#nw.to>0 or nw.armed) then 
                  notework[j].emitted=true
                  -- emit note 
                  engine.hz(MusicUtil.note_num_to_freq(note_root+nw.note))            

                  -- arm connected
                  for _,j2 in ipairs(nw.to) do 
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


function notework_initialize(seed,preserve_connections)
  math.randomseed(seed)
  if notework==nil then
    notework={}
  end
  if preserve_connections==nil then 
    preserve_connections=false 
  end
  for i=1,64 do
    -- generate random notework lattice
    local to={}
    if preserve_connections and notework[i]~= nil then
      for _,v in ipairs(notework) do 
        table.insert(to,v)
      end
    end
    notework[i]={
      armed=false,
      to=to,
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
  table.insert(notework_connect[keydown[k]].to,notework_pos)
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

  -- show the notework dots
  local tr={32,10}
  local spacing=8
  for i,nw in ipairs(notework) do
    local row=8-(i%8-1)
    local col=1+math.floor(i/8)
    local x=col*spacing+tr[1]
    local y=row*spacing+tr[2]
    screen.level(nw.iterated and 15 or 2)
    screen.circle(x,y,nw.emitted and 3 or 2)
    screen.fill()
    if notework_pos==i then 
      screen.level(15)
      screen.circle(x,y,5)
      screen.stroke()      
    end
  end

  -- show the network topology
  -- TODO: using bezier curves
  -- where curving UP connects left to right
  -- and curving DOWN connects right to left
  
  screen.update()
end

function rerun()
  norns.script.load(norns.state.script)
end
