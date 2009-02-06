if not modules then modules = { } end modules ['math-dim'] = {
    version   = 1.001,
    comment   = "companion to math-ini.tex",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

-- Beware: only Taco really understands what these dimensions do so if you
-- run into problems ...

local abs, next = math.abs, next

mathematics = mathematics or { }

local defaults = {
    ['axis']={
        ['cramped_display_style']={ "AxisHeight", "axis_height" },
        ['cramped_script_script_style']={ "AxisHeight", "axis_height" },
        ['cramped_script_style']={ "AxisHeight", "axis_height" },
        ['cramped_text_style']={ "AxisHeight", "axis_height" },
        ['display_style']={ "AxisHeight", "axis_height" },
        ['script_script_style']={ "AxisHeight", "axis_height" },
        ['script_style']={ "AxisHeight", "axis_height" },
        ['text_style']={ "AxisHeight", "axis_height" },
    },
    ['accent_base_height']={
        ['cramped_display_style']={ "AccentBaseHeight", "x_height" },
        ['cramped_script_script_style']={ "AccentBaseHeight", "x_height" },
        ['cramped_script_style']={ "AccentBaseHeight", "x_height" },
        ['cramped_text_style']={ "AccentBaseHeight", "x_height" },
        ['display_style']={ "AccentBaseHeight", "x_height" },
        ['script_script_style']={ "AccentBaseHeight", "x_height" },
        ['script_style']={ "AccentBaseHeight", "x_height" },
        ['text_style']={ "AccentBaseHeight", "x_height" },
    },
    ['fraction_del_size']={
        ['cramped_display_style']={ "0", "delim1" },
        ['cramped_script_script_style']={ "0", "delim2" },
        ['cramped_script_style']={ "0", "delim2" },
        ['cramped_text_style']={ "0", "delim2" },
        ['display_style']={ "0", "delim1" },
        ['script_script_style']={ "0", "delim2" },
        ['script_style']={ "0", "delim2" },
        ['text_style']={ "0", "delim2" },
     },
    ['fraction_denom_down']={
        ['cramped_display_style']={ "FractionDenominatorDisplayStyleShiftDown", "denom1" },
        ['cramped_script_script_style']={ "FractionDenominatorShiftDown", "denom2" },
        ['cramped_script_style']={ "FractionDenominatorShiftDown", "denom2" },
        ['cramped_text_style']={ "FractionDenominatorShiftDown", "denom2" },
        ['display_style']={ "FractionDenominatorDisplayStyleShiftDown", "denom1" },
        ['script_script_style']={ "FractionDenominatorShiftDown", "denom2" },
        ['script_style']={ "FractionDenominatorShiftDown", "denom2" },
        ['text_style']={ "FractionDenominatorShiftDown", "denom2" },
     },
    ['fraction_denom_vgap']={
        ['cramped_display_style']={ "FractionDenominatorDisplayStyleGapMin", "3*default_rule_thickness" },
        ['cramped_script_script_style']={ "FractionDenominatorGapMin", "default_rule_thickness" },
        ['cramped_script_style']={ "FractionDenominatorGapMin", "default_rule_thickness" },
        ['cramped_text_style']={ "FractionDenominatorGapMin", "default_rule_thickness" },
        ['display_style']={ "FractionDenominatorDisplayStyleGapMin", "3*default_rule_thickness" },
        ['script_script_style']={ "FractionDenominatorGapMin", "default_rule_thickness" },
        ['script_style']={ "FractionDenominatorGapMin", "default_rule_thickness" },
        ['text_style']={ "FractionDenominatorGapMin", "default_rule_thickness" },
     },
    ['fraction_num_up']={
        ['cramped_display_style']={ "FractionNumeratorDisplayStyleShiftUp", "num1" },
        ['cramped_script_script_style']={ "FractionNumeratorShiftUp", "num2" },
        ['cramped_script_style']={ "FractionNumeratorShiftUp", "num2" },
        ['cramped_text_style']={ "FractionNumeratorShiftUp", "num2" },
        ['display_style']={ "FractionNumeratorDisplayStyleShiftUp", "num1" },
        ['script_script_style']={ "FractionNumeratorShiftUp", "num2" },
        ['script_style']={ "FractionNumeratorShiftUp", "num2" },
        ['text_style']={ "FractionNumeratorShiftUp", "num2" },
     },
     ['fraction_num_vgap']={
        ['cramped_display_style']={ "FractionNumeratorDisplayStyleGapMin", "3*default_rule_thickness" },
        ['cramped_script_script_style']={ "FractionNumeratorGapMin", "default_rule_thickness" },
        ['cramped_script_style']={ "FractionNumeratorGapMin", "default_rule_thickness" },
        ['cramped_text_style']={ "FractionNumeratorGapMin", "default_rule_thickness" },
        ['display_style']={ "FractionNumeratorDisplayStyleGapMin", "3*default_rule_thickness" },
        ['script_script_style']={ "FractionNumeratorGapMin", "default_rule_thickness" },
        ['script_style']={ "FractionNumeratorGapMin", "default_rule_thickness" },
        ['text_style']={ "FractionNumeratorGapMin", "default_rule_thickness" },
     },
    ['fraction_rule']={
        ['cramped_display_style']={ "FractionRuleThickness", "default_rule_thickness" },
        ['cramped_script_script_style']={ "FractionRuleThickness", "default_rule_thickness" },
        ['cramped_script_style']={ "FractionRuleThickness", "default_rule_thickness" },
        ['cramped_text_style']={ "FractionRuleThickness", "default_rule_thickness" },
        ['display_style']={ "FractionRuleThickness", "default_rule_thickness" },
        ['script_script_style']={ "FractionRuleThickness", "default_rule_thickness" },
        ['script_style']={ "FractionRuleThickness", "default_rule_thickness" },
        ['text_style']={ "FractionRuleThickness", "default_rule_thickness" },
     },
    ['limit_above_bgap']={
        ['cramped_display_style']={ "UpperLimitBaselineRiseMin", "big_op_spacing3" },
        ['cramped_script_script_style']={ "UpperLimitBaselineRiseMin", "big_op_spacing3" },
        ['cramped_script_style']={ "UpperLimitBaselineRiseMin", "big_op_spacing3" },
        ['cramped_text_style']={ "UpperLimitBaselineRiseMin", "big_op_spacing3" },
        ['display_style']={ "UpperLimitBaselineRiseMin", "big_op_spacing3" },
        ['script_script_style']={ "UpperLimitBaselineRiseMin", "big_op_spacing3" },
        ['script_style']={ "UpperLimitBaselineRiseMin", "big_op_spacing3" },
        ['text_style']={ "UpperLimitBaselineRiseMin", "big_op_spacing3" },
     },
    ['limit_above_kern']={
        ['cramped_display_style']={ "0", "big_op_spacing5" },
        ['cramped_script_script_style']={ "0", "big_op_spacing5" },
        ['cramped_script_style']={ "0", "big_op_spacing5" },
        ['cramped_text_style']={ "0", "big_op_spacing5" },
        ['display_style']={ "0", "big_op_spacing5" },
        ['script_script_style']={ "0", "big_op_spacing5" },
        ['script_style']={ "0", "big_op_spacing5" },
        ['text_style']={ "0", "big_op_spacing5" },
     },
    ['limit_above_vgap']={
        ['cramped_display_style']={ "UpperLimitGapMin", "big_op_spacing1" },
        ['cramped_script_script_style']={ "UpperLimitGapMin", "big_op_spacing1" },
        ['cramped_script_style']={ "UpperLimitGapMin", "big_op_spacing1" },
        ['cramped_text_style']={ "UpperLimitGapMin", "big_op_spacing1" },
        ['display_style']={ "UpperLimitGapMin", "big_op_spacing1" },
        ['script_script_style']={ "UpperLimitGapMin", "big_op_spacing1" },
        ['script_style']={ "UpperLimitGapMin", "big_op_spacing1" },
        ['text_style']={ "UpperLimitGapMin", "big_op_spacing1" },
     },
    ['limit_below_bgap']={
        ['cramped_display_style']={ "LowerLimitBaselineDropMin", "big_op_spacing4" },
        ['cramped_script_script_style']={ "LowerLimitBaselineDropMin", "big_op_spacing4" },
        ['cramped_script_style']={ "LowerLimitBaselineDropMin", "big_op_spacing4" },
        ['cramped_text_style']={ "LowerLimitBaselineDropMin", "big_op_spacing4" },
        ['display_style']={ "LowerLimitBaselineDropMin", "big_op_spacing4" },
        ['script_script_style']={ "LowerLimitBaselineDropMin", "big_op_spacing4" },
        ['script_style']={ "LowerLimitBaselineDropMin", "big_op_spacing4" },
        ['text_style']={ "LowerLimitBaselineDropMin", "big_op_spacing4" },
     },
    ['limit_below_kern']={
        ['cramped_display_style']={ "0", "big_op_spacing5" },
        ['cramped_script_script_style']={ "0", "big_op_spacing5" },
        ['cramped_script_style']={ "0", "big_op_spacing5" },
        ['cramped_text_style']={ "0", "big_op_spacing5" },
        ['display_style']={ "0", "big_op_spacing5" },
        ['script_script_style']={ "0", "big_op_spacing5" },
        ['script_style']={ "0", "big_op_spacing5" },
        ['text_style']={ "0", "big_op_spacing5" },
     },
    ['limit_below_vgap']={
        ['cramped_display_style']={ "LowerLimitGapMin", "big_op_spacing2" },
        ['cramped_script_script_style']={ "LowerLimitGapMin", "big_op_spacing2" },
        ['cramped_script_style']={ "LowerLimitGapMin", "big_op_spacing2" },
        ['cramped_text_style']={ "LowerLimitGapMin", "big_op_spacing2" },
        ['display_style']={ "LowerLimitGapMin", "big_op_spacing2" },
        ['script_script_style']={ "LowerLimitGapMin", "big_op_spacing2" },
        ['script_style']={ "LowerLimitGapMin", "big_op_spacing2" },
        ['text_style']={ "LowerLimitGapMin", "big_op_spacing2" },
     },
    ['overbar_kern']={
        ['cramped_display_style']={ "OverbarExtraAscender", "default_rule_thickness" },
        ['cramped_script_script_style']={ "OverbarExtraAscender", "default_rule_thickness" },
        ['cramped_script_style']={ "OverbarExtraAscender", "default_rule_thickness" },
        ['cramped_text_style']={ "OverbarExtraAscender", "default_rule_thickness" },
        ['display_style']={ "OverbarExtraAscender", "default_rule_thickness" },
        ['script_script_style']={ "OverbarExtraAscender", "default_rule_thickness" },
        ['script_style']={ "OverbarExtraAscender", "default_rule_thickness" },
        ['text_style']={ "OverbarExtraAscender", "default_rule_thickness" },
     },
    ['overbar_rule']={
        ['cramped_display_style']={ "OverbarRuleThickness", "default_rule_thickness" },
        ['cramped_script_script_style']={ "OverbarRuleThickness", "default_rule_thickness" },
        ['cramped_script_style']={ "OverbarRuleThickness", "default_rule_thickness" },
        ['cramped_text_style']={ "OverbarRuleThickness", "default_rule_thickness" },
        ['display_style']={ "OverbarRuleThickness", "default_rule_thickness" },
        ['script_script_style']={ "OverbarRuleThickness", "default_rule_thickness" },
        ['script_style']={ "OverbarRuleThickness", "default_rule_thickness" },
        ['text_style']={ "OverbarRuleThickness", "default_rule_thickness" },
     },
    ['overbar_vgap']={
        ['cramped_display_style']={ "OverbarVerticalGap", "3*default_rule_thickness" },
        ['cramped_script_script_style']={ "OverbarVerticalGap", "3*default_rule_thickness" },
        ['cramped_script_style']={ "OverbarVerticalGap", "3*default_rule_thickness" },
        ['cramped_text_style']={ "OverbarVerticalGap", "3*default_rule_thickness" },
        ['display_style']={ "OverbarVerticalGap", "3*default_rule_thickness" },
        ['script_script_style']={ "OverbarVerticalGap", "3*default_rule_thickness" },
        ['script_style']={ "OverbarVerticalGap", "3*default_rule_thickness" },
        ['text_style']={ "OverbarVerticalGap", "3*default_rule_thickness" },
     },
    ['quad']={
        ['cramped_display_style']={ "font_size(f)", "math_quad" },
        ['cramped_script_script_style']={ "font_size(f)", "math_quad" },
        ['cramped_script_style']={ "font_size(f)", "math_quad" },
        ['cramped_text_style']={ "font_size(f)", "math_quad" },
        ['display_style']={ "font_size(f)", "math_quad" },
        ['script_script_style']={ "font_size(f)", "math_quad" },
        ['script_style']={ "font_size(f)", "math_quad" },
        ['text_style']={ "font_size(f)", "math_quad" },
     },
    ['radical_kern']={
        ['cramped_display_style']={ "RadicalExtraAscender", "default_rule_thickness" },
        ['cramped_script_script_style']={ "RadicalExtraAscender", "default_rule_thickness" },
        ['cramped_script_style']={ "RadicalExtraAscender", "default_rule_thickness" },
        ['cramped_text_style']={ "RadicalExtraAscender", "default_rule_thickness" },
        ['display_style']={ "RadicalExtraAscender", "default_rule_thickness" },
        ['script_script_style']={ "RadicalExtraAscender", "default_rule_thickness" },
        ['script_style']={ "RadicalExtraAscender", "default_rule_thickness" },
        ['text_style']={ "RadicalExtraAscender", "default_rule_thickness" },
     },
    ['radical_rule']={
        ['cramped_display_style']={ "RadicalRuleThickness", "<not set>" },
        ['cramped_script_script_style']={ "RadicalRuleThickness", "<not set>" },
        ['cramped_script_style']={ "RadicalRuleThickness", "<not set>" },
        ['cramped_text_style']={ "RadicalRuleThickness", "<not set>" },
        ['display_style']={ "RadicalRuleThickness", "<not set>" },
        ['script_script_style']={ "RadicalRuleThickness", "<not set>" },
        ['script_style']={ "RadicalRuleThickness", "<not set>" },
        ['text_style']={ "RadicalRuleThickness", "<not set>" },
     },
    ['radical_vgap']={
        ['cramped_display_style']={ "RadicalDisplayStyleVerticalGap", "default_rule_thickness+(abs(default_rule_thickness)/4)" },
        ['cramped_script_script_style']={ "RadicalVerticalGap", "default_rule_thickness+(abs(default_rule_thickness)/4)" },
        ['cramped_script_style']={ "RadicalVerticalGap", "default_rule_thickness+(abs(default_rule_thickness)/4)" },
        ['cramped_text_style']={ "RadicalVerticalGap", "default_rule_thickness+(abs(default_rule_thickness)/4)" },
        ['display_style']={ "RadicalDisplayStyleVerticalGap", "default_rule_thickness+(abs(default_rule_thickness)/4)" },
        ['script_script_style']={ "RadicalVerticalGap", "default_rule_thickness+(abs(default_rule_thickness)/4)" },
        ['script_style']={ "RadicalVerticalGap", "default_rule_thickness+(abs(default_rule_thickness)/4)" },
        ['text_style']={ "RadicalVerticalGap", "default_rule_thickness+(abs(default_rule_thickness)/4)" },
     },
    ['space_after_script']={
        ['cramped_display_style']={ "SpaceAfterScript", "script_space" },
        ['cramped_script_script_style']={ "SpaceAfterScript", "script_space" },
        ['cramped_script_style']={ "SpaceAfterScript", "script_space" },
        ['cramped_text_style']={ "SpaceAfterScript", "script_space" },
        ['display_style']={ "SpaceAfterScript", "script_space" },
        ['script_script_style']={ "SpaceAfterScript", "script_space" },
        ['script_style']={ "SpaceAfterScript", "script_space" },
        ['text_style']={ "SpaceAfterScript", "script_space" },
     },
    ['stack_denom_down']={
        ['cramped_display_style']={ "StackBottomDisplayStyleShiftDown", "denom1" },
        ['cramped_script_script_style']={ "StackBottomShiftDown", "denom2" },
        ['cramped_script_style']={ "StackBottomShiftDown", "denom2" },
        ['cramped_text_style']={ "StackBottomShiftDown", "denom2" },
        ['display_style']={ "StackBottomDisplayStyleShiftDown", "denom1" },
        ['script_script_style']={ "StackBottomShiftDown", "denom2" },
        ['script_style']={ "StackBottomShiftDown", "denom2" },
        ['text_style']={ "StackBottomShiftDown", "denom2" },
     },
    ['stack_num_up']={
        ['cramped_display_style']={ "StackTopDisplayStyleShiftUp", "num1" },
        ['cramped_script_script_style']={ "StackTopShiftUp", "num3" },
        ['cramped_script_style']={ "StackTopShiftUp", "num3" },
        ['cramped_text_style']={ "StackTopShiftUp", "num3" },
        ['display_style']={ "StackTopDisplayStyleShiftUp", "num1" },
        ['script_script_style']={ "StackTopShiftUp", "num3" },
        ['script_style']={ "StackTopShiftUp", "num3" },
        ['text_style']={ "StackTopShiftUp", "num3" },
     },
    ['stack_vgap']={
        ['cramped_display_style']={ "StackDisplayStyleGapMin", "7*default_rule_thickness" },
        ['cramped_script_script_style']={ "StackGapMin", "3*default_rule_thickness" },
        ['cramped_script_style']={ "StackGapMin", "3*default_rule_thickness" },
        ['cramped_text_style']={ "StackGapMin", "3*default_rule_thickness" },
        ['display_style']={ "StackDisplayStyleGapMin", "7*default_rule_thickness" },
        ['script_script_style']={ "StackGapMin", "3*default_rule_thickness" },
        ['script_style']={ "StackGapMin", "3*default_rule_thickness" },
        ['text_style']={ "StackGapMin", "3*default_rule_thickness" },
     },
    ['sub_shift_down']={
        ['cramped_display_style']={ "SubscriptShiftDown", "sub1" },
        ['cramped_script_script_style']={ "SubscriptShiftDown", "sub1" },
        ['cramped_script_style']={ "SubscriptShiftDown", "sub1" },
        ['cramped_text_style']={ "SubscriptShiftDown", "sub1" },
        ['display_style']={ "SubscriptShiftDown", "sub1" },
        ['script_script_style']={ "SubscriptShiftDown", "sub1" },
        ['script_style']={ "SubscriptShiftDown", "sub1" },
        ['text_style']={ "SubscriptShiftDown", "sub1" },
     },
    ['sub_shift_drop']={
        ['cramped_display_style']={ "SubscriptBaselineDropMin", "sub_drop" },
        ['cramped_script_script_style']={ "SubscriptBaselineDropMin", "sub_drop" },
        ['cramped_script_style']={ "SubscriptBaselineDropMin", "sub_drop" },
        ['cramped_text_style']={ "SubscriptBaselineDropMin", "sub_drop" },
        ['display_style']={ "SubscriptBaselineDropMin", "sub_drop" },
        ['script_script_style']={ "SubscriptBaselineDropMin", "sub_drop" },
        ['script_style']={ "SubscriptBaselineDropMin", "sub_drop" },
        ['text_style']={ "SubscriptBaselineDropMin", "sub_drop" },
     },
    ['sub_sup_shift_down']={
        ['cramped_display_style']={ "SubscriptShiftDown", "sub2" },
        ['cramped_script_script_style']={ "SubscriptShiftDown", "sub2" },
        ['cramped_script_style']={ "SubscriptShiftDown", "sub2" },
        ['cramped_text_style']={ "SubscriptShiftDown", "sub2" },
        ['display_style']={ "SubscriptShiftDown", "sub2" },
        ['script_script_style']={ "SubscriptShiftDown", "sub2" },
        ['script_style']={ "SubscriptShiftDown", "sub2" },
        ['text_style']={ "SubscriptShiftDown", "sub2" },
     },
    ['sub_top_max']={
        ['cramped_display_style']={ "SubscriptTopMax", "abs(math_x_height*4)/5" },
        ['cramped_script_script_style']={ "SubscriptTopMax", "abs(math_x_height*4)/5" },
        ['cramped_script_style']={ "SubscriptTopMax", "abs(math_x_height*4)/5" },
        ['cramped_text_style']={ "SubscriptTopMax", "abs(math_x_height*4)/5" },
        ['display_style']={ "SubscriptTopMax", "abs(math_x_height*4)/5" },
        ['script_script_style']={ "SubscriptTopMax", "abs(math_x_height*4)/5" },
        ['script_style']={ "SubscriptTopMax", "abs(math_x_height*4)/5" },
        ['text_style']={ "SubscriptTopMax", "abs(math_x_height*4)/5" },
     },
    ['subsup_vgap']={
        ['cramped_display_style']={ "SubSuperscriptGapMin", "4*default_rule_thickness" },
        ['cramped_script_script_style']={ "SubSuperscriptGapMin", "4*default_rule_thickness" },
        ['cramped_script_style']={ "SubSuperscriptGapMin", "4*default_rule_thickness" },
        ['cramped_text_style']={ "SubSuperscriptGapMin", "4*default_rule_thickness" },
        ['display_style']={ "SubSuperscriptGapMin", "4*default_rule_thickness" },
        ['script_script_style']={ "SubSuperscriptGapMin", "4*default_rule_thickness" },
        ['script_style']={ "SubSuperscriptGapMin", "4*default_rule_thickness" },
        ['text_style']={ "SubSuperscriptGapMin", "4*default_rule_thickness" },
     },
    ['sup_bottom_min']={
        ['cramped_display_style']={ "SuperscriptBottomMin", "abs(math_x_height)/4" },
        ['cramped_script_script_style']={ "SuperscriptBottomMin", "abs(math_x_height)/4" },
        ['cramped_script_style']={ "SuperscriptBottomMin", "abs(math_x_height)/4" },
        ['cramped_text_style']={ "SuperscriptBottomMin", "abs(math_x_height)/4" },
        ['display_style']={ "SuperscriptBottomMin", "abs(math_x_height)/4" },
        ['script_script_style']={ "SuperscriptBottomMin", "abs(math_x_height)/4" },
        ['script_style']={ "SuperscriptBottomMin", "abs(math_x_height)/4" },
        ['text_style']={ "SuperscriptBottomMin", "abs(math_x_height)/4" },
     },
    ['sup_shift_drop']={
        ['cramped_display_style']={ "SuperscriptBaselineDropMax", "sup_drop" },
        ['cramped_script_script_style']={ "SuperscriptBaselineDropMax", "sup_drop" },
        ['cramped_script_style']={ "SuperscriptBaselineDropMax", "sup_drop" },
        ['cramped_text_style']={ "SuperscriptBaselineDropMax", "sup_drop" },
        ['display_style']={ "SuperscriptBaselineDropMax", "sup_drop" },
        ['script_script_style']={ "SuperscriptBaselineDropMax", "sup_drop" },
        ['script_style']={ "SuperscriptBaselineDropMax", "sup_drop" },
        ['text_style']={ "SuperscriptBaselineDropMax", "sup_drop" },
     },
    ['sup_shift_up']={
        ['cramped_display_style']={ "SuperscriptShiftUpCramped", "sup3" },
        ['cramped_script_script_style']={ "SuperscriptShiftUpCramped", "sup3" },
        ['cramped_script_style']={ "SuperscriptShiftUpCramped", "sup3" },
        ['cramped_text_style']={ "SuperscriptShiftUpCramped", "sup3" },
        ['display_style']={ "SuperscriptShiftUp", "sup1" },
        ['script_script_style']={ "SuperscriptShiftUp", "sup2" },
        ['script_style']={ "SuperscriptShiftUp", "sup2" },
        ['text_style']={ "SuperscriptShiftUp", "sup2" },
     },
    ['sup_sub_bottom_max']={
        ['cramped_display_style']={ "SuperscriptBottomMaxWithSubscript", "abs(math_x_height*4)/5" },
        ['cramped_script_script_style']={ "SuperscriptBottomMaxWithSubscript", "abs(math_x_height*4)/5" },
        ['cramped_script_style']={ "SuperscriptBottomMaxWithSubscript", "abs(math_x_height*4)/5" },
        ['cramped_text_style']={ "SuperscriptBottomMaxWithSubscript", "abs(math_x_height*4)/5" },
        ['display_style']={ "SuperscriptBottomMaxWithSubscript", "abs(math_x_height*4)/5" },
        ['script_script_style']={ "SuperscriptBottomMaxWithSubscript", "abs(math_x_height*4)/5" },
        ['script_style']={ "SuperscriptBottomMaxWithSubscript", "abs(math_x_height*4)/5" },
        ['text_style']={ "SuperscriptBottomMaxWithSubscript", "abs(math_x_height*4)/5" },
     },
    ['underbar_kern']={
        ['cramped_display_style']={ "UnderbarExtraDescender", "0" },
        ['cramped_script_script_style']={ "UnderbarExtraDescender", "0" },
        ['cramped_script_style']={ "UnderbarExtraDescender", "0" },
        ['cramped_text_style']={ "UnderbarExtraDescender", "0" },
        ['display_style']={ "UnderbarExtraDescender", "0" },
        ['script_script_style']={ "UnderbarExtraDescender", "0" },
        ['script_style']={ "UnderbarExtraDescender", "0" },
        ['text_style']={ "UnderbarExtraDescender", "0" },
     },
    ['underbar_rule']={
        ['cramped_display_style']={ "UnderbarRuleThickness", "default_rule_thickness" },
        ['cramped_script_script_style']={ "UnderbarRuleThickness", "default_rule_thickness" },
        ['cramped_script_style']={ "UnderbarRuleThickness", "default_rule_thickness" },
        ['cramped_text_style']={ "UnderbarRuleThickness", "default_rule_thickness" },
        ['display_style']={ "UnderbarRuleThickness", "default_rule_thickness" },
        ['script_script_style']={ "UnderbarRuleThickness", "default_rule_thickness" },
        ['script_style']={ "UnderbarRuleThickness", "default_rule_thickness" },
        ['text_style']={ "UnderbarRuleThickness", "default_rule_thickness" },
    },
    ['underbar_vgap']={
        ['cramped_display_style']={ "UnderbarVerticalGap", "3*default_rule_thickness" },
        ['cramped_script_script_style']={ "UnderbarVerticalGap", "3*default_rule_thickness" },
        ['cramped_script_style']={ "UnderbarVerticalGap", "3*default_rule_thickness" },
        ['cramped_text_style']={ "UnderbarVerticalGap", "3*default_rule_thickness" },
        ['display_style']={ "UnderbarVerticalGap", "3*default_rule_thickness" },
        ['script_script_style']={ "UnderbarVerticalGap", "3*default_rule_thickness" },
        ['script_style']={ "UnderbarVerticalGap", "3*default_rule_thickness" },
        ['text_style']={ "UnderbarVerticalGap", "3*default_rule_thickness" },
    },
}

-- MinimumDisplayOperatorHeight : <unset>

function mathematics.dimensions(dimens)
    if dimens.AxisHeight or dimens.axis_height then
        local t = { }
        local math_x_height = dimens.x_height or 10*65526
        local default_rule_thickness = dimens.FractionDenominatorGapMin or dimens.default_rule_thickness or 0.4*65526
        dimens["0"] = 0
        dimens["3*default_rule_thickness"] = 3*default_rule_thickness
        dimens["4*default_rule_thickness"] = 4*default_rule_thickness
        dimens["7*default_rule_thickness"] = 7*default_rule_thickness
        dimens["abs(math_x_height*4)/5"] = abs(math_x_height * 4) / 5
        dimens["default_rule_thickness+(abs(math_x_height)/4)"] = default_rule_thickness+(abs(math_x_height)/4)
        dimens["abs(math_x_height)/4"] = abs(math_x_height)/4
        dimens["abs(math_x_height*4)/5"] = abs(math_x_height*4)/5
        dimens["<not set>"] = false
        dimens["script_space"] = false -- at macro level
        for variable, styles in next, defaults do
            local tt = { }
            for style, default in next, styles do
                local one, two = default[1], default[2]
                local value = dimens[one]
                if value then
                    tt[style] = value
                else
                    value = dimens[two]
                    if value == false then
                        tt[style] = nil
                    else
                        tt[style] = value or 0
                    end
                end
            end
            t[variable] = tt
        end
        local d = {
            AxisHeight                                  = t . axis                . text_style,
            AccentBaseHeight                            = t . accent_base_height  . text_style,
            FractionDenominatorDisplayStyleGapMin       = t . fraction_denom_vgap . display_style,
            FractionDenominatorDisplayStyleShiftDown    = t . fraction_denom_down . display_style,
            FractionDenominatorGapMin                   = t . fraction_denom_vgap . text_style,
            FractionDenominatorShiftDown                = t . fraction_denom_down . text_style,
            FractionNumeratorDisplayStyleGapMin         = t . fraction_num_vgap   . display_style,
            FractionNumeratorDisplayStyleShiftUp        = t . fraction_num_up     . display_style,
            FractionNumeratorGapMin                     = t . fraction_num_vgap   . text_style,
            FractionNumeratorShiftUp                    = t . fraction_num_up     . text_style,
            FractionRuleThickness                       = t . fraction_rule       . text_style,
            LowerLimitBaselineDropMin                   = t . limit_below_bgap    . text_style,
            LowerLimitGapMin                            = t . limit_below_vgap    . text_style,
            OverbarExtraAscender                        = t . overbar_kern        . text_style,
            OverbarRuleThickness                        = t . overbar_rule        . text_style,
            OverbarVerticalGap                          = t . overbar_vgap        . text_style,
            RadicalDisplayStyleVerticalGap              = t . radical_vgap        . display_style,
            RadicalExtraAscender                        = t . radical_kern        . text_style,
            RadicalRuleThickness                        = t . radical_rule        . text_style,
            RadicalVerticalGap                          = t . radical_vgap        . text_style,
            SpaceAfterScript                            = t . space_after_script  . text_style,
            StackBottomDisplayStyleShiftDown            = t . stack_denom_down    . display_style,
            StackBottomShiftDown                        = t . stack_denom_down    . text_style,
            StackDisplayStyleGapMin                     = t . stack_vgap          . display_style,
            StackGapMin                                 = t . stack_vgap          . text_style,
            StackTopDisplayStyleShiftUp                 = t . stack_num_up        . display_style,
            StackTopShiftUp                             = t . stack_num_up        . text_style,
            SubscriptBaselineDropMin                    = t . sub_shift_drop      . text_style,
            SubscriptShiftDown                          = t . sub_shift_down      . text_style,
            SubscriptTopMax                             = t . sub_top_max         . text_style,
            SubSuperscriptGapMin                        = t . subsup_vgap         . text_style,
            SuperscriptBaselineDropMax                  = t . sup_shift_drop      . text_style,
            SuperscriptBottomMaxWithSubscript           = t . sup_sub_bottom_max  . text_style,
            SuperscriptBottomMin                        = t . sup_bottom_min      . text_style,
            SuperscriptShiftUp                          = t . sup_shift_up        . text_style,
            SuperscriptShiftUpCramped                   = t . sup_shift_up        . cramped_text_style,
            UnderbarExtraDescender                      = t . underbar_kern       . text_style,
            UnderbarRuleThickness                       = t . underbar_rule       . text_style,
            UnderbarVerticalGap                         = t . underbar_vgap       . text_style,
            UpperLimitBaselineRiseMin                   = t . limit_above_bgap    . text_style,
            UpperLimitGapMin                            = t . limit_above_vgap    . text_style,
        }
        d.AccentBaseHeight = 0
        return t, d -- this might change
    else
        return { }, { }
    end
end

