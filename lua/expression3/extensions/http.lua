--[[
	Request function
]]

local tokens = EXPR_TOKENS;

local request = function(ctx, url, suc, fail)
	ctx = tokens[ctx];
	if not ctx:canGetURL(url, "HTTPRequests") then return false; end

	local entity = ctx.entity;

	http.Fetch(url, function(contents, size, headers, code)
		if not IsValid(entity) or not entity:IsRunning() then return; end
		entity:Invoke(string.format("http.request(%q).sucess", url), "", 0, suc, {"s", contents});
	end, function(err)
		if not fail then return; end
		if not IsValid(entity) or not entity:IsRunning() then return; end
		entity:Invoke(string.format("http.request(%q).fail", url), "", 0, fail, {"s", err});
	end);

	return true;
end

--[[
	I just stole e2's http functions, credit to orgional authors.
]]

local extension = EXPR_LIB.RegisterExtension("http");

extension:SetClientState();

extension:RegisterLibrary("http");

extension:RegisterPermission("HTTPRequests", "icon16/page_link.png", "This gate is allowed to make HTTP requests. The filter setting will still be applied.");


extension:RegisterFunction("http", "request", "s,f", "b", 1, request, false);
extension:RegisterFunction("http", "request", "s,f,f", "b", 1, request, false);

extension:RegisterFunction("http", "encode", "s", "s", 1, function(data)
	local ndata = string.gsub(data, "[^%w _~%.%-]", function(str)
		local nstr = string.format("%X", string.byte(str))

		return "%" .. ((string.len(nstr) == 1) and "0" or "") .. nstr
	end)

	return string.gsub(ndata, " ", "+")
end, true);

extension:RegisterFunction("http", "encode", "s", "s", 1, function(data)
	local ndata = string.gsub(data, "+", " ")

	return string.gsub(ndata, "(%%%x%x)", function(str)
		return string.char(tonumber(string.Right(str, 2), 16))
	end)
end, true);

extension:EnableExtension()
