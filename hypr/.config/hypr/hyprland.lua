-- Hyprland desktop configuration. i3 remains the rollback session in LightDM.
-- Default display state is safe WORK mode; Sunshine may switch to the dummy.
-- Ported from hyprland.conf (Hyprland 0.57 dropped the old format).

local mainMod  = "ALT"
local terminal = "kitty"
-- Search both desktop applications and every executable on PATH (including
-- ~/.local/bin); no per-application .desktop files are required.
local menu     = 'rofi -show combi -combi-modes "drun,run"'

-- A reload is an unconditional local-display recovery path.
hl.monitor({ output = "DP-1", mode = "2560x1440@240", position = "0x0", scale = 1 })
hl.monitor({ output = "HDMI-A-1", disabled = true })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.config({
    input = {
        kb_layout    = "us",
        repeat_rate  = 25,
        repeat_delay = 500,
        follow_mouse = 0,
        touchpad = {
            natural_scroll = false,
        },
    },

    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgb(89b4fa)", "rgb(cba6f7)" }, angle = 45 },
            inactive_border = "rgb(45475a)",
        },
        layout        = "dwindle",
        allow_tearing = false,
    },

    decoration = {
        rounding         = 6,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = false,
        },
    },

    -- Subtle transitions only: fast, gentle, nothing flashy.
    animations = {
        enabled = true,
    },

    dwindle = {
        -- New tiled windows split to the right (or below for vertical splits).
        force_split    = 2,
        preserve_split = true,
    },

    -- Groups are Hyprland's tabbed-window equivalent; show their tab bar.
    group = {
        groupbar = {
            enabled = true,
        },
    },

    misc = {
        disable_hyprland_logo   = true,
        force_default_wallpaper = 0,
    },
})

-- Ease-out curves: quick start, soft settle, no bounce.
hl.curve("easeOut",    { type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } })
hl.curve("smoothDamp", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })

-- Focus switching (Alt+Space / Alt+H,J,K,L): no animation.
hl.animation({ leaf = "border", enabled = false })

-- Window open/close: soft pop-in from 90% size.
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 5, bezier = "easeOut", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "easeOut", style = "popin 90%" })
-- Windows glide when moved (Alt+Shift+arrows) or the layout reflows.
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "smoothDamp" })

-- Popups, menus, and layer surfaces (topbar, rofi) fade gently.
hl.animation({ leaf = "fade",      enabled = true, speed = 5, bezier = "easeOut" })
hl.animation({ leaf = "layersIn",  enabled = true, speed = 5, bezier = "easeOut", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 5, bezier = "easeOut", style = "fade" })

-- Workspace switching (Alt+1-0): no animation.
hl.animation({ leaf = "workspaces", enabled = false })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2, bezier = "smoothDamp", style = "slide" })

-- Fcitx5 input method: Vietnamese (Bamboo) + English. IBus cannot use
-- Hyprland's zwp_input_method_v2 (it only speaks v1), so we use Fcitx5, which
-- supports it natively. GTK/Qt apps use the fcitx IM modules, XWayland apps XIM.
hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")

-- Wayland session services. Do not start Picom, xss-lock, i3lock, i3bar,
-- or XRandR display scripts. Publish this exact Hyprland instance before the
-- systemd-managed Sunshine service starts, avoiding environment/startup races.
hl.on("hyprland.start", function()
    hl.exec_cmd("/home/snow/.local/bin/hypr-session-services.sh")
    -- Snow Topbar (rollback: swap for "waybar")
    hl.exec_cmd("/home/snow/projects/topbar/bin/topbar start")
    -- Notifications are served by the topbar shell itself (rollback: "mako").
    hl.exec_cmd("hypridle")
    -- Fcitx5 input-method daemon (Vietnamese Bamboo + English).
    hl.exec_cmd("fcitx5 -d")
    -- Random wallpaper from ~/Pictures/Wallpaper, redrawn on every login.
    hl.exec_cmd("/home/snow/.local/bin/wallpaper")
end)

