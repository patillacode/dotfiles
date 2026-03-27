require 'mp.options'

local music_dir = os.getenv("HOME") .. "/media/music/oldhits"
local instrumentals_dir = os.getenv("HOME") .. "/media/music/oldhits/instrumentals"

local a_pressed_once = false
local keys_pressed = {}
local last_key = nil

function copy_to_music_handler(dst_dir)
    local src_file_name = mp.get_property('filename')
    local src_file_path = mp.get_property('path')
    local dst_file_name = src_file_name
    local dst_file_path = dst_dir .. "/" .. dst_file_name

    if os.execute("test -f " .. "\"" .. dst_file_path .. "\"") == 0
    then
        mp.osd_message("File already exists in " .. dst_dir .. " folder. Ignoring")
        return
    end
    local cp_cmd = "cp " .. "\"" .. src_file_path .. "\"" .. " \"" .. dst_file_path .. "\""
    os.execute(cp_cmd)
    mp.osd_message("Copied " .. src_file_path .. " to " .. dst_file_path)
    -- mp.command("playlist_next")
end

function check_double_tap(key)
    table.insert(keys_pressed, key)
    if #keys_pressed == 2 then
        if keys_pressed[1] == 'a' and keys_pressed[2] == 'a' then
            copy_to_music_handler(music_dir)
        elseif keys_pressed[1] == 'a' and keys_pressed[2] == 'i' then
            copy_to_music_handler(instrumentals_dir)
        end
        keys_pressed = {}
    else
        mp.add_timeout(0.3, function() keys_pressed = {} end)
    end
end

mp.add_key_binding("a", "check_double_tap_a", function() check_double_tap('a') end)
mp.add_key_binding("i", "check_double_tap_i", function() check_double_tap('i') end)
