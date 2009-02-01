if not modules then modules = { } end modules ['math-map'] = {
    version   = 1.001,
    comment   = "companion to math-ini.tex",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

--[[ldx--
<p>Remapping mathematics alphabets.</p>
--ldx]]--

-- oldstyle: not really mathematics but happened to be part of
-- the mathematics fonts in cmr
--
-- persian: we will also provide mappers for other
-- scripts

-- todo: alphabets namespace
-- maybe: script/scriptscript dynamic,

local type, next = type, next

local traverse_id   = node.traverse_id
local has_attribute = node.has_attribute
local set_attribute = node.set_attribute
local glyph         = node.id("glyph")

mathematics = mathematics or { }

mathematics.alphabets = {
    regular = {
        tf = {
            digits    = 0x00030,
            ucletters = 0x00041,
            lcletters = 0x00061,
            ucgreek   = 0x00391, -- todo
            lcgreek   = 0x003B1, -- todo
        },
        it = {
            ucletters = 0x1D434,
            lcletters = 0x1D44E,
            ucgreek   = 0x1D6E2, -- todo
            lcgreek   = 0x1D6FC, -- todo
        },
        bf= {
            digits    = 0x1D7CE,
            ucletters = 0x1D400,
            lcletters = 0x1D41A,
            ucgreek   = 0x1D6A8, -- todo
            lcgreek   = 0x1D6C2, -- todo
        },
        bi = {
            ucletters = 0x1D468,
            lcletters = 0x1D482,
            ucgreek   = 0x1D71C, -- todo
            lcgreek   = 0x1D736, -- todo
        },
    },
    sansserif = {
        tf = {
            digits    = 0x1D7E2,
            ucletters = 0x1D5A0,
            lcletters = 0x1D5BA,
        },
        it = {
            ucletters = 0x1D608,
            lcletters = 0x1D622,
        },
        bf = {
            digits    = 0x1D7EC,
            ucletters = 0x1D5D4,
            lcletters = 0x1D5EE,
            ucgreek   = 0x1D756, -- todo
            lcgreek   = 0x1D770, -- todo
        },
        bi = {
            ucletters = 0x1D63C,
            lcletters = 0x1D656,
            ucgreek   = 0x1D790, -- todo
            lcgreek   = 0x1D7AA, -- todo
        },
    },
    monospaced = {
        tf = {
            digits    = 0x1D7F6,
            ucletters = 0x1D670,
            lcletters = 0x1D68A,
        },
    },
    blackboard = { -- ok
        tf = {
            digits    = 0x1D7D8,
            ucletters = { -- C H N P Q R Z
                0x1D538, 0x1D539, 0x02102, 0x1D53B, 0x1D53C, 0x1D53D, 0x1D53E, 0x0210D, 0x1D540, 0x1D541,
                0x1D542, 0x1D543, 0x1D544, 0x02115, 0x1D546, 0x02119, 0x0211A, 0x0211D, 0x1D54A, 0x1D54B,
                0x1D54C, 0x1D54D, 0x1D54E, 0x1D54F, 0x1D550, 0x02124,
            },
            lcletters = 0x1D552,
        },
    },
    fraktur = { -- ok
        tf= {
            ucletters = { -- C H I R Z
                0x1D504, 0x1D505, 0x0212D, 0x1D507, 0x1D508, 0x1D509, 0x1D50A, 0x0210C, 0x02111, 0x1D50D,
                0x1D50E, 0x1D50F, 0x1D510, 0x1D511, 0x1D512, 0x1D513, 0x1D514, 0x0211C, 0x1D516, 0x1D517,
                0x1D518, 0x1D519, 0x1D51A, 0x1D51B, 0x1D51C, 0x02128,
            },
            lcletters = 0x1D51E,
        },
        bf = {
            ucletters = 0x1D56C,
            lcletters = 0x1D586,
        },
    },
    script = {
        tf= {
            ucletters = { -- B E F H I L M R -- P 2118
                0x1D49C, 0x0212C, 0x1D49E, 0x1D49F, 0x02130, 0x02131, 0x1D4A2, 0x0210B, 0x02110, 0x1D4A5,
                0x1D4A6, 0x02112, 0x02133, 0x1D4A9, 0x1D4AA, 0x1D4AB, 0x1D4AC, 0x0211B, 0x1D4AE, 0x1D4AF,
                0x1D4B0, 0x1D4B1, 0x1D4B2, 0x1D4B3, 0x1D4B4, 0x1D4B5,
            },
            lcletters = { -- E G O -- L 2113
                0x1D4B6, 0x1D4B7, 0x1D4B8, 0x1D4B9, 0x0212F, 0x1D4BB, 0x0210A, 0x1D4BD, 0x1D4BE, 0x1D4BF,
                0x1D4C0, 0x1D4C1, 0x1D4C2, 0x1D4C3, 0x02134, 0x1D4C5, 0x1D4C6, 0x1D4C7, 0x1D4C8, 0x1D4C9,
                0x1D4CA, 0x1D4CB, 0x1D4CC, 0x1D4CD, 0x1D4CE, 0x1D4CF,
            }
        },
        bf = {
            ucletters = 0x1D4D0,
            lcletters = 0x1D4EA,
        },
    },
}

local alphabets = mathematics.alphabets
local attribs   = { }

for alphabet, styles in next, alphabets do
    for style, data in next, styles do
     -- let's keep the long names (for tracing)
        local n = #attribs+1
        data.attribute = n
        data.alphabet = alphabet
        data.style = style
        attribs[n] = data
    end
end

-- beware, these are shared tables (no problem since they're not
-- in unicode)

alphabets.regular.it.digits     = alphabets.regular.tf.digits
alphabets.regular.bi.digits     = alphabets.regular.bf.digits

alphabets.sansserif.tf.ucgreek  = alphabets.regular.tf.ucgreek
alphabets.sansserif.tf.lcgreek  = alphabets.regular.tf.lcgreek
alphabets.sansserif.tf.digits   = alphabets.sansserif.tf.digits
alphabets.sansserif.it.ucgreek  = alphabets.sansserif.tf.ucgreek
alphabets.sansserif.it.lcgreek  = alphabets.sansserif.tf.lcgreek
alphabets.sansserif.bi.digits   = alphabets.sansserif.bf.digits

alphabets.monospaced.tf.ucgreek = alphabets.sansserif.tf.ucgreek
alphabets.monospaced.tf.lcgreek = alphabets.sansserif.tf.lcgreek
alphabets.monospaced.it         = alphabets.sansserif.tf
alphabets.monospaced.bf         = alphabets.sansserif.tf
alphabets.monospaced.bi         = alphabets.sansserif.bf

alphabets.blackboard.tf.ucgreek = alphabets.regular.tf.ucgreek
alphabets.blackboard.tf.lcgreek = alphabets.regular.tf.lcgreek
alphabets.blackboard.it         = alphabets.blackboard.tf
alphabets.blackboard.bf         = alphabets.blackboard.tf
alphabets.blackboard.bi         = alphabets.blackboard.bf

alphabets.fraktur.tf.digits     = alphabets.regular.tf.digits
alphabets.fraktur.tf.ucgreek    = alphabets.regular.tf.ucgreek
alphabets.fraktur.tf.lcgreek    = alphabets.regular.tf.lcgreek
alphabets.fraktur.bf.digits     = alphabets.regular.bf.digits
alphabets.fraktur.bf.ucgreek    = alphabets.regular.bf.ucgreek
alphabets.fraktur.bf.lcgreek    = alphabets.regular.bf.lcgreek
alphabets.fraktur.it            = alphabets.fraktur.tf
alphabets.fraktur.bi            = alphabets.fraktur.bf

alphabets.script.tf.digits      = alphabets.regular.tf.digits
alphabets.script.tf.ucgreek     = alphabets.regular.tf.ucgreek
alphabets.script.tf.lcgreek     = alphabets.regular.tf.lcgreek
alphabets.script.bf.digits      = alphabets.regular.bf.digits
alphabets.script.bf.ucgreek     = alphabets.regular.bf.ucgreek
alphabets.script.bf.lcgreek     = alphabets.regular.bf.lcgreek
alphabets.script.it             = alphabets.script.tf
alphabets.script.bi             = alphabets.script.bf

alphabets.tt = alphabets.monospaced
alphabets.ss = alphabets.sansserif
alphabets.rm = alphabets.regular
alphabets.bb = alphabets.blackboard
alphabets.fr = alphabets.fraktur
alphabets.sr = alphabets.script

alphabets.serif    = alphabets.regular
alphabets.type     = alphabets.monospaced
alphabets.teletype = alphabets.monospaced

function mathematics.to_a_style(attribute)
    local r = attribs[attribute]
    return r and r.style or "tf"
end

function mathematics.to_a_name(attribute)
    local r = attribs[attribute]
    return r and r.alphabet or "regular"
end

-- of course we could do some div/mod trickery instead

function mathematics.sync_a_both(attribute,alphabet,style)
    local data = alphabets[alphabet or "regular"] or alphabets.regular
    data = data[style or "tf"] or data.tf
    return data and data.attribute or attribute
end

function mathematics.sync_a_style(attribute,style)
    local r = attribs[attribute]
    local alphabet = r and r.alphabet or "regular"
    local data = alphabets[alphabet][style]
    return data and data.attribute or attribute
end

function mathematics.sync_a_name(attribute,alphabet)
    local r = attribs[attribute]
    local style = r and r.style or "tf"
    local data = alphabets[alphabet][style]
    return data and data.attribute or attribute
end

function mathematics.remap_alphabets(attribute,char)
    -- we could use a map[attribute][char] => newchar but first we have
    -- to finish the table
    local offset = attribs[attribute]
    if offset then
        local newchar
        if     char >= 0x030 and char <= 0x039 then
            local o = offset.digits
            newchar = (type(o) == "table" and o[char - 0x030 + 1]) or (char - 0x030 + o)
        elseif char >= 0x061 and char <= 0x07A then
            local o = offset.lcletters
            newchar = (type(o) == "table" and o[char - 0x061 + 1]) or (char - 0x061 + o)
        elseif char >= 0x3B1 and char <= 0x3C9 then
            local o = offset.lcgreek
            newchar = (type(o) == "table" and o[char - 0x0B1 + 1]) or (char - 0x0B1 + o)
        elseif char >= 0x041 and char <= 0x05A then
            local o = offset.ucletters
            newchar = (type(o) == "table" and o[char - 0x041 + 1]) or (char - 0x041 + o)
        elseif char >= 0x391 and char <= 0x3A9 then
            local o = offset.ucgreek
            newchar = (type(o) == "table" and o[char - 0x391 + 1]) or (char - 0x391 + o)
        end
        return newchar ~= char and newchar
    end
    return nil
end
