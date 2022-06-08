--CONDITIONS
-----------------------------------------------------------------------

--Event Group (eg) Check Condition
function Auxiliary.EventGroupCond(f,min,max,exc)
	if not min then min=1 end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local exc=(not exc) and nil or e:GetHandler()
				return eg:IsExists(f,min,exc,e,tp,eg,ep,ev,re,r,rp) and (not max or not eg:IsExists(f,max,exc,e,tp,eg,ep,ev,re,r,rp))
			end
end
function Auxiliary.ExactEventGroupCond(f,ct,exc)
	if not ct then ct=1 end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local exc=(not exc) and nil or e:GetHandler()
				return eg:FilterCount(f,exc,e,tp,eg,ep,ev,re,r,rp)==ct
			end
end

--Except on Damage Calc
function Auxiliary.ExceptOnDamageCalc()
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end

--Location Group Check Conditions
function Auxiliary.LocationGroupCond(f,loc1,loc2,min,max,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=loc1 end
	if not min then min=1 end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local exc=(not exc) and nil or e:GetHandler()
				local ct=Duel.GetMatchingGroupCount(f,tp,loc1,loc2,exc,e,tp,eg,ep,ev,re,r,rp)
				return ct>=min and (not max or ct<=max)
			end
end
function Auxiliary.ExactLocationGroupCond(f,loc1,loc2,ct0,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=loc1 end
	if not ct then ct=1 end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local exc=(not exc) and nil or e:GetHandler()
				local ct=Duel.GetMatchingGroupCount(f,tp,loc1,loc2,exc,e,tp,eg,ep,ev,re,r,rp)
				return ct==ct0
			end
end
function Auxiliary.CompareLocationGroupCond(res,f,loc,exc)
	if not loc then loc=LOCATION_MZONE end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local res = (res and res==1) and 1-tp or tp
				local exc=(not exc) and nil or e:GetHandler()
				local ct1=Duel.GetMatchingGroupCount(f,tp,loc,0,exc,e,tp,eg,ep,ev,re,r,rp)
				local ct2=Duel.GetMatchingGroupCount(f,tp,0,loc,exc,e,tp,eg,ep,ev,re,r,rp)
				local winner
				if ct1>ct2 then
					winner=tp
				elseif ct1<ct2 then
					winner=1-tp
				else
					winner=PLAYER_NONE
				end
				return res==winner
			end
end

--When this card is X Summoned
function Auxiliary.FusionSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function Auxiliary.SynchroSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function Auxiliary.XyzSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function Auxiliary.PendulumSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
function Auxiliary.LinkSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function Auxiliary.PandemoniumSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PANDEMONIUM)
end
function Auxiliary.BigbangSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_BIGBANG)
end
function Auxiliary.TimeleapSummonedCond(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP)
end

--Equip
function Auxiliary.IsEquippedCond(e)
	return e:GetHandler():GetEquipTarget()
end