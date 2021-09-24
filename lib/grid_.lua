-- local pattern_time = require("pattern")
local GGrid={}

function GGrid:new(args)
  local m=setmetatable({},{__index=GGrid})
  local args=args==nil and {} or args

  m.grid_on=args.grid_on==nil and true or args.grid_on

  -- initiate the grid
  m.g=grid.connect()
  m.g.key=function(x,y,z)
    if m.grid_on then
      m:grid_key(x,y,z)
    end
  end

  print("grid columns: "..m.g.cols)

  -- setup visual
  m.visual={}
  m.grid_width=16
  for i=1,8 do
    m.visual[i]={}
    for j=1,m.grid_width do
      m.visual[i][j]=0
    end
  end

  -- keep track of pressed buttons
  m.pressed_buttons={}

  -- grid refreshing
  m.grid_refresh=metro.init()
  m.grid_refresh.time=1/15
  m.grid_refresh.event=function()
    if m.grid_on then
      m:grid_redraw()
    end
  end
  m.grid_refresh:start()

  return m
end

function GGrid:grid_key(x,y,z)
  self:key_press(y,x,z==1)
  self:grid_redraw()
end

function GGrid:key_press(row,col,on)
  if on then
    self.pressed_buttons[row..","..col]=clock.get_beats()
  else
    self.pressed_buttons[row..","..col]=nil
  end
  -- organize pressed buttons by time
  local buttons={}
  for k,v in pairs(self.pressed_buttons) do
    local row,col=k:match("(%d+),(%d+)")
    table.insert(buttons,{v,tonumber(row),tonumber(col)})
  end
  -- make a connection between the two pressed buttons
  if #buttons~=2 then
    do return end
  end
  table.sort(buttons,function(a,b) return a[1]<b[1] end)
  local i=networks[global_page].rowcol_to_i[buttons[1][2]][buttons[1][3]]
  local j=networks[global_page].rowcol_to_i[buttons[2][2]][buttons[2][3]]
  if not netwworks[global_page]:is_connected_to(i,j) then
    networks[global_page]:connect(i,j)
  else
    networks[global_page]:disconnect(i,j)
  end
end

function GGrid:get_visual()
  -- clear visual
  for row=1,8 do
    for col=1,self.grid_width do
      self.visual[row][col]=self.visual[row][col]-1
      if self.visual[row][col]<0 then
        self.visual[row][col]=0
      end
    end
  end

  -- illuminate the network
  for i,nw in ipairs(networks[global_page].nw) do
    if nw.emitted then
      self.visual[nw.row][nw.col]=10
    elseif nw.iterated then
      self.visual[nw.row][nw.col]=5
    else
      self.visual[nw.row][nw.col]=0
    end
  end

  -- illuminate currently pressed button
  for k,_ in pairs(self.pressed_buttons) do
    local row,col=k:match("(%d+),(%d+)")
    self.visual[tonumber(row)][tonumber(col)]=15
    -- illuminate all the connections from the pressed node
    local i=networks[global_page].rowcol_to_i[row][col]
    for _,j in ipairs(networks[global_page]:to(i)) do
      self.visual[networks[global_page].nw[j].row][networks[global_page].nw[j].col]=15
    end
  end

  return self.visual
end

function GGrid:grid_redraw()
  self.g:all(0)
  local gd=self:get_visual()
  local s=1
  local e=self.grid_width
  local adj=0
  for row=1,8 do
    for col=s,e do
      if gd[row][col]~=0 then
        self.g:led(col+adj,row,gd[row][col])
      end
    end
  end
  self.g:refresh()
end

return GGrid
