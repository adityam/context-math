if not modules then modules = { } end modules ['math-noa'] = {
    version   = 1.001,
    comment   = "companion to math-ini.tex",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

local set_attribute  = node.set_attribute
local has_attribute  = node.has_attribute
local mlist_to_hlist = node.mlist_to_hlist
local font_of_family = node.family_font
local fontdata       = fonts.tfm.id

local format, rep  = string.format, string.rep
local utfchar, utfbyte = utf.char, utf.byte

noads = noads or { }

local trace_remapping  = false  trackers.register("math.remapping",  function(v) trace_remapping  = v end)
local trace_processing = false  trackers.register("math.processing", function(v) trace_processing = v end)
local trace_analyzing  = false  trackers.register("math.analyzing",  function(v) trace_analyzing  = v end)

local math_ord       = node.id("ord")            -- attr nucleus sub sup
local math_op        = node.id("op")             -- attr nucleus sub sup subtype
local math_bin       = node.id("bin")            -- attr nucleus sub sup
local math_rel       = node.id("rel")            -- attr nucleus sub sup
local math_punct     = node.id("punct")          -- attr nucleus sub sup

local math_open      = node.id("open")           -- attr nucleus sub sup
local math_close     = node.id("close")          -- attr nucleus sub sup

local math_inner     = node.id("inner")          -- attr nucleus sub sup
local math_vcenter   = node.id("vcenter")        -- attr nucleus sub sup
local math_under     = node.id("under")          -- attr nucleus sub sup
local math_over      = node.id("over")           -- attr nucleus sub sup

local math_accent    = node.id("accent")         -- attr nucleus sub sup accent
local math_radical   = node.id("radical")        -- attr nucleus sub sup left
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
    math_ord, math_op, math_bin, math_rel, math_punct,
    math_open, math_close,
    math_inner, math_vcenter, math_under, math_over,
}

local all_noads = {
    math_ord, math_op, math_bin, math_rel, math_open, math_close, math_punct, math_inner, math_vcenter, math_under, math_over,
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
        elseif simple_noads[id] then
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
        elseif id == math_accent then
            local noad = start.nucleus      if noad then process(noad,what,n) end -- list
                  noad = start.sup          if noad then process(noad,what,n) end -- list
                  noad = start.sub          if noad then process(noad,what,n) end -- list
                  noad = start.accent       if noad then process(noad,what,n) end -- list
        else
            -- glue, penalty, etc
        end
        start = start.next
    end
end

noads.process = process

local attribute = attributes.numbers["mathalph"] or 240 -- brr

noads.processors.relocate = { }

local function report_remap(tag,old,new,extra)
    logs.report("math","remapping %s from U+%04X (%s) to U+%04X (%s)%s",tag,old,utfchar(old),new,utfchar(new),extra or "")
end

local remap_alphabets = mathematics.remap_alphabets
local fcs = fonts.color.set

noads.processors.relocate[math_char] = function(pointer)
    local a = has_attribute(pointer,attribute)
    if a and a > 0 then
        local fam = pointer.fam
        if fam ~= 3 then -- this will change
            set_attribute(pointer,attribute,0)
            local char = pointer.char
            local newchar = remap_alphabets(a,char)
            if newchar then
                local id = font_of_family(fam)
                if fontdata[id].characters[newchar] then -- we could probably speed this up
                    if trace_remapping then
                        report_remap("char",char,newchar)
                    end
                    if trace_analyzing then
                        fcs(pointer,"font:isol")
                    end
                    pointer.char = newchar
                    return
                elseif trace_remapping then
                    report_remap("char",char,newchar," fails")
                end
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

function noads.mlist_to_hlist(head,tail,style,penalties)
    return mlist_to_hlist(head,style,penalties), true
end

nodes.tasks.new (
    "math",
    {
        "normalizers",
        "builders",
    }
)

nodes.tasks.appendaction("math", "normalizers", "noads.relocate_characters", nil, "nohead")
nodes.tasks.appendaction("math", "builders", "noads.mlist_to_hlist", nil, "notail")

local actions = nodes.tasks.actions("math")

local starttiming, stoptiming = input.starttiming, input.stoptiming

function nodes.processors.mlist_to_hlist(head,style,penalties)
    starttiming(noads)
    local head, done = actions(head,nil,style,penalties)
    stoptiming(noads)
    return head, done
end

callback.register('mlist_to_hlist',nodes.processors.mlist_to_hlist)
