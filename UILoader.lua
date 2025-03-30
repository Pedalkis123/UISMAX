-- Simple UI Loader
-- This is a minimalist loader that directly loads the UI library with minimal error handling

-- Create the loader function
local function LoadUI()
    -- Set the URL to load from (use main branch, not refs/heads)
    local url = "https://raw.githubusercontent.com/Pedalkis123/UISMAX/main/UI.lua"
    
    print("Loading UI library from: " .. url)
    
    -- Attempt to load
    local content = game:HttpGet(url)
    
    -- Execute the script
    return loadstring(content)()
end

-- Return the loaded UI
return LoadUI() 
