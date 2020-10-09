--[[
*****************************************************************************************************************************************************
	create a new extention
*****************************************************************************************************************************************************
]]--

local extension = EXPR_LIB.RegisterExtension("boolean");

--[[
*****************************************************************************************************************************************************
	register boolean class
*****************************************************************************************************************************************************
]]--

local class_bool = extension:RegisterClass({
	id = "b",
	name = "bool",
	isType = isbool,
	isValid = EXPR_LIB.NOTNIL,
	docstring = "Boolean datatype, can be true or false."
})

extension:RegisterWiredInport("b", "NORMAL", function(i)
	return i ~= 0;
end);

extension:RegisterWiredOutport("b", "NORMAL", function(o)
	return o and 1 or 0;
end);

--[[
*****************************************************************************************************************************************************
	boolean operations
*****************************************************************************************************************************************************
]]--

extension:RegisterOperator("neq", "b,b", "b", 1);
extension:RegisterOperator("eq", "b,b", "b", 1);
extension:RegisterOperator("and", "b,b", "b", 1);
extension:RegisterOperator("or", "b,b", "b", 1);
extension:RegisterOperator("is", "b", "b", 1);
extension:RegisterOperator("not", "b", "b", 1);
extension:RegisterOperator("ten", "b,b,b", "b", 1);

--[[
*****************************************************************************************************************************************************
	Casting
*****************************************************************************************************************************************************
]]--

extension:RegisterCastingOperator("n", "b", function(b)
	return b and 1 or 0;
end, false);

extension:RegisterCastingOperator("b", "n", function(n)
	return n ~= 0 and true or false;
end, false);

extension:RegisterCastingOperator("s", "b", function(b)
	return b and "true" or "false";
end, false);

extension:RegisterCastingOperator("b", "s", function(s)
	if s == "1" or s == "true" or s == "True" then return true
	else return false end
end, false);

--[[
*****************************************************************************************************************************************************
	
*****************************************************************************************************************************************************
]]--

extension:EnableExtension();
