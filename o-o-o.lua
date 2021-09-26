-- o-o-o v0.0.1
-- connect the dots.
--
-- llllllll.co/t/o-o-o
--
-- hold k1 for hints
--

-- keep track of which keys are down
keydown={}

-- import main libraries
if not string.find(package.cpath,"/home/we/dust/code/o-o-o/lib/") then
  package.cpath=package.cpath..";/home/we/dust/code/o-o-o/lib/?.so"
end
json=require("cjson")
include("o-o-o/lib/utils")
local er=include("o-o-o/lib/er")
local Lattice=require("lattice")
local MusicUtil=require("musicutil")
local Network=include("o-o-o/lib/network")
local Gridd=include("o-o-o/lib/grid_")
--local Ternary=include("o-o-o/lib/ternary")

engine.name="Odashodasho"

-- define patches
patches={}
-- https://sccode.org/1-5bA
patches["lead"]={
  db=-2,
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
  send=-18,
  divs={1/4,1/4,1/8,1/8,1/8,1/8,1/8,1/16},
  dens={0.5,0.75,0.15,0.25,0.5,0.25,0.75,0.5},
  eq_freq=650,
  eq_db=9,
  noise=-96,
  noise_attack=0.01,
  noise_decay=1,
}
patches["bass"]={
  db=6,
  attack=0.0,
  decay=1,
  attack_curve=4,
  decay_curve=-4,
  mod_ratio=2,
  car_ratio=1.02,
  index=1.5,
  index_scale=1.2,
  send=-20,
  divs={1/2,1/2,1/4,1/4,1/8,1/8,1/16,1/16},
  dens={0.75,0.5,0.5,0.75,0.5,0.75,0.5,0.75},
  eq_freq=150,
  eq_db=8,
  noise=-96,
  noise_attack=0.01,
  noise_decay=1,
  freq_scale=3,
}
patches["snare"]={
  db=-6,
  amp=0.5,
  pan=math.random(-50,50)/100,
  attack=0,
  decay=0.5,
  attack_curve=4,
  decay_curve=-8,
  mod_ratio=1.5,
  car_ratio=45.9,
  index=100,
  index_scale=1,
  send=-25,
  divs={1/2,1/2,1/4,1/4,1/8,1/8,1/16,1/16},
  dens={0.8,0.5,0.5,0.75,0.5,0.75,0.5,0.75},
  eq_freq=450,
  eq_db=9,
  noise=15,
  noise_attack=0.01,
  noise_decay=0.1,
  lpf=2000,
}
patches["hihat"]={
  db=-20,
  amp=0.5,
  attack=0,
  decay=0.1,
  attack_curve=4,
  decay_curve=-8,
  mod_ratio=1.5,
  car_ratio=45.9,
  index=100,
  index_scale=1,
  send=-18,
  divs={1/2,1/2,1/4,1/4,1/8,1/8,1/16,1/16},
  dens={1,0.6,0.5,0.75,0.5,0.75,0.5,0.75},
  eq_freq=1200,
  eq_db=0,
  noise=11,
  noise_attack=0.01,
  noise_decay=0.11,
}
patches["kick"]={
  db=20,
  pan=0,
  attack=0,
  decay=1,
  attack_curve=4,
  decay_curve=-8,
  mod_ratio=0.4,
  car_ratio=1.5,
  index=0.5,
  index_scale=0.5,
  send=-24,
  divs={1/2,1/2,1/4,1/4,1/8,1/8,1/16,1/16},
  dens={0.75,0.5,0.5,0.75,0.5,0.75,0.5,0.75},
  eq_freq=134,
  eq_db=8,
  noise=-7,
  noise_attack=0.01,
  noise_decay=0.6,
  lpf=320,
}
patches["pad"]={
  db=-10,
  amp=0.5,
  pan=0,
  attack=2,
  decay=2,
  attack_curve=0,
  decay_curve=0,
  mod_ratio=2,
  car_ratio=1,
  index=1.0,
  -- mod_ratio=1,
  -- car_ratio=1,
  -- index=1.5,
  index_scale=4,
  send=-15,
  divs={2,2,2,2,1,1,1,1},
  dens={1,1,1,1,1,1,1,1},
  eq_freq=800,
  eq_db=10,
  noise=-96,
  noise_attack=0.01,
  noise_decay=1,
  freq_scale=4,
}

