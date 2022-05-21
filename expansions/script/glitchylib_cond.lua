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

--Equip
function Auxiliary.IsEquippedCond(e)
	return e:GetHandler():GetEquipTarget()
end