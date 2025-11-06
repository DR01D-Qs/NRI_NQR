Hooks:PostHook(NarrativeTweakData, "init", "nqr_NarrativeTweakData:init", function(self, tweak_data)
    table.delete(self._jobs_index, "haunted")
end)