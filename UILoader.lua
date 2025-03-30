-- UI Loader with enhanced error handling
local LoadUI = function()
    local uiUrl = "https://raw.githubusercontent.com/Pedalkis123/UISMAX/refs/heads/main/UI.lua"
    print("Attempting to load UI from: " .. uiUrl)
    
    -- Step 1: Fetch the content
    local fetchSuccess, content = pcall(function()
        return game:HttpGet(uiUrl)
    end)
    
    if not fetchSuccess then
        warn("Failed to fetch UI content: " .. tostring(content))
        error("HTTP request failed. Make sure HTTP requests are enabled.")
        return nil
    end
    
    print("Content fetched successfully! Length: " .. #content)
    
    -- Step 2: Load and execute the content
    local loadSuccess, result = pcall(function()
        return loadstring(content)()
    end)
    
    if not loadSuccess then
        warn("Failed to execute UI code: " .. tostring(result))
        error("UI library execution failed.")
        return nil
    end
    
    print("UI library loaded successfully!")
    return result
end

return LoadUI() 
