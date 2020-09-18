if SERVER then return; end

/*********************************************************************************
	Golem menu panel
*********************************************************************************/
local EDITOR_PANEL = {};

local tick = Material("icon16/tick.png");
local cross = Material("icon16/cross.png");

function EDITOR_PANEL:Init()
	self.items = {};
end

function EDITOR_PANEL:AddValue(name, value, callback)
	local h = 22;
	local w = self:GetWide();

	local pnl = self:Add("DHorizontalDivider");
	pnl:SetSize(w, h);

	pnl.lbl = pnl:Add("DLabel");
	pnl.lbl:SetText(name);
	pnl:SetLeftWidth(w * 0.25);
	pnl:SetLeft(pnl.lbl);

	pnl.txt = pnl:Add("GOLEM_TextEntry");
	pnl.txt:SetMaterial(tick);
	pnl.txt:SetPlaceholderText(name);
	pnl.txt:SetValue(value);
	pnl:SetRight(pnl.txt);

	local function updateIcon(v)
		pnl.txt:SetMaterial(value == v and tick or cross);
	end

	pnl.txt.OnChange = function(_, v)
		updateIcon(v);
	end;

	pnl.txt.DoClick = function(_, v)
		value = v;
		callback(v);
		updateIcon(v);
	end;

	pnl.txt.OnEnter = function(_, v)
		value = v;
		callback(v);
		updateIcon(v);
	end;

	self.items[name] = pnl;

	return pnl;
end

function EDITOR_PANEL:Clear()
	for k, v in pairs(self.items) do
		v:Remove();
	end

	self.items = {};

	self:InvalidateLayout();
end

function EDITOR_PANEL:SetValues(kv, csv, pnl)
	
	self:Clear();
	
	for k, v in pairs(kv) do
		self:AddValue(k, v, function(value)
			kv[k] = value;

			if csv then
				csv:insert(csv:FromKV(kv));
			end

			if pnl then
				pnl:WriteLine(Color(255, 0, 0), "Updated Helper Info"); 
				pnl:WriteLine(Color(255, 0, 0), " Key: ", Color(0, 255, 0), k); 
				pnl:WriteLine(Color(255, 0, 0), " Value: ", Color(0, 255, 0), value); 
			end
		end);
	end
end

vgui.Register("GOLEM_E3HelperEditor", EDITOR_PANEL, "DListLayout");


/*********************************************************************************
	Golem helper menu panel
*********************************************************************************/

local HELPER_PANEL = {};

function HELPER_PANEL:Init()

	self.srch_pnl:SetParent(nil);

	self.edtr_pnl = self:Add("GOLEM_E3HelperEditor");
	self.edtr_pnl:SetTall(0);
	self.edtr_pnl:DockMargin(5, 5, 5, 5);
	self.edtr_pnl:Dock(TOP);

	self.html_pnl = self:Add("DHTML");
	self.html_pnl:SetTall(0);
	self.html_pnl:DockMargin(5, 5, 5, 5);
	self.html_pnl:Dock(TOP);

	self.srch_pnl:SetParent(self);
	self.srch_pnl:Dock(TOP);

	self.cls_btn = self.srch_pnl:SetupButton("Expand Browser", "icon16/arrow_up.png", RIGHT, function()
		self.cls_btn:SetVisible(false);
		self.srch_pnl:InvalidateLayout()
		self:CloseHTML();
		self:CloseEditor();
	end);

	self.cls_btn:SetVisible(false);

	self.expt_btn = self.ctrl_pnl:SetupTextBox("Export Custom Helper Data", "icon16/disk.png", RIGHT, function(_, str)
		if str ~= "" then
			EXPR_DOCS.SaveChangedDocs(str .. ".txt");
			self:WriteLine(Color(255, 255, 255), "Exported Custom Helpers");
			self:WriteLine(Color(0, 255, 0), str .. ".txt");
		end
	end, nil);

	self.expt_btn:SetWide(100);
	self.expt_btn:SetPlaceholderText("file name");

	self:Reload();
end

function HELPER_PANEL:OpenEditor(kv, csv)
	self.cls_btn:SetVisible(true);
	self.edtr_pnl:SetVisible(true);
	if kv then self.edtr_pnl:SetValues(kv, csv, self); end
	self:CloseHTML();
end

function HELPER_PANEL:CloseEditor()
	self.edtr_pnl:SetVisible(false);
	self.edtr_pnl:SetTall(0);
	self:InvalidateLayout();
