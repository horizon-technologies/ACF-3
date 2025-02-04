DEFINE_BASECLASS("acf_base_simple")

include("shared.lua")

language.Add("Cleanup_acf_armor_controllers", "ACF Armor Controllers")
language.Add("Cleaned_acf_crew", "Cleaned up all ACF Armor Controllers")
language.Add("SBoxLimit__acf_crew", "You've reached the ACF Armor Controller limit!")

function ENT:Initialize(...)
    BaseClass.Initialize(self, ...)
end

function ENT:Draw(...)
    BaseClass.Draw(self, ...)
end

function ENT:VisualizeMesh()
    if not self.MeshData then
        self.MeshData = {
            Vertices = {},
            Convexes = {}
        }
    end

    local vertices = self.MeshData.Vertices
    local convexes = self.MeshData.Convexes

    local function drawVertex(pos)
        render.DrawWireframeSphere(pos, 1, 8, 8, Color(255, 0, 255))
    end

    local function drawConvex(convex)
        local verts = {}
        for _, vertexID in ipairs(convex) do
            table.insert(verts, vertices[vertexID].Pos)
        end
        render.DrawWireframePoly(verts)
    end

    for _, vertex in ipairs(vertices) do
        drawVertex(vertex.Pos)
    end

    for _, convex in ipairs(convexes) do
        drawConvex(convex)
    end
end

function ENT:CanDrawOverlay() -- This is called to see if DrawOverlay can be called
    return true
end

function ENT:DrawOverlay() -- Draw the overlay
    self:VisualizeMesh()
end

do
    --- Adds a vertex to the controller
    --- @param Pos any The local position to add it at, or nil for 0,0,0
    --- @return integer The index of the created vertex
    function ENT:AddVertex(Pos)
        local newindex = #self.MeshData.Vertices + 1
        self.MeshData.Vertices[newindex] = {}
        self.MeshData.Vertices[newindex].Pos = Pos or Vector()
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

net.Receive("acf_mesh_full", function()
    local ent = net.ReadEntity()
    local data = net.ReadTable()
    ent.MeshData = data
end)

net.Receive("acf_mesh_v_new", function()
    local ent = net.ReadEntity()
    local pos = net.ReadVector()
    print("acf_mesh_v_new", ent, pos)
    ent:AddVertex(pos)
end)
