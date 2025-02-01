local ACF = ACF
local Contraption	= ACF.Contraption
local IsValid = IsValid

TOOL.Category	 = (ACF.CustomToolCategory and ACF.CustomToolCategory:GetBool()) and "ACF" or "Construction"
TOOL.Name		 = "#tool.acfarmormesh.name"
TOOL.Command	 = nil
TOOL.ConfigName	 = ""
-- TOOL.Information = {
-- 	{ name = "left" },
-- 	{ name = "right" },
-- 	{ name = "reload" }
-- }

if CLIENT then
	language.Add("tool.acfarmormesh.name", "ACF Armor Compiler")
	language.Add("tool.acfarmormesh.desc", "Aids in editting an ACF Armor Mesh")

	surface.CreateFont("Torchfont", { size = 40, weight = 1000, font = "arial" })

	--- Making the menu actually work...

	--- Creates (Or recreates) the menu for this tool
	local function CreateMenu(Panel)
		local Menu = ACF.ArmorMenu

		if not IsValid(Menu) then
			Menu = vgui.Create("ACF_Panel")
			Menu.Panel = Panel

			Panel:AddItem(Menu)

			ACF.ArmorMenu = Menu
		else
			Menu:ClearAllTemporal()
			Menu:ClearAll()
		end

		local Reload = Menu:AddButton("Reload Menu")
		Reload:SetTooltip("You can also type 'acf_reload_armor_menu' in console.")
		function Reload:DoClickInternal()
			RunConsoleCommand("acf_reload_armor_menu")
		end

		Menu:AddLabel("ACF Armor Mesh Tool")
		Menu:AddLabel("This tool is used to create and edit ACF armor meshes.")

		local Instructions = Menu:AddCollapsible("General Instructions", false)
		Instructions:AddLabel("Test")

		Menu:AddTextEntry("Controller Model: ", "models/hunter/plates/plate025x025.mdl")
	end

	TOOL.BuildCPanel = CreateMenu

	concommand.Add("acf_reload_armor_menu", function()
		if not IsValid(ACF.ArmorMenu) then return end

		CreateMenu(ACF.ArmorMenu.Panel)
	end)

	local TextGray = Color(224, 224, 255)
	local BGGray = Color(200, 200, 200)
	local Blue = Color(50, 200, 200)
	local Red = Color(200, 50, 50)
	local Green = Color(50, 200, 50)
	local Black = Color(0, 0, 0)
	local drawText = draw.SimpleTextOutlined

	surface.CreateFont("ACF_ToolTitle", {
		font = "Arial",
		size = 32
	})

	surface.CreateFont("ACF_ToolSub", {
		font = "Arial",
		size = 25
	})

	surface.CreateFont("ACF_ToolLabel", {
		font = "Arial",
		size = 32,
		weight = 620,
	})

	--- Draws the hud/tooltips for this tool
	function TOOL:DrawHUD()
		local Trace = self:GetOwner():GetEyeTrace()
		local Ent = Trace.Entity

		if not IsValid(Ent) then return false end
		if Ent:IsPlayer() or Ent:IsNPC() then return false end
	end

	function TOOL:DrawToolScreen()
		local Trace = self:GetOwner():GetEyeTrace()
		local Ent   = Trace.Entity
		local Weapon = self.Weapon
	end

	function TOOL:Think()

	end
else -- Serverside-only stuff	
	function TOOL:CheckForExtras()
		local isFirstTimePredicted = IsFirstTimePredicted()
		if not isFirstTimePredicted then return end

		local Player = self:GetOwner()

		if Player:KeyPressed(IN_SPEED) then
			print("Change Modes")
		end

		if Player:KeyPressed(IN_WALK) then
			print("Change Targets")
		end
	end

	function TOOL:Think()
		local Player = self:GetOwner()
		local Trace = Player:GetEyeTrace()
		local Ent = Trace.Entity

		self:CheckForExtras()
	end

	function TOOL:LeftClick(Trace)
		local Player = self:GetOwner()
		if Player:KeyDown(IN_DUCK) then
			print("Ctrl + LeftClick")
			return true
		end
		print("LeftClick")
		return true
	end

	function TOOL:RightClick(Trace)
		local Player = self:GetOwner()
		if Player:KeyDown(IN_DUCK) then
			print("Ctrl + RightClick")
			return true
		end
		print("RightClick")
		return true
	end

	function TOOL:Reload(Trace)
		print("Reload")
		return true
	end
end