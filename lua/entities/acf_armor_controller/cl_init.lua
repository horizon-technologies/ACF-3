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