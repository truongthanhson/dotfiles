local obj = {}
obj.current_windows = {}
obj.theWindows = hs.window.filter.new()

hs.window.animationDuration = 0
obj.altShortcuts = {
	{ "1", { "qemu-system-aarch64", "Alacritty" } },
	{ "2", { "Firefox" } },
	{ "3", { "Zalo", "Slack" } },
	{ "4", { "Obsidian", "Todoist" } },
	{ "5", { "Proxyman" } },
}

for _, v in ipairs(obj.theWindows:getWindows()) do
	table.insert(obj.current_windows, v)
end

function obj:find_window_by_title(t)
	-- find a window by title.
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
						hs.window.animationDuration = 0
						work:focus()
					end
				elseif i == 7 then
					local relax = obj:find_window_by_title("ch_relax")
					if relax then
						hs.window.animationDuration = 0
						relax:focus()
					end
				end
			else
				hs.window.animationDuration = 0
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
config = {}
config.applications = {
	['Alfred'] = {
		bundleID = 'com.runningwithcrayons.Alfred',
		local_bindings = { 'c', 'space', 'o' }
	},
	['Brave'] = {
		bundleID = 'com.brave.browser',
		hyper_key = 'k',
		preferred_display = 1
	},
	['Finder'] = {
		bundleID = 'com.apple.finder',
		hyper_key = 'f'
	},
}

config.domains = {
	['twitter.com'] = {
		url = 'twitter.com',
		tags = { '#distraction', '#socialmedia' }
	},
	['instagram.com'] = {
		url = 'instagram.com',
		tags = { '#distraction', '#socialmedia' }
	},
	['reddit.com'] = {
		url = 'reddit.com',
		tags = { '#distraction' }
	},
	['instapaper.com'] = {
		url = 'instapaper.com',
		tags = { '#distraction', '#reading' }
	},
	['youtube.com'] = {
		url = 'youtube.com',
		tags = { '#distraction' }
	}
}

-- configure spaces for headspace
config.spaces = {}
config.setup = {}

hyper = require('hyper')
hyper.start(config)

movewindows = require('movewindows')
movewindows.start()
return obj
