if not modules then modules = { } end modules ['math-ext'] = {
    version   = 1.001,
    comment   = "companion to math-ini.tex",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

-- if needed we can use the info here to set up xetex definition files
-- the "8000 hackery influences direct characters (utf) as indirect \char's

local texsprint, format, utfchar, utfbyte = tex.sprint, string.format, utf.char, utf.byte

local trace_defining = false  trackers.register("math.defining", function(v) trace_defining = v end)

mathematics = mathematics or { }

mathematics.extrabase   = 0xFE000 -- here we push some virtuals
mathematics.privatebase = 0xFF000 -- here we push the ex

--~ function mathematics.parameterset()
--~     return {
--~         quad = 0,
--~         axis = 0,
--~         overbarkern = 0,
--~         overbarrule = 0,
--~         overbarvgap = 0,
--~         underbarkern = 0,
--~         underbarrule = 0,
--~         underbarvgap = 0,
--~         radicalkern = 0,
--~         radicalrule = 0,
--~         radicalvgap = 0,
--~         stackvgap = 0,
--~         stacknumup = 0,
--~         stackdenomdown = 0,
--~         fractionrule = 0,
--~         fractionnumvgap = 0,
--~         fractionnumup = 0,
--~         fractiondenomvgap = 0,
--~         fractiondenomdown = 0,
--~         fractiondelsize = 0,
--~         limitabovevgap = 0,
--~         limitabovebgap = 0,
--~         limitabovekern = 0,
--~         limitbelowvgap = 0,
--~         limitbelowbgap = 0,
--~         limitbelowkern = 0,
--~         subshiftdrop = 0,
--~         supshiftdrop = 0,
--~         subshiftdown = 0,
--~         subsupshiftdown = 0,
--~         supshiftup = 0,
--~         subtopmax = 0,
--~         supbottommin = 0,
--~         supsubbottommax = 0,
--~         subsupvgap = 0,
--~         spaceafterscrip = 0,
--~     }
--~ end

local families = {
    tf = 1, it = 2, sl = 4, bf = 5, bi = 6, bs = 7, -- virtual fonts or unicode otf
}

local classes = {
    ord     =  0,  -- mathordcomm     mathord
    op      =  1,  -- mathopcomm      mathop
    bin     =  2,  -- mathbincomm     mathbin
    rel     =  3,  -- mathrelcomm     mathrel
    open    =  4,  -- mathopencomm    mathopen
    close   =  5,  -- mathclosecomm   mathclose
    punct   =  6,  -- mathpunctcomm   mathpunct
    alpha   =  7,  -- mathalphacomm   firstofoneargument
    accent  =  8,  -- class 0
    radical =  9,
    xaccent = 10,  -- class 3
    inner   =  0,  -- mathinnercomm   mathinner
    nothing =  0,  -- mathnothingcomm firstofoneargument
    choice  =  0,  -- mathchoicecomm  @@mathchoicecomm
    box     =  0,  -- mathboxcomm     @@mathboxcomm
    limop   =  1,  -- mathlimopcomm   @@mathlimopcomm
    nolop   =  1,  -- mathnolopcomm   @@mathnolopcomm
}

mathematics.families = families
mathematics.classes  = classes

classes.alphabetic  = classes.alpha
classes.unknown     = classes.nothing
classes.default     = classes.nothing
classes.punctuation = classes.punct
classes.normal      = classes.nothing
classes.opening     = classes.open
classes.closing     = classes.close
classes.binary      = classes.bin
classes.relation    = classes.rel
classes.fence       = classes.unknown
classes.diacritic   = classes.accent
classes.large       = classes.op
classes.variable    = classes.alphabetic
classes.number      = classes.alphabetic

-- there will be proper functions soon (and we will move this code in-line)

local function delcode(target,family,slot)
    return format('\\Udelcode%s="%X "%X ',target,family,slot)
end
local function mathchar(class,family,slot)
    return format('\\Umathchar "%X "%X "%X ',class,family,slot)
end
local function mathaccent(class,family,slot)
    return format('\\Umathaccent "%X "%X "%X ',0,family,slot) -- no class
end
local function delimiter(class,family,slot)
    return format('\\Udelimiter "%X "%X "%X ',class,family,slot)
end
local function radical(family,slot)
    return format('\\Uradical "%X "%X ',family,slot)
end
local function mathchardef(name,class,family,slot)
    return format('\\Umathchardef\\%s "%X "%X "%X ',name,class,family,slot)
end
local function mathcode(target,class,family,slot)
    return format('\\Umathcode%s="%X "%X "%X ',target,class,family,slot)
end

mathematics.delcode     = delcode
mathematics.radical     = radical
mathematics.mathchar    = mathchar
mathematics.mathaccent  = mathaccent
mathematics.delimiter   = delimiter
mathematics.mathchardef = mathchardef
mathematics.mathcode    = mathcode

local function setmathsymbol(name,class,family,slot)
    class = classes[class] or class -- no real checks needed
    family = families[family] or family
    if class == classes.accent then
        texsprint(format("\\unexpanded\\xdef\\%s{%s }",name,mathaccent(class,family,slot)))
    elseif class == classes.open or class == classes.close then
        texsprint(delcode(slot,family,slot))
        texsprint(format("\\xdef\\%s{%s }",name,delimiter(class,family,slot)))
    elseif class == classes.radical then
        texsprint(format("\\xdef\\%s{%s }",name,radical(family,slot)))
    else
        -- beware, open/close and other specials should not end up here
        local ch = utfchar(slot)
        if characters.filters.utf.private.escapes[ch] then
            texsprint(format("\\xdef\\%s{\\char%s }",name,slot))
        else
            texsprint(format("\\xdef\\%s{%s}",name,ch))
        end
    end
end

local function setmathcharacter(class,family,slot,unicode)
    class = classes[class] or class
    if class <= 7 then
        family = families[family] or family
        texsprint(mathcode(slot,class,family,unicode or slot))
    end
end

mathematics.setmathsymbol    = setmathsymbol
mathematics.setmathcharacter = setmathcharacter

local function report(class,family,unicode,name)
    local classname = mathematics.classes[class] or class
    local nametype = type(name)
    if nametype == "string" then
        logs.report("mathematics","%s:%s %s U+%05X (%s) => %s",classname,class,family,unicode,utfchar(unicode),name)
    elseif nametype == "number" then
        logs.report("mathematics","%s:%s %s U+%05X (%s) => U+%05X",classname,class,family,unicode,utfchar(unicode),name)
    else
        logs.report("mathematics","%s:%s %s U+%05X (%s)", classname,class,family,unicode,utfchar(unicode))
    end
end

-- there will be a combined \(math)chardef

function mathematics.define(slots,family)
    family = family or 1
    local data = characters.data
    for unicode, character in next, data do
        local symbol = character.mathsymbol
        if symbol then
            local class = data[symbol].mathclass
            if class then
                if trace_defining then
                    report(class,family,unicode,symbol)
                end
                setmathcharacter(class,family,unicode,symbol)
            end
        end
        local class = character.mathclass
        if class then
            local name = character.mathname
            if name == false then
                if trace_defining then
                    report(class,family,unicode,name)
                end
                setmathcharacter(class,family,unicode)
            else
                name = name or character.contextname
                if name then
                    if trace_defining then
                        report(class,family,unicode,name)
                    end
                    setmathsymbol(name,class,family,unicode)
                    setmathcharacter(class,family,unicode)
                else
                    if trace_defining then
                        report(class,family,unicode,character.adobename)
                    end
                    setmathcharacter(class,family,unicode)
                end
            end
        end
        local spec =character.mathspec
        if spec then
            for _, m in next, spec do
                local name = m.name
                local class = m.class
                if class then
                    if name then
                        if trace_defining then
                            report(class,family,unicode,name)
                        end
                        setmathsymbol(name,class,family,unicode)
                        setmathcharacter(class,family,unicode)
                    else
                        name = class == "variable" or class == "number" and character.adobename
                        if name then
                            if trace_defining then
                                report(class,family,unicode,name)
                            end
                            setmathcharacter(class,family,unicode)
                        end
                    end
                end
            end
        end
    end
end

function mathematics.utfmathclass(chr, default)
    local cd = characters.data[utfbyte(chr)]
    return (cd and cd.mathclass) or default or "unknown"
end
function mathematics.utfmathstretch(chr, default) -- "h", "v", "b", ""
    local cd = characters.data[utfbyte(chr)]
    return (cd and cd.mathstretch) or default or ""
end
function mathematics.utfmathcommand(chr, default)
    local cd = characters.data[utfbyte(chr)]
    local cmd = cd and cd.mathname
    tex.sprint(cmd or default or "")
end
function mathematics.utfmathfiller(chr, default)
    local cd = characters.data[utfbyte(chr)]
    local cmd = cd and (cd.mathfiller or cd.mathname)
    tex.sprint(cmd or default or "")
end

mathematics.entities = mathematics.entities or { }

function mathematics.register_xml_entities()
    local entities = xml.entities
    for name, unicode in pairs(mathematics.entities) do
        if not entities[name] then
            entities[name] = utfchar(unicode)
        end
    end
end

-- helpers

function mathematics.big(tfmdata,unicode,n)
    local t = tfmdata.characters
    local c = t[unicode]
    if c then
        local next = c.next
        while next do
            if n <= 1 then
                return next
            else
                n = n - 1
                next = t[next].next
            end
        end
    end
    return unicode
end
