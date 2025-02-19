local awful = require "awful"
local naughty = require "naughty"
local gears = require "gears"
local beautiful = require "beautiful"
local apps = require "apps"
local decorations = require "components.decorations"
local icons = require "icons"
local bling = require "lib.bling"
local rubato = require "lib.rubato"

local helpers = require "helpers"
local hotkeys_popup = require "awful.hotkeys_popup"
require "awful.hotkeys_popup.keys"

local anim_y = rubato.timed {
    pos = 1090,
    rate = 60,
    easing = rubato.quadratic,
    intro = 0.1,
    duration = 0.3,
    awestore_compat = true, -- this option must be set to true.
}

local anim_x = rubato.timed {
    pos = 2070,
    rate = 60,
    easing = rubato.quadratic,
    intro = 0.1,
    duration = 0.3,
    awestore_compat = true, -- this option must be set to true.
}

local spotify_scratch = bling.module.scratchpad:new {
    command = "spotify",
    rule = { instance = "spotify" },
    sticky = false,
    autoclose = false,
    floating = true,
    geometry = { x = 150, y = 65, height = 660, width = 960 },
    reapply = true,
    dont_focus_before_close = false,
    rubato = { y = anim_y },
}

-- Signals
------------
awesome.connect_signal("scratch::spotify", function()
    spotify_scratch:toggle()
end)

local keys = {}

-- Mod keys
superkey = "Mod1"
altkey = "Mod4"
ctrlkey = "Control"
shiftkey = "Shift"

bling.widget.window_switcher.enable {
    type = "thumbnail",
    hide_window_switcher_key = "Escape",
    minimize_key = "n",
    unminimize_key = "N",
    kill_client_key = "q",
    cycle_key = "Tab",
    previous_key = "Left",
    next_key = "Right",
    vim_previous_key = "h",
    vim_next_key = "l",
}
-- {{{ Mouse bindings on desktop
keys.desktopbuttons = gears.table.join(
    awful.button({}, 1, function()
        -- Single tap
        awesome.emit_signal "elemental::dismiss"
        naughty.destroy_all_notifications()
        if mymainmenu then
            mymainmenu:hide()
        end
        if sidebar_hide then
            sidebar_hide()
        end
        -- Double tap
        local function double_tap()
            uc = awful.client.urgent.get()
            -- If there is no urgent client, go back to last tag
            if uc == nil then
                awful.tag.history.restore()
            else
                awful.client.urgent.jumpto()
            end
        end
        helpers.single_double_tap(function() end, double_tap)
    end),

    -- Right click - Show app drawer
    -- awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({}, 3, function()
        F.action.toggle()
    end),

    -- Middle button - Toggle dashboard
    awful.button({}, 2, function()
        if dashboard_show then
            dashboard_show()
        end
    end),

    -- Scrolling - Switch tags
    awful.button({}, 4, awful.tag.viewprev),
    awful.button({}, 5, awful.tag.viewnext),

    -- Side buttons - Control volume
    awful.button({}, 9, function()
        helpers.volume_control(5)
    end),
    awful.button({}, 8, function()
        helpers.volume_control(-5)
    end)

    -- Side buttons - Minimize and restore minimized client
    -- awful.button({ }, 8, function()
    --     if client.focus ~= nil then
    --         client.focus.minimized = true
    --     end
    -- end),
    -- awful.button({ }, 9, function()
    --       local c = awful.client.restore()
    --       -- Focus restored client
    --       if c then
    --           client.focus = c
    --       end
    -- end)
)
-- }}}

