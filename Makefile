format: lua-format.py
	python3 lua-format.py todot.lua
	python3 lua-format.py lib/utils.lua
	python3 lua-format.py lib/network.lua
	python3 lua-format.py lib/er.lua
	python3 lua-format.py lib/grid_.lua

lua-format.py:
	wget https://raw.githubusercontent.com/schollz/LuaFormat/master/lua-format.py
