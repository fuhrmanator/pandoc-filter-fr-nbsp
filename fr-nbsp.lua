--- fr-nbsp.lua – add no-break spaces in French documents
---
--- Copyright: © 2022 Romain Lesur
--- License: MIT – see LICENSE for details

PANDOC_VERSION:must_be_at_least '2.9.2'


--- Copyright: © 2022 Christopher Fuhrman
--- License: MIT – see LICENSE for details
--- add non-breaking spaces according to high punctuation rules, similar to babel-french
local function space_high_punctuation_and_quotes(inlines)
    local i = 1
    while inlines[i] do
        if inlines[i].t == 'Str' then
            if string.len(inlines[i].text) > 1 and string.match(inlines[i].text:sub(-1), '[;!%?%%:]') then
                -- insert nbsp before last char
                inlines[i].text = inlines[i].text:sub(1, -2) .. '\u{202f}' .. inlines[i].text:sub(-1)
            end
            -- unicode is a problem in patterns, so we just brute force it?
            inlines[i].text = string.gsub(inlines[i].text, "€", '\u{202f}' .. "€")
            inlines[i].text = string.gsub(inlines[i].text, "»", '\u{202f}' .. "»")
            inlines[i].text = string.gsub(inlines[i].text, "«", "«" .. '\u{202f}')
        end
        -- quotes, citation
        if inlines[i+1] and (inlines[i].t == 'Quoted' or inlines[i].t == 'Cite') 
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
                inlines = space_high_punctuation_and_quotes(inlines)
                inlines = wrap_nnbsp_in_span(inlines)
                return inlines
            end
        }
    }
else
    return {
        {
            Inlines = function(inlines)
                inlines = space_high_punctuation_and_quotes(inlines)
                return inlines
            end
        }
    }
end
