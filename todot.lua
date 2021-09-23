-- todot v0.0.1
-- connect the dots.
--
-- llllllll.co/t/todot
--
--
--
--    ▼ instructions below ▼
--
-- E1 changes page

-- keep track of which keys are down
keydown={}

-- import main libraries
if not string.find(package.cpath,"/home/we/dust/code/todot/lib/") then
  package.cpath=package.cpath..";/home/we/dust/code/todot/lib/?.so"
end
json=require("cjson")
include("todot/lib/utils")
local er=include("todot/lib/er")
local Lattice=require("lattice")
local MusicUtil=require("musicutil")
local Network=include("todot/lib/network")
local Gridd=include("todot/lib/grid_")
--local Ternary=include("todot/lib/ternary")
-- TODO: add JSON library

engine.name="FM1"

-- define patches
patches={}
-- https://sccode.org/1-5bA
patches["lead"]={
  amp=0.5,
  pan=math.random(-50,50)/100,
  attack=0.01,
  decay=2,
  attack_curve=1,
  decay_curve=-4,
  mod_ratio=1,
  car_ratio=1,
  index=math.random(200,250)/100,
  index_scale=1.2,
  send=-15,
  divs={1/4,1/4,1/8,1/8,1/8,1/16,1/16,1/16},
  dens={0.5,0.75,0.25,0.5,0.75,0.25,0.5,0.75},
  eq_freq=1200,
  eq_db=0,
  noise=0,
  attack_noise=0.01,
  attack_decay=1,
}
patches["bass"]={
  amp=0.5,
  pan=math.random(-25,25)/100,
  attack=0.0,
  decay=2,
  attack_curve=4,
  decay_curve=-4,
  mod_ratio=2,
  car_ratio=1,
  index=1.5,
  index_scale=math.random(100,300)/100,
  send=-20,
  divs={1/2,1/2,1/4,1/4,1/8,1/8,1/16,1/16},
  dens={1,0.6,0.5,0.75,0.5,0.75,0.5,0.75},
  eq_freq=1200,
  eq_db=0,
  noise=0,
  attack_noise=0.01,
  attack_decay=1,
}
patches["snare"]={
  amp=0.5,
  pan=math.random(-50,50)/100,
  attack=0,
  decay=0.1,
  attack_curve=4,
  decay_curve=-8,
  mod_ratio=1.5,
  car_ratio=45.9,
  index=100,
  index_scale=1,
  send=-12,
  divs={1/2,1/2,1/4,1/4,1/8,1/8,1/16,1/16},
  dens={1,0.6,0.5,0.75,0.5,0.75,0.5,0.75},
  eq_freq=1200,
  eq_db=0,
  noise=0,
  attack_noise=0.01,
  attack_decay=1,
}
patches["hihat"]={
  amp=0.5,
  pan=math.random(-50,50)/100,
  attack=0,
  decay=0.1,
  attack_curve=4,
  decay_curve=-8,
  mod_ratio=1.5,
  car_ratio=45.9,
  index=100,
  index_scale=1,
  send=-12,
  divs={1/2,1/2,1/4,1/4,1/8,1/8,1/16,1/16},
  dens={1,0.6,0.5,0.75,0.5,0.75,0.5,0.75},
  eq_freq=1200,
  eq_db=0,
  noise=0.1,
  attack_noise=0.01,
  attack_decay=1,
}
patches["kick"]={
  hz=25,
  amp=0.5,
  pan=0,
  attack=0,
  decay=0.1,
  attack_curve=4,
  decay_curve=-4,
  mod_ratio=0.4,
  car_ratio=1,
  index=2,
  index_scale=8,
  send=-30,
  divs={1/2,1/2,1/4,1/4,1/8,1/8,1/16,1/16},
  dens={1,0.6,0.5,0.75,0.5,0.75,0.5,0.75},
  eq_freq=1200,
  eq_db=0,
  noise=0,
  attack_noise=0.01,
  attack_decay=1,
}
patches["pad"]={
  amp=0.5,
  pan=0,
  attack=2,
  decay=2,
  attack_curve=0,
  decay_curve=0,
  mod_ratio=1,
  car_ratio=1,
  index=1.5,
  index_scale=math.random(2,4),
  send=-10,
  divs={1,1/2,1,1/2,1,1/2,1,1/2},
  dens={1,1,1,1,1,1,1,1},
  eq_freq=1200,
  eq_db=0,
  noise=0,
  attack_noise=0.01,
  attack_decay=1,
}

