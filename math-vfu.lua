if not modules then modules = { } end modules ['math-vfu'] = {
    version   = 1.001,
    comment   = "companion to math-ini.tex",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

local trace_virtual = false trackers.register("math.virtual", function(v) trace_virtual = v end)
local trace_timings = false trackers.register("math.timings", function(v) trace_timings = v end)

fonts.enc.math = fonts.enc.math or { }

local shared = { }

fonts.vf.math          = fonts.vf.math or { }
fonts.vf.math.optional = false

function fonts.vf.math.define(specification,set)
    local name = specification.name -- symbolic name
    local size = specification.size -- given size
    local fnt, lst, main = { }, { }, nil
    local start = (trace_virtual or trace_timings) and os.clock()
    for s=1,#set do
        local ss = set[s]
        local ssname = ss.name
        if ss.optional and fonts.vf.math.optional then
            if trace_virtual then
                logs.report("math virtual","loading font %s subfont %s with name %s at %s is skipped",name,s,ssname,size)
            end
        else
            if ss.features then ssname = ssname .. "*" .. ss.features end
            if ss.main then main = s end
            local f, id = fonts.tfm.read_and_define(ssname,size)
            fnt[s] = f
            lst[s] = { id = id, size = size }
            if not shared[s] then shared[s] = { } end
            if trace_virtual then
                logs.report("math virtual","loading font %s subfont %s with name %s at %s as id %s using encoding %s",name,s,ssname,size,id,ss.vector or "none")
            end
        end
    end
    main = table.copy(fnt[main or 1])
    main.name, main.type, main.fonts = name, 'virtual', lst
    main.math_parameters = { }
    local characters = main.characters
    local descriptions = main.descriptions
--~ for i=1,22 do
--~     main.parameters[i] = main.parameters[i] or 0
--~ end
    for s=1,#set do
        local ss, fs = set[s], fnt[s]
        if ss.optional and fonts.vf.math.optional then
            -- skipped
        else
            local mm, fp = main.math_parameters, fs.parameters
            if ss.extension then
            --  logs.report("math virtual","loading and virtualizing font %s at size %s, setting ex parameters",name,size)
                mm.math_x_height          = mm.math_x_height or fp[ 5] or 0 -- math_x_height           height of x
                mm.default_rule_thickness = fp[ 8] or 0 -- default_rule_thickness  thickness of \over bars
                mm.big_op_spacing1        = fp[ 9] or 0 -- big_op_spacing1         minimum clearance above a displayed op
                mm.big_op_spacing2        = fp[10] or 0 -- big_op_spacing2         minimum clearance below a displayed op
                mm.big_op_spacing3        = fp[11] or 0 -- big_op_spacing3         minimum baselineskip above displayed op
                mm.big_op_spacing4        = fp[12] or 0 -- big_op_spacing4         minimum baselineskip below displayed op
                mm.big_op_spacing5        = fp[13] or 0 -- big_op_spacing5         padding above and below displayed limits
            elseif ss.parameters then
            --  logs.report("math virtual","loading and virtualizing font %s at size %s, setting sy parameters",name,size)
                mm.math_x_height = mm.math_x_height or fp[ 5] or 0 -- math_x_height           height of x
                mm.num1          = fp[ 8] or 0 -- num1                    numerator shift-up in display styles
                mm.num2          = fp[ 9] or 0 -- num2                    numerator shift-up in non-display, non-\atop
                mm.num3          = fp[10] or 0 -- num3                    numerator shift-up in non-display \atop
                mm.denom1        = fp[11] or 0 -- denom1                  denominator shift-down in display styles
                mm.denom2        = fp[12] or 0 -- denom2                  denominator shift-down in non-display styles
                mm.sup1          = fp[13] or 0 -- sup1                    superscript shift-up in uncramped display style
                mm.sup2          = fp[14] or 0 -- sup2                    superscript shift-up in uncramped non-display
                mm.sup3          = fp[15] or 0 -- sup3                    superscript shift-up in cramped styles
                mm.sub1          = fp[16] or 0 -- sub1                    subscript shift-down if superscript is absent
                mm.sub2          = fp[17] or 0 -- sub2                    subscript shift-down if superscript is present
                mm.sup_drop      = fp[18] or 0 -- sup_drop                superscript baseline below top of large box
                mm.sub_drop      = fp[19] or 0 -- sub_drop                subscript baseline below bottom of large box
                mm.delim1        = fp[20] or 0 -- delim1                  size of \atopwithdelims delimiters in display styles
                mm.delim2        = fp[21] or 0 -- delim2                  size of \atopwithdelims delimiters in non-displays
                mm.axis_height   = fp[22] or 0 -- axis_height             height of fraction lines above the baseline
            end
            local vector = ss.vector
            if vector then
                vector = fonts.enc.math[vector]
                if vector then
                    local fc, fd, si = fs.characters, fs.descriptions, shared[s]
                    if ss.extension then
                        local extension = fonts.enc.math["large-to-small"]
                        for index, fci in next, fc do -- the raw ex file
                            local ref = si[index]
                            if not ref then
                                ref = { { 'slot', s, index } }
                                si[index] = ref
                            end
                            local n = fci.next
                            if n then
                                characters[0xFF000 + index] = {
                                    width    = fci.width,
                                    height   = fci.height,
                                    depth    = fci.depth,
                                    next     = n + 0xFF000,
                                    commands = ref,
                                }
                            else
                                -- we can share these
                                local e = fci.extensible
                                if e then
                                    local top = e.top if top ~= 0 then top = top + 0xFF000 end
                                    local rep = e.rep if rep ~= 0 then rep = rep + 0xFF000 end
                                    local mid = e.mid if mid ~= 0 then mid = mid + 0xFF000 end
                                    local bot = e.bot if bot ~= 0 then bot = bot + 0xFF000 end
                                    characters[0xFF000 + index] = {
                                        width      = fci.width,
                                        height     = fci.height,
                                        depth      = fci.depth,
                                        extensible = { top = top, rep = rep, mid = mid, bot = bot },
                                        commands   = ref,
                                    }
                                else
                                    characters[0xFF000 + index] = {
                                        width    = fci.width,
                                        height   = fci.height,
                                        depth    = fci.depth,
                                        commands = ref,
                                    }
                                end
                            end
                        end
                        for unicode, index in next, extension do
                            local cu = characters[unicode]
                            if cu then
                                cu["next"] = 0xFF000 + index
                            else
                            --  logs.report("math virtual", "no unicode point U+%04X for extensible U+%04X",unicode,index)
                                local fci = fc[index]
                                local ref = si[index]
                                if not ref then
                                    ref = { { 'slot', s, index } }
                                    si[index] = ref
                                end
                                characters[unicode] = {
                                    width    = fci.width,
                                    height   = fci.height,
                                    depth    = fci.depth,
                                    italic   = fci.italic,
                                    kerns    = fci.kerns,
                                    commands = ref,
                                    next     = 0xFF000 + index
                                }
                            end
                        end
                    end
                    for unicode, index in next, vector do
                        local fci = fc[index]
                        local ref = si[index]
                        if not ref then
                            ref = { { 'slot', s, index } }
                            si[index] = ref
                        end
                        characters[unicode] = {
                            width    = fci.width,
                            height   = fci.height,
                            depth    = fci.depth,
                            italic   = fci.italic,
                            kerns    = fci.kerns,
                            commands = ref,
                        }
                    end
                end
            end
        end
    end
    if trace_virtual or trace_timings then
        logs.report("math virtual","loading and virtualizing font %s at size %s took %0.3f seconds",name,size,os.clock()-start)
    end
    main.MathConstants = fonts.tfm.scaled_math_parameters(main.math_parameters,1)
    return main
end

function mathematics.make_font(name, set)
    fonts.define.methods[name] = function(specification)
        return fonts.vf.math.define(specification,set)
    end
end

-- varphi is part of the alphabet, contrary to the other var*s'

mathematics.private = 0xFF000 -- here we push the ex

fonts.enc.math["large-to-small"] = {
    [0x00028] = 0x00, -- (
    [0x00029] = 0x01, -- )
    [0x0005B] = 0x02, -- [
    [0x0005D] = 0x03, -- ]
    [0x0230A] = 0x04, -- lfloor
    [0x0230B] = 0x05, -- rfloor
    [0x02308] = 0x06, -- lceil
    [0x02309] = 0x07, -- rceil
    [0x0007B] = 0x08, -- {
    [0x0007D] = 0x09, -- }
    [0x027E8] = 0x0A, -- <
    [0x027E9] = 0x0B, -- >
    [0x0007C] = 0x0C, -- |
--~ [0x0]     = 0x0D, -- lVert rVert Vert
    [0x0002F] = 0x0E, -- /
    [0x0005C] = 0x0F, -- \
--~ [0x0]     = 0x3A, -- lgroup
--~ [0x0]     = 0x3B, -- rgroup
--~ [0x0]     = 0x3C, -- arrowvert
--~ [0x0]     = 0x3D, -- Arrowvert
    [0x02195] = 0x3F, -- updownarrow
--~ [0x0]     = 0x40, -- lmoustache
--~ [0x0]     = 0x41, -- rmoustache
--~ [0x0005E] = 0x62, -- widehat
    [0x0007E] = 0x65, -- widetilde
    [0x0221A] = 0x70, -- sqrt
    [0x021D5] = 0x77, -- Updownarrow
    [0x02191] = 0x78, -- uparrow
    [0x02193] = 0x79, -- downarrow
    [0x021D1] = 0x7E, -- Uparrow
    [0x021D3] = 0x7F, -- Downarrow
}

fonts.enc.math["traditional-ex"] = {
    [0x0220F] = 0x51, -- prod
    [0x02210] = 0x60, -- coprod
    [0x02211] = 0x50, -- sum
    [0x0222B] = 0x52, -- intop
    [0x022C0] = 0x56, -- bigwedge
    [0x022C1] = 0x57, -- bigvee
    [0x022C2] = 0x54, -- bigcap
    [0x022C3] = 0x53, -- bigcup
--~ [0x02215] = 0x3D, -- /
}

fonts.enc.math["traditional-mr"] = {
    [0x00391] = 0x41, -- Alpha
    [0x00392] = 0x42, -- Beta
    [0x00393] = 0x00, -- Gamma
    [0x00394] = 0x01, -- Delta
    [0x00395] = 0x45, -- Epsilon
    [0x00396] = 0x5A, -- Zeta
    [0x00397] = 0x48, -- Eta
    [0x00398] = 0x02, -- Theta
    [0x00399] = 0x49, -- Iota
    [0x0039A] = 0x4B, -- Kappa
    [0x0039B] = 0x03, -- Lambda
    [0x0039C] = 0x4D, -- Mu
    [0x0039D] = 0x4E, -- Nu
    [0x0039E] = 0x04, -- Xi
    [0x0039F] = 0x4F, -- Omicron
    [0x003A0] = 0x05, -- Pi
    [0x003A1] = 0x52, -- Rho
    [0x003A3] = 0x06, -- Sigma
    [0x003A4] = 0x54, -- Tau
    [0x003A5] = 0x07, -- Upsilon
    [0x003A6] = 0x08, -- Phi
    [0x003A7] = 0x58, -- Chi
    [0x003A8] = 0x09, -- Psi
    [0x003A9] = 0x0A, -- Omega
    [0x00021] = 0x21, -- !
    [0x00028] = 0x28, -- (
    [0x00029] = 0x29, -- )
    [0x0002B] = 0x2B, -- +
    [0x0003A] = 0x3A, -- :
    [0x0003B] = 0x3B, -- ;
    [0x0003C] = 0x3C, -- <
    [0x0003D] = 0x3D, -- =
    [0x0003E] = 0x3E, -- >
    [0x0003F] = 0x3F, -- ?
    [0x02236] = 0x3A, -- colon
    [0x00028] = 0x28, -- (
    [0x00029] = 0x29, -- )
    [0x0002F] = 0x2F, -- /
    [0x0005B] = 0x5B, -- [
    [0x0005D] = 0x5D, -- ]
    [0x0005E] = 0x5E, -- hat
    [0x0007E] = 0x7E, -- widetilde
    [0x02145] = 0x44,
    [0x02146] = 0x64,
    [0x02147] = 0x65,
}

fonts.enc.math["traditional-mi"] = {
    [0x1D6E4] = 0x00, -- Gamma
    [0x1D6E5] = 0x01, -- Delta
    [0x1D6E9] = 0x02, -- Theta
    [0x1D6F3] = 0x02, -- varTheta (not present in TeX)
    [0x1D6EC] = 0x03, -- Lambda
    [0x1D6EF] = 0x04, -- Xi
    [0x1D6F1] = 0x05, -- Pi
    [0x1D6F4] = 0x06, -- Sigma
    [0x1D6F6] = 0x07, -- Upsilon
    [0x1D6F7] = 0x08, -- Phi
    [0x1D6F9] = 0x09, -- Psi
    [0x1D6FA] = 0x0A, -- Omega
    [0x1D6FC] = 0x0B, -- alpha
    [0x1D6FD] = 0x0C, -- beta
    [0x1D6FE] = 0x0D, -- gamma
    [0x1D6FF] = 0x0E, -- delta
    [0x1D716] = 0x0F, -- epsilon TODO: 1D716
    [0x1D701] = 0x10, -- zeta
    [0x1D702] = 0x11, -- eta
    [0x1D703] = 0x12, -- theta TODO: 1D703
    [0x1D704] = 0x13, -- iota
    [0x1D705] = 0x14, -- kappa
    [0x1D718] = 0x14, -- varkappa, not in tex fonts
    [0x1D706] = 0x15, -- lambda
    [0x1D707] = 0x16, -- mu
    [0x1D708] = 0x17, -- nu
    [0x1D709] = 0x18, -- xi
    [0x1D70B] = 0x19, -- pi
    [0x1D70C] = 0x1A, -- rho
    [0x1D70E] = 0x1B, -- sigma
    [0x1D70F] = 0x1C, -- tau
    [0x1D710] = 0x1D, -- upsilon
    [0x1D719] = 0x1E, -- phi
    [0x1D712] = 0x1F, -- chi
    [0x1D713] = 0x20, -- psi
    [0x1D714] = 0x21, -- omega
    [0x1D700] = 0x22, -- varepsilon (the other way around)
    [0x1D717] = 0x23, -- vartheta
    [0x1D71B] = 0x24, -- varpi
    [0x1D71A] = 0x25, -- varrho
    [0x1D70D] = 0x26, -- varsigma
    [0x1D711] = 0x27, -- varphi (the other way around)
    [0x021BC] = 0x28, -- leftharpoonup
    [0x021BD] = 0x29, -- leftharpoondown
    [0x021C0] = 0x2A, -- righttharpoonup
    [0x021C1] = 0x2B, -- rightharpoondown
    --          0x2C, -- lhook (hook for combining arrows)
    --          0x2D, -- rhook (hook for combining arrows)
    [0x022B3] = 0x2E, -- triangleright (TODO: which one is right?)
    [0x025B7] = 0x2E, -- triangleright
    [0x022B2] = 0x2F, -- triangleleft (TODO: which one is right?)
    [0x025C1] = 0x2F, -- triangleleft
--  [0x00041] = 0x30, -- 0
--  [0x00041] = 0x31, -- 1
--  [0x00041] = 0x32, -- 2
--  [0x00041] = 0x33, -- 3
--  [0x00041] = 0x34, -- 4
--  [0x00041] = 0x35, -- 5
--  [0x00041] = 0x36, -- 6
--  [0x00041] = 0x37, -- 7
--  [0x00041] = 0x38, -- 8
--  [0x00041] = 0x39, -- 9
    [0x0002E] = 0x3A, -- .
    [0x0002C] = 0x3B, -- ,
    [0x0003C] = 0x3C, -- <
    [0x0002F] = 0x3D, -- /, slash, solidus
    [0x02215] = 0x3D, -- / AM: Not sure
    [0x0003E] = 0x3E, -- >
    [0x022C6] = 0x3F, -- star
    [0x02202] = 0x40, -- partial
--  [0x00041] = 0x41, -- A
    [0x1D6E2] = 0x41, -- Alpha
--  [0x00042] = 0x42, -- B
    [0x1D6E3] = 0x42, -- Beta
--  [0x00043] = 0x43, -- C
--  [0x00044] = 0x44, -- D
--  [0x00045] = 0x45, -- E
    [0x1D6E6] = 0x45, -- Epsilon
--  [0x00046] = 0x46, -- F
--  [0x00047] = 0x47, -- G
--  [0x00048] = 0x48, -- H
    [0x1D6E8] = 0x48, -- Eta
--  [0x00049] = 0x49, -- I
    [0x1D6EA] = 0x49, -- Iota
--  [0x0004A] = 0x4A, -- J
--  [0x0004B] = 0x4B, -- K
    [0x1D6EB] = 0x4B, -- Kappa
--  [0x0004C] = 0x4C, -- L
--  [0x0004D] = 0x4D, -- M
    [0x1D6ED] = 0x4D, -- Mu
--  [0x0004E] = 0x4E, -- N
    [0x1D6EE] = 0x4E, -- Nu
--  [0x0004F] = 0x4F, -- O
    [0x1D6F0] = 0x4F, -- Omicron
--  [0x00050] = 0x50, -- P
    [0x1D6F2] = 0x50, -- Rho
--  [0x00051] = 0x51, -- Q
--  [0x00052] = 0x52, -- R
--  [0x00053] = 0x53, -- S
--  [0x00054] = 0x54, -- T
    [0x1D6F5] = 0x54, -- Tau
--  [0x00055] = 0x55, -- U
--  [0x00056] = 0x56, -- V
--  [0x00057] = 0x57, -- W
--  [0x00058] = 0x58, -- X
    [0x1D6F8] = 0x58, -- Chi
--  [0x00059] = 0x59, -- Y
--  [0x0005A] = 0x5A, -- Z
    [0x1D6E7] = 0x5A, -- Zeta
    [0x0266D] = 0x5B, -- flat
    [0x0266E] = 0x5C, -- natural
    [0x0266F] = 0x5D, -- sharp
    [0x02323] = 0x5E, -- smile
    [0x02322] = 0x5F, -- frown
    [0x02113] = 0x60, -- ell
--  [0x00061] = 0x61, -- a
--  [0x00062] = 0x62, -- b
--  [0x00063] = 0x63, -- c
--  [0x00064] = 0x64, -- d
--  [0x00065] = 0x65, -- e
--  [0x00066] = 0x66, -- f
--  [0x00067] = 0x67, -- g
--  [0x00068] = 0x68, -- h
--  [0x00069] = 0x69, -- i
--  [0x0006A] = 0x6A, -- j
--  [0x0006B] = 0x6B, -- k
--  [0x0006C] = 0x6C, -- l
--  [0x0006D] = 0x6D, -- m
--  [0x0006E] = 0x6E, -- n
--  [0x0006F] = 0x6F, -- o
    [0x1D70A] = 0x6F, -- omicron
--  [0x00070] = 0x70, -- p
--  [0x00071] = 0x71, -- q
--  [0x00072] = 0x72, -- r
--  [0x00073] = 0x73, -- s
--  [0x00074] = 0x74, -- t
--  [0x00075] = 0x75, -- u
--  [0x00076] = 0x76, -- v
--  [0x00077] = 0x77, -- w
--  [0x00078] = 0x78, -- x
--  [0x00079] = 0x79, -- y
--  [0x0007A] = 0x7A, -- z
    [0x1D6A4] = 0x7B, -- imath (TODO: also 0131)
    [0x1D6A5] = 0x7C, -- jmath (TODO: also 0237)
    [0x02118] = 0x7D, -- wp
    [0x020D7] = 0x7E, -- vec (TODO: not sure)
--              0x7F, -- (no idea what that could be)
}

fonts.enc.math["traditional-ss"] = { }
fonts.enc.math["traditional-tt"] = { }
fonts.enc.math["traditional-bf"] = { }
fonts.enc.math["traditional-bi"] = { }

local mi_vec = fonts.enc.math["traditional-mi"]
local ss_vec = fonts.enc.math["traditional-ss"]
local tt_vec = fonts.enc.math["traditional-tt"]
local bf_vec = fonts.enc.math["traditional-bf"]
local bi_vec = fonts.enc.math["traditional-bi"]

for i=0,25 do
    local u, l = i + 0x41, i + 0x61
    mi_vec[0x1D434+i] = u
    mi_vec[0x1D44E+i] = l
    ss_vec[0x1D5A0+i] = u
    ss_vec[0x1D5BA+i] = l
    tt_vec[0x1D670+i] = u
    tt_vec[0x1D68A+i] = l
    bf_vec[0x1D400+i] = u
    bf_vec[0x1D41A+i] = l
    bi_vec[0x1D468+i] = u
    bi_vec[0x1D482+i] = l
end

for i=0,9 do
    ss_vec[0x1D7E2+i] = i + 0x30
    tt_vec[0x1D7F6+i] = i + 0x30
    bf_vec[0x1D7CE+i] = i + 0x30
--  bi_vec[0x1D7CE+i] = i + 0x30
end

fonts.enc.math["traditional-sy"] = {
    [0x0002D] = 0x00, -- -
    [0x02212] = 0x00, -- -
--  [0x02201] = 0x00, -- complement
--  [0x02206] = 0x00, -- increment
--  [0x02204] = 0x00, -- not exists
    [0x000B7] = 0x01, -- cdot
    [0x022C5] = 0x01, -- cdot
    [0x000D7] = 0x02, -- times
    [0x0002A] = 0x03, -- *
    [0x02217] = 0x03, -- *
    [0x000F7] = 0x04, -- div
    [0x022C4] = 0x05, -- diamond
    [0x000B1] = 0x06, -- pm
    [0x02213] = 0x07, -- mp
    [0x02295] = 0x08, -- oplus
    [0x02296] = 0x09, -- ominus
    [0x02297] = 0x0A, -- otimes
    [0x02298] = 0x0B, -- oslash
    [0x02299] = 0x0C, -- odot
--  [0x0]     = 0x0D, -- bigcirc, Orb (either 25EF or 25CB)
    [0x02218] = 0x0E, -- circ
    [0x02219] = 0x0F, -- bullet
    [0x02022] = 0x0F, -- bullet
    [0x0224D] = 0x10, -- asymp
    [0x02261] = 0x11, -- equiv
    [0x02286] = 0x12, -- subseteq
    [0x02287] = 0x13, -- supseteq
    [0x02264] = 0x14, -- leq
    [0x02265] = 0x15, -- geq
    [0x02AAF] = 0x16, -- preceq
--  [0x0227C] = 0x16, -- preceq, AM:No see 2AAF
    [0x02AB0] = 0x17, -- succeq
--  [0x0227D] = 0x17, -- succeq, AM:No see 2AB0
    [0x0223C] = 0x18, -- sim
    [0x02248] = 0x19, -- approx
    [0x02282] = 0x1A, -- subset
    [0x02283] = 0x1B, -- supset
    [0x0226A] = 0x1C, -- ll
    [0x0226B] = 0x1D, -- gg
    [0x0227A] = 0x1E, -- prec
    [0x0227B] = 0x1F, -- succ
    [0x02190] = 0x20, -- leftarrow
    [0x02192] = 0x21, -- rightarrow
    [0x02191] = 0x22, -- uparrow
    [0x02193] = 0x23, -- downarrow
    [0x02194] = 0x24, -- leftrightarrow
    [0x02197] = 0x25, -- nearrow
    [0x02198] = 0x26, -- searrow
    [0x02243] = 0x27, -- simeq
    [0x021D0] = 0x28, -- Leftarrow
    [0x021D2] = 0x29, -- Rightarrow
    [0x021D1] = 0x2A, -- Uparrow
    [0x021D3] = 0x2B, -- Downarrow
    [0x021D4] = 0x2C, -- Leftrightarrow
    [0x02196] = 0x2D, -- nwarrow
    [0x02199] = 0x2E, -- swarrow
    [0x0221D] = 0x2F, -- propto
--  [0x02032] = 0x30, -- prime (not really the right symbol)
    [0x0221E] = 0x31, -- infty
    [0x02208] = 0x32, -- in
    [0x0220B] = 0x33, -- ni
    [0x025B3] = 0x34, -- triangle, bigtriangleup
    [0x025BD] = 0x35, -- bigtriangledown
--              0x36, -- not
--              0x37, -- (beginning of arrow)
    [0x02200] = 0x38, -- forall
    [0x02203] = 0x39, -- exists
    [0x000AC] = 0x3A, -- neg, lnot
    [0x02205] = 0x3B, -- empty set
    [0x0211C] = 0x3C, -- Re
    [0x02111] = 0x3D, -- Im
    [0x022A4] = 0x3E, -- top
    [0x022A5] = 0x3F, -- bot, perp
    [0x02135] = 0x40, -- aleph
    [0x1D49C] = 0x41, -- script A
    [0x0212C] = 0x42, -- script B
    [0x1D49E] = 0x43, -- script C
    [0x1D49F] = 0x44, -- script D
    [0x02130] = 0x45, -- script E
    [0x02131] = 0x46, -- script F
    [0x1D4A2] = 0x47, -- script G
    [0x0210B] = 0x48, -- script H
    [0x02110] = 0x49, -- script I
    [0x1D4A5] = 0x4A, -- script J
    [0x1D4A6] = 0x4B, -- script K
    [0x02112] = 0x4C, -- script L
    [0x02133] = 0x4D, -- script M
    [0x1D4A9] = 0x4E, -- script N
    [0x1D4AA] = 0x4F, -- script O
    [0x1D4AB] = 0x50, -- script P
    [0x1D4AC] = 0x51, -- script Q
    [0x0211B] = 0x52, -- script R
    [0x1D4AE] = 0x53, -- script S
    [0x1D4AF] = 0x54, -- script T
    [0x1D4B0] = 0x55, -- script U
    [0x1D4B1] = 0x56, -- script V
    [0x1D4B2] = 0x57, -- script W
    [0x1D4B3] = 0x58, -- script X
    [0x1D4B4] = 0x59, -- script Y
    [0x1D4B5] = 0x5A, -- script Z
    [0x0222A] = 0x5B, -- cup
    [0x02229] = 0x5C, -- cap
    [0x0228E] = 0x5D, -- uplus
    [0x02227] = 0x5E, -- wedge, land
    [0x02228] = 0x5F, -- vee, lor
    [0x022A2] = 0x60, -- vdash
    [0x022A3] = 0x61, -- dashv
    [0x0230A] = 0x62, -- lfloor
    [0x0230B] = 0x63, -- rfloor
    [0x02308] = 0x64, -- lceil
    [0x02309] = 0x65, -- rceil
    [0x0007B] = 0x66, -- {, lbrace
    [0x0007D] = 0x67, -- }, rbrace
    [0x027E8] = 0x68, -- <, langle
    [0x027E9] = 0x69, -- >, rangle
    [0x0007C] = 0x6A, -- |, mid, lvert, rvert
    [0x02225] = 0x6B, -- parallel, Vert, lVert, rVert, arrowvert
    [0x02195] = 0x6C, -- updownarrow
    [0x021D5] = 0x6D, -- Updownarrow
    [0x0005C] = 0x6E, -- \, backslash, setminus
    [0x02216] = 0x6E, -- setminus
    [0x02240] = 0x6F, -- wr
--  [0x0221A] = 0x70, -- sqrt. AM: Check surd??
    [0x02A3F] = 0x71, -- amalg
    [0x02207] = 0x72, -- nabla
    [0x0222B] = 0x73, -- smallint (TODO: what about intop?)
    [0x02294] = 0x74, -- sqcup
    [0x02293] = 0x75, -- sqcap
    [0x02291] = 0x76, -- sqsubseteq
    [0x02292] = 0x77, -- sqsupseteq
    [0x000A7] = 0x78, -- S
    [0x02020] = 0x79, -- dagger, dag
    [0x02021] = 0x7A, -- ddagger, ddag
    [0x000B6] = 0x7B, -- P
    [0x02663] = 0x7C, -- clubsuit
    [0x02662] = 0x7D, -- diamondsuit
    [0x02661] = 0x7E, -- heartsuit
    [0x02660] = 0x7F, -- spadesuit
}

fonts.enc.math["traditional-sy"] = {
    [0x0002D] = 0x00, -- -
    [0x02212] = 0x00, -- -
--  [0x02201] = 0x00, -- complement
--  [0x02206] = 0x00, -- increment
--  [0x02204] = 0x00, -- not exists
    [0x000B7] = 0x01, -- cdot
    [0x022C5] = 0x01, -- cdot
    [0x000D7] = 0x02, -- times
    [0x0002A] = 0x03, -- *
    [0x02217] = 0x03, -- *
    [0x000F7] = 0x04, -- div
    [0x022C4] = 0x05, -- diamond
    [0x000B1] = 0x06, -- pm
    [0x02213] = 0x07, -- mp
    [0x02295] = 0x08, -- oplus
    [0x02296] = 0x09, -- ominus
    [0x02297] = 0x0A, -- otimes
    [0x02298] = 0x0B, -- oslash
    [0x02299] = 0x0C, -- odot
--  [0x0]     = 0x0D, -- bigcirc, Orb (either 25EF or 25CB)
    [0x02218] = 0x0E, -- circ
    [0x02219] = 0x0F, -- bullet
    [0x02022] = 0x0F, -- bullet
    [0x0224D] = 0x10, -- asymp
    [0x02261] = 0x11, -- equiv
    [0x02286] = 0x12, -- subseteq
    [0x02287] = 0x13, -- supseteq
    [0x02264] = 0x14, -- leq
    [0x02265] = 0x15, -- geq
    [0x02AAF] = 0x16, -- preceq
--  [0x0227C] = 0x16, -- preceq, AM:No see 2AAF
    [0x02AB0] = 0x17, -- succeq
--  [0x0227D] = 0x17, -- succeq, AM:No see 2AB0
    [0x0223C] = 0x18, -- sim
    [0x02248] = 0x19, -- approx
    [0x02282] = 0x1A, -- subset
    [0x02283] = 0x1B, -- supset
    [0x0226A] = 0x1C, -- ll
    [0x0226B] = 0x1D, -- gg
    [0x0227A] = 0x1E, -- prec
    [0x0227B] = 0x1F, -- succ
    [0x02190] = 0x20, -- leftarrow
    [0x02192] = 0x21, -- rightarrow
    [0x02191] = 0x22, -- uparrow
    [0x02193] = 0x23, -- downarrow
    [0x02194] = 0x24, -- leftrightarrow
    [0x02197] = 0x25, -- nearrow
    [0x02198] = 0x26, -- searrow
    [0x02243] = 0x27, -- simeq
    [0x021D0] = 0x28, -- Leftarrow
    [0x021D2] = 0x29, -- Rightarrow
    [0x021D1] = 0x2A, -- Uparrow
    [0x021D3] = 0x2B, -- Downarrow
    [0x021D4] = 0x2C, -- Leftrightarrow
    [0x02196] = 0x2D, -- nwarrow
    [0x02199] = 0x2E, -- swarrow
    [0x0221D] = 0x2F, -- propto
--  [0x02032] = 0x30, -- prime (not really the right symbol)
    [0x0221E] = 0x31, -- infty
    [0x02208] = 0x32, -- in
    [0x0220B] = 0x33, -- ni
    [0x025B3] = 0x34, -- triangle, bigtriangleup
    [0x025BD] = 0x35, -- bigtriangledown
--              0x36, -- not
--              0x37, -- (beginning of arrow)
    [0x02200] = 0x38, -- forall
    [0x02203] = 0x39, -- exists
    [0x000AC] = 0x3A, -- neg, lnot
    [0x02205] = 0x3B, -- empty set
    [0x0211C] = 0x3C, -- Re
    [0x02111] = 0x3D, -- Im
    [0x022A4] = 0x3E, -- top
    [0x022A5] = 0x3F, -- bot, perp
    [0x02135] = 0x40, -- aleph
    [0x1D49C] = 0x41, -- script A
    [0x0212C] = 0x42, -- script B
    [0x1D49E] = 0x43, -- script C
    [0x1D49F] = 0x44, -- script D
    [0x02130] = 0x45, -- script E
    [0x02131] = 0x46, -- script F
    [0x1D4A2] = 0x47, -- script G
    [0x0210B] = 0x48, -- script H
    [0x02110] = 0x49, -- script I
    [0x1D4A5] = 0x4A, -- script J
    [0x1D4A6] = 0x4B, -- script K
    [0x02112] = 0x4C, -- script L
    [0x02133] = 0x4D, -- script M
    [0x1D4A9] = 0x4E, -- script N
    [0x1D4AA] = 0x4F, -- script O
    [0x1D4AB] = 0x50, -- script P
    [0x1D4AC] = 0x51, -- script Q
    [0x0211B] = 0x52, -- script R
    [0x1D4AE] = 0x53, -- script S
    [0x1D4AF] = 0x54, -- script T
    [0x1D4B0] = 0x55, -- script U
    [0x1D4B1] = 0x56, -- script V
    [0x1D4B2] = 0x57, -- script W
    [0x1D4B3] = 0x58, -- script X
    [0x1D4B4] = 0x59, -- script Y
    [0x1D4B5] = 0x5A, -- script Z
    [0x0222A] = 0x5B, -- cup
    [0x02229] = 0x5C, -- cap
    [0x0228E] = 0x5D, -- uplus
    [0x02227] = 0x5E, -- wedge, land
    [0x02228] = 0x5F, -- vee, lor
    [0x022A2] = 0x60, -- vdash
    [0x022A3] = 0x61, -- dashv
    [0x0230A] = 0x62, -- lfloor
    [0x0230B] = 0x63, -- rfloor
    [0x02308] = 0x64, -- lceil
    [0x02309] = 0x65, -- rceil
    [0x0007B] = 0x66, -- {, lbrace
    [0x0007D] = 0x67, -- }, rbrace
    [0x027E8] = 0x68, -- <, langle
    [0x027E9] = 0x69, -- >, rangle
    [0x0007C] = 0x6A, -- |, mid, lvert, rvert
    [0x02225] = 0x6B, -- parallel, Vert, lVert, rVert, arrowvert
    [0x02195] = 0x6C, -- updownarrow
    [0x021D5] = 0x6D, -- Updownarrow
    [0x0005C] = 0x6E, -- \, backslash, setminus
    [0x02216] = 0x6E, -- setminus
    [0x02240] = 0x6F, -- wr
--  [0x0221A] = 0x70, -- sqrt. AM: Check surd??
    [0x02A3F] = 0x71, -- amalg
    [0x02207] = 0x72, -- nabla
    [0x0222B] = 0x73, -- smallint (TODO: what about intop?)
    [0x02294] = 0x74, -- sqcup
    [0x02293] = 0x75, -- sqcap
    [0x02291] = 0x76, -- sqsubseteq
    [0x02292] = 0x77, -- sqsupseteq
    [0x000A7] = 0x78, -- S
    [0x02020] = 0x79, -- dagger, dag
    [0x02021] = 0x7A, -- ddagger, ddag
    [0x000B6] = 0x7B, -- P
    [0x02663] = 0x7C, -- clubsuit
    [0x02662] = 0x7D, -- diamondsuit
    [0x02661] = 0x7E, -- heartsuit
    [0x02660] = 0x7F, -- spadesuit
}

fonts.enc.math["traditional-sy"] = {
    [0x0002D] = 0x00, -- -
    [0x02212] = 0x00, -- -
--  [0x02201] = 0x00, -- complement
--  [0x02206] = 0x00, -- increment
--  [0x02204] = 0x00, -- not exists
    [0x000B7] = 0x01, -- cdot
    [0x022C5] = 0x01, -- cdot
    [0x000D7] = 0x02, -- times
    [0x0002A] = 0x03, -- *
    [0x02217] = 0x03, -- *
    [0x000F7] = 0x04, -- div
    [0x022C4] = 0x05, -- diamond
    [0x000B1] = 0x06, -- pm
    [0x02213] = 0x07, -- mp
    [0x02295] = 0x08, -- oplus
    [0x02296] = 0x09, -- ominus
    [0x02297] = 0x0A, -- otimes
    [0x02298] = 0x0B, -- oslash
    [0x02299] = 0x0C, -- odot
--  [0x0]     = 0x0D, -- bigcirc, Orb (either 25EF or 25CB)
    [0x02218] = 0x0E, -- circ
    [0x02219] = 0x0F, -- bullet
    [0x02022] = 0x0F, -- bullet
    [0x0224D] = 0x10, -- asymp
    [0x02261] = 0x11, -- equiv
    [0x02286] = 0x12, -- subseteq
    [0x02287] = 0x13, -- supseteq
    [0x02264] = 0x14, -- leq
    [0x02265] = 0x15, -- geq
    [0x02AAF] = 0x16, -- preceq
--  [0x0227C] = 0x16, -- preceq, AM:No see 2AAF
    [0x02AB0] = 0x17, -- succeq
--  [0x0227D] = 0x17, -- succeq, AM:No see 2AB0
    [0x0223C] = 0x18, -- sim
    [0x02248] = 0x19, -- approx
    [0x02282] = 0x1A, -- subset
    [0x02283] = 0x1B, -- supset
    [0x0226A] = 0x1C, -- ll
    [0x0226B] = 0x1D, -- gg
    [0x0227A] = 0x1E, -- prec
    [0x0227B] = 0x1F, -- succ
    [0x02190] = 0x20, -- leftarrow
    [0x02192] = 0x21, -- rightarrow
    [0x02191] = 0x22, -- uparrow
    [0x02193] = 0x23, -- downarrow
    [0x02194] = 0x24, -- leftrightarrow
    [0x02197] = 0x25, -- nearrow
    [0x02198] = 0x26, -- searrow
    [0x02243] = 0x27, -- simeq
    [0x021D0] = 0x28, -- Leftarrow
    [0x021D2] = 0x29, -- Rightarrow
    [0x021D1] = 0x2A, -- Uparrow
    [0x021D3] = 0x2B, -- Downarrow
    [0x021D4] = 0x2C, -- Leftrightarrow
    [0x02196] = 0x2D, -- nwarrow
    [0x02199] = 0x2E, -- swarrow
    [0x0221D] = 0x2F, -- propto
--  [0x02032] = 0x30, -- prime (not really the right symbol)
    [0x0221E] = 0x31, -- infty
    [0x02208] = 0x32, -- in
    [0x0220B] = 0x33, -- ni
    [0x025B3] = 0x34, -- triangle, bigtriangleup
    [0x025BD] = 0x35, -- bigtriangledown
--              0x36, -- not
--              0x37, -- (beginning of arrow)
    [0x02200] = 0x38, -- forall
    [0x02203] = 0x39, -- exists
    [0x000AC] = 0x3A, -- neg, lnot
    [0x02205] = 0x3B, -- empty set
    [0x0211C] = 0x3C, -- Re
    [0x02111] = 0x3D, -- Im
    [0x022A4] = 0x3E, -- top
    [0x022A5] = 0x3F, -- bot, perp
    [0x02135] = 0x40, -- aleph
    [0x1D49C] = 0x41, -- script A
    [0x0212C] = 0x42, -- script B
    [0x1D49E] = 0x43, -- script C
    [0x1D49F] = 0x44, -- script D
    [0x02130] = 0x45, -- script E
    [0x02131] = 0x46, -- script F
    [0x1D4A2] = 0x47, -- script G
    [0x0210B] = 0x48, -- script H
    [0x02110] = 0x49, -- script I
    [0x1D4A5] = 0x4A, -- script J
    [0x1D4A6] = 0x4B, -- script K
    [0x02112] = 0x4C, -- script L
    [0x02133] = 0x4D, -- script M
    [0x1D4A9] = 0x4E, -- script N
    [0x1D4AA] = 0x4F, -- script O
    [0x1D4AB] = 0x50, -- script P
    [0x1D4AC] = 0x51, -- script Q
    [0x0211B] = 0x52, -- script R
    [0x1D4AE] = 0x53, -- script S
    [0x1D4AF] = 0x54, -- script T
    [0x1D4B0] = 0x55, -- script U
    [0x1D4B1] = 0x56, -- script V
    [0x1D4B2] = 0x57, -- script W
    [0x1D4B3] = 0x58, -- script X
    [0x1D4B4] = 0x59, -- script Y
    [0x1D4B5] = 0x5A, -- script Z
    [0x0222A] = 0x5B, -- cup
    [0x02229] = 0x5C, -- cap
    [0x0228E] = 0x5D, -- uplus
    [0x02227] = 0x5E, -- wedge, land
    [0x02228] = 0x5F, -- vee, lor
    [0x022A2] = 0x60, -- vdash
    [0x022A3] = 0x61, -- dashv
    [0x0230A] = 0x62, -- lfloor
    [0x0230B] = 0x63, -- rfloor
    [0x02308] = 0x64, -- lceil
    [0x02309] = 0x65, -- rceil
    [0x0007B] = 0x66, -- {, lbrace
    [0x0007D] = 0x67, -- }, rbrace
    [0x027E8] = 0x68, -- <, langle
    [0x027E9] = 0x69, -- >, rangle
    [0x0007C] = 0x6A, -- |, mid, lvert, rvert
    [0x02225] = 0x6B, -- parallel, Vert, lVert, rVert, arrowvert
    [0x02195] = 0x6C, -- updownarrow
    [0x021D5] = 0x6D, -- Updownarrow
    [0x0005C] = 0x6E, -- \, backslash, setminus
    [0x02216] = 0x6E, -- setminus
    [0x02240] = 0x6F, -- wr
--  [0x0221A] = 0x70, -- sqrt. AM: Check surd??
    [0x02A3F] = 0x71, -- amalg
    [0x02207] = 0x72, -- nabla
    [0x0222B] = 0x73, -- smallint (TODO: what about intop?)
    [0x02294] = 0x74, -- sqcup
    [0x02293] = 0x75, -- sqcap
    [0x02291] = 0x76, -- sqsubseteq
    [0x02292] = 0x77, -- sqsupseteq
    [0x000A7] = 0x78, -- S
    [0x02020] = 0x79, -- dagger, dag
    [0x02021] = 0x7A, -- ddagger, ddag
    [0x000B6] = 0x7B, -- P
    [0x02663] = 0x7C, -- clubsuit
    [0x02662] = 0x7D, -- diamondsuit
    [0x02661] = 0x7E, -- heartsuit
    [0x02660] = 0x7F, -- spadesuit
}

-- The names in masm10.enc can be trusted best and are shown in the first
-- column, while in the second column we show the tex/ams names. As usual
-- it costs hours to figure out such a table.

fonts.enc.math["traditional-ma"] = {
    [0x022A1] = 0x00, -- squaredot             \boxdot
    [0x0229E] = 0x01, -- squareplus            \boxplus
    [0x022A0] = 0x02, -- squaremultiply        \boxtimes
    [0x0033B] = 0x03, -- square                \square \Box
    [0x025A0] = 0x04, -- squaresolid           \blacksquare
    [0x000B7] = 0x05, -- squaresmallsolid      \centerdot
    [0x022C4] = 0x06, -- diamond               \Diamond \lozenge
    [0x029EB] = 0x07, -- diamondsolid          \blacklozenge
    [0x021BA] = 0x08, -- clockwise             \circlearrowright
    [0x021BB] = 0x09, -- anticlockwise         \circlearrowleft
    [0x021CC] = 0x0A, -- harpoonleftright      \rightleftharpoons
    [0x021CB] = 0x0B, -- harpoonrightleft      \leftrightharpoons
    [0x0229F] = 0x0C, -- squareminus           \boxminus
    [0x022A9] = 0x0D, -- forces                \Vdash
    [0x022AA] = 0x0E, -- forcesbar             \Vvdash
    [0x022A8] = 0x0F, -- satisfies             \vDash
    [0x021A0] = 0x10, -- dblarrowheadright     \twoheadrightarrow
    [0x0219E] = 0x11, -- dblarrowheadleft      \twoheadleftarrow
    [0x021C7] = 0x12, -- dblarrowleft          \leftleftarrows
    [0x021C9] = 0x13, -- dblarrowright         \rightrightarrows
    [0x021C8] = 0x14, -- dblarrowup            \upuparrows
    [0x021CA] = 0x15, -- dblarrowdwn           \downdownarrows
    [0x021BE] = 0x16, -- harpoonupright        \upharpoonright \restriction
    [0x021C2] = 0x17, -- harpoondownright      \downharpoonright
    [0x021BF] = 0x18, -- harpoonupleft         \upharpoonleft
    [0x021C3] = 0x19, -- harpoondownleft       \downharpoonleft
    [0x021A3] = 0x1A, -- arrowtailright        \rightarrowtail
    [0x021A2] = 0x1B, -- arrowtailleft         \leftarrowtail
    [0x021C6] = 0x1C, -- arrowparrleftright    \leftrightarrows
    [0x021C4] = 0x1D, -- arrowparrrightleft    \rightleftarrows
    [0x021B0] = 0x1E, -- shiftleft             \Lsh
    [0x021B1] = 0x1F, -- shiftright            \Rsh
    [0x021DD] = 0x20, -- squiggleright         \leadsto \rightsquigarrow
    [0x021AD] = 0x21, -- squiggleleftright     \leftrightsquigarrow
    [0x021AB] = 0x22, -- curlyleft             \looparrowleft
    [0x021AC] = 0x23, -- curlyright            \looparrowright
    [0x02257] = 0x24, -- circleequal           \circeq
    [0x0227F] = 0x25, -- followsorequal        \succsim
    [0x02273] = 0x26, -- greaterorsimilar      \gtrsim
    [0x02A86] = 0x27, -- greaterorapproxeql    \gtrapprox
    [0x022B8] = 0x28, -- multimap              \multimap
    [0x02234] = 0x29, -- therefore             \therefore
    [0x02235] = 0x2A, -- because               \because
    [0x02251] = 0x2B, -- equalsdots            \Doteq \doteqdot
    [0x0225C] = 0x2C, -- defines               \triangleq
    [0x0227E] = 0x2D, -- precedesorequal       \precsim
    [0x02272] = 0x2E, -- lessorsimilar         \lesssim
    [0x02A85] = 0x2F, -- lessorapproxeql       \lessapprox
    [0x02A95] = 0x30, -- equalorless           \eqslantless
    [0x02A96] = 0x31, -- equalorgreater        \eqslantgtr
    [0x022DE] = 0x32, -- equalorprecedes       \curlyeqprec
    [0x022DF] = 0x33, -- equalorfollows        \curlyeqsucc
    [0x0227C] = 0x34, -- precedesorcurly       \preccurlyeq
    [0x02266] = 0x35, -- lessdblequal          \leqq
    [0x02A7D] = 0x36, -- lessorequalslant      \leqslant
    [0x02276] = 0x37, -- lessorgreater         \lessgtr
    [0x02035] = 0x38, -- primereverse          \backprime
    --  [0x0] = 0x39, -- axisshort             \dabar
    [0x02253] = 0x3A, -- equaldotrightleft     \risingdotseq
    [0x02252] = 0x3B, -- equaldotleftright     \fallingdotseq
    [0x0227D] = 0x3C, -- followsorcurly        \succcurlyeq
    [0x02267] = 0x3D, -- greaterdblequal       \geqq
    [0x02A7E] = 0x3E, -- greaterorequalslant   \geqslant
    [0x02277] = 0x3F, -- greaterorless         \gtrless
    [0x0228F] = 0x40, -- squareimage           \sqsubset
    [0x02290] = 0x41, -- squareoriginal        \sqsupset
    -- wrong:
    [0x022B3] = 0x42, -- triangleright         \rhd \vartriangleright
    [0x022B2] = 0x43, -- triangleleft          \lhd \vartriangleleft
    [0x022B5] = 0x44, -- trianglerightequal    \unrhd \trianglerighteq
    [0x022B4] = 0x45, -- triangleleftequal     \unlhd \trianglelefteq
    --
    [0x02605] = 0x46, -- star                  \bigstar
    [0x0226C] = 0x47, -- between               \between
    [0x025BC] = 0x48, -- triangledownsld       \blacktriangledown
    [0x025B6] = 0x49, -- trianglerightsld      \blacktriangleright
    [0x025C0] = 0x4A, -- triangleleftsld       \blacktriangleleft
    --  [0x0] = 0x4B, -- arrowaxisright
    --  [0x0] = 0x4C, -- arrowaxisleft
    [0x025B2] = 0x4D, -- triangle              \triangleup \vartriangle
    [0x025B2] = 0x4E, -- trianglesolid         \blacktriangle
    [0x025BC] = 0x4F, -- triangleinv           \triangledown
    [0x02256] = 0x50, -- ringinequal           \eqcirc
    [0x022DA] = 0x51, -- lessequalgreater      \lesseqgtr
    [0x022DB] = 0x52, -- greaterlessequal      \gtreqless
    [0x02A8B] = 0x53, -- lessdbleqlgreater     \lesseqqgtr
    [0x02A8C] = 0x54, -- greaterdbleqlless     \gtreqqless
    --  [0x0] = 0x55, -- Yen
    [0x021DB] = 0x56, -- arrowtripleright      \Rrightarrow
    [0x021DA] = 0x57, -- arrowtripleleft       \Lleftarrow
    --  [0x0] = 0x58, -- check
    [0x022BB] = 0x59, -- orunderscore          \veebar
    [0x022BC] = 0x5A, -- nand                  \barwedge
    [0x02306] = 0x5B, -- perpcorrespond        \doublebarwedge
    [0x02220] = 0x5C, -- angle                 \angle
    [0x02221] = 0x5D, -- measuredangle         \measuredangle
    [0x02222] = 0x5E, -- sphericalangle        \sphericalangle
    --  [0x0] = 0x5F, -- proportional          \varpropto
    --  [0x0] = 0x60, -- smile                 \smallsmile
    --  [0x0] = 0x61, -- frown                 \smallfrown
    [0x02282] = 0x62, -- subsetdbl             \Subset
    [0x022D1] = 0x63, -- supersetdbl           \Supset
    [0x022D3] = 0x64, -- uniondbl              \doublecup \Cup
    [0x00100] = 0x65, -- intersectiondbl       \doublecap \Cap
    [0x022CF] = 0x66, -- uprise                \curlywedge
    [0x022CE] = 0x67, -- downfall              \curlyvee
    [0x022CB] = 0x68, -- multiopenleft         \leftthreetimes
    [0x022CC] = 0x69, -- multiopenright        \rightthreetimes
    [0x02AC5] = 0x6A, -- subsetdblequal        \subseteqq
    [0x02AC6] = 0x6B, -- supersetdblequal      \supseteqq
    [0x0224F] = 0x6C, -- difference            \bumpeq
    [0x0224E] = 0x6D, -- geomequivalent        \Bumpeq
    [0x022D8] = 0x6E, -- muchless              \lll \llless
    [0x022D9] = 0x6F, -- muchgreater           \ggg \gggtr
    [0x0231C] = 0x70, -- rightanglenw          \ulcorner
    [0x0231D] = 0x71, -- rightanglene          \urcorner
    --  [0x0] = 0x72, -- circleR
    [0x024C8] = 0x73, -- circleS               \circledS
    [0x022D4] = 0x74, -- fork                  \pitchfork
    [0x02245] = 0x75, -- dotplus               \dotplus
    [0x0223D] = 0x76, -- revsimilar            \backsim
    [0x022CD] = 0x77, -- revasymptequal        \backsimeq
    [0x0231E] = 0x78, -- rightanglesw          \llcorner
    [0x0231F] = 0x79, -- rightanglese          \lrcorner
    --  [0X0] = 0X7A,    maltesecross
    [0x02201] = 0x7B, -- complement            \complement
    [0x022BA] = 0x7C, -- intercal              \intercal
    [0x0229A] = 0x7D, -- circlering            \circledcirc
    [0x0229B] = 0x7E, -- circleasterisk        \circledast
    [0x0229D] = 0x7F, -- circleminus           \circleddash
}

fonts.enc.math["traditional-mb"] = {
    --  [0x0] = 0x00, -- lessornotequal        \lvertneqq
    --  [0x0] = 0x01, -- greaterornotequal     \gvertneqq
    [0x02270] = 0x02, -- notlessequal          \nleq
    [0x02271] = 0x03, -- notgreaterequal       \ngeq
    [0x0226E] = 0x04, -- notless               \nless
    [0x0226F] = 0x05, -- notgreater            \ngtr
    [0x02280] = 0x06, -- notprecedes           \nprec
    [0x02281] = 0x07, -- notfollows            \nsucc
    [0x02268] = 0x08, -- lessornotdbleql       \lneqq
    [0x02269] = 0x09, -- greaterornotdbleql    \gneqq
    --  [0x0] = 0x0A, -- notlessorslnteql      \nleqslant
    --  [0x0] = 0x0B, -- notgreaterorslnteql   \ngeqslant
    [0x02268] = 0x0C, -- lessnotequal          \lneq
    [0x02269] = 0x0D, -- greaternotequal       \gneq
    --  [0x0] = 0x0E, -- notprecedesoreql      \npreceq
    --  [0x0] = 0x0F, -- notfollowsoreql       \nsucceq
    [0x022E8] = 0x10, -- precedeornoteqvlnt    \precnsim
    [0x022E9] = 0x11, -- followornoteqvlnt     \succnsim
    [0x022E6] = 0x12, -- lessornotsimilar      \lnsim
    [0x022E7] = 0x13, -- greaterornotsimilar   \gnsim
    --  [0x0] = 0x14, -- notlessdblequal       \nleqq
    --  [0x0] = 0x15, -- notgreaterdblequal    \ngeqq
    [0x02AB5] = 0x16, -- precedenotslnteql     \precneqq
    [0x02AB6] = 0x17, -- follownotslnteql      \succneqq
    [0x02AB9] = 0x18, -- precedenotdbleqv      \precnapprox
    [0x02ABA] = 0x19, -- follownotdbleqv       \succnapprox
    [0x02A89] = 0x1A, -- lessnotdblequal       \lnapprox
    [0x02A8A] = 0x1B, -- greaternotdblequal    \gnapprox
    [0x02241] = 0x1C, -- notsimilar            \nsim
    [0x02247] = 0x1D, -- notapproxequal        \ncong
    --  [0x0] = 0x1E, -- upslope               \diagup
    --  [0x0] = 0x1F, -- downslope             \diagdown
    --  [0x0] = 0x20, -- notsubsetoreql        \varsubsetneq
    --  [0x0] = 0x21, -- notsupersetoreql      \varsupsetneq
    --  [0x0] = 0x22, -- notsubsetordbleql     \nsubseteqq
    --  [0x0] = 0x23, -- notsupersetordbleql   \nsupseteqq
    [0x02ACB] = 0x24, -- subsetornotdbleql     \subsetneqq
    [0x02ACC] = 0x25, -- supersetornotdbleql   \supsetneqq
    --  [0x0] = 0x26, -- subsetornoteql        \varsubsetneqq
    --  [0x0] = 0x27, -- supersetornoteql      \varsupsetneqq
    [0x0228A] = 0x28, -- subsetnoteql          \subsetneq
    [0x0228B] = 0x29, -- supersetnoteql        \supsetneq
    [0x02288] = 0x2A, -- notsubseteql          \nsubseteq
    [0x02289] = 0x2B, -- notsuperseteql        \nsupseteq
    [0x02226] = 0x2C, -- notparallel           \nparallel
    [0x02224] = 0x2D, -- notbar                \nmid
    --  [0x0] = 0x2E, -- notshortbar           \nshortmid
    --  [0x0] = 0x2F, -- notshortparallel      \nshortparallel
    [0x022AC] = 0x30, -- notturnstile          \nvdash
    [0x022AE] = 0x31, -- notforces             \nVdash
    [0x022AD] = 0x32, -- notsatisfies          \nvDash
    [0x022AF] = 0x33, -- notforcesextra        \nVDash
    [0x022ED] = 0x34, -- nottriangeqlright     \ntrianglerighteq
    [0x022EC] = 0x35, -- nottriangeqlleft      \ntrianglelefteq
    [0x022EA] = 0x36, -- nottriangleleft       \ntriangleleft
    [0x022EB] = 0x37, -- nottriangleright      \ntriangleright
    [0x0219A] = 0x38, -- notarrowleft          \nleftarrow
    [0x0219B] = 0x39, -- notarrowright         \nrightarrow
    [0x021CD] = 0x3A, -- notdblarrowleft       \nLeftarrow
    [0x021CF] = 0x3B, -- notdblarrowright      \nRightarrow
    [0x021CE] = 0x3C, -- notdblarrowboth       \nLeftrightarrow
    [0x021AE] = 0x3D, -- notarrowboth          \nleftrightarrow
    [0x022C7] = 0x3E, -- dividemultiply        \divideontimes
    [0x02205] = 0x3F, -- emptyset              \varnothing
    [0x02204] = 0x40, -- notexistential        \nexists
    [0x1D538] = 0x41, -- A                     (blackboard A)
    [0x1D539] = 0x42, -- B
    [0x02102] = 0x43, -- C
    [0x1D53B] = 0x44, -- D
    [0x1D53C] = 0x45, -- E
    [0x1D53D] = 0x46, -- F
    [0x1D53E] = 0x47, -- G
    [0x0210D] = 0x48, -- H
    [0x1D540] = 0x49, -- I
    [0x1D541] = 0x4A, -- J
    [0x1D542] = 0x4B, -- K
    [0x1D543] = 0x4C, -- L
    [0x1D544] = 0x4D, -- M
    [0x02115] = 0x4E, -- N
    [0x1D546] = 0x4F, -- O
    [0x02119] = 0x50, -- P
    [0x0211A] = 0x51, -- Q
    [0x0211D] = 0x52, -- R
    [0x1D54A] = 0x53, -- S
    [0x1D54B] = 0x54, -- T
    [0x1D54C] = 0x55, -- U
    [0x1D54D] = 0x56, -- V
    [0x1D54E] = 0x57, -- W
    [0x1D54F] = 0x58, -- X
    [0x1D550] = 0x59, -- Y
    [0x02124] = 0x5A, -- Z                     (blackboard A)
    [0x02132] = 0x60, -- hatwide               \Finv
    [0x02141] = 0x61, -- hatwider              \Game
    --  [0x0] = 0x62,    tildewide
    --  [0x0] = 0x63,    tildewider
    --  [0x0] = 0x64,    Finv
    --  [0x0] = 0x65,    Gmir
    [0x02127] = 0x66, -- Omegainv              \mho
    [0x02136] = 0x67, -- eth                   \eth
    [0x02242] = 0x68, -- equalorsimilar        \eqsim
    [0x02136] = 0x69, -- beth                  \beth
    [0x02137] = 0x6A, -- gimel                 \gimel
    [0x02138] = 0x6B, -- daleth                \daleth
    [0x022D6] = 0x6C, -- lessdot               \lessdot
    [0x022D7] = 0x6D, -- greaterdot            \gtrdot
    [0x022C9] = 0x6E, -- multicloseleft        \ltimes
    [0x022CA] = 0x6F, -- multicloseright       \rtimes
    --  [0x0] = 0x70, -- barshort              \shortmid
    --  [0x0] = 0x71, -- parallelshort         \shortparallel
    [0x02216] = 0x72, -- integerdivide         \smallsetminus
    --  [0x0] = 0x73, -- similar               \thicksim
    --  [0x0] = 0x74, -- approxequal           \thickapprox
    [0x0224A] = 0x75, -- approxorequal         \approxeq
    [0x02AB8] = 0x76, -- followsorequal        \succapprox
    [0x02AB7] = 0x77, -- precedesorequal       \precapprox
    [0x021B6] = 0x78, -- archleftdown          \curvearrowleft
    [0x021B7] = 0x79, -- archrightdown         \curvearrowright
    [0x003DC] = 0x7A, -- Digamma               \digamma
    [0x003F0] = 0x7B, -- kappa                 \varkappa
    [0x1D55C] = 0x7C, -- k                     \Bbbk (blackboard k)
    [0x0210F] = 0x7D, -- planckover2pi         \hslash
    [0x0210F] = 0x7E, -- planckover2pi1        \hbar
    [0x003F6] = 0x7F, -- epsiloninv            \backepsilon
}

-- todo: add ss, tt, bf etc vectors
-- we can make ss tt etc an option

-- rm-lmr5  : LMMathRoman5-Regular
-- rm-lmbx5 : LMMathRoman5-Bold          ]
-- lmbsy5   : LMMathSymbols5-BoldItalic
-- lmsy5    : LMMathSymbols5-Italic
-- lmmi5    : LMMathItalic5-Italic
-- lmmib5   : LMMathItalic5-BoldItalic

