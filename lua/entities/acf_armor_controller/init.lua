
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

--===============================================================================================--
-- Local Funcs and Vars
--===============================================================================================--
local ACF = ACF
local HookRun     = hook.Run
local HookRemove     = hook.Remove
local Utilities   = ACF.Utilities
local Clock       = Utilities.Clock
local WireIO      = Utilities.WireIO

local Contraption = ACF.Contraption
local hook	   = hook
local Classes	= ACF.Classes
local Entities   = Classes.Entities
local CheckLegal = ACF.CheckLegal
local TraceHull = util.TraceHull
local TimerSimple	= timer.Simple

do
	local Outputs = {
		"TotalMass",
		"TotalVolume",
		"TotalHealth",
		"MaxHealth",
		"Entity (The controller entity itself) [ENTITY]",
	}

	local function VerifyData(Data)

	end

	local function UpdateArmorController(Entity, Data)
		-- Update model info and physics
		Entity.ACF = Entity.ACF or {}
		Entity.ACF.Model = "models/hunter/plates/plate025x025.mdl"

		Entity:SetModel("models/hunter/plates/plate025x025.mdl")

		Entity:PhysicsInit(SOLID_VPHYSICS)
		Entity:SetMoveType(MOVETYPE_VPHYSICS)

		for _, V in ipairs(Entity.DataStore) do
			Entity[V] = Data[V]
		end

		-- Update entity data

		Entity:SetNWString("WireName", "ACF Armor Controller") -- Set overlay wire entity name

		ACF.Activate(Entity, true)

		local PhysObj = Entity.ACF.PhysObj
		if IsValid(PhysObj) then
			Contraption.SetMass(Entity, 1000)
		end

		Entity:UpdateOverlay(true)
	end

	function MakeArmorController(Player, Pos, Angle, Data)
		VerifyData(Data)

		-- Creating the entity
		local CanSpawn	= HookRun("ACF_PreEntitySpawn", "acf_armor_controller", Player, Data)
		if CanSpawn == false then return false end

		local Entity = ents.Create("acf_armor_controller")

		if not IsValid(Entity) then return end

		Entity:SetPlayer(Player)
		Entity:SetAngles(Angle)
		Entity:SetPos(Pos)
		Entity:Spawn()

		Entity.Name = "ACF Armor Controller"
		Entity.ShortName = "ACF Armor Controller"
		Entity.EntType = "ACF Armor Controller"

		Entity.Owner = Player -- MUST be stored on ent for PP
		Entity.DataStore = Entities.GetArguments("acf_armor_controller")

		Entity.MeshData = {
			Vertices = {},
			Convexes = {},
		}

		UpdateArmorController(Entity, Data)

		-- Finish setting up the entity
		hook.Run("ACF_OnSpawnEntity", "acf_armor_controller", Entity, Data)

		WireIO.SetupOutputs(Entity, Outputs, Data)

		WireLib.TriggerOutput(Entity, "Entity", Entity)

		Entity:UpdateOverlay(true)

		CheckLegal(Entity)

		net.Start("acf_mesh_full")
		net.WriteEntity(Entity)
		net.WriteTable(Entity.MeshData)
		net.Broadcast()

		return Entity
	end

	-- Bare minimum arguments to reconstruct an armor controller
	Entities.Register("acf_armor_controller", MakeArmorController)

	function ENT:Update(Data)
		-- Called when updating the entity
		VerifyData(Data)

		local CanUpdate, Reason = HookRun("ACF_PreEntityUpdate", "acf_armor_controller", self, Data)
		if CanUpdate == false then return CanUpdate, Reason end

		HookRun("ACF_OnEntityLast", "acf_armor_controller", self)

		ACF.SaveEntity(self)

		UpdateArmorController(self, Data)

		ACF.RestoreEntity(self)

		HookRun("ACF_OnEntityUpdate", "acf_armor_controller", self, Data)

		self:UpdateOverlay(true)

		return true, "Armor Controller updated successfully!"
	end

	function ENT:UpdateOverlayText()
		str = string.format("TotalMass: %s\nTotalVolume: %s\nTotalHealth: %s\nMaxHealth: %s\n",
		self.TotalMass or 0,
		self.TotalVolume or 0,
		self.TotalHealth or 0,
		self.MaxHealth or 0)
		return str
	end
