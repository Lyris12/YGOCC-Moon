--Nano-Mesh Maiden
function c249001163.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(2)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c249001163.spcost)
	e1:SetTarget(c249001163.sptg)
	e1:SetOperation(c249001163.spop)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(249001163,ACTIVITY_SPSUMMON,c249001163.counterfilter)
end
function c249001163.counterfilter(c)
	return c:IsRace(RACE_CYBERSE) or c:IsRace(RACE_MACHINE)
end
function c249001163.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(249001163,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c249001163.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c249001163.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_CYBERSE) and not c:IsRace(RACE_MACHINE)
end
function c249001163.mzfilter(c,e,tp,lv)
	return c:IsControler(tp) and c:GetSequence()<5 and c249001163.filter1(c,e,tp,lv)
end
function c249001163.filter1(c,e,tp,lv)
	return c:IsRace(RACE_MACHINE) and c:IsLevelAbove(1) and Duel.IsExistingMatchingCard(c249001163.filter2,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp,lv+c:GetOriginalLevel())
end
function c249001163.filter2(c,e,tp,lv)
	return c:IsSetCard(0x22D) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(lv)
end
function c249001163.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and c:IsReleasable() and Duel.IsExistingMatchingCard(c249001163.filter1,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetOriginalLevel()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c249001163.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsReleasable() and Duel.IsExistingMatchingCard(c249001163.filter1,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetOriginalLevel())) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local dg=Duel.SelectMatchingCard(tp,c249001163.filter1,tp,LOCATION_HAND,0,1,1,nil,e,tp,c:GetOriginalLevel())
	local lv=dg:GetFirst():GetOriginalLevel()
	Duel.SendtoGrave(dg,REASON_EFFECT)
	Duel.Release(c,REASON_EFFECT)
	local g=Duel.SelectMatchingCard(tp,c249001163.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,lv+c:GetOriginalLevel())
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1,true)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			tc:RegisterEffect(e2,true)
		end			
		Duel.SpecialSummonComplete()
	end
end