mathematics.make_font ( "lmroman5-math", {
    { name = "lmroman5-regular", features = "default", main = true },
    { name = "rm-lmr5", vector = "traditional-mr" } ,
    { name = "lmmi5", vector = "traditional-mi" },
    { name = "lmsy5", vector = "traditional-sy", parameters = true } ,
    { name = "lmex10", vector = "traditional-ex", extension = true } ,
    { name = "msam5", vector = "traditional-ma" },
    { name = "msbm5", vector = "traditional-mb" },
    { name = "lmsans8-regular", vector = "traditional-ss", optional=true },
    { name = "lmmono8-regular", vector = "traditional-tt", optional=true },
    { name = "rm-lmbx5", vector = "traditional-bf" } ,
    { name = "lmmib5", vector = "traditional-bi" } ,
} )

-- rm-lmr6  : LMMathRoman6-Regular
-- rm-lmbx6 : LMMathRoman6-Bold
-- lmsy6    : LMMathSymbols6-Italic
-- lmmi6    : LMMathItalic6-Italic

mathematics.make_font ( "lmroman6-math", {
    { name = "lmroman6-regular", features = "default", main = true },
    { name = "rm-lmr6", vector = "traditional-mr" } ,
    { name = "lmmi6", vector = "traditional-mi" },
    { name = "lmsy6", vector = "traditional-sy", parameters = true } ,
    { name = "lmex10", vector = "traditional-ex", extension = true } ,
    { name = "msam5", vector = "traditional-ma" },
    { name = "msbm5", vector = "traditional-mb" },
    { name = "lmsans8-regular", vector = "traditional-ss", optional=true },
    { name = "lmmono8-regular", vector = "traditional-tt", optional=true },
    { name = "rm-lmbx6", vector = "traditional-bf" } ,
    { name = "lmmib5", vector = "traditional-bi" } ,
} )

