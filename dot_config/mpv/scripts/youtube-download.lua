require 'mp.options'

local downloads_dir = os.getenv("HOME") .. "/Downloads/"
local keys_pressed = {}
local last_key = nil

function youtube_downloads_handler(type)
    local src_file_path = mp.get_property('path')

    local output_format = downloads_dir .. "\"%(title)s.%(ext)s\""
    local youtube_dl_cmd = "yt-dlp -S vcodec:h264 -f \"bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best\" -o " ..
    output_format
    -- local youtube_dl_cmd = "yt-dlp -f 'bv*[height=1080][ext=mp4]+ba' -o " .. output_format
    if type == "audio" then
        youtube_dl_cmd = youtube_dl_cmd .. " -x --audio-format mp3"
    end

    youtube_dl_cmd = youtube_dl_cmd .. " " .. src_file_path
    os.execute(youtube_dl_cmd)
    if type == "video" then
        mp.osd_message("Video downloaded!")
    else
        mp.osd_message("Audio downloaded!")
    end
end

function check_double_tap(key)
    table.insert(keys_pressed, key)
    if #keys_pressed == 2 then
        if keys_pressed[1] == 'd' and keys_pressed[2] == 'd' then
            youtube_downloads_handler('video')
        elseif keys_pressed[1] == 'd' and keys_pressed[2] == 'a' then
            youtube_downloads_handler('audio')
        end
        keys_pressed = {}
    else
        mp.add_timeout(0.3, function() keys_pressed = {} end)
    end
end

mp.add_key_binding("d", "check_double_tap_d", function() check_double_tap('d') end)
mp.add_key_binding("a", "check_double_tap_a", function() check_double_tap('a') end)