end

function HELPER_PANEL:OpenHTML(h)
	self.cls_btn:SetVisible(true);
	self.html_pnl:SetVisible(true);
	self.html_pnl:SetTall(h);
	self:CloseEditor();
end

function HELPER_PANEL:CloseHTML()
	self.html_pnl:SetVisible(false);
	self.html_pnl:SetTall(0);
	self:InvalidateLayout();
end

function HELPER_PANEL:WriteLine(...)
	Golem.Print(...);
end

/*********************************************************************************
	Reload
*********************************************************************************/

function HELPER_PANEL:Reload()
	local subnodes = self.root_tree.subnodes;

	if subnodes then

		for _, node in pairs(subnodes) do
			node:Remove();
		end

		self.root_tree.subnodes = {};
	end

	--e3docs/saved/

	local Links = self:AddNode("Links");
	local Examples = self:AddNode("Examples");
	local BookMarks = self:AddNode("Bookmarks");
	local CustomHelpers = self:AddNode("Custom Helpers");
	local Libraries = self:AddNode("Libraries");
	local Classes = self:AddNode("Classes");
	local Operators = self:AddNode("Operators");

	Links:SetIcon("icon16/link.png");
	Examples:SetIcon("icon16/folder.png");
	CustomHelpers:SetIcon("icon16/folder.png");
	BookMarks:SetIcon("icon16/star.png");

	self:AddHTMLCallback(BookMarks, function()
		return EXPR_DOCS.toHTML({
			"<h2>Bookmarks:</h2>",
			"Right click a node to",
			"save a new bookmark.",
			"",
			"Right click a bookmark",
			"to go to that node."
		});
	end);

	self:AddHTMLCallback(CustomHelpers, function()
		return EXPR_DOCS.toHTML({
			"<h2>Custom Helpers:</h2>",
			"Right click a node to",
			"change its helper data.",
			"",
			"Click the export button",
			"at the bottom of the helper",
			"to export your custom helper",
			"information.",
			"",
			"Click one of the saved custom",
			"helper files to load the the",
			"files saved helper data.",
		});
	end);

	hook.Run("Expression3.LoadHelperNodes", self);
end

/*********************************************************************************
	Show html
*********************************************************************************/

function HELPER_PANEL:AddHTMLCallback(node, callback)
	node.DoClick = function(this)
		local str, num = callback();
		local tall = num and ((num * 25) + 10) or 100;
		self.html_pnl:SetHTML(str);
		self:OpenHTML(tall);
	end;
end

/*********************************************************************************
	Show Menu Options
*********************************************************************************/

function HELPER_PANEL:AddOptionsMenu(node, callback)
	
	node.DoRightClick = function()

		local menu = DermaMenu();

		if callback then
			menu:AddOption("Edit", function()
				local kv, csv = callback();

				self:OpenEditor(kv, csv);

			end):SetIcon("icon16/pencil.png");
		end

		menu:AddOption("Copy to clipboard", function()
			SetClipboardText(node:GetText());
		end):SetIcon("icon16/page_copy.png");

		if not node.isBookMarked then

			menu:AddOption("Bookmark", function()
				
				node.isBookMarked = true;
				node.bookMark = self:AddNode("Bookmarks", node:GetText());
				node.bookMark.BookMarkOff = node;
				node.bookMark.isBookMarked = true;
				node.bookMark:SetIcon(node:GetIcon());
				node.bookMark.DoClick = function()
					node:DoClick();
				end;

				self:AddOptionsMenu(node.bookMark);

			end):SetIcon("icon16/star.png");

		end

		if node.isBookMarked then

			menu:AddOption("Remove Bookmark", function()
				if node.bookMark then
					node.bookMark:Remove();
				else
					node:Remove();
				end

				node.bookMark = nil;
				node.isBookMarked = false;
			end):SetIcon("icon16/delete.png");

			if node.BookMarkOff then
				menu:AddOption("Goto", function()
					self.root_tree:SetSelectedItem(node.BookMarkOff);
					node.BookMarkOff:ExpandTo(true);
					self:ScrollTo(node);
				end):SetIcon("icon16/application_go.png");
			end

		end

		menu:Open();
	end;

end

function HELPER_PANEL:Paint(w, h) 
	surface.SetDrawColor(30, 30, 30, 255)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register("GOLEM_E3Helper", HELPER_PANEL, "GOLEM_Tree");