end

-- Entity methods
do
	-- Think logic (mostly checks and stuff that updates frequently)
	function ENT:Think()
		self:UpdateOverlay()
		self:NextThink(Clock.CurTime + math.Rand(1, 2))
		return true
	end

	function ENT:ACF_Activate(Recalc)
		local PhysObj = self.ACF.PhysObj
		local Mass    = PhysObj:GetMass()
		local Area    = PhysObj:GetSurfaceArea() * ACF.InchToCmSq
		local Armour  = 5
		local Health  = 100
		local Percent = 1

		if Recalc and self.ACF.Health and self.ACF.MaxHealth then
			Percent = self.ACF.Health / self.ACF.MaxHealth
		end

		self.ACF.Area      = Area
		self.ACF.Health    = Health * Percent
		self.ACF.MaxHealth = Health
		self.ACF.Armour    = Armour * Percent
		self.ACF.MaxArmour = Armour
		self.ACF.Type      = "Prop"
	end
end

-- Tool integration
do
	util.AddNetworkString("acf_mesh_full")
	util.AddNetworkString("acf_mesh_clear")

	util.AddNetworkString("acf_mesh_v_new")
	util.AddNetworkString("acf_mesh_v_upd")
	util.AddNetworkString("acf_mesh_v_rem")
	util.AddNetworkString("acf_mesh_c_new")
	util.AddNetworkString("acf_mesh_c_upd")
	util.AddNetworkString("acf_mesh_c_rem")


	--- Adds a vertex to the controller
	--- @param Pos any The local position to add it at, or nil for 0,0,0
	--- @return integer The index of the created vertex
	function ENT:AddVertex(Pos)
		local newindex = #self.MeshData.Vertices + 1
		self.MeshData.Vertices[newindex] = {}
		self.MeshData.Vertices[newindex].Pos = Pos or Vector()

		net.Start("acf_mesh_v_new")
		net.WriteEntity(self)
		net.WriteVector(Pos or Vector())
		net.Broadcast()
		return newindex
	end

	--- Removes a vertex from the controller
	--- @param ID any The index of the vertex to remove
	function ENT:RemoveVertex(ID)
		table.remove(self.MeshData.Vertices, ID)
	end

	--- Updates a vertex in the controller
	--- @param ID any The index of the vertex to update
	--- @param Data any The new data to set
	function ENT:UpdateVertex(ID, Data)
		for k, v in pairs(Data) do
			self.MeshData.Vertices[ID][k] = v
		end
	end

	--- Adds a convex to the controller
	--- @param vertexIDs any The indices of the vertices to use in the convex
	function ENT:AddConvex(vertexIDs)
		local newindex = #self.MeshData.Convexes + 1
		self.MeshData.Convexes[newindex] = {}
	end

	--- Removes a convex from the controller
	--- @param ID any The index of the convex to remove
	function ENT:RemoveConvex(ID)
		table.remove(self.MeshData.Convexes, ID)
	end

	--- Updates a convex in the controller
	--- @param ID any The index of the convex to update
	--- @param Data any The new data to set
	function ENT:UpdateConvex(ID, Data)
		for k, v in pairs(Data) do
			self.MeshData.Convexes[ID][k] = v
		end
	end
end

-- Adv Dupe 2 Related
do
	function ENT:PreEntityCopy()

		-- Wire dupe info
		self.BaseClass.PreEntityCopy(self)
	end

	function ENT:PostEntityPaste(Player, Ent, CreatedEntities)
		local EntMods = Ent.EntityMods

		--Wire dupe info
		self.BaseClass.PostEntityPaste(self, Player, Ent, CreatedEntities)
	end

	function ENT:OnRemove()
		HookRun("ACF_OnEntityLast", "acf_armor_controller", self)

		WireLib.Remove(self)
	end
end