--[[
*****************************************************************************************************************************************************
	create a new extention
*****************************************************************************************************************************************************
]]--

local extension = EXPR_LIB.RegisterExtension("userclasses");

--[[
*****************************************************************************************************************************************************
	register userclass class
*****************************************************************************************************************************************************
]]--

local class_type = extension:RegisterClass("cls", {"type", "class"}, isstring, isnil);

extension:RegisterOperator("neq", "cls,cls", "b", 1);
extension:RegisterOperator("eq", "cls,cls", "b", 1);

--[[
*****************************************************************************************************************************************************
	
*****************************************************************************************************************************************************
]]--

extension:EnableExtension();











