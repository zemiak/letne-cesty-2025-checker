--
-- Mestska cesta
--

-- 1. nájdi 5 kešiek s atribútom Public Transportation Nearby -- [26] = "Public transit available"
-- 2. nájdi 3 kešky s atribútom Stroller Accessible -- [41] = "Stroller-accessible"
-- 3. nájdi 5 kešiek s atribútom Bicycles -- [32] = "Bikes allowed"
-- 4. nájdi 2 kešky s atribútom Food Nearby -- [59] = "Food nearby"
-- 5. založ event

table.insert(html, "<h4>Mestska cesta</h4>")
table.insert(html, [[ <table style="margin-bottom: 1em; border-collapse: collapse;"> ]])

local c1_public_transit_caches_found = 0
local c1_stroller_accessible_caches_found = 0
local c1_bicycles_caches_found = 0
local c1_food_nearby_caches_found = 0
local c1_events_placed = 0

for _, f in ipairs(finds) do
    if testAttribute(f, 26) then
        c1_public_transit_caches_found = c1_public_transit_caches_found + 1
    end

    if testAttribute(f, 41) then
        c1_stroller_accessible_caches_found = c1_stroller_accessible_caches_found + 1
    end

    if testAttribute(f, 32) then
        c1_bicycles_caches_found = c1_bicycles_caches_found + 1
    end

    if testAttribute(f, 59) then
        c1_food_nearby_caches_found = c1_food_nearby_caches_found + 1
    end
end

for _, h in ipairs(hides) do
    if (f.type == "Event Cache" or f.type == "Cache In Trash Out Event" or f.type == "Lost and Found Event Cache"
        or f.type == "Mega-Event Cache" or f.type == "Giga-Event Cache" or f.type == "Groundspeak Block Party") then
        c1_events_placed = c1_events_placed + 1
    end
end

if c1_public_transit_caches_found >= 5 then
    table.insert(html, q(
        "check",
        "Find 5 caches with the 'Public Transportation Nearby' attribute.",
        string.format("You've found %d cache(s) with the 'Public Transportation Nearby' attribute.", c1_public_transit_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 5 caches with the 'Public Transportation Nearby' attribute.",
        string.format("You've found %d cache(s) with the 'Public Transportation Nearby' attribute.", c1_public_transit_caches_found)
    ))
end

if c1_stroller_accessible_caches_found >= 3 then
    table.insert(html, q(
        "check",
        "Find 3 caches with the 'Stroller Accessible' attribute.",
        string.format("You've found %d cache(s) with the 'Stroller Accessible' attribute.", c1_stroller_accessible_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 3 caches with the 'Stroller Accessible' attribute.",
        string.format("You've found %d cache(s) with the 'Stroller Accessible' attribute.", c1_stroller_accessible_caches_found)
    ))
end

if c1_bicycles_caches_found >= 5 then
    table.insert(html, q(
        "check",
        "Find 5 caches with the 'Bicycles' attribute.",
        string.format("You've found %d cache(s) with the 'Bicycles' attribute.", c1_bicycles_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 5 caches with the 'Bicycles' attribute.",
        string.format("You've found %d cache(s) with the 'Bicycles' attribute.", c1_bicycles_caches_found)
    ))
end

if c1_food_nearby_caches_found >= 2 then
    table.insert(html, q(
        "check",
        "Find 2 caches with the 'Food Nearby' attribute.",
        string.format("You've found %d cache(s) with the 'Food Nearby' attribute.", c1_food_nearby_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 2 caches with the 'Food Nearby' attribute.",
        string.format("You've found %d cache(s) with the 'Food Nearby' attribute.", c1_food_nearby_caches_found)
    ))
end

if c1_events_placed >= 1 then
    table.insert(html, q(
        "check",
        "Place an event cache.",
        string.format("You've placed %d event(s).", c1_events_placed)
    ))
else
    table.insert(html, q(
        "cancel",
        "Place an event cache.",
        string.format("You've placed %d event(s).", c1_events_placed)
    ))
end

table.insert(html, [[ </table> ]])
