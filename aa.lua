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
include("aa/lib/utils")
local er=include("aa/lib/er")
local Lattice=require("lattice")
local MusicUtil=require("musicutil")
local Network=include("aa/lib/network")
local Ternary=include("aa/lib/ternary")

engine.name="Fm1"


function init()
  -- available divisions
  global_divisions={1/16,1/8}
  global_page=1

  notework_pos=1
  local scale_melody_transpose=0
  local scale_melody=generate_scale(24) -- generate scale starting with C
  nw_melody=Network:new()
  nw_melody:set_action(function(j)
    scale_melody_transpose=0
    fm1({note=scale_melody[j+scale_melody_transpose]+24})
    -- if MusicUtil.note_num_to_name(scale_melody[j])~="B" then
    --   engine.hz(MusicUtil.note_num_to_freq(scale_melody[j]+24))
    -- end
  end)

  nw_chords=Ternary:new()
  nw_chords:set_action(function(notes)
    for _, note in ipairs(notes) do
      print("Ternary note: "..scale_melody[note+24])
    end
  end)

  -- generate some test connections
  nw_melody:connect(1,8)
  nw_melody:connect(1,17)
  nw_melody:connect(1,27)
  nw_melody:connect(1,47)

  -- nw_melody:connect(8,33)
  -- nw_melody:connect(33,48)
  -- nw_melody:connect(48,64)
  tab.print(nw_melody:networked(1))

  nw_melody.playing=true

  local lattice=Lattice:new{
    ppqn=96
  }
  for i,div in ipairs({1/16,1/8,1/4,1/2,1}) do
    local step=-1
    lattice:new_pattern{
      action=function(t)
        step=step+1
        if div==1 then
          if step%4==0 then
            engine.attack(4)
            engine.decay(0.1)
            -- engine.hz(MusicUtil.note_num_to_freq(60+12))
            -- engine.hz(MusicUtil.note_num_to_freq(64+12))
            -- engine.hz(MusicUtil.note_num_to_freq(69+12))
            scale_melody_transpose=5
          elseif step%4==1 then
            engine.attack(4)
            engine.decay(0.1)
            -- engine.hz(MusicUtil.note_num_to_freq(60+12))
            -- engine.hz(MusicUtil.note_num_to_freq(65+12))
            -- engine.hz(MusicUtil.note_num_to_freq(69+12))
            scale_melody_transpose=3
          elseif step%4==2 then
            engine.attack(4)
            engine.decay(0.5)
            -- engine.hz(MusicUtil.note_num_to_freq(60+12))
            -- engine.hz(MusicUtil.note_num_to_freq(64+12))
            -- engine.hz(MusicUtil.note_num_to_freq(67+12))
            scale_melody_transpose=0
          elseif step%4==3 then
            engine.attack(4)
            engine.decay(0.5)
            -- engine.hz(MusicUtil.note_num_to_freq(59+12))
            -- engine.hz(MusicUtil.note_num_to_freq(62+12))
            -- engine.hz(MusicUtil.note_num_to_freq(67+12))
            scale_melody_transpose=4
          end
        end
        nw_melody:emit(step,div)
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

-- fm1 is a helper function for the engie
function fm1(a)
  if a.note then 
    a.hz=MusicUtil.note_num_to_freq(a.note)
  else
    a.hz=a.hz or 220
  end
  a.amp=a.amp or 0.5 
  a.pan=a.pan or 0
  a.attack=a.attack or 0.01
  a.decay=a.decay or 2
  a.ratio=a.ratio or 0.6
  a.amount=a.amount or 0.36
  engine.fm1(
    a.hz,
    a.amp,
    a.pan,
    a.attack,
    a.decay,
    a.ratio,
    a.amount,
  )
end

function generate_scale(root)
  local note_list={}
  for i=1,4 do
    for _,note in ipairs(MusicUtil.generate_scale_of_length(root,1,8)) do
      table.insert(note_list,note)
    end
    -- root=note_list[#note_list-3] -- plonky type keyboard
    root=root+12
  end
  root=root-48
  for i=1,4 do
    for _,note in ipairs(MusicUtil.generate_scale_of_length(root,1,8)) do
      table.insert(note_list,note)
    end
    -- root=note_list[#note_list-3] -- plonky type keyboard
    root=root+12
  end
  return note_list
end

function update_screen()
  redraw()
end

function key(k,z)
  if global_page==2 and (not keydown[1]) then
    if z==1 then
        nw_melody:connect_first()
    else
      if z==0 and k==3 then
          nw_melody:connect()
      end
      keydown[k]=nil
    end
  end
  if keydown[1] then
    if k==1 then
    elseif k==2 then
    elseif k==3 then
      -- toggle playing
      if global_page==1 then nw_chords:toggle_play() end
      if global_page==2 then nw_melody:toggle_play() end
    end
  else
    if k==1 then
    elseif k==2 then
      if global_page==1 then nw_chords:remove_chord() end
    elseif k==3 then
      if global_page==1 then nw_chords:add_chord() end
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
      global_page=util.clamp(global_page+d,1,2)
    elseif k==2 then
      if global_page==1 then nw_chords:change_pos(d) end
      if global_page==2 then nw_melody:change_pos(d*8) end
    elseif k==3 then
      if global_page==1 then nw_chords:change_chord(d) end
      if global_page==2 then nw_melody:change_pos(d) end
    end
  end
end

function redraw()
  screen.clear()

  if global_page==2 then nw_melody:draw() end

  screen.update()
end

function rerun()
  norns.script.load(norns.state.script)
end
