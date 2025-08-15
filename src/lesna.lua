--
-- Lesna cesta
--

table.insert(html, "<h4>Lesna cesta</h4>")
table.insert(html, [[ <table style="margin-bottom: 1em; border-collapse: collapse;"> ]])

-- 1. nájdi 5 earth kešiek -- Earthcache
-- 2. nájdi 3 kešky s atribútom -- [63] = "Recommended for tourists"
-- 3. nájdi 5 kešiek s atribútom -- [8] = "Scenic view"
-- 4. nájdi 2 kešky s atribútom -- [57] = "Hike longer than 10km"
-- 5. založ fyzickú kešku

local c3_earth_caches_found = 0
local c3_tourist_caches_found = 0
local c3_scenic_caches_found = 0
local c3_hike_caches_found = 0
local c3_physical_cache_created = 0

for _, f in ipairs(finds) do
    if f.type == "Earthcache" then
        c3_earth_caches_found = c3_earth_caches_found + 1
    end

    if hasAttribute(f, 63) then
        c3_tourist_caches_found = c3_tourist_caches_found + 1
    end

    if hasAttribute(f, 8) then
        c3_scenic_caches_found = c3_scenic_caches_found + 1
    end

    if hasAttribute(f, 57) then
        c3_hike_caches_found = c3_hike_caches_found + 1
    end
end

for _, h in ipairs(hides) do
    if (h.type == "Traditional Cache" or h.type == "Multi-cache" or h.type == "Unknown Cache"
        or h.type == "Letterbox Hybrid" or h.type == "Wherigo Cache" or h.type == "Project APE Cache") then
        c3_physical_cache_created = c3_physical_cache_created + 1
    end
end

if c3_earth_caches_found >= 5 then
    table.insert(html, q(
        "check",
        "Find 5 Earth caches",
        string.format("You've found %d Earth caches(s)", c3_earth_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 5 Earth caches",
        string.format("You've found %d Earth caches(s)", c3_earth_caches_found)
    ))
end

if c3_tourist_caches_found >= 3 then
    table.insert(html, q(
        "check",
        "Find 3 caches with the 'Recommended for Tourists' attribute.",
        string.format("You've found %d cache(s) with the 'Recommended for Tourists' attribute.", c3_tourist_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 3 caches with the 'Recommended for Tourists' attribute.",
        string.format("You've found %d cache(s) with the 'Recommended for Tourists' attribute.", c3_tourist_caches_found)
    ))
end

if c3_scenic_caches_found >= 5 then
    table.insert(html, q(
        "check",
        "Find 5 caches with the 'Scenic View' attribute.",
        string.format("You've found %d cache(s) with the 'Scenic View' attribute.", c3_scenic_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 5 caches with the 'Scenic View' attribute.",
        string.format("You've found %d cache(s) with the 'Scenic View' attribute.", c3_scenic_caches_found)
    ))
end

if c3_hike_caches_found >= 2 then
    table.insert(html, q(
        "check",
        "Find 2 caches with the 'Hike longer than 10km' attribute.",
        string.format("You've found %d cache(s) with the 'Hike longer than 10km' attribute.", c3_hike_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 2 caches with the 'Hike longer than 10km' attribute.",
        string.format("You've found %d cache(s) with the 'Hike longer than 10km' attribute.", c3_hike_caches_found)
    ))
end

if c3_physical_cache_created >=1 then
    table.insert(html, q(
        "check",
        "Create a physical cache.",
        string.format("You've placed %d physical caches", c3_physical_cache_created)
    ))
else
    table.insert(html, q(
        "cancel",
        "Create a physical cache.",
        string.format("You've placed %d physical caches", c3_physical_cache_created)
    ))
end

table.insert(html, [[ </table> ]])
