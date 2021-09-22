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
  self.chords={10,10}
  self.chord_current=1
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

function Ternary:change_pos(d)
  self.chord_current=util.clamp(self.chord_current+d,1,#self.chords)
end

function Ternary:change_chord(d)
  self.chords[self.chord_current]=util.clamp(self.chords[self.chord_current]+d,1,#self.chords)
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
    local interval=self.chords[self.chord_current]
    notes[1]=interval[1]
    notes[2]=notes[1]+interval[2]
    notes[3]=notes[2]+interval[3]
    self.fn(notes)
  end
end

function Ternary:toggle_play()
  self.playing=(not self.playing)
end

function Ternary:plot_points(ps)
  for i,p in ipairs(ps) do
    if i>1 then 
      screen.line(p[1],p[2])
      screen.stroke()
    end
    screen.move(p[1],p[2])
    screen.level(15)
    screen.circle(p[1],p[2],2)
    screen.fill()
    if i==self.chord_current then 
      screen.circle(p[1],p[2],4)
      screen.stroke()  
    end
  end
end

function Ternary:draw()
  local spacing=math.floor(56/#self.chords)
  local tr={39,1}
  local ps={}
  for i,v in ipairs(self.chords) do
    table.insert(ps,{tr[1]+(i-1)*spacing,tr[2]+ops[2]+50})
  end
  self:plot_points(ps)

  ps={}
  for i,v in ipairs(self.chords) do
    table.insert(ps,{tr[1]+(i-1)*spacing,tr[2]+ops[2]+30})
  end
  self:plot_points(ps)

  ps={}
  for i,v in ipairs(self.chords) do
    table.insert(ps,{tr[1]+(i-1)*spacing,tr[2]+ops[3]+10})
  end
  self:plot_points(ps)
end

return Ternary
