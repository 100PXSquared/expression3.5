--[[============================================================================================================================================
	Name: GOLEM_Search
	Author: Rusketh (The whole point of this, is to make Oskar hate it so he replaces it!)
	Based on Sublime Text 3, because its the best Text Editor (Disagree? Your wrong!).

	Disregard above if reading this, completely redesigned and replaced as the original doesn't even work.
	Now uses the same UI, and similar underlying functions as E2's find and replace.
	Also has respect for code folding and will only unfold blocks that contain the string to find or line to go to when they are found or gone to respectively.

	Complete rewrite author: Derpius

	Also, VSCode is the best text editor based on feature set and available extensions,
	and if you want to talk about asthetics, well Rusketh, you aren't really in a position to talk about asthetics given your human rights violation of an editor colour scheme.
	I mean jesus, pure black background and bright red characters, REALLY? I've seen PC UIs from the 90s that look better than that
============================================================================================================================================]]

--[[
	Search Box
]]

local SEARCH = {
	bWholeWord = false,
	bMatchCase = false,
	bAllowRegex = false,
	bWrapAround = false,
	bFindDown = true
}

function SEARCH:Init() 
	-- Nothing needs to be done here anymore, at least not right now
end

function SEARCH:CreateFindWindow()
	self.FindWindow = vgui.Create("DFrame", self)
	local ide = self:GetIDE()

	local pnl = self.FindWindow
	pnl:SetSize(322, 201)
	pnl:ShowCloseButton(true)
	pnl:SetDeleteOnClose(false) -- No need to create a new window every time
	pnl:MakePopup() -- Make it separate from the editor itself
	pnl:SetVisible(false) -- but hide it for now
	pnl:SetTitle("Find")
	pnl:SetScreenLock(true)
	do
		local old = pnl.Close
		function pnl.Close()
			self.ForceDrawCursor = false
			old(pnl)
		end
	end

	-- Center it above the editor
	local x,y = ide:GetPos()
	local w,h = ide:GetSize()
	pnl:SetPos(x+w/2-150, y+h/2-100)

	pnl.TabHolder = vgui.Create("DPropertySheet", pnl)
	pnl.TabHolder:StretchToParent(1, 23, 1, 1)

	-- Options
	local common_panel = vgui.Create("DPanel", pnl)
	common_panel:SetSize(225, 60)
	common_panel:SetPos(10, 130)
	common_panel.Paint = function()
		local w,h = common_panel:GetSize()
		draw.RoundedBox(4, 0, 0, w, h, Color(0,0,0,150))
	end

	local use_patterns = vgui.Create("DCheckBoxLabel", common_panel)
	use_patterns:SetText("Use Patterns")
	use_patterns:SetToolTip("Use/Don't use Lua patterns in the find.")
	use_patterns:SizeToContents()
	use_patterns.OnChange = function(chk) self.bAllowRegex = chk:GetChecked() end
	use_patterns:SetPos(4, 4)
	do
		local old = use_patterns.Button.SetValue
		use_patterns.Button.SetValue = function(pnl, b)
			if self.bWholeWord then return end
			old(pnl, b)
		end
	end

	local case_sens = vgui.Create("DCheckBoxLabel", common_panel)
	case_sens:SetText("Match Case")
	case_sens:SetToolTip("Ignore/Don't ignore case in the find.")
	case_sens:SizeToContents()
	case_sens:SetValue(self.bMatchCase)
	case_sens.OnChange = function(chk) self.bMatchCase = chk:GetChecked() end
	case_sens:SetPos(4, 24)

	local whole_word = vgui.Create("DCheckBoxLabel", common_panel)
	whole_word:SetText("Match Whole Word")
	whole_word:SetToolTip("Match/Don't match the entire word in the find.")
	whole_word:SizeToContents()
	whole_word:SetValue(self.bWholeWord)
	whole_word.OnChange = function(chk) self.bWholeWord = chk:GetChecked() end
	whole_word:SetPos(4, 44)
	do
		local old = whole_word.Button.Toggle
		whole_word.Button.Toggle = function(pnl)
			old(pnl)
			if pnl:GetValue() then use_patterns:SetValue(false) end
		end
	end

	local wrap_around = vgui.Create("DCheckBoxLabel", common_panel)
	wrap_around:SetText("Wrap Around")
	wrap_around:SetToolTip("Start/Don't start from the top after reaching the bottom, or the bottom after reaching the top.")
	wrap_around:SizeToContents()
	wrap_around:SetValue(self.bWrapAround)
	wrap_around.OnChange = function(chk) self.bWrapAround = chk:GetChecked() end
	wrap_around:SetPos(130, 4)

	local dir_down = vgui.Create("DCheckBoxLabel", common_panel)
	local dir_up = vgui.Create("DCheckBoxLabel", common_panel)

	dir_up:SetText("Up")
	dir_up:SizeToContents()
	dir_up:SetPos(130, 24)
	dir_up:SetTooltip("Note: Most patterns won't work when searching up because the search function reverses the string to search backwards.")
	dir_up:SetValue(not self.bFindDown)
	dir_down:SetText("Down")
	dir_down:SizeToContents()
	dir_down:SetPos(130, 44)
	dir_down:SetValue(self.bFindDown)

	dir_up.Button.Toggle = function()
		dir_up:SetValue(true)
		dir_down:SetValue(false)
		self.bFindDown = false
	end
	dir_down.Button.Toggle = function()
		dir_down:SetValue(true)
		dir_up:SetValue(false)
		self.bFindDown = true
	end

	do
		-- Find tab
		local findtab = vgui.Create("DPanel")

		-- Label
		local FindLabel = vgui.Create("DLabel", findtab)
		FindLabel:SetText("Find:")
		FindLabel:SetPos(4, 4)
		FindLabel:SetTextColor(Color(0,0,0,255))

		-- Text entry
		local FindEntry = vgui.Create("DTextEntry", findtab)
		FindEntry:SetPos(30,4)
		FindEntry:SetSize(200,20)
		FindEntry:RequestFocus()
		FindEntry.OnEnter = function(pnl)
			self:Find(pnl:GetValue())
			pnl:RequestFocus()
		end

		-- Find next button
		local FindNext = vgui.Create("DButton", findtab)
		FindNext:SetText("Find Next")
		FindNext:SetToolTip("Find the next match and highlight it.")
		FindNext:SetPos(233,4)
		FindNext:SetSize(70,20)
		FindNext.DoClick = function(pnl)
			self:Find(FindEntry:GetValue())
		end

		-- Find button
		local Find = vgui.Create("DButton", findtab)
		Find:SetText("Find")
		Find:SetToolTip("Find the next match, highlight it, and close the Find window.")
		Find:SetPos(233,29)
		Find:SetSize(70,20)
		Find.DoClick = function(pnl)
			self.FindWindow:Close()
			self:Find(FindEntry:GetValue())
		end

		-- Count button
		local Count = vgui.Create("DButton", findtab)
		Count:SetText("Count")
		Count:SetPos(233, 95)
		Count:SetSize(70, 20)
		Count:SetTooltip("Count the number of matches in the file.")
		Count.DoClick = function(pnl)
			Derma_Message(self:CountFinds(FindEntry:GetValue()) .. " matches found.", "", "Ok")
		end

		-- Cancel button
		local Cancel = vgui.Create("DButton", findtab)
		Cancel:SetText("Cancel")
		Cancel:SetPos(233,120)
		Cancel:SetSize(70,20)
		Cancel.DoClick = function(pnl)
			self.FindWindow:Close()
		end

		pnl.FindTab = pnl.TabHolder:AddSheet("Find", findtab, "icon16/page_white_find.png", false, false)
		pnl.FindTab.Entry = FindEntry
	end

	do
		-- Replace tab
		local replacetab = vgui.Create("DPanel")

		-- Label
		local FindLabel = vgui.Create("DLabel", replacetab)
		FindLabel:SetText("Find:")
		FindLabel:SetPos(4, 4)
		FindLabel:SetTextColor(Color(0,0,0,255))

		-- Text entry
		local FindEntry = vgui.Create("DTextEntry", replacetab)
		local ReplaceEntry
		FindEntry:SetPos(30,4)
		FindEntry:SetSize(200,20)
		FindEntry:RequestFocus()
		FindEntry.OnEnter = function(pnl)
			self:Replace(pnl:GetValue(), ReplaceEntry:GetValue())
			ReplaceEntry:RequestFocus()
		end

		-- Label
		local ReplaceLabel = vgui.Create("DLabel", replacetab)
		ReplaceLabel:SetText("Replace With:")
		ReplaceLabel:SetPos(4, 32)
		ReplaceLabel:SizeToContents()
		ReplaceLabel:SetTextColor(Color(0,0,0,255))

		-- Replace entry
		ReplaceEntry = vgui.Create("DTextEntry", replacetab)
		ReplaceEntry:SetPos(75,29)
		ReplaceEntry:SetSize(155,20)
		ReplaceEntry:RequestFocus()
		ReplaceEntry.OnEnter = function(pnl)
			self:Replace(FindEntry:GetValue(), pnl:GetValue())
			pnl:RequestFocus()
		end

		-- Find next button
		local FindNext = vgui.Create("DButton", replacetab)
		FindNext:SetText("Find Next")
		FindNext:SetToolTip("Find the next match and highlight it.")
		FindNext:SetPos(233,4)
		FindNext:SetSize(70,20)
		FindNext.DoClick = function(pnl)
			self:Find(FindEntry:GetValue())
		end

		-- Replace next button
		local ReplaceNext = vgui.Create("DButton", replacetab)
		ReplaceNext:SetText("Replace")
		ReplaceNext:SetToolTip("Replace the current selection if it matches, else find the next match.")
		ReplaceNext:SetPos(233,29)
		ReplaceNext:SetSize(70,20)
		ReplaceNext.DoClick = function(pnl)
			self:Replace(FindEntry:GetValue(), ReplaceEntry:GetValue())
		end

		-- Replace all button
		local ReplaceAll = vgui.Create("DButton", replacetab)
		ReplaceAll:SetText("Replace All")
		ReplaceAll:SetToolTip("Replace all occurences of the match in the entire file, and close the Find window.")
		ReplaceAll:SetPos(233,54)
		ReplaceAll:SetSize(70,20)
		ReplaceAll.DoClick = function(pnl)
			self.FindWindow:Close()
			self:ReplaceAll(FindEntry:GetValue(), ReplaceEntry:GetValue())
		end

		-- Count button
		local Count = vgui.Create("DButton", replacetab)
		Count:SetText("Count")
		Count:SetPos(233, 95)
		Count:SetSize(70, 20)
		Count:SetTooltip("Count the number of matches in the file.")
		Count.DoClick = function(pnl)
			Derma_Message(self:CountFinds(FindEntry:GetValue()) .. " matches found.", "", "Ok")
		end

		-- Cancel button
		local Cancel = vgui.Create("DButton", replacetab)
		Cancel:SetText("Cancel")
		Cancel:SetPos(233,120)
		Cancel:SetSize(70,20)
		Cancel.DoClick = function(pnl)
			self.FindWindow:Close()
		end

		pnl.ReplaceTab = pnl.TabHolder:AddSheet("Replace", replacetab, "icon16/page_white_wrench.png", false, false)
		pnl.ReplaceTab.Entry = FindEntry
	end

	-- Go to line tab
	local gototab = vgui.Create("DPanel")

	-- Label
	local GotoLabel = vgui.Create("DLabel", gototab)
	GotoLabel:SetText("Go to Line:")
	GotoLabel:SetPos(4, 4)
	GotoLabel:SetTextColor(Color(0,0,0,255))

	-- Text entry
	local GoToEntry = vgui.Create("DTextEntry", gototab)
	GoToEntry:SetPos(57,4)
	GoToEntry:SetSize(173,20)
	GoToEntry:SetNumeric(true)

	-- Goto Button
	local Goto = vgui.Create("DButton", gototab)
	Goto:SetText("Go to Line")
	Goto:SetPos(233,4)
	Goto:SetSize(70,20)

	-- Action
	local function GoToAction(panel)
		local val = tonumber(GoToEntry:GetValue())
		if val then
			val = math.Clamp(val, 1, #ide.tRows)
			ide:SetCaret(Vector2(val, 1))
			local toUnfold = self:RecursiveUnfold(ide.tRows, Vector2(val, 1))
			for i = 1, #ide.tRows do
				if not toUnfold[i] then continue end
				ide:ExpandLine(i, false)
			end
		end
		GoToEntry:SetText(tostring(val))
		self.FindWindow:Close()
	end
	GoToEntry.OnEnter = GoToAction
	Goto.DoClick = GoToAction

	pnl.GoToLineTab = pnl.TabHolder:AddSheet("Go to Line", gototab, "icon16/page_white_go.png", false, false)
	pnl.GoToLineTab.Entry = GoToEntry

	-- Tab buttons
	do
		local old = pnl.FindTab.Tab.OnMousePressed
		pnl.FindTab.Tab.OnMousePressed = function(...)
			pnl.FindTab.Entry:SetText(pnl.ReplaceTab.Entry:GetValue() or "")
			local active = pnl.TabHolder:GetActiveTab()
			if active == pnl.GoToLineTab.Tab then
				pnl:SetHeight(200)
				pnl.TabHolder:StretchToParent(1, 23, 1, 1)
			end
			old(...)
		end
	end

	do
		local old = pnl.ReplaceTab.Tab.OnMousePressed
		pnl.ReplaceTab.Tab.OnMousePressed = function(...)
			pnl.ReplaceTab.Entry:SetText(pnl.FindTab.Entry:GetValue() or "")
			local active = pnl.TabHolder:GetActiveTab()
			if active == pnl.GoToLineTab.Tab then
				pnl:SetHeight(200)
				pnl.TabHolder:StretchToParent(1, 23, 1, 1)
			end
			old(...)
		end
	end

	do
		local old = pnl.GoToLineTab.Tab.OnMousePressed
		pnl.GoToLineTab.Tab.OnMousePressed = function(...)
			pnl:SetHeight(86)
			pnl.TabHolder:StretchToParent(1, 23, 1, 1)
			pnl.GoToLineTab.Entry:SetText(1)
			old(...)
		end
	end
end

function SEARCH:OpenFindWindow(mode, selection)
	if not self.FindWindow then self:CreateFindWindow() end
	self.FindWindow:SetVisible(true)
	self.FindWindow:MakePopup() -- This will move it above the E2 editor if it is behind it.
	self.ForceDrawCursor = true

	if mode == "find" then
		if selection and selection ~= "" then self.FindWindow.FindTab.Entry:SetText(selection) end
		self.FindWindow.TabHolder:SetActiveTab(self.FindWindow.FindTab.Tab)
		self.FindWindow.FindTab.Entry:RequestFocus()
		self.FindWindow:SetHeight(201)
		self.FindWindow.TabHolder:StretchToParent(1, 23, 1, 1)
	elseif mode == "find and replace" then
		if selection and selection ~= "" then self.FindWindow.ReplaceTab.Entry:SetText(selection) end
		self.FindWindow.TabHolder:SetActiveTab(self.FindWindow.ReplaceTab.Tab)
		self.FindWindow.ReplaceTab.Entry:RequestFocus()
		self.FindWindow:SetHeight(201)
		self.FindWindow.TabHolder:StretchToParent(1, 23, 1, 1)
	elseif mode == "go to line" then
		self.FindWindow.TabHolder:SetActiveTab(self.FindWindow.GoToLineTab.Tab)
		local caretPos = self:GetIDE().Caret.x
		self.FindWindow.GoToLineTab.Entry:SetText(caretPos)
		self.FindWindow.GoToLineTab.Entry:RequestFocus()
		self.FindWindow.GoToLineTab.Entry:SelectAllText()
		self.FindWindow.GoToLineTab.Entry:SetCaretPos(tostring(caretPos):len())
		self.FindWindow:SetHeight(83)
		self.FindWindow.TabHolder:StretchToParent(1, 23, 1, 1)
	end
end

function SEARCH:SetEditor(ide)
	self.pEditor = ide
end

function SEARCH:GetIDE()
	local pTab = self.pEditor.pnlTabHolder:GetActiveTab()

	if not pTab then return end

	if not IsValid(pTab) or not ispanel(pTab) then return end

	if pTab.__type ~= "editor" then return end

	return pTab:GetPanel();
end

function SEARCH:Close(noanim)
	local pw, ph = self:GetParent():GetSize();
	local w, h = self:GetSize();
	local x = pw - w - 20;
	local y = -h - 10;

	if noanim then self:SetPos(x, y);
	else self:MoveTo(x, y, 0.2, 0.2); end

	if self.btnOptions then
		for i = 1, 5 do
			local btn = self.btnOptions[i];
			btn:SetEnabled(false);
			btn:SetVisible(false);
		end
	end

	self.pEditor.tbRight:InvalidateLayout(false);

	self.bOpen = false;
end

function SEARCH:RecursiveUnfold(rows, pos, toExpand, offset)
	local toExpand = toExpand or {}
	local offset = offset or 0

	for i = 1, #rows do
		if rows[i] == nil or not istable(rows[i]) or toExpand[rows[i].Primary] then continue end
		if pos.x <= i + offset or pos.x >= #rows[i] + i + offset then continue end

		toExpand[i + offset] = true
		toExpand = self:RecursiveUnfold(rows[i], pos, toExpand, offset + i - 1)
		break
	end

	return toExpand
end

function SEARCH:HighlightFoundWord(caretstart, start, stop, prevFolded)
	local ide = self:GetIDE()
	caretstart = caretstart or ide.Start

	if istable(start) then
		ide.Start = Vector2(start.x, start.y)
	elseif isnumber(start) then
		ide.Start = ide:MovePosition(caretstart, start)
	end
	if istable(stop) then
		ide.Caret = Vector2(stop.x, stop.y + 1)
	elseif isnumber(stop) then
		ide.Caret = ide:MovePosition(caretstart, stop + 1)
	end

	ide:ScrollCaret()

	ide:FoldAll(prevFolded)

	local toExpand = self:RecursiveUnfold(ide.tRows, ide.Start)
	PrintTable(toExpand)

	for i = 1, #ide.tRows do
		if not toExpand[i] then continue end
		ide:ExpandLine(i, false)
	end
end

function SEARCH:Find(str, looped, prevFolded)
	local ide = self:GetIDE()

	if looped and looped >= 2 then return end
	if str == "" then return end
	local _str = str

	-- Check if the match exists anywhere at all
	local temptext = ide:GetCode()
	if not self.bMatchCase then
		temptext = temptext:lower()
		str = str:lower()
	end
	local _start,_stop = temptext:find(str, 1, not self.bAllowRegex)
	if not _start or not _stop then return false end

	local prevFolded = prevFolded or ide:ExpandAll() -- Expand all the rows internally, then fold all but the ones that the match is in

	if self.bFindDown then -- Down
		local line = ide.tRows[ide.Start.x]
		local text = line:sub(ide.Start.y) .. "\n" .. table.concat(ide.tRows, "\n", ide.Start.x + 1) --_text:sub(0, #_text)

		if not self.bMatchCase then text = text:lower() end

		if not self.bAllowRegex then
			str = string.PatternSafe(str)
		end

		if self.bWholeWord then
			str = "%f[%w_]" .. str .. "%f[^%w_]"
		end

		local start, stop = text:find(str, 2)
		if start and stop then
			self:HighlightFoundWord(nil, start - 1, stop - 1, prevFolded)
			return true
		end

		if self.bWrapAround then
			ide:SetCaret(Vector2(1, 1))
			return self:Find(_str, (looped or 0) + 1, prevFolded)
		end

		ide:FoldAll(prevFolded)
		return false
	else -- Up
		local line = ide.tRows[ide.Start.x]
		text = table.concat(ide.tRows, "\n", 1, ide.Start.x - 1) .. "\n" .. line:sub(1, ide.Start.y - 1)

		str = string.reverse(str)
		text = string.reverse(text)

		if not self.bMatchCase then text = text:lower() end

		if not self.bAllowRegex then
			str = string.PatternSafe(str)
		end

		if self.bWholeWord then
			str = "%f[%w_]" .. str .. "%f[^%w_]"
		end

		local start, stop = text:find(str, 2)
		if start and stop then
			self:HighlightFoundWord(nil, -(start - 1), -(stop + 1), prevFolded)
			return true
		end

		if self.bWrapAround then
			ide:SetCaret(Vector2(#ide.tRows, #ide.tRows[#ide.tRows]))
			return self:Find(_str, (looped or 0) + 1, prevFolded)
		end

		ide:FoldAll(prevFolded)
		return false
	end
end

function SEARCH:Replace(str, replacewith)
	if str == "" or str == replacewith then return end

	local ide = self:GetIDE()

	local selection = ide:GetSelection()

	local _str = str
	if not self.bAllowRegex then
		str = string.PatternSafe(str)
		replacewith = replacewith:gsub("%%", "%%%1")
	end

	if selection:match(str) ~= nil then
		ide:SetSelection(selection:gsub(str, replacewith))
		return self:Find(_str)
	else
		return self:Find(_str)
	end
end

function SEARCH:ReplaceAll(str, replacewith)
	if str == "" then return end

	local ide = self:GetIDE()

	if not self.bAllowRegex then
		str = string.PatternSafe(str)
		replacewith = replacewith:gsub("%%", "%%%1")
	end

	if not self.bMatchCase then
		str = str:lower()
	end

	local pattern
	if self.bWholeWord then
		pattern = "%f[%w_]()" .. str .. "%f[^%w_]()"
	else
		pattern = "()" .. str .. "()"
	end

	local txt = ide:GetCode()

	if not self.bMatchCase then
		local txt2 = txt -- Store original cased copy
		txt = txt:lower() -- Lowercase everything

		local positions = {}

		for startpos, endpos in string.gmatch(txt, pattern) do
			positions[#positions + 1] = {startpos, endpos}
		end

		-- Do the replacing backwards, or it won't work
		for i = #positions, 1, -1 do
			local startpos, endpos = positions[i][1], positions[i][2]
			txt2 = string.sub(txt2, 1, startpos - 1) .. replacewith .. string.sub(txt2, endpos)
		end

		-- Replace everything with the edited copy
		ide:SelectAll()
		ide:SetSelection(txt2)
	else
		txt = string.gsub(txt, pattern, replacewith)

		ide:SelectAll()
		ide:SetSelection(txt)
	end
end

function SEARCH:CountFinds(str)
	PrintTable({
		bWholeWord = self.bWholeWord,
		bMatchCase = self.bMatchCase,
		bAllowRegex = self.bAllowRegex,
		bWrapAround = self.bWrapAround,
		bFindDown = self.bFindDown
	})
	if str == "" then return 0 end

	if not self.bAllowRegex then
		str = string.PatternSafe(str)
	end

	local txt = self:GetIDE():GetCode()

	if not self.bMatchCase then
		txt = txt:lower()
		str = str:lower()
	end

	if self.bWholeWord then
		str = "%f[%w_]()" .. str .. "%f[^%w_]()"
	end

	return select(2, txt:gsub(str, ""))
end

vgui.Register("GOLEM_SearchBox", SEARCH, "DPanel");