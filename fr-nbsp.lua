--- fr-nbsp.lua – add no-break spaces in French documents
---
--- Copyright: © 2022 Romain Lesur
--- License: MIT – see LICENSE for details

PANDOC_VERSION:must_be_at_least '2.9.2'


local function space_high_punctuation(inlines)
    local i = 1
    while inlines[i] do
        if inlines[i].t == 'Str' then
            -- print('[debug] ' .. inlines[i].text)
            -- inlines[i].text = inlines[i].text:gsub("[;:€%?!%%]", "\u{202f}%1")
            -- inlines[i].text = inlines[i].text:gsub("\u{00ab}", "%1\u{202f}")
            -- ends with high punctuation
            if string.len(inlines[i].text) > 1 and string.match(inlines[i].text:sub(-1), '[;!%?%%:]') then
                -- insert nbsp before last char
                inlines[i].text = inlines[i].text:sub(1, -2) .. '\u{202f}' .. inlines[i].text:sub(-1)
            end
            -- unicode is a problem in patterns, so we just brute force it?
            inlines[i].text = string.gsub(inlines[i].text, "€", '\u{202f}' .. "€")
            inlines[i].text = string.gsub(inlines[i].text, "»", '\u{202f}' .. "»")
            inlines[i].text = string.gsub(inlines[i].text, "«", "«" .. '\u{202f}')
            -- print('[debug] ' .. inlines[i].text)
        end
        -- check for ':' after quoted text
        -- print('[debug] i:' .. inlines[i].t)
        -- if inlines[i+1] then 
        --     print('[debug] i+1:' .. inlines[i+1].t)
        -- end
        if inlines[i+1] and inlines[i].t == 'Quoted' 
            and inlines[i+1].t == 'Str' 
            and inlines[i+1].text:match('[;!%?%%:]') then
                inlines[i+1].text = '\u{202f}' .. inlines[i+1].text
            -- skip the item we just spaced
            i = i + 1
        end
        i = i + 1
    end
    return inlines
end

local function add_non_breaking_spaces(inlines)
    local i = 1
    
    while inlines[i+2] do
        if inlines[i].t == 'Str' and inlines[i+1].t == 'Space' and inlines[i+2].t == 'Str' then
            if string.match(inlines[i+2].text,  '^[;!%?%%:€]')
            or string.match(inlines[i].text, '%d$') and string.match(inlines[i+2].text, '^%d%d%d[^%d]*')
            or string.match(inlines[i].text, '°$') and string.match(inlines[i+2].text, '^%d')
            or string.match(inlines[i].text, '[+-]$') and string.match(inlines[i+2].text, '^%d') then
                inlines[i].text = inlines[i].text .. '\u{202f}' .. inlines[i+2].text
                inlines:remove(i+2)
                inlines:remove(i+1)
            elseif string.match(inlines[i].text, '%d$') and string.match(inlines[i+2].text, '^ans.*$')
            or string.match(inlines[i].text, '%d$') and string.match(inlines[i+2].text, '^mill.*$')
            or string.match(inlines[i].text, '%d$') and string.match(inlines[i+2].text, '^point.*$')
            or string.match(inlines[i].text, '%d$') and string.match(inlines[i+2].text, '^ETP.*$') then
                inlines[i].text = inlines[i].text .. '\u{00a0}' .. inlines[i+2].text
                inlines:remove(i+2)
                inlines:remove(i+1)
            else
                i = i+1
            end
        else
            i = i+1
        end
    end
  
    return inlines
end

--- For HTML output, since the Narrow No-Break Spaces (U+202F) are not well supported
--- by browsers (they are breakable), use this solution: https://stackoverflow.com/a/1570664
--- We replace nnbsp with &thinsp; and embed them in spans with white-space:nowrap styling.
--- Detecting U+202F in Lua is tricky bc of its unicode support in string matching.
--- We must detect bytes corresponding to U+202F encoded in UTF8 (226 128 175 in decimals)
local function wrap_nnbsp_in_span(inlines)
    for i = 1, #inlines, 1 do
        if inlines[i].t == 'Str' and string.match(inlines[i].text, '\226\128\175') then
            inlines[i] = pandoc.RawInline('html', "<span style='white-space:nowrap'>" .. string.gsub(inlines[i].text, '\226\128\175', '&thinsp;') .. '</span>')
        end
    end
    return inlines
end


if FORMAT:match 'html' or FORMAT:match 'html5' then
    return {
        {
            Inlines = function(inlines)
                inlines = space_high_punctuation(inlines)
                inlines = wrap_nnbsp_in_span(inlines)
                return inlines
            end
        }
    }
else
    return {
        {
            Inlines = function(inlines)
                inlines = space_high_punctuation(inlines)
                return inlines
            end
        }
    }
end