-- rm-lmr7  : LMMathRoman7-Regular
-- rm-lmbx7 : LMMathRoman7-Bold
-- lmbsy7   : LMMathSymbols7-BoldItalic
-- lmsy7    : LMMathSymbols7-Italic
-- lmmi7    : LMMathItalic7-Italic
-- lmmib7   : LMMathItalic7-BoldItalic

mathematics.make_font ( "lmroman7-math", {
    { name = "lmroman7-regular", features = "default", main = true },
    { name = "rm-lmr7", vector = "traditional-mr" } ,
    { name = "lmmi7", vector = "traditional-mi" },
    { name = "lmsy7", vector = "traditional-sy", parameters = true } ,
    { name = "lmex10", vector = "traditional-ex", extension = true } ,
    { name = "msam7", vector = "traditional-ma" },
    { name = "msbm7", vector = "traditional-mb" },
    { name = "lmsans8-regular", vector = "traditional-ss", optional=true },
    { name = "lmmono8-regular", vector = "traditional-tt", optional=true },
    { name = "rm-lmbx7", vector = "traditional-bf" } ,
    { name = "lmmib7", vector = "traditional-bi" } ,
} )

-- rm-lmr8  : LMMathRoman8-Regular
-- rm-lmbx8 : LMMathRoman8-Bold
-- lmsy8    : LMMathSymbols8-Italic
-- lmmi8    : LMMathItalic8-Italic

