-- new script v0.0.1
-- ?
--
-- llllllll.co/t/?
--
--
--
--    ▼ instructions below ▼
--
-- E1 changes page

-- keep track of which keys are down
keydown={}

-- import main libraries
include("aa/lib/utils")
local er=include("aa/lib/er")
local Lattice=require("lattice")
local MusicUtil=require("musicutil")
local Network=include("aa/lib/network")
local Ternary=include("aa/lib/ternary")

engine.name="FM1"

function init()
  -- available divisions
  global_divisions={1/16,1/8}
  global_page=1

  notework_pos=1
  local scale_melody_transpose=0
  local scale_melody=generate_scale(24) -- generate scale starting with C
  nw_melody=Network:new()
  nw_melody:set_action(function(nw)
    scale_melody_transpose=0
    fm1({amp=nw_melody.amp*nw.amp,note=24+scale_melody[nw.id+scale_melody_transpose],pan=nw.pan,type="lead"})
    -- if MusicUtil.note_num_to_name(scale_melody[j])~="B" then
    --   engine.hz(MusicUtil.note_num_to_freq(scale_melody[j]+24))
    -- end
  end)

  nw_chords=Ternary:new()
  nw_chords:set_action(function(notes)
    for _,note in ipairs(notes) do
      print(note)
      print("Ternary note: "..scale_melody[note+24])
      fm1({amp=nw_chords.amp,pan=note%8/8-0.5,note=12+scale_melody[note+24],type="pad",attack=clock.get_beat_sec()*4,decay=clock.get_beat_sec()/8})
    end
  end)

  -- generate some test connections
  -- nw_melody:connect(1,8)
  -- nw_melody:connect(1,17)
  -- nw_melody:connect(1,27)
  -- nw_melody:connect(1,47)

  -- nw_melody:connect(8,33)
  -- nw_melody:connect(33,48)
  -- nw_melody:connect(48,64)
  tab.print(nw_melody:networked(1))

  local lattice=Lattice:new{
    ppqn=96
  }
  for i,div in ipairs({1/16,1/8,1/4,1/2,1}) do
    local step=-1
    lattice:new_pattern{
      action=function(t)
        step=step+1
        nw_melody:emit(step,div)
        nw_chords:emit(step,div)
      end,
      division=div,
    }
  end
  lattice:start()

  nw_chords:toggle_play()

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
  timer.time=1/5
  timer.count=-1
  timer.event=update_screen
  timer:start()
end

-- fm1 is a helper function for the engie
function fm1(a)
  if a.type==nil then
    a.type="lead"
  end
  patches={}
  patches["lead"]={
    amp=0.5,
    pan=math.random(-50,50)/100,
    attack=0.01,
    decay=2,
    attack_curve=1,
    decay_curve=-4,
    ratio=1,
    ratio_curve=1,
    index=math.random(200,250)/100,
    iscale=1.2,
    send=-15,
  }
  patches["snare"]={
    amp=0.5,
    pan=math.random(-50,50)/100,
    attack=0,
    decay=0.1,
    attack_curve=4,
    decay_curve=-8,
    ratio=1.5,
    ratio_curve=45.9,
    index=100,
    iscale=1,
    send=-12,
  }
  patches["pad"]={
    amp=0.5,
    pan=0,
    attack=2,
    decay=2,
    attack_curve=0,
    decay_curve=0,
    ratio=1,
    ratio_curve=1,
    index=1.5,
    iscale=math.random(2,4),
    send=-10,
  }
  if a.note then
    a.hz=MusicUtil.note_num_to_freq(a.note)/2
  else
    a.hz=a.hz or 220
  end
  a.amp=a.amp or patches[a.type].amp
  a.pan=a.pan or patches[a.type].pan
  a.attack=a.attack or patches[a.type].attack
  a.decay=a.decay or patches[a.type].decay
  a.attack_curve=a.attack_curve or patches[a.type].attack_curve
  a.decay_curve=a.decay_curve or patches[a.type].decay_curve
  a.ratio=a.ratio or patches[a.type].ratio
  a.ratio_curve=a.ratio_curve or patches[a.type].ratio_curve
  a.index=a.index or patches[a.type].index
  a.iscale=a.iscale or patches[a.type].iscale
  a.send=a.send or patches[a.type].send
  engine.fm1(
    a.hz,
    a.amp,
    a.pan,
    a.attack,
    a.decay,
    a.attack_curve,
    a.decay_curve,
    a.ratio,
    a.ratio_curve,
    a.index,
    a.iscale,
    a.send
  )
end

function generate_scale(root)
  local note_list={}
  for i=1,8 do
    for _,note in ipairs(MusicUtil.generate_scale_of_length(root+24,5,8)) do
      table.insert(note_list,note)
    end
    -- root=note_list[#note_list-3] -- plonky type keyboard
    -- root=root+12
  end
  -- for i=1,4 do
  --   for _,note in ipairs(MusicUtil.generate_scale_of_length(root,5,8)) do
  --     table.insert(note_list,note)
  --   end
  --   -- root=note_list[#note_list-3] -- plonky type keyboard
  --   root=root+12
  -- end
  -- root=root-48
  -- for i=1,4 do
  --   for _,note in ipairs(MusicUtil.generate_scale_of_length(root,5,8)) do
  --     table.insert(note_list,note)
  --   end
  --   -- root=note_list[#note_list-3] -- plonky type keyboard
  --   root=root+12
  -- end
  return note_list
end

function update_screen()
  redraw()
end

function key(k,z)
  if z==1 then
    keydown[k]=true
  else
    keydown[k]=false
  end
  if global_page==2 and (not keydown[1]) then
    if z==1 then
      nw_melody:connect_first()
    else
      if z==0 and k==3 then
        nw_melody:connect()
      end
    end
  end
  if keydown[1] then
    if k==1 then
    elseif k==2 then
    elseif k==3 then
      -- toggle playing
      if global_page==1 and z==1 then nw_chords:toggle_play() end
      if global_page==2 and z==1 then nw_melody:toggle_play() end
    end
  else
    if k==1 then
    elseif k==2 then
      if global_page==1 and z==1 then nw_chords:remove_chord() end
    elseif k==3 then
      if global_page==1 and z==1 then nw_chords:add_chord() end
    end
  end
end

function enc(k,d)
  if keydown[1] then
    if k==1 then
      if global_page==1 then nw_chords:change_amp(d/100) end
      if global_page==2 then nw_melody:change_amp(d/100) end
    elseif k==2 then
    else
    end
  else
    if k==1 then
      global_page=util.clamp(global_page+sign(d),1,2)
    elseif k==2 then
      if global_page==1 then nw_chords:change_pos(sign(d)) end
      if global_page==2 then nw_melody:change_pos(d*8) end
    elseif k==3 then
      if global_page==1 then nw_chords:change_chord(-1*sign(d)) end
      if global_page==2 then nw_melody:change_pos(d) end
    end
  end
end

function redraw()
  screen.clear()

  if global_page==1 then nw_chords:draw() end
  if global_page==2 then nw_melody:draw() end

  screen.update()
end

function rerun()
  norns.script.load(norns.state.script)
end
