-- local pattern_time = require("pattern")
local GGrid={}

function GGrid:new(args)
  local m=setmetatable({},{__index=GGrid})
  local args=args==nil and {} or args

  m.grid_on=args.grid_on==nil and true or args.grid_on

  -- initiate the grid
  local grid_device=util.file_exists(_path.code.."midigrid") and include "midigrid/lib/mg_128" or grid
  m.g=grid_device.connect()
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
  m.blinky=0
  m.blinky_step=1
  m.grid_refresh=metro.init()
  m.grid_refresh.time=1/15
  m.grid_refresh.event=function()
    if m.grid_on then
      m:grid_redraw()
    end
    m.blinky_step=m.blinky_step+1
    if m.blinky_step>15 then
      m.blinky=1-m.blinky
      m.blinky_step=0
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
  local time_pressed=0
  if on then
    self.pressed_buttons[row..","..col]=clock.get_beats()*clock.get_beat_sec()
  else
    time_pressed=self.pressed_buttons[row..","..col]
    if time_pressed~=nil then
      time_pressed=clock.get_beats()*clock.get_beat_sec()-time_pressed
    else
      time_pressed=0
    end
    self.pressed_buttons[row..","..col]=nil
  end
  if col>8 then
    if not on then
      if row<3 then
        local bank_id=(col-8)+(row-1)*8
        local ins=instrument_list[global_page]
        params:set(ins.."bank",bank_id)
        if time_pressed>0.5 then
          -- save bank on long press
          bank_save()
        else
          -- load bank on short press
          bank_load()
        end
      end
      do return end
    end
    local page=col-8
    if row==8 then
      global_page=page
    elseif row==7 then
      params:delta(instrument_list[page].."play",1)
    elseif row==6 then
      params:delta(instrument_list[page].."solo",1)
    end
    do return end
  end

  -- organize pressed buttons by time
  local buttons={}
  for k,v in pairs(self.pressed_buttons) do
    local row,col=k:match("(%d+),(%d+)")
    table.insert(buttons,{v,tonumber(row),tonumber(col)})
  end
  -- make a connection between the two pressed buttons
  if #buttons==1 then
    -- play the button
    local i=networks[global_page].rowcol_to_i[buttons[1][2]][buttons[1][3]]
    networks[global_page].pos=i
    perform(instrument_list[global_page],networks[global_page]:current_nw(),networks[global_page].playing==false or params:get("playback")==2)
  end
  if #buttons~=2 then
    do return end
  end
  table.sort(buttons,function(a,b) return a[1]<b[1] end)
  local i=networks[global_page].rowcol_to_i[buttons[1][2]][buttons[1][3]]
  local j=networks[global_page].rowcol_to_i[buttons[2][2]][buttons[2][3]]
  if not networks[global_page]:is_connected_to(i,j) then
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
      self.visual[nw.row][nw.col]=3
    elseif nw.iterated then
      self.visual[nw.row][nw.col]=1
    else
      self.visual[nw.row][nw.col]=0
    end
  end

  -- illuminate current network
  local listed={}
  for _,v in ipairs(networks[global_page].conn) do
    for i=1,2 do
      if listed[v[i]]==nil then
        listed[v[i]]=true
        local nw=networks[global_page].nw[v[i]]
        self.visual[nw.row][nw.col]=self.visual[nw.row][nw.col]+2
      end
    end
  end

  -- illuminate playing buttons
  for i=1,8 do
    local row=7
    local col=i+8
    self.visual[row][col]=(networks[i].playing and 4 or 2)
  end

  -- illuminate switch buttons
  for i=1,8 do
    local row=8
    local col=i+8
    self.visual[row][col]=(i==global_page and 4 or 2)
  end

  -- illuminate solo buttons
  for i=1,8 do
    local row=6
    local col=i+8
    self.visual[row][col]=(params:get(instrument_list[i].."solo")==1 and 4 or 2)
  end

  -- illuminate the bank buttons
  local ins=instrument_list[global_page]
  for row=1,2 do
    for col=9,16 do
      local bank_id=(col-8)+(row-1)*8
      self.visual[row][col]=(bank_id==params:get(ins.."bank") and 2 or 0)*self.blinky
      self.visual[row][col]=self.visual[row][col]+(bank[global_page][bank_id].saved and 4 or 1)
    end
  end

  -- illuminate currently pressed button
  for k,_ in pairs(self.pressed_buttons) do
    local row,col=k:match("(%d+),(%d+)")
    self.visual[tonumber(row)][tonumber(col)]=self.visual[tonumber(row)][tonumber(col)]+5
    -- illuminate all the connections from the pressed node
    local i=networks[global_page].rowcol_to_i[tonumber(row)][tonumber(col)]
    for _,j in ipairs(networks[global_page]:to(i)) do
      self.visual[networks[global_page].nw[j].row][networks[global_page].nw[j].col]=self.visual[networks[global_page].nw[j].row][networks[global_page].nw[j].col]+5
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

function GGrid:gridstation()
  local c={"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"}
  gs="16 8 #bbbbbb #fcb400 #ffffff #000000 20 \n"
  gs=gs.."20 4 1 1\n"
  for row=1,8 do 
    for col=1,16 do
      gs=gs..c[self.visual[row][col]*3+1].." "
    end
    gs=gs.."\n"
  end
  print(gs)
end

return GGrid
