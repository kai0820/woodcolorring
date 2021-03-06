
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = true

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = true

-- for module display
CC_DESIGN_RESOLUTION = {
    width = 720,
    height = 1280,
    autoscale = "SHOW_ALL",
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        local x_scale = framesize.width / 720
        local y_scale = framesize.height / 1280
        if x_scale < y_scale then
            return { autoscale = "FIXED_WIDTH" }
        else
            return { autoscale = "FIXED_HEIGHT" }
        end
    end
}