mathematics.make_font ( "lmroman8-math", {
    { name = "lmroman8-regular", features = "default", main = true },
    { name = "rm-lmr8", vector = "traditional-mr" } ,
    { name = "lmmi8", vector = "traditional-mi" },
    { name = "lmsy8", vector = "traditional-sy", parameters = true } ,
    { name = "lmex10", vector = "traditional-ex", extension = true } ,
    { name = "msam7", vector = "traditional-ma" },
    { name = "msbm7", vector = "traditional-mb" },
    { name = "lmsans8-regular", vector = "traditional-ss", optional=true },
    { name = "lmmono8-regular", vector = "traditional-tt", optional=true },
    { name = "rm-lmbx8", vector = "traditional-bf" } ,
    { name = "lmmib7", vector = "traditional-bi" } ,
} )

-- rm-lmr9  : LMMathRoman9-Regular
-- rm-lmbx9 : LMMathRoman9-Bold
-- lmsy9    : LMMathSymbols9-Italic
-- lmmi9    : LMMathItalic9-Italic

mathematics.make_font ( "lmroman9-math", {
    { name = "lmroman9-regular", features = "default", main = true },
    { name = "rm-lmr9", vector = "traditional-mr" } ,
    { name = "lmmi9", vector = "traditional-mi" },
    { name = "lmsy9", vector = "traditional-sy", parameters = true } ,
    { name = "lmex10", vector = "traditional-ex", extension = true } ,
    { name = "msam10", vector = "traditional-ma" },
    { name = "msbm10", vector = "traditional-mb" },
    { name = "rm-lmbx9", vector = "traditional-bf" } ,
    { name = "lmmib10", vector = "traditional-bi" } ,
    { name = "lmsans9-regular", vector = "traditional-ss", optional=true },
    { name = "lmmono9-regular", vector = "traditional-tt", optional=true },
} )

