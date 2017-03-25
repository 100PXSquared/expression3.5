local compFunc = EXPR_WIKI.COMPILER.Function
local compOper = EXPR_WIKI.COMPILER.Operator

local prefabFunc = EXPR_WIKI.COMPILER.PrefabFunction
local prefabOper = EXPR_WIKI.COMPILER.PrefabOperator

local states = {
	[0] = "server",
	[1] = "shared",
	[2] = "client"
}

local operators = {
	["not"] = "!",
	["neg"] = "-",
	["is"] = ""
}
--op.rCount
hook.Add("Expression3.LoadWiki", "Expression3.Wiki.RegisterFunction.autogen", function()
	print("Autogenerated "..table.Count(EXPR_LIB.GetEnabledExtensions()).." extention wiki pages!")
	
	for lib, data in pairs(EXPR_LIB.GetEnabledExtensions()) do
		if data.enabled then
			for func, data2 in pairs(data.constructors) do
				local class = data2.extension
				local args = data2.parameter
				local rtns = string.rep(data2.result, data2.rCount or 0, ",")
				
				EXPR_WIKI.RegisterConstructor(lib, func, compFunc(prefabFunc(states[data2.state], class, args, rtns)))
			end
			
			for func, data2 in pairs(data.methods) do
				local class = data2.extension
				local name = data2.name
				local args = data2.parameter
				local rtns = string.rep(data2.result, data2.rCount or 0, ",")
				
				EXPR_WIKI.RegisterMethod(lib, func, compFunc(prefabFunc(states[data2.state], class.."."..name, args, rtns)))
			end
			
			for func, data2 in pairs(data.functions) do
				local name = data2.name
				local args = data2.parameter
				local rtns = string.rep(data2.result, data2.rCount or 0, ",")
				
				EXPR_WIKI.RegisterFunction(lib, func, compFunc(prefabFunc(states[data2.state], name, args, rtns)))
			end
			
			for func, data2 in pairs(data.operators) do
				local name = data2.name or " "
				local args = data2.parameter
				local rtns = string.rep(data2.result, data2.rCount or 0, ",")
				
				if string.find("+-*/!=<>", string.sub(name, 1, 1)) then
					EXPR_WIKI.RegisterOperator(lib, func, compOper(prefabOper(states[data2.state], name, args, rtns)))
				else
					if operators[name] then
						local func_ = operators[name].."("..args..")"
						EXPR_WIKI.RegisterOperator(lib, func_, compOper(prefabOper(states[data2.state], operators[name], args, rtns), w, h))
					else
						EXPR_WIKI.RegisterOperator(lib, func, compFunc(prefabFunc(states[data2.state], name, args, rtns)))
					end
				end
			end
		end
	end
	
	for func, data2 in pairs(EXPR_LIB.WikiEvents) do
		local name = func
		local args = data2.parameter or "_nil"
		local rtns = data2.result or "_nil"
		
		EXPR_WIKI.RegisterEvent(func, compFunc(prefabFunc(states[data2.state], name, args, rtns)))
	end
end)

--PrintTable(EXPR_WIKI)