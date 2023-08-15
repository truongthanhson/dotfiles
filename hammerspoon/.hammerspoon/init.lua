local obj = {}

obj.current_windows = {}
obj.theWindows = hs.window.filter.new()

obj.altShortcuts = {
	{ "1", { "Simulator", "iTerm" } },
	{ "2", { "Google Chrome" } },
	{ "3", { "Zalo", "Slack" } },
	{ "4", { "Proxyman", "Simulator" } },
	{ "5", { "Notion", "Todoist" } },
	{ "6", { "Preview" } },
	{ "7", { "Google Chrome" } },
}

for _, v in ipairs(obj.theWindows:getWindows()) do
	print(v)
	table.insert(obj.current_windows, v)
end

function obj:find_window_by_title(t)
	-- find a window by title.
	print(t)
	if not t then
		hs.alert.show("No string provided to focus_by_title")
		return nil
	end
	for i, v in ipairs(obj.current_windows) do
		if string.find(v:title(), t) then
			return v
		end
	end
	return nil
end

-- debug
function obj:print_windows()
	function w_info(w)
		return w:title() .. w:application():name()
	end

	obj.print_table(hs.window.visibleWindows(), w_info)
end

function obj:print_table(t, f)
	for i, v in ipairs(t) do
		print(i, f(v))
	end
end

for i, shortcut in ipairs(obj.altShortcuts) do
	hs.hotkey.bind({ "alt" }, shortcut[1], function()
		for _, app in ipairs(shortcut[2]) do
			if app == 'Google Chrome' then
				if i == 2 then
					local work = obj:find_window_by_title('ch_work')
					if work then
						work:focus()
					end
				elseif i == 7 then
					local relax = obj:find_window_by_title("ch_relax")
					if relax then
						relax:focus()
					end
				end
			else
				hs.application.launchOrFocus(app)
			end
		end
	end)
end

-- function obj:print_windows()
--    function w_info(w)
--       return w:title() .. w:application():name()
--    end
--    obj:print_table(hs.window.visibleWindows(), w_info)
-- end
-- altShortcuts = {
-- 	{ "1", { "Simulator", "Alacritty" } },
-- 	{ "2", { "Google Chrome" } },
-- 	{ "3", { "Notion", "Todoist" } },
-- 	{ "4", { "Zalo", "Slack" } },
-- 	{ "5", { "Preview" } },
-- }
--
-- for i, shortcut in ipairs(altShortcuts) do
-- 	hs.hotkey.bind({ "alt" }, shortcut[1], function()
-- 		print(shortcut[2])
-- 		for _, app in ipairs(shortcut[2]) do
-- 			print(app)
-- 			hs.application.launchOrFocus(app)
-- 		end
-- 	end)
-- end
return obj
