if not modules then modules = { } end modules ['math-noa'] = {
    version   = 1.001,
    comment   = "companion to math-ini.tex",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

-- beware: this is experimental code and there will be a more
-- generic (attribute value driven) interface too but for the
-- moment this is ok

local utf = unicode.utf8

local set_attribute  = node.set_attribute
local has_attribute  = node.has_attribute
local mlist_to_hlist = node.mlist_to_hlist
local font_of_family = node.family_font
local fontdata       = fonts.ids

local format, rep  = string.format, string.rep
local utfchar, utfbyte = utf.char, utf.byte

noads = noads or { }

local trace_remapping  = false  trackers.register("math.remapping",  function(v) trace_remapping  = v end)
local trace_processing = false  trackers.register("math.processing", function(v) trace_processing = v end)
local trace_analyzing  = false  trackers.register("math.analyzing",  function(v) trace_analyzing  = v end)

local noad_ord               =  0
local noad_op_displaylimits  =  1
local noad_op_limits         =  2
local noad_op_nolimits       =  3
local noad_bin               =  4
local noad_rel               =  5
local noad_open              =  6
local noad_close             =  7
local noad_punct             =  8
local noad_inner             =  9
local noad_under             = 10
local noad_over              = 11
local noad_vcenter           = 12

-- obsolete:
--
--    math_ord       = node.id("ord")            -- attr nucleus sub sup
--    math_op        = node.id("op")             -- attr nucleus sub sup subtype
--    math_bin       = node.id("bin")            -- attr nucleus sub sup
--    math_rel       = node.id("rel")            -- attr nucleus sub sup
--    math_punct     = node.id("punct")          -- attr nucleus sub sup
--
--    math_open      = node.id("open")           -- attr nucleus sub sup
--    math_close     = node.id("close")          -- attr nucleus sub sup
--
--    math_inner     = node.id("inner")          -- attr nucleus sub sup
--    math_vcenter   = node.id("vcenter")        -- attr nucleus sub sup
--    math_under     = node.id("under")          -- attr nucleus sub sup
--    math_over      = node.id("over")           -- attr nucleus sub sup

local math_noad      = node.id("noad")           -- attr nucleus sub sup

local math_accent    = node.id("accent")         -- attr nucleus sub sup accent
local math_radical   = node.id("radical")        -- attr nucleus sub sup left degree
local math_fraction  = node.id("fraction")       -- attr nucleus sub sup left right

local math_box       = node.id("sub_box")        -- attr list
local math_sub       = node.id("sub_mlist")      -- attr list
local math_char      = node.id("math_char")      -- attr fam char
local math_text_char = node.id("math_text_char") -- attr fam char
local math_delim     = node.id("delim")          -- attr small_fam small_char large_fam large_char
local math_style     = node.id("style")          -- attr style
local math_choice    = node.id("choice")         -- attr display text script scriptscript
local math_fence     = node.id("fence")          -- attr subtype

local simple_noads = table.tohash {
    math_noad,
}

local all_noads = {
    math_noad,
    math_box, math_sub,
    math_char, math_text_char, math_delim, math_style,
    math_accent, math_radical, math_fraction, math_choice, math_fence,
}

noads.processors = noads.processors or { }

local function process(start,what,n)
    if n then n = n + 1 else n = 0 end
    while start do
        if trace_processing then
            texio.write_nl(format("%s%s",rep("  ",n or 0),tostring(start)))
        end
        local id = start.id
        local proc = what[id]
        if proc then
            proc(start,what,n)
        elseif id == math_char or id == math_text_char or id == math_delim then
            break
        elseif id == math_style then
            -- has a next
        elseif id == math_noad then
            local noad = start.nucleus      if noad then process(noad,what,n) end -- list
                  noad = start.sup          if noad then process(noad,what,n) end -- list
                  noad = start.sub          if noad then process(noad,what,n) end -- list
        elseif id == math_box or id == math_sub then
            local noad = start.list         if noad then process(noad,what,n) end -- list
        elseif id == math_fraction then
            local noad = start.num          if noad then process(noad,what,n) end -- list
                  noad = start.denom        if noad then process(noad,what,n) end -- list
                  noad = start.left         if noad then process(noad,what,n) end -- delimiter
                  noad = start.right        if noad then process(noad,what,n) end -- delimiter
        elseif id == math_choice then
            local noad = start.display      if noad then process(noad,what,n) end -- list
                  noad = start.text         if noad then process(noad,what,n) end -- list
                  noad = start.script       if noad then process(noad,what,n) end -- list
                  noad = start.scriptscript if noad then process(noad,what,n) end -- list
        elseif id == math_fence then
            local noad = start.delim        if noad then process(noad,what,n) end -- delimiter
        elseif id == math_radical then
            local noad = start.nucleus      if noad then process(noad,what,n) end -- list
                  noad = start.sup          if noad then process(noad,what,n) end -- list
                  noad = start.sub          if noad then process(noad,what,n) end -- list
                  noad = start.left         if noad then process(noad,what,n) end -- delimiter
                  noad = start.degree       if noad then process(noad,what,n) end -- list
        elseif id == math_accent then
            local noad = start.nucleus      if noad then process(noad,what,n) end -- list
                  noad = start.sup          if noad then process(noad,what,n) end -- list
                  noad = start.sub          if noad then process(noad,what,n) end -- list
                  noad = start.accent       if noad then process(noad,what,n) end -- list
                  noad = start.bot_accent   if noad then process(noad,what,n) end -- list
        else
            -- glue, penalty, etc
        end
        start = start.next
    end
end

noads.process = process

-- character remapping

local attribute = attributes.private("mathalph")

noads.processors.relocate = { }

local function report_remap(tag,id,old,new,extra)
    logs.report("math","remapping %s in font %s from U+%04X (%s) to U+%04X (%s)%s",tag,id,old,utfchar(old),new,utfchar(new),extra or "")
end

local remap_alphabets = mathematics.remap_alphabets
local fcs = fonts.color.set

noads.processors.relocate[math_char] = function(pointer)
    local a = has_attribute(pointer,attribute)
    if a and a > 0 then
        local fam = pointer.fam
        set_attribute(pointer,attribute,0)
        local char = pointer.char
        local newchar = remap_alphabets(a,char)
        if newchar then
            local id = font_of_family(fam)
            local tfmdata = fontdata[id]
            if tfmdata and tfmdata.characters[newchar] then -- we could probably speed this up
                if trace_remapping then
                    report_remap("char",id,char,newchar)
                end
                if trace_analyzing then
                    fcs(pointer,"font:isol")
                end
                pointer.char = newchar
                return
            elseif trace_remapping then
                report_remap("char",id,char,newchar," fails")
            end
        end
    end
    if trace_analyzing then
        fcs(pointer,"font:medi")
    end
end

noads.processors.relocate[math_text_char] = function(pointer)
    if trace_analyzing then
        fcs(pointer,"font:init")
    end
end

noads.processors.relocate[math_delim] = function(pointer)
    if trace_analyzing then
        fcs(pointer,"font:fina")
    end
end

function noads.relocate_characters(head,tail,style,penalties)
    process(head,noads.processors.relocate)
    return true
end

-- some resize options (this works ok because the content is
-- empty and no larger next will be forced)
--
-- beware: we don't use \delcode but \Udelcode and as such have
-- no large_fam; also, we need to check for subtype and/or
-- small_fam not being 0 because \. sits in 0,0 by default
--
-- todo: just replace the character by an ord noad
-- and remove the right delimiter as well

local attribute = attributes.private("mathsize")

noads.processors.resize = { }

noads.processors.resize[math_fence] = function(pointer)
    if pointer.subtype == 1 then -- left
        local a = has_attribute(pointer,attribute)
        if a and a > 0 then
            set_attribute(pointer,attribute,0)
            local d = pointer.delim
            local df = d.small_fam
            local id = font_of_family(df)
            if id > 0 then
                local ch = d.small_char
                d.small_char = mathematics.big(fontdata[id],ch,a)
            end
        end
    end
end

function noads.resize_characters(head,tail,style,penalties)
    process(head,noads.processors.resize)
    return true
end

-- respacing

local attribute = attributes.private("mathpunc")

noads.processors.respace = { }

local chardata = characters.data

-- only [nd,ll,ul][po][nd,ll,ul]

noads.processors.respace[math_noad] = function(pointer)
    if pointer.subtype == noad_ord then
        local a = has_attribute(pointer,attribute)
        if a and a > 0 then
            set_attribute(pointer,attribute,0)
            local current_nucleus = pointer.nucleus
            if current_nucleus.id == math_char then
                local current_char = current_nucleus.char
                local fc = chardata[current_char]
                if fc == "nd" or fc == "ll" or fc == "lu" then
                    local next_noad = pointer.next
                    if next_noad and next_noad.id == math_noad and next_noad.subtype == noad_punct then
                        local next_nucleus = next_noad.nucleus
                        if next_nucleus.id == math_char then
                            local next_char = next_nucleus.char
                            if chardata[next_char].category == "po" then
                                local last_noad = next_noad.next
                                if last_noad then
                                    local last_nucleus = last_noad.nucleus
                                    if last_nucleus.id == math_char then
                                        local last_char = last_nucleus.char
                                        local lc = chardata[first_char]
                                        if lc == "nd" or lc == "ll" or lc == "lu" then
                                            local ord = node.new(math_noad) -- todo: pool
                                            ord.subtype, ord.nucleus, ord.sub, ord.sup, ord.attr = noad_ord, next_noad.nucleus, next_noad.sub, next_noad.sup, next_noad.attr
                                        --  next_noad.nucleus, next_noad.sub, next_noad.sup, next_noad.attr = nil, nil, nil, nil
                                            next_noad.nucleus, next_noad.sub, next_noad.sup = nil, nil, nil -- else crash with attributes ref count
--~ next_noad.attr = nil
                                            ord.next = last_noad
                                            pointer.next = ord
                                            node.free(next_noad)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end


function noads.respace_characters(head,tail,style,penalties)
    noads.process(head,noads.processors.respace)
    return true
end

-- the normal builder

function noads.mlist_to_hlist(head,tail,style,penalties)
    return mlist_to_hlist(head,style,penalties), true
end

tasks.new (
    "math",
    {
        "normalizers",
        "builders",
    }
)

--~ tasks.appendaction("math", "normalizers", "noads.relocate_characters", nil, "nohead")
--~ tasks.appendaction("math", "normalizers", "noads.resize_characters",   nil, "nohead")
--~ tasks.appendaction("math", "normalizers", "noads.respace_characters",  nil, "nohead")
--~ tasks.appendaction("math", "builders",    "noads.mlist_to_hlist",      nil, "notail")

local actions = tasks.actions("math")

local starttiming, stoptiming = statistics.starttiming, statistics.stoptiming

function nodes.processors.mlist_to_hlist(head,style,penalties)
    starttiming(noads)
    local head, done = actions(head,nil,style,penalties)
    stoptiming(noads)
    return head, done
end

callback.register('mlist_to_hlist',nodes.processors.mlist_to_hlist)

-- tracing

statistics.register("math processing time", function()
    if statistics.elapsedindeed(noads) then
        return format("%s seconds", statistics.elapsedtime(noads))
    end
end)