function init()
  -- available divisions
  global_div_scales={1/16,1/8,1/4,1/2,1,2,4,8,16}
  global_page=1

  -- setup softcut stereo delay (based on halfsecond)
  print("starting halfsecond")
  audio.level_cut(1.0)
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)
  for i=1,2 do
    softcut.buffer(i,i)
    softcut.level(i,1.0)
    softcut.level_slew_time(i,0.25)
    softcut.level_input_cut(i,i,1.0)
    softcut.level_input_cut(i,i,1.0)
    softcut.pan(i,i*2-3)

    softcut.play(i,1)
    softcut.rate(i,1)
    softcut.rate_slew_time(i,0.25)
    softcut.loop_start(i,1)
    softcut.loop_end(i,1+clock.get_beat_sec())
    softcut.loop(i,1)
    softcut.fade_time(i,0.1)
    softcut.rec(i,1)
    softcut.rec_level(i,1)
    softcut.pre_level(i,0.75)
    softcut.position(i,1)
    softcut.enable(i,1)

    softcut.filter_dry(i,0.125);
    softcut.filter_fc(i,1200);
    softcut.filter_lp(i,0);
    softcut.filter_bp(i,1.0);
    softcut.filter_rq(i,2.0);

  end

  -- setup midi
  local midi_devices={"none"}
  midi_conn={} -- needs to be global
  for _,dev in pairs(midi.devices) do
    if dev.port~=nil then
      table.insert(midi_devices,dev.name)
      table.insert(midi_conn,midi.connect(dev.port))
    end
  end

  -- setup parameters
  instrument_list={"lead","pad","bass","kick","snare"}
  for _,ins in ipairs(instrument_list) do
    params:add_group(ins,15)
    params:add{type="control",id=ins.."db",name="volume",controlspec=controlspec.new(-96,12,'lin',0.1,-6,'',0.1/(12+96)),formatter=function(v)
      local val=math.floor(util.linlin(0,1,v.controlspec.minval,v.controlspec.maxval,v.raw)*10)/10
      return ((val<0) and "" or "+")..val.." dB"
    end}
    params:add{type="control",id=ins.."attack",name="attack",controlspec=controlspec.new(0,6,'lin',0.01,patches[ins].attack,'s',0.01/6)}
    params:add{type="control",id=ins.."decay",name="decay",controlspec=controlspec.new(0,6,'lin',0.01,patches[ins].decay,'s',0.01/6)}
    params:add{type="control",id=ins.."attack_curve",name="attack curve",controlspec=controlspec.new(-8,8,'lin',1,patches[ins].attack_curve,'',1/16)}
    params:add{type="control",id=ins.."decay_curve",name="decay curve",controlspec=controlspec.new(-8,8,'lin',1,patches[ins].decay_curve,'',1/16)}
    params:add{type="control",id=ins.."mod_ratio",name="mod ratio",controlspec=controlspec.new(0,2,'lin',0.01,patches[ins].mod_ratio,'x',0.01/2)}
    params:add{type="control",id=ins.."car_ratio",name="car ratio",controlspec=controlspec.new(0,50,'lin',0.01,patches[ins].car_ratio,'x',0.01/50)}
    params:add{type="control",id=ins.."index",name="index",controlspec=controlspec.new(0,200,'lin',0.1,patches[ins].index,'',0.1/200)}
    params:add{type="control",id=ins.."index_scale",name="index scale",controlspec=controlspec.new(0,10,'lin',0.1,patches[ins].index_scale,'',0.1/10)}
    params:add{type="control",id=ins.."noise",name="noise",controlspec=controlspec.new(-96,12,'lin',0.1,patches[ins].noise,'',0.1/(12+96)),formatter=function(v)
      local val=math.floor(util.linlin(0,1,v.controlspec.minval,v.controlspec.maxval,v.raw)*10)/10
      return ((val<0) and "" or "+")..val.." dB"
    end}
    params:add{type="control",id=ins.."noise_attack",name="noise attack",controlspec=controlspec.new(0,6,'lin',0.01,patches[ins].noise_attack,'s',0.01/6)}
    params:add{type="control",id=ins.."noise_decay",name="noise decay",controlspec=controlspec.new(0,6,'lin',0.01,patches[ins].noise_decay,'s',0.01/6)}
    params:add_control(ins.."lpf","lpf",controlspec.WIDEFREQ)
    params:add_control(ins.."eq_freq","eq freq",controlspec.WIDEFREQ)
    params:set(ins.."eq_freq",patches[ins].eq_freq)
    params:add{type="control",id=ins.."eq_db",name="reverb eq_db",controlspec=controlspec.new(-96,36,'lin',0.1,patches[ins].eq_db,'',0.1/(36+96)),formatter=function(v)
      local val=math.floor(util.linlin(0,1,v.controlspec.minval,v.controlspec.maxval,v.raw)*10)/10
      return ((val<0) and "" or "+")..val.." dB"
    end}
    params:add{type="control",id=ins.."reverb",name="reverb send",controlspec=controlspec.new(-96,12,'lin',0.1,patches[ins].send,'',0.1/(12+96)),formatter=function(v)
      local val=math.floor(util.linlin(0,1,v.controlspec.minval,v.controlspec.maxval,v.raw)*10)/10
      return ((val<0) and "" or "+")..val.." dB"
    end}
    params:add_option(ins.."div_scale","div scale",5)
    -- add optional midi out and crow out
    params:add_option(ins.."midi_out","midi out",midi_devices)
    params:add{type="control",id=ins.."midi_ch",name="midi out ch",controlspec=controlspec.new(1,16,'lin',1,1,'',1/16)}
  end

  -- setup networks
  local scale_melody=generate_scale(24) -- generate scale starting with C
  local pad_rows={-4,-3,-2,-1,0,1,2,3}
  local pad_cols=[{2,2},{2,2},{2,3},{2,3},{3,2},{3,2},{3,1},{1,3}]
  networks={}
  for i,v in ipairs(instrument_list) do
    networks[i]=Network:new({divs=patches[v].divs,dens=patches[v].dens,id=i})
    networks[i]:set_action(function(nw)
      if v=="pad" then
        -- play three notes
        local notes={pad_rows[nw.row]}
        table.insert(notes,notes[1]+pad_cols[nw.col][1])
        table.insert(notes,notes[2]+pad_cols[nw.col][2])
        for _,note in ipairs(notes) do
          fm1({note=scale_melody[note+24],pan=(note%12)/12-0.5,type=v,decay=clock.get_beat_sec()*16*nw.div})
        end
      else
        local note=24+scale_melody[nw.id]
        if v=="bass" then
          note=note-24
        end
        fm1({amp=nw.amp,note=note,pan=nw.pan,type=v,decay=clock.get_beat_sec()*16*nw.div})
      end
    end)
    networks[i]:toggle_play()
    networks[i].name=v
  end

  -- nw_chords=Ternary:new()
  -- nw_chords:set_action(function(notes)
  --   for _,note in ipairs(notes) do
  --     print(note)
  --     print("Ternary note: "..scale_melody[note+24])
  --     fm1({pan=note%8/8-0.5,note=12+scale_melody[note+24],type="pad",attack=clock.get_beat_sec()*4,decay=clock.get_beat_sec()/8})
  --   end
  -- end)

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

  -- initialize metro for updating screen
  timer=metro.init()
  timer.time=1/15
  timer.count=-1
  timer.event=update_screen
  timer:start()

  -- add saving/loading handlers
  params.action_write=function(filename,name)
    todot_save(filename)
  end
  params.action_read=function(filename,silent)
    todo_load(filename)
  end

  -- add grid
  grid_=gridd:new()
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
  if a.amp then
    a.amp=a.amp*util.dbamp(params:get(a.type.."db"))
  else
    a.amp=util.dbamp(params:get(a.type.."db"))
  end
  a.pan=a.pan or 0
  a.attack=a.attack or params:get(a.type.."attack")
  a.decay=a.decay or params:get(a.type.."decay")
  a.attack_curve=a.attack_curve or params:get(a.type.."attack_curve")
  a.decay_curve=a.decay_curve or params:get(a.type.."decay_curve")
  a.mod_ratio=a.mod_ratio or params:get(a.type.."mod_ratio")
  a.car_ratio=a.car_ratio or params:get(a.type.."car_ratio")
  a.index=a.index or params:get(a.type.."index")
  a.index_scale=a.index_scale or params:get(a.type.."index_scale")
  a.send=a.send or params:get(a.type.."reverb")
  a.eq_freq=a.eq_freq or params:get(a.type.."eq_freq")
  a.eq_db=a.eq_db or params:get(a.type.."eq_db")
  a.lpf=a.lpf or params:get(a.type.."lpf")
  a.noise=a.noise or util.dbamp(params:get(a.type.."noise"))
  a.noise_attack=a.noise_attack or params:get(a.type.."noise_attack")
  a.noise_decay=a.noise_decay or params:get(a.type.."noise_decay")
  tab.print(a)
  engine.fm1(
    a.hz,
    a.amp,
    a.pan,
    a.attack,
    a.decay,
    a.attack_curve,
    a.decay_curve,
    a.mod_ratio,
    a.car_ratio,
    a.index,
    a.index_scale,
    a.send,
    a.eq_freq,
    a.eq_db,
    a.lpf,
    a.noise,
    a.noise_attack,
    a.noise_decay
  )

  -- send out midi if activated
  if params:get(ins.."midi_out")>1 then
    local conn=midi_conn[params:get(ins.."midi_out")]
    conn:note_on(a.note,util.clamp(math.floor(a.amp*127),0,127))
    clock.run(function()
      clock.sleep(a.decay)
      conn:note_off(a.note)
    end)
  end
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
  if keydown[1] and z==1 then
    if k==1 then
    elseif k==2 then
      networks[global_page]:disconnect()
    elseif k==3 then
      networks[global_page]:toggle_play()
    end
  elseif z==1
    if k==1 then
    elseif k==2 then
      networks[global_page]:connect_cancel()
    elseif k==3 then
      networks[global_page]:connect()
    end
  end