-- Applications and session controls
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("slack --password-store=gnome-libsecret"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("nautilus"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))
-- Hold Alt and drag a floating window: left button moves, right button resizes.
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + SPACE", hl.dsp.window.cycle_next())
-- Input method toggles natively in Fcitx5 (Control+Shift+space; see ~/.config/fcitx5/config).
-- Stream display controls; F2 remains a local recovery path if a stream fails.
hl.bind(mainMod .. " + SHIFT + F1", hl.dsp.exec_cmd("/home/snow/.local/bin/stream-mode.sh"))
hl.bind(mainMod .. " + SHIFT + F2", hl.dsp.exec_cmd("/home/snow/.local/bin/work-mode.sh"))

-- Window groups (tabbed windows): create/toggle a group, join the group in a
-- direction, switch its active tab, or remove the focused tab.
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.move({ into_group = "left" }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.move({ into_group = "down" }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.move({ into_group = "up" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.move({ into_group = "right" }))
hl.bind(mainMod .. " + TAB", hl.dsp.group.next())
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.group.prev())
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.window.move({ out_of_group = true }))

hl.bind("SHIFT + F4", hl.dsp.exec_cmd("shutter --select"))

-- Vim-style directional focus/movement: h/j/k/l = left/down/up/right.
local directions = {
    H = "left", J = "down", K = "up", L = "right",
    left = "left", down = "down", up = "up", right = "right",
}
for key, direction in pairs(directions) do
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = direction }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
end

-- Workspaces
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +10%"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -10%"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind(mainMod .. " + F10", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
-- Microphone mute mirrors output mute one row up.
hl.bind(mainMod .. " + SHIFT + F10", hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"))
hl.bind(mainMod .. " + F11", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -10%"))
hl.bind(mainMod .. " + F12", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +10%"))

-- Capture: saves to ~/Pictures and the clipboard. Smart freezes the screen so a
-- click snaps to a window or monitor and a drag takes a freeform region.
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("screenshot region"))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("screenshot"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("screenshot fullscreen"))
hl.bind("Print", hl.dsp.exec_cmd("screenshot"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("screenshot region"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("screenshot fullscreen"))

-- Resize submap; Escape, Return, or Alt+R returns to normal mode.
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    local steps = {
        H = { -40, 0 }, J = { 0, 40 }, K = { 0, -40 }, L = { 40, 0 },
        left = { -40, 0 }, down = { 0, 40 }, up = { 0, -40 }, right = { 40, 0 },
    }
    for key, step in pairs(steps) do
        hl.bind(key, hl.dsp.window.resize({ x = step[1], y = step[2], relative = true }), { repeating = true })
    end
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("return", hl.dsp.submap("reset"))
    hl.bind(mainMod .. " + R", hl.dsp.submap("reset"))
end)

-- Exit submap: Alt+X shows the available actions, then l/r/s/p. Escape or
-- Return cancels. A submap alone is intentionally invisible, hence the notice.
hl.bind(mainMod .. " + X", function()
    hl.dispatch(hl.dsp.exec_cmd("notify-send -u normal -t 5000 'Power controls' 'r: reboot   s: shutdown   p: suspend   l: log out   Esc: cancel'"))
    hl.dispatch(hl.dsp.submap("exit"))
end)
hl.define_submap("exit", function()
    hl.bind("l", hl.dsp.exit())
    hl.bind("r", hl.dsp.exec_cmd("systemctl reboot"))
    hl.bind("s", hl.dsp.exec_cmd("systemctl poweroff"))
    hl.bind("p", function()
        hl.dispatch(hl.dsp.submap("reset"))
        hl.dispatch(hl.dsp.exec_cmd("systemctl suspend"))
    end)
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("return", hl.dsp.submap("reset"))
end)
