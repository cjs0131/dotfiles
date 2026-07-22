-- This is a Hyprland Lua config generated from moduleslua
-- See https://wiki.hypr.land/Configuring/Start/

-- Monitor
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1.25,
})

-- User variables
local terminal = "kitty"
local fileManager = "kitty -e yazi"
local menu = "vicinae open"
local editor = "nvim"
local browser = "firefox"
local ide = "code"
local obsidian = "obsidian"
local opencode = "kitty -e opencode"
local pbrowser = "firefox --private-window"
local ipc = "qs -c noctalia-shell ipc call"

-- Environment
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hyprland-session.target")
    hl.exec_cmd("qs -c noctalia-shell")
    hl.exec_cmd("pgrep -x handy >/dev/null || /home/charlie/.local/share/applications/Handy_0.8.3_amd64.AppImage --start-hidden")
    hl.exec_cmd("pgrep -x kdeconnectd >/dev/null || /usr/bin/kdeconnectd")
end)

-- Input
hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

-- Look and feel
hl.config({
    general = {
        gaps_in = 2,
        gaps_out = 5,
        border_size = 2,
        col = {
            active_border = { colors = { "rgba(CB7CF7ff)", "rgba(F38BA8ff)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
})

hl.config({
    decoration = {
        rounding = 5,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },
})

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "slave",
    },
})

hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = false,
    },
})

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

-- Curves and animations
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- Window rules
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = "20 monitor_h-120",
    float = true,
})

hl.layer_rule({
    name = "noctalia-region-selector-noanim",
    match = { namespace = "noctalia-shell:regionSelector" },
    no_anim = true,
})

-- Keybinds
local mainMod = "SUPER"

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(ide)) -- VS Code
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(ipc .. " notifications toggleHistory"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd(ipc .. " sessionMenu toggle"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. "+ SHIFT + B", hl.dsp.exec_cmd(pbrowser))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("qs -c noctalia-shell ipc call plugin:screen-toolkit annotate")) -- region screenshot -> annotate/save
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("qs -c noctalia-shell ipc call plugin:screen-toolkit toggle")) -- open full screen toolkit
-- Super+Shift+R toggles recording: if wl-screenrec/wf-recorder is running, stop; else start a region mp4
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("bash -c 'if pgrep -x wl-screenrec >/dev/null || pgrep -x wf-recorder >/dev/null; then qs -c noctalia-shell ipc call plugin:screen-toolkit recordStop; else qs -c noctalia-shell ipc call plugin:screen-toolkit recordMp4; fi'"))
hl.bind(
    mainMod .. " + M",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit")
)
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(obsidian)) -- Obsidian
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd(opencode)) -- opencode (moved off Super+O)
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(terminal .. " -e ranger"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("/home/charlie/.local/share/applications/Handy_0.8.3_amd64.AppImage --toggle-transcription")) -- Handy dictation: tap to start, tap to stop
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen(2))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen(0))

-- Move focus
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Move window
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- Switch workspaces / move window to workspace
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume and brightness
hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Media keys
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Tablet mode: kill the internal keyboard + touchpad so the folded-back keys
-- can't register presses; restore them when flipping back to laptop mode.
-- The tablet-mode switch lives on the "HP WMI hotkeys" device (hyprctl devices).
local tabletModeDevices = { "at-translated-set-2-keyboard", "elan012a:00-04f3:32ed-touchpad" }
-- Temporary debug logging while we chase the stuck-disabled bug
local function tabletLog(msg)
    local f = io.open(os.getenv("HOME") .. "/hypr-tablet-debug.log", "a")
    if f then
        f:write(os.date("%H:%M:%S") .. " " .. msg .. "\n")
        f:close()
    end
end
-- The fold event actually fires on "Intel HID switches" (verified with evdev
-- capture); "HP WMI hotkeys" advertises the same switch but stays silent.
-- Bind both anyway — the callbacks are idempotent.
local tabletSwitches = { "Intel HID switches", "HP WMI hotkeys" }
for _, sw in ipairs(tabletSwitches) do
    hl.bind("switch:on:" .. sw, function()
        tabletLog("switch:on (" .. sw .. ") fired -> disabling")
        for _, dev in ipairs(tabletModeDevices) do
            hl.device({ name = dev, enabled = false })
        end
        tabletLog("switch:on done")
    end, { locked = true })
    hl.bind("switch:off:" .. sw, function()
        tabletLog("switch:off (" .. sw .. ") fired -> enabling")
        for _, dev in ipairs(tabletModeDevices) do
            hl.device({ name = dev, enabled = true })
        end
        tabletLog("switch:off done")
    end, { locked = true })
end

-- Manual version of the above for tent mode (~270°), where the hardware switch
-- hasn't fired yet: Super+K kills the internal keyboard + touchpad before flipping.
-- The disabled keyboard can't press Super+K again, so to re-enable either fold
-- fully flat and back (trips the switch:off bind above), press Super+K on an
-- external/Bluetooth keyboard, or run `hyprctl reload` from the touchscreen.
local tabletModeManual = false
hl.bind("SUPER + K", function()
    tabletModeManual = not tabletModeManual
    tabletLog("Super+K fired -> manual=" .. tostring(tabletModeManual))
    for _, dev in ipairs(tabletModeDevices) do
        hl.device({ name = dev, enabled = not tabletModeManual })
    end
    if tabletModeManual then
        -- Built-in safety net: while we trust-build this, auto-restore the
        -- devices 2 minutes after a manual disable so a missed switch event
        -- can never strand the keyboard.
        os.execute("nohup sh -c 'sleep 120; "
            .. "hyprctl eval \"hl.device({ name = \\\"at-translated-set-2-keyboard\\\", enabled = true })\"; "
            .. "hyprctl eval \"hl.device({ name = \\\"elan012a:00-04f3:32ed-touchpad\\\", enabled = true })\"; "
            .. "echo \"$(date +%H:%M:%S) built-in safety net fired\" >> \"$HOME/hypr-tablet-debug.log\"' >/dev/null 2>&1 &")
    end
    tabletLog("Super+K done")
end, { locked = true })

hl.bind("SUPER + tab", function()
    local layouts     = {"dwindle", "master"}
    local workspace   = hl.get_active_workspace()
    if hl.get_active_special_workspace() then
        workspace = hl.get_active_special_workspace()
    end

    local next_layout = "dwindle"

    if not workspace then
        return
    end

    for i = 1, #layouts do
        if layouts[i] == workspace.tiled_layout then
            local next_layout_idx = (i % #layouts) + 1
            next_layout = layouts[next_layout_idx]
            break
        end
    end

    if workspace.special then
        hl.workspace_rule({ workspace = tostring(workspace.name), layout = next_layout })
    else
        hl.workspace_rule({ workspace = tostring(workspace.id), layout = next_layout })
    end
end)
