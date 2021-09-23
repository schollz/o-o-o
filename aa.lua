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

-- define patches
patches={}
-- TODO: add bass https://sccode.org/1-5bA
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
patches["bass"]={
  amp=0.5,
  pan=math.random(-25,25)/100,
  attack=0.0,
  decay=2,
  attack_curve=4,
  decay_curve=-4,
  ratio=2,
  ratio_curve=1,
  index=1.5,
  iscale=math.random(100,300)/100,
  send=-20,
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
patches["kick"]={
  hz=25,
  amp=0.5,
  pan=0,
  attack=0,
  decay=0.1,
  attack_curve=4,
  decay_curve=-4,
  ratio=0.4,
  ratio_curve=1,
  index=2,
  iscale=8,
  send=-30,
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

function init()
  -- available divisions
  global_divisions={1/16,1/8}
  global_page=1

  -- amp=0.5,
  -- pan=math.random(-50,50)/100,
  -- attack=0.01,
  -- decay=2,
  -- attack_curve=1,
  -- decay_curve=-4,
  -- ratio=1,
  -- ratio_curve=1,
  -- index=math.random(200,250)/100,
  -- iscale=1.2,
  -- send=-15,

  -- setup parameters
  instrument_list={"pad","lead","bass","kick","snare"}
  for _,ins in ipairs(instrument_list) do
    params:add_group(ins,5)
    params:add{type="control",id=ins.."db",name="volume",controlspec=controlspec.new(-96,12,'lin',0.1,-6,'',0.1/(12+96)),formatter=function(v)
      local val=math.floor(util.linlin(0,1,v.controlspec.minval,v.controlspec.maxval,v.raw)*10)/10
      return ((val<0) and "" or "+")..val.." dB"
    end}
    params:add{type="control",id=ins.."attack",name="attack",controlspec=controlspec.new(0,6,'lin',0.01,patches[ins].attack,'s',0.01/6)}
    params:add{type="control",id=ins.."decay",name="decay",controlspec=controlspec.new(0,6,'lin',0.01,patches[ins].decay,'s',0.01/6)}
    params:add{type="control",id=ins.."attack_curve",name="attack curve",controlspec=controlspec.new(-8,8,'lin',1,patches[ins].attack_curve,'',1/16)}
    params:add{type="control",id=ins.."decay_curve",name="decay curve",controlspec=controlspec.new(-8,8,'lin',1,patches[ins].decay_curve,'',1/16)}
    params:add{type="control",id=ins.."mod_ratio",name="mod ratio",controlspec=controlspec.new(0,2,'lin',0.1,patches[ins].ratio,'',0.1/2)}
    params:add{type="control",id=ins.."carrier_ratio",name="carrier ratio",controlspec=controlspec.new(0,50,'lin',0.1,patches[ins].ratio,'',0.1/50)}
  end

  -- setup networks
  notework_pos=1
  local scale_melody_transpose=0
  local scale_melody=generate_scale(24) -- generate scale starting with C
  networks={}
  for i,v in ipairs({"kick","bass","lead","snare"}) do
    local divs=nil
    if v=="kick" then
      divs={1,1,1/2,1/2,1/4,1/4,1/8,1/8}
    end
    networks[i]=Network:new({divs=divs})
    networks[i]:set_action(function(nw)
      scale_melody_transpose=0
      local note=24+scale_melody[nw.id+scale_melody_transpose]
      if v=="bass" then
        note=note-24
      end
      fm1({amp=networks[i].amp*nw.amp,note=note,pan=nw.pan,type=v,decay=clock.get_beat_sec()*16*nw.div})
    end)
    networks[i]:toggle_play()
    networks[i].name=v
  end

  nw_chords=Ternary:new()
  nw_chords:set_action(function(notes)
    for _,note in ipairs(notes) do
      print(note)
      print("Ternary note: "..scale_melody[note+24])
      fm1({amp=nw_chords.amp,pan=note%8/8-0.5,note=12+scale_melody[note+24],type="pad",attack=clock.get_beat_sec()*4,decay=clock.get_beat_sec()/8})
    end
  end)

  local lattice=Lattice:new{
    ppqn=96
  }
  for i,div in ipairs({1/16,1/8,1/4,1/2,1}) do
    local step=-1
    lattice:new_pattern{
      action=function(t)
        step=step+1
        for _,nw in ipairs(networks) do
          nw:emit(step,div)
        end
        nw_chords:emit(step,div)
      end,
      division=div,
    }
  end
  lattice:start()

  -- nw_chords:toggle_play()

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

  if a.note then
    a.hz=MusicUtil.note_num_to_freq(a.note)/2
  else
    a.hz=a.hz or 220
  end
  if a.type=="kick" then
    while a.hz>30 do
      a.hz=a.hz/2
    end
    while a.amp<5 do
      a.amp=a.amp*2
    end
    a.decay=0.1
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
  if global_page>1 and (not keydown[1]) then
    if z==1 then
      networks[global_page-1]:connect_first()
    else
      if z==0 and k==3 then
        networks[global_page-1]:connect()
      end
    end
  end
  if keydown[1] then
    if k==1 then
    elseif k==2 then
    elseif k==3 then
      -- toggle playing
      if global_page==1 and z==1 then nw_chords:toggle_play() end
      if global_page>1 and z==1 then networks[global_page-1]:toggle_play() end
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
      if global_page>1 then networks[global_page-1]:change_amp(d/100) end
    elseif k==2 then
    else
    end
  else
    if k==1 then
      global_page=util.clamp(global_page+sign(d),1,1+#networks)
    elseif k==2 then
      if global_page==1 then nw_chords:change_pos(sign(d)) end
      if global_page>1 then networks[global_page-1]:change_col(d) end
    elseif k==3 then
      if global_page==1 then nw_chords:change_chord(-1*sign(d)) end
      if global_page>1 then networks[global_page-1]:change_row(d) end
    end
  end
end

function redraw()
  screen.clear()

  if global_page==1 then nw_chords:draw() end
  if global_page>1 then networks[global_page-1]:draw() end

  screen.level(15)
  screen.move(1,5)
  screen.text(global_page==1 and "chords" or networks[global_page-1].name)
  screen.update()
end

function rerun()
  norns.script.load(norns.state.script)
end
