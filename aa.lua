-- new script v0.0.1
-- ?
--
-- llllllll.co/t/?
--
--
--
--    ▼ instructions below ▼
--
-- ?

local shift=false
engine.name="Fm1"

function init()

  -- define the chord lists
  chord_list={
    {2,2,0},
    {3,2,0},
    {3,2,0},
    {2,3,-1},
  }
  chord_current=1
  choice_chord_list={}
  for j=-2,2 do
    for i,c in ipairs({{2,2},{2,3},{3,2}}) do
      table.insert(choice_chord_list,{c[1],[c[2],j]})
    end
  end

  -- initialize metro for updating screen
  timer=metro.init()
  timer.time=1/15
  timer.count=-1
  timer.event=update_screen
  timer:start()
end

function update_screen()
  redraw()
end

function key(k,z)
  if k==1 then
    shift=z==1
  end
  if shift then
    if k==1 then
    elseif k==2 then
    else
    end
  else
    if k==1 then
    elseif k==2 then
    else
    end
  end
end

function enc(k,d)
  if shift then
    if k==1 then
    elseif k==2 then
    else
    end
  else
    if k==1 then
    elseif k==2 then
    else
    end
  end
end

function redraw()
  screen.clear()

  -- show the current chord
  
  screen.update()
end

function rerun()
  norns.script.load(norns.state.script)
end
