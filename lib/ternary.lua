local Ternary={}

function Ternary:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o.seed=o.seed or 42
  o:init()
  return o
end

function Ternary:init()
  math.randomseed(self.seed)
  self.chord_options={}
  self.chords={10,11,12,8}
  self.chord_current=1
  self.amp=0.5
  for i=-3,3 do
    for _,v in ipairs({{2,2},{2,3},{3,2}}) do
      table.insert(self.chord_options,{i,v[1],v[2]})
    end
  end
  self.playing=false
  self.div=1
end

function Ternary:set_action(fn)
  self.fn=fn
end

function Ternary:change_amp(d)
  self.amp=util.clamp(self.amp+d,0,1)
end

function Ternary:change_pos(d)
  self.chord_current=util.clamp(self.chord_current+d,1,#self.chords)
end

function Ternary:change_chord(d)
  self.chords[self.chord_current]=util.clamp(self.chords[self.chord_current]+d,1,#self.chord_options)
  print(self.chords[self.chord_current])
end

-- add_chord adds one chord to the end
function Ternary:add_chord()
  table.insert(self.chords,10)
end

-- remove_chord removes current chord
function Ternary:remove_chord()
  table.remove(self.chords,self.chord_current)
end

function Ternary:emit(step,div)
  if (not self.playing) or (self.div~=div) then
    do return end
  end
  self.chord_current=(self.chord_current%#self.chords)+1
  if self.fn~=nil then
    local notes={}
    local interval=self.chord_options[self.chords[self.chord_current]]
    notes[1]=interval[1]
    notes[2]=notes[1]+interval[2]
    notes[3]=notes[2]+interval[3]
    self.fn(notes)
  end
end

function Ternary:toggle_play()
  print("Ternary: toggle_play")
  self.playing=(not self.playing)
end

function Ternary:plot_points(ps)
  for i,p in ipairs(ps) do
    if i>1 then
      screen.level(2)
      screen.line(p[1],p[2])
      screen.stroke()
    end
    screen.move(p[1],p[2])
    screen.level(i==self.chord_current and 15 or 5)
    screen.circle(p[1],p[2],2)
    screen.fill()
    -- TODO allow changing selection from playig
    -- if i==self.chord_current then
    --   screen.circle(p[1],p[2],4)
    --   screen.stroke()
    -- end
    screen.move(p[1]+2,p[2])
  end
end

function Ternary:draw()
  local spacing=math.floor(60/(#self.chords-1))
  local tr={39,1}
  local ps={}
  for i,v in ipairs(self.chords) do
    local ops=self.chord_options[v]
    table.insert(ps,{tr[1]+(i-1)*spacing,tr[2]+2*ops[1]+45})
  end
  self:plot_points(ps)

  ps={}
  for i,v in ipairs(self.chords) do
    local ops=self.chord_options[v]
    table.insert(ps,{tr[1]+(i-1)*spacing,tr[2]+4*ops[2]+20})
  end
  self:plot_points(ps)

  ps={}
  for i,v in ipairs(self.chords) do
    local ops=self.chord_options[v]
    table.insert(ps,{tr[1]+(i-1)*spacing,tr[2]+4*ops[3]+5})
  end
  self:plot_points(ps)

  if keydown[1] then
    screen.level(15)
    local help={{"k2","takes"},{"k3","gives"},{"e2","selects"},{"e3","changes"}}
    local y=7
    for _,h in ipairs(help) do
      screen.move(1,y)
      screen.text(h[1])
      y=y+7
      screen.move(5,y)
      screen.text(h[2])
      y=y+8
    end

    screen.move(128,15)
    screen.text_right((params:get("paddb")>0 and "+" or "")..params:get("paddb").." dB")
  end

  -- show if playing
  screen.level(15)
  screen.move(125,5)
  screen.text(self.playing and ">" or "||")
end

return Ternary