-- rm-lmr10  : LMMathRoman10-Regular
-- rm-lmbx10 : LMMathRoman10-Bold
-- lmbsy10   : LMMathSymbols10-BoldItalic
-- lmsy10    : LMMathSymbols10-Italic
-- lmex10    : LMMathExtension10-Regular
-- lmmi10    : LMMathItalic10-Italic
-- lmmib10   : LMMathItalic10-BoldItalic

mathematics.make_font ( "lmroman10-math", {
    { name = "lmroman10-regular", features = "default", main = true },
    { name = "rm-lmr10", vector = "traditional-mr" } ,
    { name = "lmmi10", vector = "traditional-mi" },
    { name = "lmsy10", vector = "traditional-sy", parameters = true } ,
    { name = "lmex10", vector = "traditional-ex", extension = true } ,
    { name = "msam10", vector = "traditional-ma" },
    { name = "msbm10", vector = "traditional-mb" },
    { name = "rm-lmbx10", vector = "traditional-bf" } ,
    { name = "lmmib10", vector = "traditional-bi" } ,
    { name = "lmsans10-regular", vector = "traditional-ss", optional=true },
    { name = "lmmono10-regular", vector = "traditional-tt", optional=true },
} )

-- rm-lmr12  : LMMathRoman12-Regular
-- rm-lmbx12 : LMMathRoman12-Bold
-- lmmi12    : LMMathItalic12-Italic