function init()
  -- available divisions
  global_div_scales={1/16,1/8,1/4,1/2,1,2,4,8,16}
  global_page=1
  networks={}

  -- -- setup softcut stereo delay (based on halfsecond)
  -- print("starting halfsecond")
  -- audio.level_cut(1.0)
  -- audio.level_adc_cut(1)
  -- audio.level_eng_cut(1)
  -- for i=1,2 do
  --   softcut.buffer(i,i)
  --   softcut.level(i,1.0)
  --   softcut.level_slew_time(i,0.25)
  --   softcut.level_input_cut(i,i,1.0)
  --   softcut.level_input_cut(i,i,1.0)
  --   softcut.pan(i,i*2-3)

  --   softcut.play(i,1)
  --   softcut.rate(i,1)
  --   softcut.rate_slew_time(i,0.25)
  --   softcut.loop_start(i,1)
  --   softcut.loop_end(i,1+clock.get_beat_sec())
  --   softcut.loop(i,1)
  --   softcut.fade_time(i,0.1)
  --   softcut.rec(i,1)
  --   softcut.rec_level(i,1)
  --   softcut.pre_level(i,0.75)
  --   softcut.position(i,1)
  --   softcut.enable(i,1)

  --   softcut.filter_dry(i,0.125);
  --   softcut.filter_fc(i,1200);
  --   softcut.filter_lp(i,0);
  --   softcut.filter_bp(i,1.0);
  --   softcut.filter_rq(i,2.0);

  -- end

  -- setup midi
  local midi_devices={"none"}
  midi_conn={"none"} -- needs to be global
  for _,dev in pairs(midi.devices) do
    if dev.port~=nil then
      table.insert(midi_devices,dev.name)
      table.insert(midi_conn,midi.connect(dev.port))
    end
  end

  params:add_separator("o-o-o")
  -- TODO: add seed
  params:add{type="control",id="seed",name="seed",controlspec=controlspec.new(0,1000,'lin',1,42,'',1/1000),action=function(x)
    for _,nw in ipairs(networks) do
      nw:init_dots()
    end
  end}
  local scale_names={}
  for i=1,#MusicUtil.SCALES do
    table.insert(scale_names,string.lower(MusicUtil.SCALES[i].name))
  end
  params:add{type="option",id="scale_mode",name="scale mode",
    options=scale_names,default=1,
  action=function() scale_melody=generate_scale() end}
  params:add{type="number",id="root_note",name="root note",
    min=0,max=127,default=60,formatter=function(param) return MusicUtil.note_num_to_name(param:get(),true) end,
  action=function() scale_melody=generate_scale() end}
  -- setup parameters
  instrument_list={"lead","pad","bass","kick","snare","hihat"}
  for _,ins in ipairs(instrument_list) do
    params:add_group(ins,20)
    params:add{type="control",id=ins.."db",name="volume",controlspec=controlspec.new(-96,36,'lin',0.1,patches[ins].db,'',0.1/(36+96)),formatter=function(v)
      local val=math.floor(util.linlin(0,1,v.controlspec.minval,v.controlspec.maxval,v.raw)*10)/10
      return ((val<0) and "" or "+")..val.." dB"
    end}
    params:add{type="control",id=ins.."attack",name="attack",controlspec=controlspec.new(0,8,'lin',0.01,patches[ins].attack,'beats',0.01/8)}
    params:add{type="control",id=ins.."decay",name="decay",controlspec=controlspec.new(0,8,'lin',0.01,patches[ins].decay,'beats',0.01/8)}
    params:add{type="control",id=ins.."attack_curve",name="attack curve",controlspec=controlspec.new(-8,8,'lin',1,patches[ins].attack_curve,'',1/16)}
    params:add{type="control",id=ins.."decay_curve",name="decay curve",controlspec=controlspec.new(-8,8,'lin',1,patches[ins].decay_curve,'',1/16)}
    params:add{type="control",id=ins.."mod_ratio",name="mod ratio",controlspec=controlspec.new(0,8,'lin',0.01,patches[ins].mod_ratio,'x',0.01/8)}
    params:add{type="control",id=ins.."car_ratio",name="car ratio",controlspec=controlspec.new(0,50,'lin',0.01,patches[ins].car_ratio,'x',0.01/50)}
    params:add{type="control",id=ins.."index",name="index",controlspec=controlspec.new(0,200,'lin',0.1,patches[ins].index,'',0.1/200)}
    params:add{type="control",id=ins.."index_scale",name="index scale",controlspec=controlspec.new(0,10,'lin',0.1,patches[ins].index_scale,'',0.1/10)}
    params:add{type="control",id=ins.."noise",name="noise",controlspec=controlspec.new(-96,36,'lin',1,patches[ins].noise,'',1/(36+96)),formatter=function(v)
      local val=math.floor(util.linlin(0,1,v.controlspec.minval,v.controlspec.maxval,v.raw)*10)/10
      return ((val<0) and "" or "+")..val.." dB"
    end}
    params:add{type="control",id=ins.."noise_attack",name="noise attack",controlspec=controlspec.new(0,6,'lin',0.01,patches[ins].noise_attack,'beats',0.01/6)}
    params:add{type="control",id=ins.."noise_decay",name="noise decay",controlspec=controlspec.new(0,6,'lin',0.01,patches[ins].noise_decay,'beats',0.01/6)}
    params:add_control(ins.."lpf","lpf",controlspec.WIDEFREQ)
    params:set(ins.."lpf",patches[ins].lpf or 20000)
    params:add_control(ins.."eq_freq","eq freq",controlspec.WIDEFREQ)
    params:set(ins.."eq_freq",patches[ins].eq_freq)
    params:add{type="control",id=ins.."eq_db",name="eq boost",controlspec=controlspec.new(-96,36,'lin',0.1,patches[ins].eq_db,'',0.1/(36+96)),formatter=function(v)
      local val=math.floor(util.linlin(0,1,v.controlspec.minval,v.controlspec.maxval,v.raw)*10)/10
      return ((val<0) and "" or "+")..val.." dB"
    end}
    params:add{type="control",id=ins.."reverb",name="reverb send",controlspec=controlspec.new(-96,12,'lin',0.1,patches[ins].send,'',0.1/(12+96)),formatter=function(v)
      local val=math.floor(util.linlin(0,1,v.controlspec.minval,v.controlspec.maxval,v.raw)*10)/10
      return ((val<0) and "" or "+")..val.." dB"
    end}
    params:add_option(ins.."div_scale","div scale",global_div_scales,5)
    params:set(ins.."div_scale",patches[ins].div_scale or 5)
    params:add_option(ins.."freq_scale","freq scale",global_div_scales,5)
    params:set(ins.."freq_scale",patches[ins].freq_scale or 5)
    -- add optional midi out and crow out
    params:add_option(ins.."midi_out","midi out",midi_devices)
    params:add{type="control",id=ins.."midi_ch",name="midi out ch",controlspec=controlspec.new(1,16,'lin',1,1,'',1/16)}
  end

  -- setup networks
  scale_melody=generate_scale() -- generate scale starting with C
  -- local pad_cols={{2,2},{2,2},{2,3},{2,3},{3,2},{3,2},{3,1},{1,3}}
  local pad_cols={{2,2},{2,3},{3,2},{3,1},{2,2},{2,3},{3,2},{1,3}}
  for i,v in ipairs(instrument_list) do
    networks[i]=Network:new({divs=patches[v].divs,dens=patches[v].dens,id=i})
    networks[i]:set_action(function(nw)
      if v=="pad" then
        local scale=MusicUtil.generate_scale_of_length(params:get("root_note"),params:get("scale_mode"),16)
        -- play three notes
        local notes={9-nw.row}
        table.insert(notes,notes[1]+pad_cols[nw.col][1])
        table.insert(notes,notes[2]+pad_cols[nw.col][2])
        for _,note in ipairs(notes) do
          note=scale[note]
          print(note)
          local attack=params:get(v.."attack")*clock.get_beat_sec()*1*nw.div
          local decay=params:get(v.."decay")*clock.get_beat_sec()*1*nw.div
          fm1({note=note,pan=(note%12)/12-0.5,type=v,decay=decay,attack=attack})
        end
      else
        local note=scale_melody[nw.id]
        local attack=params:get(v.."attack")*clock.get_beat_sec()*16*nw.div
        local decay=params:get(v.."decay")*clock.get_beat_sec()*16*nw.div
        fm1({amp=nw.amp,note=note,pan=nw.pan,type=v,attack=attack,decay=decay})
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
  for i,div in ipairs({1/16,1/8,1/4,1/2,1,2}) do
    local step=-1
    lattice:new_pattern{
      action=function(t)
        step=step+1
        for _,nw in ipairs(networks) do
          nw:emit(step,div)
        end
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
    odasho_save(filename)
  end
  params.action_read=function(filename,silent)
    odasho_load(filename)
  end

  -- add grid
  grid_=Gridd:new()

  -- add osc
  osc.event=function(path,args,from)
    if path=="voice" then
      local dat={}
      for i in string.gmatch(args[1],"%S+") do
        table.insert(dat,i)
      end
      local type=dat[1]
      local note=tonumber(dat[2])
      if params:get(type.."midi_out")>1 then
        local conn=midi_conn[params:get(type.."midi_out")]
        conn:note_off(note)
      end
    end
  end
end

-- fm1 is a helper function for the engie
function fm1(a)
  if a.type==nil then
    a.type="lead"
  end

  if a.type=="kick" then
    while a.note>31 do
      a.note=a.note-12
    end
  end

  a.note=a.note+(12*(global_div_scales[params:get(a.type.."freq_scale")]-1))
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
  -- tab.print(a)
  engine.fm1(
    a.note,
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
    a.noise_decay,
    a.type
  )

  -- send out midi if activated
  if params:get(a.type.."midi_out")>1 then
    local conn=midi_conn[params:get(a.type.."midi_out")]
    conn:note_on(a.note,util.clamp(math.floor(a.amp*127),0,127))
  end
end

function generate_scale()
  local note_list={}
  for i=1,8 do
    for _,note in ipairs(MusicUtil.generate_scale_of_length(params:get("root_note"),params:get("scale_mode"),8)) do
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
  if keydown[1] and z==1 then
    if k==1 then
    elseif k==2 then
      networks[global_page]:clear()
    elseif k==3 then
      networks[global_page]:toggle_play()
    end
  elseif z==1 then
    if k==1 then
    elseif k==2 then
      networks[global_page]:disconnect()
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
      global_page=util.clamp(global_page+sign(d),1,#networks)
    elseif k==2 then
      networks[global_page]:change_col(d)
    elseif k==3 then
      networks[global_page]:change_row(d)
    end
  end
end

function redraw()
  screen.clear()

  screen.level(15)
  screen.move(128,60)
  if networks[global_page].name~=nil then
    screen.text_right(networks[global_page].name)
  end

  networks[global_page]:draw()

  screen.update()
end

function rerun()
  norns.script.load(norns.state.script)
end

function odasho_save(filename)
  filename=filename..".json"
  print("o-o-o: saving "..filename)
  local data={}
  for i,nw in ipairs(networks) do
    data[i]={}
    data[i].nw=nw.nw
    data[i].conn=nw.conn
  end
  file=io.open(filename,"w+")
  io.output(file)
  io.write(json.encode(data))
  io.close(file)
end

function odasho_load(filename)
  filename=filename..".json"
  print("o-o-o: loading "..filename)
  local f=io.open(filename,"rb")
  local content=f:read("*all")
  f:close()

  local data=json.decode(content)
  for i,_ in ipairs(networks) do
    networks[i].nw=data[i].nw
    networks[i].conn=data[i].conn
  end
end
