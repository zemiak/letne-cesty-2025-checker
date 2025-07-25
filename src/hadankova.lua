--
-- Hadankova cesta
--

table.insert(html, "<h4>Hadankova cesta</h4>")
table.insert(html, [[ <table style="margin-bottom: 1em; border-collapse: collapse;"> ]])

-- 1. nájdi 5 mystery kešiek bez atribútu Challenge Cache -- [71] = "Challenge cache"
-- 2. nájdi 3 challenge kešky, ktoré spĺňaš -- [71] = "Challenge cache"
-- 3. nájdi 5 multi kešiek -- Multi-cache
-- 4. nájdi 2 kešky typu Whereigo alebo Letterbox -- Wherigo Cache, Letterbox Hybrid
-- 5. založ mystery kešku -- Unknown Cache

local c2_mystery_caches_found = 0
local c2_challenge_caches_found = 0
local c2_multi_caches_found = 0
local c2_whereigo_letterbox_caches_found = 0
local c2_mystery_hides = 0

for _, f in ipairs(finds) do
    if ((not testAttribute(f, 71)) and f.type == "Unknown Cache") then
        c2_mystery_caches_found = c2_mystery_caches_found + 1
    end

    if testAttribute(f, 71) then
        c2_challenge_caches_found = c2_challenge_caches_found + 1
    end

    if f.type == "Multi-cache" then
        c2_multi_caches_found = c2_multi_caches_found + 1
    end

    if (f.type == "Wherigo Cache" or f.type == "Letterbox Hybrid") then
        c2_whereigo_letterbox_caches_found = c2_whereigo_letterbox_caches_found + 1
    end
end

for _, h in ipairs(hides) do
    if (f.type == "Unknown Cache") then
        c2_mystery_hides = c2_mystery_hides + 1
    end
end

if c2_mystery_caches_found >= 5 then
    table.insert(html, q(
        "check",
        "Find 5 Mystery Caches, not Challenges.",
        string.format("You've found %d Mystery Caches, not Challenges", c2_mystery_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 5 Mystery Caches, not Challenges.",
        string.format("You've found %d Mystery Caches, not Challenges", c2_mystery_caches_found)
    ))
end

if c2_challenge_caches_found >= 3 then
    table.insert(html, q(
        "check",
        "Find 3 Challenge Caches that you qualify for.",
        string.format("You've found %d Challenge Caches that you qualify for", c2_challenge_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 3 Challenge Caches that you qualify for.",
        string.format("You've found %d Challenge Caches that you qualify for", c2_challenge_caches_found)
    ))
end

if c2_multi_caches_found >= 5 then
    table.insert(html, q(
        "check",
        "Find 5 Multi Caches.",
        string.format("You've found %d Multi Caches", c2_multi_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 5 Multi Caches.",
        string.format("You've found %d Multi Caches", c2_multi_caches_found)
    ))
end

if c2_whereigo_letterbox_caches_found >= 2 then
    table.insert(html, q(
        "check",
        "Find 2 Whereigo or Letterbox Caches.",
        string.format("You've found %d Whereigo or Letterbox Caches", c2_whereigo_letterbox_caches_found)
    ))
else
    table.insert(html, q(
        "cancel",
        "Find 2 Whereigo or Letterbox Caches.",
        string.format("You've found %d Whereigo or Letterbox Caches", c2_whereigo_letterbox_caches_found)
    ))
end

if c2_mystery_hides >= 1 then
    table.insert(html, q(
        "check",
        "Place a Mystery Cache.",
        string.format("You've placed %d Mystery Caches", c2_mystery_hides)
    ))
else
    table.insert(html, q(
        "cancel",
        "Place a Mystery Cache.",
        string.format("You've placed %d Mystery Caches", c2_mystery_hides)
    ))
end

table.insert(html, [[ </table> ]])
