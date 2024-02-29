local _RitualUltimateTarget = aux.RitualUltimateTarget

function Auxiliary.RitualUltimateTarget(filter,level_function,greater_or_equal,summon_location,grave_filter,mat_filter,extra_target)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if not aux.EnableSpSummonRitualMonsterOperationInfo then
					return _RitualUltimateTarget(filter,level_function,greater_or_equal,summon_location,grave_filter,mat_filter,extra_target)(e,tp,eg,ep,ev,re,r,rp,chk)
				end
				if chk==0 then
					local mg=Duel.GetRitualMaterial(tp)
					if mat_filter then mg=mg:Filter(mat_filter,nil,e,tp,true) end
					local exg=nil
					if grave_filter then
						exg=Duel.GetMatchingGroup(Auxiliary.RitualExtraFilter,tp,LOCATION_GRAVE,0,nil,grave_filter)
					end
					return Duel.IsExistingMatchingCard(Auxiliary.RitualUltimateFilter,tp,summon_location,0,1,nil,filter,e,tp,mg,exg,level_function,greater_or_equal,true)
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,summon_location)
				Duel.SetCustomOperationInfo(0,CATEGORY_SPSUMMON_RITUAL_MONSTER,nil,1,tp,summon_location)
				if grave_filter then
					Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
				end
				if extra_target then
					extra_target(e,tp,eg,ep,ev,re,r,rp)
				end
			end
end