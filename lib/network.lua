local Network={}

function Network:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o.seed=o.seed or 42
  o:init()
  return o
end

function Network:init()
  math.randomseed(self.seed)
  self.pos=1
  self.pos_hold=nil
  self.nw={}
  self.conn={}
  self.playing=false
  for i=1,64 do
    -- generate random notework lattice
    self.nw[i]={
      armed=false,
      er=er.random(math.random(8,32)),
      pos=0,
      div=global_divisions[math.random(#global_divisions)],
      emitted=false,
      iterated=false,
    }
  end
end

function Network:set_action(fn)
  self.fn=fn
end

function Network:emit(step,div)
  if not self.playing then
    do return end
  end
  for j,nw in ipairs(self.nw) do
    if nw.div==div then
      self.nw[j].pos=(step%#nw.er)+1
      -- emit if either...
      -- ...it is connected TO something
      -- ...it is armed
      if nw.er[self.nw[j].pos] then
        self.nw[j].iterated=true
        local to=self:to(j)
        -- only play if nothing is armed
        local none_armed=true
        for _,k in ipairs(to) do
          if self.nw[k].armed then
            none_armed=false
          end
        end
        if ((none_armed and #to>0) or nw.armed) then
          self.nw[j].emitted=true
          -- emit note
          if self.fn~=nil then
            self.fn(j)
          end

          -- arm connected
          for _,j2 in ipairs(to) do
            if not self.nw[j2].armed then
              self.nw[j2].armed=true
            end
          end

          -- disarm current
          self.nw[j].armed=false
        else
          self.nw[j].emitted=false
        end
      else
        self.nw[j].iterated=false
        self.nw[j].emitted=false
      end
    end
  end
end

function Network:toggle_playing()
  self.playing=not self.playing
end

function Network:connect(i,j)
  if i==nil and j==nil then
    i=self.pos_hold
    j=self.pos
  end
  if i==j then
    do return end
  end
  -- connect the first key to the second key
  -- if it isn't already connected
  if not self:is_connected(i,j) then
    table.insert(self.conn,{i,j})
  end
  self.pos_hold=nil
end

function Network:is_connected(i,j)
  for k,v in ipairs(self.conn) do
    if i==v[1] and j==v[2] then
      do return k end
    end
  end
end

function Network:disconnect(i,j)
  local ind=self:is_connected(i,j)
  if ind then
    table.remove(self.conn,ind)
  end
end

function Network:to(i)
  local to={}
  for _,v in ipairs(self.conn) do
    if v[1]==i then
      table.insert(to,v[2])
    end
  end
  return to
end

function Network:change_pos(d)
  local pos=self.pos
  pos=pos+d
  if pos>=1 and pos<=64 then
    self.pos=pos
  end
end

function Network:connect_first()
  self.pos_hold=self.pos
end

function Network:coord(i)
  local spacing=7
  local tr={39,1}
  local row=8-((i-1)%8)
  local col=1+math.floor((i-0.01)/8)
  local x=col*spacing+tr[1]
  local y=row*spacing+tr[2]
  return x,y
end

function Network:draw_connection(i,j,lw)
  local x1,y1=self:coord(i)
  local x2,y2=self:coord(j)
  local d=distance_points(x1,y1,x2,y2)
  -- TODO: add a little lfo to the the point so they sway
  local p=perpendicular_points({x1,y1},{x2,y2},math.sqrt(d)*4)
  screen.line_width(lw or 1)
  screen.level(15)
  screen.move(x1,y1)
  screen.curve(p[1],p[2],p[1],p[2],x2,y2)
  screen.stroke()
end

function Network:draw()
  -- show the network topology
  -- using bezier curves
  -- where curving UP connects left to right
  -- and curving DOWN connects right to left
  for i,nw in ipairs(self.nw) do
    local to=self:to(i)
    if to then
      for _,j in ipairs(to) do
        self:draw_connection(i,j)
      end
    end
  end
  if self.pos_hold~=nil then
    if self.pos_hold~=self.pos then
      self:draw_connection(self.pos_hold,self.pos,2)
    end
  end

  -- show the notework dots
  for i,nw in ipairs(self.nw) do
    local x,y=self:coord(i)
    -- erase the network topology directly around
    screen.level(0)
    screen.circle(x,y,self.pos==i and 5 or 2)
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
    if self.pos==i then
      screen.level(15)
      screen.circle(x,y,5)
      screen.stroke()
    end
  end
end

return Network
