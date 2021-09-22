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
  self.playing=false
  self.pos=1
  self.div=1
end

function Ternary:set_action(fn)
  self.fn=fn
end

function Ternary:emit(step,div)
  if not self.playing then
    do return end
  end
end

function Ternary:toggle_play()
  self.playing=(not self.playing)
end

function Ternary:draw()

end

return Ternary