mathematics.make_font ( "lmroman12-math", {
    { name = "lmroman12-regular", features = "default", main = true },
    { name = "rm-lmr12", vector = "traditional-mr" } ,
    { name = "lmmi12", vector = "traditional-mi" },
    { name = "lmsy12", vector = "traditional-sy", parameters = true } ,
    { name = "lmex10", vector = "traditional-ex", extension = true } ,
    { name = "msam10", vector = "traditional-ma" },
    { name = "msbm10", vector = "traditional-mb" },
    { name = "rm-lmbx12", vector = "traditional-bf" } ,
    { name = "lmmib10", vector = "traditional-bi" } ,
    { name = "lmsans12-regular", vector = "traditional-ss", optional=true },
    { name = "lmmono12-regular", vector = "traditional-tt", optional=true },
} )

-- rm-lmr17 : LMMathRoman17-Regular

mathematics.make_font ( "lmroman17-math", {
    { name = "lmroman17-regular", features = "default", main = true },
    { name = "rm-lmr12", vector = "traditional-mr" } ,
    { name = "lmmi12", vector = "traditional-mi" },
    { name = "lmsy12", vector = "traditional-sy", parameters = true } ,
    { name = "lmex10", vector = "traditional-ex", extension = true } ,
    { name = "msam10", vector = "traditional-ma" },
    { name = "msbm10", vector = "traditional-mb" },
    { name = "rm-lmbx12", vector = "traditional-bf" } ,
    { name = "lmmib10", vector = "traditional-bi" } ,
    { name = "lmsans17-regular", vector = "traditional-ss", optional=true },
    { name = "lmmono17-regular", vector = "traditional-tt", optional=true },
} )

mathematics.make_font ( "px-math", {
    { name = "texgyrepagella-regular", features = "default", main = true },
    { name = "pxr", vector = "traditional-mr" } ,
    { name = "pxmi", vector = "traditional-mi" },
    { name = "pxsy", vector = "traditional-sy", parameters = true } ,
    { name = "pxex", vector = "traditional-ex", extension = true } ,
    { name = "pxsya", vector = "traditional-ma" },
    { name = "pxsyb", vector = "traditional-mb" },
} )

mathematics.make_font ( "tx-math", {
    { name = "texgyretermes-regular", features = "default", main = true },
    { name = "txr", vector = "traditional-mr" } ,
    { name = "txmi", vector = "traditional-mi" },
    { name = "txsy", vector = "traditional-sy", parameters = true } ,
    { name = "txex", vector = "traditional-ex", extension = true } ,
    { name = "txsya", vector = "traditional-ma" },
    { name = "txsyb", vector = "traditional-mb" },
} )