-- {{{ Key bindings
keys.globalkeys = gears.table.join(
    awful.key({ altkey }, "f", hotkeys_popup.show_help, { description = "HELP ME PLS!!!", group = "awesome" }),
    -- Focus client by direction (hjkl keys)
    awful.key({ superkey }, "j", function()
        awful.client.focus.bydirection "down"
    end, { description = "focus down", group = "client" }),
    awful.key({ superkey }, "k", function()
        awful.client.focus.bydirection "up"
    end, { description = "focus up", group = "client" }),
    awful.key({ superkey }, "h", function()
        awful.client.focus.bydirection "left"
    end, { description = "focus left", group = "client" }),
    awful.key({ superkey }, "l", function()
        awful.client.focus.bydirection "right"
    end, { description = "focus right", group = "client" }),

    -- focus screen (monitor) direction
    awful.key({ altkey }, "h", function()
        awful.screen.focus(2)
    end, { description = "focus the next screen", group = "screen" }),
    awful.key({ altkey }, "l", function()
        awful.screen.focus(1)
    end, { description = "focus the previous screen", group = "screen" }),

    -- Layout
    -- Single tap: Set max layout
    -- Double tap: Also disable floating for ALL visible clients in the tag
    --
    awful.key({ altkey }, "n", function()
        layout_popup_show(awful.screen.focused())
    end, { description = "select next", group = "layout" }),

    awful.key({ superkey }, "'", function()
        awful.layout.set(awful.layout.suit.max)
        helpers.single_double_tap(nil, function()
            local clients = awful.screen.focused().clients
            for _, c in pairs(clients) do
                c.floating = false
            end
        end)
    end, { description = "set max layout", group = "layout" }),
    -- Tiling
    -- Single tap: Set tiled layout
    -- Double tap: Also disable floating for ALL visible clients in the tag
    awful.key({ superkey }, ";", function()
        awful.layout.set(awful.layout.suit.spiral.dwindle)
        helpers.single_double_tap(nil, function()
            local clients = awful.screen.focused().clients
            for _, c in pairs(clients) do
                c.floating = false
            end
        end)
    end, { description = "set dwindle layout", group = "layout" }),
    -- Set floating layout
    awful.key({ superkey }, "[", function()
        awful.layout.set(awful.layout.suit.floating)
    end, { description = "set floating layout", group = "layout" }),

    -- set tile layout
    awful.key({ superkey }, "]", function()
        awful.layout.set(awful.layout.suit.tile)
    end, { description = "set tile layout", group = "layout" }),

    -- Window switcher
    awful.key({ superkey }, "Tab", function()
        awesome.emit_signal "bling::window_switcher::turn_on"
        -- window_switcher_show(awful.screen.focused())
    end, { description = "activate window switcher", group = "client" }),

    -- Gaps
    awful.key({ superkey, shiftkey }, "minus", function()
        awful.tag.incgap(5, nil)
    end, { description = "increment gaps size for the current tag", group = "gaps" }),
    awful.key({ superkey }, "minus", function()
        awful.tag.incgap(-5, nil)
    end, { description = "decrement gap size for the current tag", group = "gaps" }),

    -- Kill all visible clients for the current tag
    awful.key({ superkey, shiftkey }, "q", function()
        local clients = awful.screen.focused().clients
        for _, c in pairs(clients) do
            c:kill()
        end
    end, { description = "kill all visible clients for the current tag", group = "client" }),

    -- Resize focused client or layout factor
    awful.key({ superkey, ctrlkey }, "Down", function(c)
        helpers.resize_dwim(client.focus, "down")
    end),
    awful.key({ superkey, ctrlkey }, "Up", function(c)
        helpers.resize_dwim(client.focus, "up")
    end),
    awful.key({ superkey, ctrlkey }, "Left", function(c)
        helpers.resize_dwim(client.focus, "left")
    end),
    awful.key({ superkey, ctrlkey }, "Right", function(c)
        helpers.resize_dwim(client.focus, "right")
    end),
    awful.key({ superkey, ctrlkey }, "k", function(c)
        helpers.resize_dwim(client.focus, "down")
    end),
    awful.key({ superkey, ctrlkey }, "j", function(c)
        helpers.resize_dwim(client.focus, "up")
    end),
    awful.key({ superkey, ctrlkey }, "h", function(c)
        helpers.resize_dwim(client.focus, "left")
    end),
    awful.key({ superkey, ctrlkey }, "l", function(c)
        helpers.resize_dwim(client.focus, "right")
    end),

    -- Urgent or Undo:
    -- Jump to urgent client or (if there is no such client) go back
    -- to the last tag
    awful.key({ superkey }, "u", function()
        uc = awful.client.urgent.get()
        -- If there is no urgent client, go back to last tag
        if uc == nil then
            awful.tag.history.restore()
        else
            awful.client.urgent.jumpto()
        end
    end, { description = "jump to urgent client", group = "client" }),

    -- Spawn terminal
    awful.key({ superkey }, "Return", function()
        awful.spawn(user.terminal)
    end, { description = "open a terminal", group = "launcher" }),

    awful.key({ altkey }, "Return", function()
        awesome.emit_signal "scratch::term"
    end),

    -- Spawn floating terminal
    awful.key({ superkey, shiftkey }, "Return", function()
        awful.spawn.with_shell "st -c float"
    end, { description = "spawn floating terminal", group = "launcher" }),

    -- Reload Awesome
    awful.key({ superkey, shiftkey }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),

    -- Quit Awesome
    awful.key({ superkey }, "Escape", function()
        exit_screen_show()
    end, { description = "quit awesome", group = "awesome" }),

    -- Dismiss notifications and elements that connect to the dismiss signal
    awful.key({ ctrlkey }, "space", function()
        awesome.emit_signal "elemental::dismiss"
        naughty.destroy_all_notifications()
    end, { description = "dismiss notification", group = "notifications" }),

    -- Brightness
    awful.key({}, "XF86MonBrightnessDown", function()
        awful.spawn.with_shell "light -U 10"
    end, { description = "decrease brightness", group = "brightness" }),
    awful.key({}, "XF86MonBrightnessUp", function()
        awful.spawn.with_shell "light -A 10"
    end, { description = "increase brightness", group = "brightness" }),

    -- Volume Control with volume keys
    awful.key({}, "XF86AudioMute", function()
        helpers.volume_control(0)
    end, { description = "(un)mute volume", group = "volume" }),
    awful.key({}, "XF86AudioLowerVolume", function()
        helpers.volume_control(-5)
    end, { description = "lower volume", group = "volume" }),
    awful.key({}, "XF86AudioRaiseVolume", function()
        helpers.volume_control(5)
    end, { description = "raise volume", group = "volume" }),

    -- clipboard manager keybingdings like windows
    awful.key({ altkey }, "v", function()
        awful.spawn.with_shell "copyq show"
    end, { description = "show clipboard", group = "launcher" }),
    -- Microphone (V for voice)
    awful.key({}, "XF86AudioMicMute", function()
        awful.spawn.with_shell "pactl set-source-mute @DEFAULT_SOURCE@ toggle"
    end, { description = "(un)mute microphone", group = "volume" }),

    -- Microphone overlay
    awful.key({ superkey }, "XF86AudioMicMute", function()
        microphone_overlay_toggle()
    end, { description = "toggle microphone overlay", group = "volume" }),

    -- Screenshots
    awful.key({}, "Print", function()
        apps.screenshot "full"
    end, { description = "take full screenshot", group = "Screenshot and record" }),
    awful.key({ altkey, ctrlkey }, "s", function()
        apps.screenshot "selection"
    end, { description = "select area to capture", group = "Screenshot and record" }),
    awful.key({ altkey, shiftkey }, "s", function()
        -- like window
        apps.screenshot "clipboard"
    end, { description = "select area to copy to clipboard", group = "Screenshot and record" }),

    -- Record
    awful.key({ altkey }, "r", function()
        apps.record()
    end, { description = "Recording", group = "Screenshot and record" }),

    -- Toggle tray visibility
    awful.key({ superkey }, "=", function()
        tray_toggle()
    end, { description = "toggle tray visibility", group = "awesome" }),

    -- Media keys
    awful.key({ superkey }, "Right", function()
        awful.spawn.with_shell "mpc -q next"
    end, { description = "next song", group = "media" }),
    awful.key({ superkey }, "Left", function()
        awful.spawn.with_shell "mpc -q prev"
    end, { description = "previous song", group = "media" }),
    awful.key({ superkey, ctrlkey }, "space", function()
        awful.spawn.with_shell "mpc -q toggle"
    end, { description = "toggle pause/play", group = "media" }),

    -- Prompt
    awful.key({ superkey }, "/", function()
        awful.spawn.with_shell "rofi -show drun -show-icons -theme ~/.config/rofi/nord/nord.rasi"
    end, { description = "rofi launcher", group = "launcher" }),
    awful.key({ superkey, shiftkey }, "/", function()
        awful.spawn.with_shell "dmenu_run -fn 'JetBrainsMono Nerd Font-9'  -p  -class films -sb '#EBCB8B' -sf '#2E3440'"
    end, { description = "dmenu run", group = "launcher" }),

    -- toggle wibar
    awful.key({ superkey, shiftkey }, "b", function()
        for s in screen do
            s.taglist_box.visible = not s.taglist_box.visible
            if s.mybottomwibox then
                s.mybottomwibox.visible = not s.mybottomwibox.visible
            end
        end
    end, { description = "toggle wibox", group = "awesome" }),
    -- Toggle sidebar
    awful.key({ superkey }, "o", function()
        sidebar_toggle()
    end, { description = "show or hide sidebar", group = "awesome" }),

    -- Toggle wibar(s)
    awful.key({ superkey }, "b", function()
        wibars_toggle()
    end, { description = "show or hide wibar(s)", group = "awesome" }),

    awful.key({ superkey, shiftkey }, "i", function()
        apps.browser()
    end, { description = "google", group = "launcher" }),

    -- Spotify scratchpad
    awful.key({ superkey, shiftkey }, "s", function()
        awesome.emit_signal "scratch::spotify"
    end, { description = "Toggle music scratchpad", group = "Bling" }),

    awful.key({ superkey, shiftkey }, "n", function(c)
        apps.notion()
    end, { description = "notion", group = "launcher" }),

    awful.key({ superkey, shiftkey }, "a", function(c)
        apps.anki()
    end, { description = "anki", group = "launcher" }),

    awful.key({ superkey, shiftkey }, "p", function()
        apps.scratchpad()
    end, { description = "scratchpad", group = "launcher" }),
    awful.key({ superkey, shiftkey }, "o", function()
        awful.spawn.with_shell "code"
    end, { description = "open VScode", group = "launcher" }),

    awful.key({ superkey }, "F12", function()
        awful.spawn.with_shell "farge --no-preview --notify --expire-time 2000"
    end, { description = "color picker !!", group = "launcher" }),
    awful.key({ superkey }, "F10", function()
        awful.spawn.with_shell "class"
    end, { description = "show class of program !!", group = "launcher" }),
    awful.key({}, "XF86Favorites", function()
        awful.spawn.with_shell "notflix"
    end, { description = "netflix and chill!!", group = "launcher" }),
    awful.key({ superkey }, "F11", function()
        awful.spawn.with_shell "fdoc"
    end, { description = "open Document!", group = "launcher" }),

    awful.key(
        { ctrlkey, shiftkey },
        "Escape",
        apps.process_monitor,
        { description = "process monitor", group = "launcher" }
    ),

    awful.key({ superkey }, "F5", apps.mail, { description = "open email client!", group = "launcher" }),

    -- Dashboard
    awful.key({ superkey }, "F1", function()
        if dashboard_show then
            dashboard_show()
        end
    end, { description = "dashboard", group = "awesome" }),

    awful.key({ superkey }, "p", function()
        F.action.toggle()
    end, { description = "notif", group = "awesome" }),

    -- App drawer
    -- awful.key({ superkey }, "a", function()
    --     app_drawer_show()
    -- end, { description = "App drawer", group = "awesome" }),

    -- Spawn file manager
    awful.key({ superkey }, "F2", apps.file_manager, { description = "file manager", group = "launcher" }),
    -- Spawn music client
    awful.key({ superkey }, "F3", apps.music, { description = "music client", group = "launcher" }),
    -- Spawn cava in a terminal
    awful.key({ superkey }, "F4", function()
        awful.spawn "visualizer"
    end, { description = "cava", group = "launcher" }),
    -- Quick edit file
    awful.key({ superkey }, "F9", function()
        awful.spawn.with_shell "rofi_edit"
    end, { description = "quick edit file", group = "launcher" }),
    -- Spawn file manager
    awful.key({ superkey, shiftkey }, "f", apps.file_manager, { description = "file manager", group = "launcher" })
)

keys.clientkeys = gears.table.join(
    -- Move to edge or swap by direction
    awful.key({ superkey, shiftkey }, "Down", function(c)
        helpers.move_client_dwim(c, "down")
    end),
    awful.key({ superkey, shiftkey }, "Up", function(c)
        helpers.move_client_dwim(c, "up")
    end),
    awful.key({ superkey, shiftkey }, "Left", function(c)
        helpers.move_client_dwim(c, "left")
    end),
    awful.key({ superkey, shiftkey }, "Right", function(c)
        helpers.move_client_dwim(c, "right")
    end),
    awful.key({ superkey, shiftkey }, "j", function(c)
        helpers.move_client_dwim(c, "down")
    end),
    awful.key({ superkey, shiftkey }, "k", function(c)
        helpers.move_client_dwim(c, "up")
    end),
    awful.key({ superkey, shiftkey }, "h", function(c)
        helpers.move_client_dwim(c, "left")
    end),
    awful.key({ superkey, shiftkey }, "l", function(c)
        helpers.move_client_dwim(c, "right")
    end),

    -- Single tap: Center client
    -- Double tap: Center client + Floating + Resize
    awful.key({ superkey }, "c", function(c)
        awful.placement.centered(c, { honor_workarea = true, honor_padding = true })
        helpers.single_double_tap(nil, function()
            helpers.float_and_resize(c, screen_width * 0.65, screen_height * 0.7)
        end)
    end),

    awful.key({ superkey }, "m", function(c)
        c:move_to_screen()
    end, { description = "move running now client to next screen", group = "screen" }),
    -- Relative move client
    awful.key({ superkey, shiftkey, ctrlkey }, "j", function(c)
        c:relative_move(0, dpi(20), 0, 0)
    end),
    awful.key({ superkey, shiftkey, ctrlkey }, "k", function(c)
        c:relative_move(0, dpi(-20), 0, 0)
    end),
    awful.key({ superkey, shiftkey, ctrlkey }, "h", function(c)
        c:relative_move(dpi(-20), 0, 0, 0)
    end),
    awful.key({ superkey, shiftkey, ctrlkey }, "l", function(c)
        c:relative_move(dpi(20), 0, 0, 0)
    end),
    awful.key({ superkey, shiftkey, ctrlkey }, "Down", function(c)
        c:relative_move(0, dpi(20), 0, 0)
    end),
    awful.key({ superkey, shiftkey, ctrlkey }, "Up", function(c)
        c:relative_move(0, dpi(-20), 0, 0)
    end),
    awful.key({ superkey, shiftkey, ctrlkey }, "Left", function(c)
        c:relative_move(dpi(-20), 0, 0, 0)
    end),
    awful.key({ superkey, shiftkey, ctrlkey }, "Right", function(c)
        c:relative_move(dpi(20), 0, 0, 0)
    end),

    -- Toggle titlebars (for focused client only)
    awful.key({ superkey }, "t", function(c)
        decorations.cycle(c)
    end, { description = "toggle titlebar", group = "client" }),

    -- Toggle fullscreen
    awful.key({ superkey }, "f", function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end, { description = "toggle fullscreen", group = "client" }),

    -- F for focused view
    awful.key({ superkey, ctrlkey }, "f", function(c)
        helpers.float_and_resize(c, screen_width * 0.7, screen_height * 0.75)
    end, { description = "resize client to focus mode", group = "client" }),

    -- N for normal size (good for terminals)
    awful.key({ superkey, ctrlkey }, "n", function(c)
        helpers.float_and_resize(c, screen_width * 0.45, screen_height * 0.5)
    end, { description = "resize client to normal mode (small than focus)", group = "client" }),

    -- Close client
    awful.key({ superkey }, "q", function(c)
        c:kill()
    end, { description = "close", group = "client" }),

    -- Toggle floating
    awful.key({ superkey }, "space", function(c)
        local layout_is_floating = (awful.layout.get(mouse.screen) == awful.layout.suit.floating)
        if not layout_is_floating then
            awful.client.floating.toggle()
        end
    end, { description = "toggle floating", group = "client" }),

    -- Change client opacity
    awful.key({ superkey, shiftkey }, "Down", function(c)
        c.opacity = c.opacity - 0.1
    end, { description = "decrease client opacity", group = "client" }),
    awful.key({ superkey, shiftkey }, "Up", function(c)
        c.opacity = c.opacity + 0.1
    end, { description = "increase client opacity", group = "client" }),

    -- toggle client on top
    awful.key({ altkey }, "t", function(c)
        c.ontop = not c.ontop
    end, { description = "toggle keep on top", group = "client" }),

    awful.key({ altkey, shiftkey }, "t", function(c)
        c.sticky = not c.sticky
    end, { description = "toggle sticky", group = "client" }),

    -- Minimize
    awful.key({ superkey }, "Down", function(c)
        c.minimized = true
    end, { description = "minimize", group = "client" }),

    -- Maximize
    awful.key({ superkey }, "Up", function(c)
        c.maximized = not c.maximized
    end, { description = "(un)maximize", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
local ntags = 3
for i = 1, ntags do
    keys.globalkeys = gears.table.join(
        keys.globalkeys,
        -- View tag only.
        awful.key({ superkey }, "#" .. i + 9, function()
            -- Tag back and forth
            helpers.tag_back_and_forth(i)
        end, { description = "view tag #" .. i, group = "tag" }),

        -- Move client to tag.
        awful.key({ superkey, shiftkey }, "#" .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, { description = "move focused client to tag #" .. i, group = "tag" })
    )
end

keys.globalkeys = gears.table.join(
    keys.globalkeys,
    awful.key({ superkey }, 8, function()
        helpers.tag_back_and_forth(4)
    end),

    awful.key({ superkey }, 9, function()
        helpers.tag_back_and_forth(5)
    end),
    awful.key({ superkey }, 0, function()
        helpers.tag_back_and_forth(6)
    end),
    awful.key({ superkey, shiftkey }, 8, function()
        if client.focus then
            local tag = client.focus.screen.tags[4]
            if tag then
                client.focus:move_to_tag(tag)
            end
        end
    end),
    awful.key({ superkey, shiftkey }, 9, function()
        if client.focus then
            local tag = client.focus.screen.tags[5]
            if tag then
                client.focus:move_to_tag(tag)
            end
        end
    end),
    awful.key({ superkey, shiftkey }, 0, function()
        if client.focus then
            local tag = client.focus.screen.tags[6]
            if tag then
                client.focus:move_to_tag(tag)
            end
        end
    end)
)
-- Mouse buttons on the client (whole window, not just titlebar)
keys.clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        client.focus = c
    end),
    awful.button({ superkey }, 1, awful.mouse.client.move),
    -- awful.button({ superkey }, 2, function (c) c:kill() end),
    awful.button({ superkey }, 3, function(c)
        client.focus = c
        awful.mouse.client.resize(c)
        -- awful.mouse.resize(c, nil, {jump_to_corner=true})
    end),

    -- Super + scroll = Change client opacity
    awful.button({ superkey }, 4, function(c)
        c.opacity = c.opacity + 0.1
    end),
    awful.button({ superkey }, 5, function(c)
        c.opacity = c.opacity - 0.1
    end)
)

-- Mouse buttons on the tasklist
-- Use 'Any' modifier so that the same buttons can be used in the floating
-- tasklist displayed by the window switcher while the superkey is pressed
keys.tasklist_buttons = gears.table.join(
    awful.button({ "Any" }, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
                c.first_tag:view_only()
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
        end
    end),
    -- Middle mouse button closes the window (on release)
    awful.button({ "Any" }, 2, nil, function(c)
        c:kill()
    end),
    awful.button({ "Any" }, 3, function(c)
        c.minimized = true
    end),
    awful.button({ "Any" }, 4, function()
        awful.client.focus.byidx(-1)
    end),
    awful.button({ "Any" }, 5, function()
        awful.client.focus.byidx(1)
    end),

    -- Side button up - toggle floating
    awful.button({ "Any" }, 9, function(c)
        c.floating = not c.floating
    end),
    -- Side button down - toggle ontop
    awful.button({ "Any" }, 8, function(c)
        c.ontop = not c.ontop
    end)
)

-- Mouse buttons on a tag of the taglist widget
keys.taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t)
        -- t:view_only()
        helpers.tag_back_and_forth(t.index)
    end),
    awful.button({ superkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    -- awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({}, 3, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ superkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t)
        awful.tag.viewprev(t.screen)
    end),
    awful.button({}, 5, function(t)
        awful.tag.viewnext(t.screen)
    end)
)

-- Mouse buttons on the primary titlebar of the window
keys.titlebar_buttons = gears.table.join(
    -- Left button - move
    -- (Double tap - Toggle maximize) -- A little BUGGY
    awful.button({}, 1, function()
        local c = mouse.object_under_pointer()
        client.focus = c
        awful.mouse.client.move(c)
        -- local function single_tap()
        --   awful.mouse.client.move(c)
        -- end
        -- local function double_tap()
        --   gears.timer.delayed_call(function()
        --       c.maximized = not c.maximized
        --   end)
        -- end
        -- helpers.single_double_tap(single_tap, double_tap)
        -- helpers.single_double_tap(nil, double_tap)
    end),
    -- Middle button - close
    awful.button({}, 2, function()
        local c = mouse.object_under_pointer()
        c:kill()
    end),
    -- Right button - resize
    awful.button({}, 3, function()
        local c = mouse.object_under_pointer()
        client.focus = c
        awful.mouse.client.resize(c)
        -- awful.mouse.resize(c, nil, {jump_to_corner=true})
    end),
    -- Side button up - toggle floating
    awful.button({}, 9, function()
        local c = mouse.object_under_pointer()
        client.focus = c
        --awful.placement.centered(c,{honor_padding = true, honor_workarea=true})
        c.floating = not c.floating
    end),
    -- Side button down - toggle ontop
    awful.button({}, 8, function()
        local c = mouse.object_under_pointer()
        client.focus = c
        c.ontop = not c.ontop
        -- Double Tap - toggle sticky
        -- local function single_tap()
        --   c.ontop = not c.ontop
        -- end
        -- local function double_tap()
        --   c.sticky = not c.sticky
        -- end
        -- helpers.single_double_tap(single_tap, double_tap)
    end)
)

-- }}}

-- Set root (desktop) keys
root.keys(keys.globalkeys)
root.buttons(keys.desktopbuttons)

return keys
