-- UILoader: A robust loader for SMAX V2 UI Library
-- This module handles fetching, loading, and error reporting for the UI library

-- Define the UI URL
local UI_URL = "https://raw.githubusercontent.com/Pedalkis123/UISMAX/refs/heads/main/UI.lua"

-- Create a module that returns the UI library
local UILoader = {}

-- Main loading function
local function LoadUI()
    -- Step 1: Print loading message with timestamp
    local timestamp = os.date("%H:%M:%S")
    print(timestamp .. " -- Loading UI library from GitHub...")
    
    -- Step 2: Attempt to fetch the content with error handling
    local success, content
    success, content = pcall(function()
        return game:HttpGet(UI_URL)
    end)
    
    -- Handle fetch errors
    if not success then
        warn(timestamp .. " -- Failed to fetch UI library: " .. tostring(content))
        error("HTTP GET failed. Verify HTTP requests are enabled in game settings.")
        return nil
    end
    
    -- Step 3: Validate content
    if not content or #content < 100 then
        warn(timestamp .. " -- Invalid UI content received (too short or empty)")
        error("Retrieved content appears invalid. The GitHub URL may be incorrect.")
        return nil
    end
    
    -- Step 4: Execute the content
    local execSuccess, result
    execSuccess, result = pcall(function()
        return loadstring(content)()
    end)
    
    -- Handle execution errors
    if not execSuccess then
        warn(timestamp .. " -- Failed to execute UI code: " .. tostring(result))
        error("UI library execution failed. The library may have syntax errors.")
        return nil
    end
    
    -- Success!
    print(timestamp .. " -- UI library loaded successfully!")
    return result
end

-- Return the loaded UI
return LoadUI() 