end

function enc(k,d)
  if keydown[1] then
    if k==1 then
      params:delta(instrument_list[global_page].."db",d)
    elseif k==2 then
    else
    end
  else
    if k==1 then
      global_page=util.clamp(global_page+sign(d),1,1+#networks)
    elseif k==2 then
      networks[global_page]:change_col(d)
    elseif k==3 then
      networks[global_page]:change_row(d)
    end
  end
end

function redraw()
  screen.clear()

  if not keydown[1] then
    screen.level(15)
    screen.move(1,5)
    screen.text(networks[global_page].name)
  end

  networks[global_page]:draw()

  screen.update()
end

function rerun()
  norns.script.load(norns.state.script)
end

function todot_save(filename)
  print("todot: saving "..filename)
  local data={}
  for i,nw in ipairs(networks) do
    data[i]={}
    data[i].nw=nw.nw
    data[i].conn=nw.conn
  end
  file=io.open(filename,"w+")
  io.output(file)
  io.write(data)
  io.close(file)
end

function todot_load(filename)
  print("todot: loading "..filename)
  local f=io.open(filename,"rb")
  local content=f:read("*all")
  f:close()

  local data=json.decode(content)
  for i,_ in ipairs(networks) do
    networks[i].nw=data[i].nw
    networks[i].conn=data[i].conn
  end
end


