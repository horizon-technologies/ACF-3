local ACF = ACF
local Contraption	= ACF.Contraption
local IsValid = IsValid

TOOL.Category	 = (ACF.CustomToolCategory and ACF.CustomToolCategory:GetBool()) and "ACF" or "Construction"
TOOL.Name		 = "#tool.acfarmormesh.name"
TOOL.Command	 = nil
TOOL.ConfigName	 = ""
TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
	{ name = "reload" }
}

if CLIENT then
	language.Add("tool.acfarmormesh.name", "ACF Armor Compiler")
	language.Add("tool.acfarmormesh.desc", "Aids in editting an ACF Armor Mesh")

	surface.CreateFont("Torchfont", { size = 40, weight = 1000, font = "arial" })

	function TOOL.BuildCPanel(Panel)
		local Reload = Menu:AddButton("#tool.acfcopy.reload")
		Reload:SetTooltip("#tool.acfcopy.reload_desc")
		function Reload:DoClickInternal()
			RunConsoleCommand("acf_reload_copy_menu")
		end

		Panel:AddControl("Header", { Text = "#tool.acfarmormesh.name", Description = "#tool.acfarmormesh.desc" })
		Panel:AddControl("Label", { Text = "This tool is still in development..." })
	end

	function TOOL:DrawHUD()
		local Trace = self:GetOwner():GetEyeTrace()
		local Ent = Trace.Entity

		if not IsValid(Ent) then return false end
		if Ent:IsPlayer() or Ent:IsNPC() then return false end
	end

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

	function TOOL:DrawToolScreen()
		local Trace = self:GetOwner():GetEyeTrace()
		local Ent   = Trace.Entity
		local Weapon = self.Weapon
	end

	function TOOL:Think()

	end
else -- Serverside-only stuff
	function TOOL:Think()

	end
end

-- Apply settings to prop
function TOOL:LeftClick(Trace)

	return true
end

-- Suck settings from prop
function TOOL:RightClick(Trace)


	return true
end