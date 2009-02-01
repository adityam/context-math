if not modules then modules = { } end modules ['math-ini'] = {
    version   = 1.001,
    comment   = "companion to math-ini.tex",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

-- if needed we can use the info here to set up xetex definition files
-- the "8000 hackery influences direct characters (utf) as indirect \char's

--~ % \definemathcharacter [(]   [nothing] [mr] ["28] [ex] ["00]
--~ % \definemathcharacter [)]   [nothing] [mr] ["29] [ex] ["01]
--~ % \definemathcharacter [91]  [nothing] [mr] ["5B] [ex] ["02] % [
--~ % \definemathcharacter [93]  [nothing] [mr] ["5D] [ex] ["03] % ]
--~ % \definemathcharacter [<]   [nothing] [sy] ["68] [ex] ["0A]
--~ % \definemathcharacter [>]   [nothing] [sy] ["69] [ex] ["0B]
--~ % \definemathcharacter [/]   [nothing] [mr] ["2F] [ex] ["0E]
--~ % \definemathcharacter [124] [nothing] [sy] ["6A] [ex] ["0C] % |
--~ % \definemathcharacter [92]  [nothing] [sy] ["6E] [ex] ["0F] % \

--~ % \definemathsymbol [lmoustache]  [open]    [ex] ["7A] [ex] ["40]
--~ % \definemathsymbol [rmoustache]  [close]   [ex] ["7B] [ex] ["41]
--~ % \show\lgroup]      [open]    [mr] ["28] [ex] ["3A] % ?
--~ % \show\rgroup]      [close]   [mr] ["29] [ex] ["3B] % ?
--~ % \definemathsymbol [arrowvert]   [nothing] [sy] ["6A] [ex] ["3C]
--~ % \definemathsymbol [Arrowvert]   [nothing] [sy] ["6B] [ex] ["3D]
--~ % \definemathsymbol [bracevert]   [nothing] [ex] ["3E] % ?
--~ % \definemathsymbol [Vert]        [nothing] [sy] ["6B] [ex] ["0D]
--~ % \definemathsymbol [vert]        [nothing] [sy] ["6A] [ex] ["0C]
--~ % \definemathsymbol [uparrow]     [rel]     [sy] ["22] [ex] ["78]
--~ % \definemathsymbol [downarrow]   [rel]     [sy] ["23] [ex] ["79]
--~ % \definemathsymbol [updownarrow] [rel]     [sy] ["6C] [ex] ["3F]
--~ % \definemathsymbol [Uparrow]     [rel]     [sy] ["2A] [ex] ["7E]
--~ % \definemathsymbol [Downarrow]   [rel]     [sy] ["2B] [ex] ["7F]
--~ % \definemathsymbol [Updownarrow] [rel]     [sy] ["6D] [ex] ["77]
--~ % \definemathsymbol [backslash]   [nothing] [sy] ["6E] [ex] ["0F]
--~ % \definemathsymbol [langle]      [open]    [sy] ["68] [ex] ["0A]
--~ % \definemathsymbol [rangle]      [close]   [sy] ["69] [ex] ["0B]
--~ % \definemathsymbol [lbrace]      [open]    [sy] ["66] [ex] ["08]
--~ % \definemathsymbol [rbrace]      [close]   [sy] ["67] [ex] ["09]
--~ % \definemathsymbol [lceil]       [open]    [sy] ["64] [ex] ["06]
--~ % \definemathsymbol [rceil]       [close]   [sy] ["65] [ex] ["07]
--~ % \definemathsymbol [lfloor]      [open]    [sy] ["62] [ex] ["04]
--~ % \definemathsymbol [rfloor]      [close]   [sy] ["63] [ex] ["05]
--~ % \definemathsymbol [sqrt]        [radical] [sy] ["70] [ex] ["70]
--~ % \definemathsymbol [lvert]       [open]    [sy] ["6A] [ex] ["0C]
--~ % \definemathsymbol [rvert]       [close]   [sy] ["6A] [ex] ["0C]
--~ % \definemathsymbol [lVert]       [open]    [sy] ["6B] [ex] ["0D]
--~ % \definemathsymbol [rVert]       [close]   [sy] ["6B] [ex] ["0D]

--~ ell
--~ wp
--~ Re
--~ Im
--~ partial
--~ emptyset
--~ nabla
--~ top
--~ bot
--~ triangle          ord
--~ neg               ord
--~ flat              ord
--~ natural           ord
--~ sharp             ord
--~ clubsuit          ord
--~ diamondsuit       ord
--~ heartsuit         ord
--~ spadesuit         ord
--~ coprod            op
--~ bigvee            op
--~ bigwedge          op
--~ biguplus          op
--~ bigcap            op
--~ bigcup            op
--~ intop             op
--~ prod              op
--~ sum               op
--~ bigotimes         op
--~ bigoplus          op
--~ bigodot           op
--~ ointop            op
--~ bigsqcup          op
--~ smallint          op
--~ bigtriangleup     bin
--~ bigtriangledown   bin
--~ wedge             bin
--~ vee               bin
--~ cap               bin
--~ cup               bin
--~ ddagger           bin
--~ dagger            bin
--~ sqcap             bin
--~ sqcup             bin
--~ uplus             bin
--~ amalg             bin
--~ diamond           bin
--~ wr                bin
--~ div               bin
--~ odot              bin
--~ mp                bin
--~ pm                bin
--~ circ              bin
--~ bigcirc           bin
--~ setminus          bin
--~ cdot              bin
--~ ast               bin
--~ star              bin
--~ propto            rel
--~ sqsubseteq        rel
--~ sqsupseteq        rel
--~ mid               rel
--~ dashv             rel
--~ vdash             rel
--~ lnot              {\neg}
--~ int               {\intop \intlimits}
--~ oint              {\ointop\intlimits}
--~ land              {\wedge}
--~ lor               {\vee}
--~ neq               {\not=}
--~ ne                {\neq}
--~ le                {\leq}
--~ ge                {\geq}
--~ eq                {=}
--~ gt                {>}
--~ lt                {<}
--~ gets              {\leftarrow}
--~ owns              {\ni}
--~ to                {\rightarrow}
--~ mapsto            {\mapstochar\rightarrow}
--~ leq               rel
--~ geq               rel
--~ succ              rel
--~ prec              rel
--~ supset            rel
--~ subset            rel
--~ supseteq          rel
--~ subseteq          rel
--~ in                rel
--~ ni                rel
--~ gg                rel
--~ ll                rel
--~ not               rel
--~ mapstochar        rel
--~ sim               rel
--~ simeq             rel
--~ perp              rel
--~ asymp             rel
--~ smile
--~ frown
--~ leftharpoonup     rel
--~ leftharpoondown   rel
--~ rightharpoonup    rel
--~ rightharpoondown  rel
--~ lhook             rel
--~ rhook             rel
--~ hbar              {{\mathchar'26\mkern-9muh}}
--~ surd              {{\mathchar"1270}}          % ?
--~ angle             {\PLAINangle}
--~ square            {\hbox{\hsmash{$\sqcup$}$\sqcap$}}
--~ hookrightarrow    {\lhook\joinrel\rightarrow}
--~ hookleftarrow     {\leftarrow\joinrel\rhook}
--~ bowtie            {\mathrel\triangleright\joinrel\mathrel\triangleleft}
--~ models            {\mathrel|\joinrel=}
--~ iff               {\;\Longleftrightarrow\;}
--~ ldotp             punct
--~ cdotp             punct
--~ colon             punct
--~ ldots             inner    {\PLAINldots}
--~ cdots             inner    {\PLAINcdots}
--~ vdots             nothing  {\PLAINvdots}
--~ ddots             inner    {\PLAINddots}
--~ acute             accent
--~ grave             accent
--~ ddot              accent
--~ tilde             accent
--~ mathring          accent
--~ bar               accent
--~ breve             accent
--~ check             accent
--~ hat               accent
--~ vec               accent
--~ dot               accent
--~ widetilde         accent
--~ widehat           accent
--~ lmoustache        open
--~ rmoustache        close
--~ lgroup            open
--~ rgroup            close
--~ arrowvert         ex "3C
--~ Arrowvert         ex "3D
--~ bracevert         ex "3E
--~ Vert              ex -> "0D
--~ vert              ex -> "0C
--~ backslash         nothing (ook ex)
--~ langle            open
--~ rangle            close
--~ sqrt              radical
--~ lvert             open
--~ rvert             close
--~ lVert             open
--~ rVert             close

--~ 0x033B -> square Box
--~ 0x2035 -> backprime
--~ 0x2132 -> Finv
--~ 0x2136 -> beth
--~ 0x2137 -> gimel
--~ 0x2138 -> daleth
--~ 0x2141 -> Game
--~ 0x21B0 -> Lsh
--~ 0x21B1 -> Rsh
--~ 0x21DD -> leadsto rightsquigarrow
--~ 0x2201 -> complement
--~ 0x2205 -> varnothing
--~ 0x2208 -> in
--~ 0x2216 -> smallsetminus
--~ 0x2224 -> nmid
--~ 0x2226 -> nparallel
--~ 0x2234 -> therefore
--~ 0x2235 -> because
--~ 0x223D -> backsim
--~ 0x2241 -> nsim
--~ 0x2242 -> eqsim
--~ 0x2247 -> ncong
--~ 0x224E -> Bumpeq
--~ 0x224F -> bumpeq
--~ 0x2251 -> Doteq doteqdot
--~ 0x2252 -> fallingdotseq
--~ 0x2253 -> risingdotseq
--~ 0x2256 -> eqcirc
--~ 0x2257 -> circeq
--~ 0x226C -> between
--~ 0x22A4 -> bop
--~ 0x22A8 -> vDash
--~ 0x22A9 -> Vdash
--~ 0x22AA -> Vvdash
--~ 0x22AC -> nvdash
--~ 0x22AD -> nvDash
--~ 0x22AE -> nVdash
--~ 0x22AF -> nVDash
--~ 0x22B2 -> lhd vartriangleleft
--~ 0x22B3 -> rhd vartriangleright
--~ 0x22B4 -> unlhd trianglelefteq
--~ 0x22B5 -> unrhd trianglerighteq
--~ 0x22B8 -> multimap
--~ 0x22BA -> intercal
--~ 0x22BB -> veebar
--~ 0x22BC -> barwedge
--~ 0x22C4 -> Diamond lozenge
--~ 0x22C7 -> divideontimes
--~ 0x22C9 -> ltimes
--~ 0x22CA -> rtimes
--~ 0x22CB -> leftthreetimes
--~ 0x22CC -> rightthreetimes
--~ 0x22CD -> backsimeq
--~ 0x22CE -> curlyvee
--~ 0x22CF -> curlywedge
--~ 0x22D1 -> Supset
--~ 0x22D3 -> doublecup Cup
--~ 0x22D4 -> pitchfork
--~ 0x22D6 -> lessdot
--~ 0x22D7 -> gtrdot
--~ 0x22D8 -> lll llless
--~ 0x22D9 -> ggg gggtr
--~ 0x22DA -> lesseqgtr
--~ 0x22DB -> gtreqless
--~ 0x22DE -> curlyeqprec
--~ 0x22DF -> curlyeqsucc
--~ 0x22E6 -> lnsim
--~ 0x22E7 -> gnsim
--~ 0x22E8 -> precnsim
--~ 0x22E9 -> succnsim
--~ 0x22EA -> ntriangleleft
--~ 0x22EB -> ntriangleright
--~ 0x22EC -> ntrianglelefteq
--~ 0x22ED -> ntrianglerighteq
--~ 0x2306 -> doublebarwedge
--~ 0x231C -> ulcorner
--~ 0x231D -> urcorner
--~ 0x231E -> llcorner
--~ 0x231F -> lrcorner
--~ 0x24C8 -> circledS
--~ 0x25A0 -> blacksquare ord
--~ 0x25B2 -> blacktriangle
--~ 0x25B3 -> triangle up
--~ 0x25B6 -> blacktriangleright rel
--~ 0x25BC -> triangledown
--~ 0x25C0 -> blacktriangleleft rel
--~ 0x2605 -> bigstar
--~ 0x29EB -> blacklozenge
--~ 0x1D55C -> Bbbk

local texsprint, format, utfchar, utfbyte = tex.sprint, string.format, utf.char, utf.byte

local trace_defining = false  trackers.register("math.defining", function(v) trace_defining = v end)

mathematics       = mathematics       or { }
mathematics.data  = mathematics.data  or { }
mathematics.slots = mathematics.slots or { }

function mathematics.parameterset()
    return {
        quad = 0,
        axis = 0,
        overbarkern = 0,
        overbarrule = 0,
        overbarvgap = 0,
        underbarkern = 0,
        underbarrule = 0,
        underbarvgap = 0,
        radicalkern = 0,
        radicalrule = 0,
        radicalvgap = 0,
        stackvgap = 0,
        stacknumup = 0,
        stackdenomdown = 0,
        fractionrule = 0,
        fractionnumvgap = 0,
        fractionnumup = 0,
        fractiondenomvgap = 0,
        fractiondenomdown = 0,
        fractiondelsize = 0,
        limitabovevgap = 0,
        limitabovebgap = 0,
        limitabovekern = 0,
        limitbelowvgap = 0,
        limitbelowbgap = 0,
        limitbelowkern = 0,
        subshiftdrop = 0,
        supshiftdrop = 0,
        subshiftdown = 0,
        subsupshiftdown = 0,
        supshiftup = 0,
        subtopmax = 0,
        supbottommin = 0,
        supsubbottommax = 0,
        subsupvgap = 0,
        spaceafterscrip = 0,
    }
end

local families = {
    tf = 1, it = 2, sl = 4, bf = 5, bi = 6, bs = 7, -- virtual fonts or unicode otf
}

local classes = {
    ord     = 0,  -- mathordcomm     mathord
    op      = 1,  -- mathopcomm      mathop
    bin     = 2,  -- mathbincomm     mathbin
    rel     = 3,  -- mathrelcomm     mathrel
    open    = 4,  -- mathopencomm    mathopen
    close   = 5,  -- mathclosecomm   mathclose
    punct   = 6,  -- mathpunctcomm   mathpunct
    alpha   = 7,  -- mathalphacomm   firstofoneargument
    accent  = 8,
    radical = 9,
    inner   = 0,  -- mathinnercomm   mathinner
    nothing = 0,  -- mathnothingcomm firstofoneargument
    choice  = 0,  -- mathchoicecomm  @@mathchoicecomm
    box     = 0,  -- mathboxcomm     @@mathboxcomm
    limop   = 1,  -- mathlimopcomm   @@mathlimopcomm
    nolop   = 1,  -- mathnolopcomm   @@mathnolopcomm
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

local function mathcode(target,class,family,slot)
    if class <= 7 then
        return format('\\Umathcode%s="%X "%X "%X ',target,class,family,slot)
    end
end
local function delcode(target,family,slot)
    return format('\\Udelcode%s="%X "%X ',target,family,slot)
end
local function mathchar(class,family,slot)
    return format('\\Umathchar "%X "%X "%X ',class,family,slot)
end
local function mathaccent(class,family,slot)
    return format('\\Umathaccent "%X "%X "%X ',class,family,slot)
end
local function delimiter(class,family,slot)
    return format('\\Udelimiter "%X "%X "%X ',class,family,slot)
end
local function radical(family,slot)
    return format('\\Uradical "%X "%X ',family,slot)
end
local function mathchardef(name,class,family,slot) -- we can avoid this one
    return format('\\Umathchardef\\%s "%X "%X "%X ',name,class,family,slot)
end
local function mathcode(target,class,family,slot)
    if class <= 7 then
        return format('\\Umathcode%s="%X "%X "%X ',target,class,family,slot)
    end
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
    family = families[family] or family
    texsprint(mathcode(slot,class,family,unicode or slot))
end

mathematics.setmathsymbol    = setmathsymbol
mathematics.setmathcharacter = setmathcharacter

local function report(class,family,unicode,name)
    local classname = mathematics.classes[class] or class
    local nametype = type(name)
    if nametype == "string" then
        logs.report("mathematics","%s:%s %s U+%05X (%s) -> %s",classname,class,family,unicode,utfchar(unicode),name)
    elseif nametype == "number" then
        logs.report("mathematics","%s:%s %s U+%05X (%s) -> U+%05X",classname,class,family,unicode,utfchar(unicode),name)
    else
        logs.report("mathematics","%s:%s %s U+%05X (%s)",      classname,class,family,unicode,utfchar(unicode))
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
