--Nano-Mesh Drone
function c249001162.initial_effect(c)
	--special summon other
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(2)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c249001162.spcost)
	e1:SetTarget(c249001162.sptg)
	e1:SetOperation(c249001162.spop)
	c:RegisterEffect(e1)
	--special summon self
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c249001162.spcon2)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(249001162,ACTIVITY_SPSUMMON,c249001162.counterfilter)
end
function c249001162.counterfilter(c)
	return c:IsRace(RACE_CYBERSE) or c:IsRace(RACE_MACHINE)
end
function c249001162.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(249001162,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c249001162.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c249001162.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_CYBERSE) and not c:IsRace(RACE_MACHINE)
end
function c249001162.mzfilter(c,e,tp,lv)
	return c:IsControler(tp) and c:GetSequence()<5 and c249001162.filter1(c,e,tp,lv)
end
function c249001162.filter1(c,e,tp,lv)
	return c:IsRace(RACE_MACHINE) and c:IsLevelAbove(1) and Duel.IsExistingMatchingCard(c249001162.filter2,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp,lv+c:GetOriginalLevel())
end
function c249001162.filter2(c,e,tp,lv)
	return c:IsSetCard(0x22D) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(lv)
end
function c249001162.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and c:IsReleasable() and Duel.CheckReleaseGroup(tp,c249001162.filter1,1,c,e,tp,c:GetOriginalLevel())
		and (ft>0 or Duel.CheckReleaseGroup(tp,c249001162.mzfilter,1,c,e,tp,lv)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c249001162.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if c:GetSequence()<5 then ft=ft+1 end
	if not (ft>-1 and c:IsReleasable() and Duel.CheckReleaseGroup(tp,c249001162.filter1,1,c,e,tp,c:GetOriginalLevel())
		and (ft>0 or Duel.CheckReleaseGroup(tp,c249001162.mzfilter,1,c,e,tp,lv))) then return end
	local rg=nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	if ft>0 then
		rg=Duel.SelectReleaseGroup(tp,c249001162.filter1,1,1,c,e,tp,c:GetOriginalLevel())
	else
		rg=Duel.SelectReleaseGroup(tp,c249001162.mzfilter,1,1,c,e,tp,c:GetOriginalLevel())
	end
	local lv=rg:GetFirst():GetOriginalLevel()
	rg:AddCard(c)
	Duel.Release(rg,REASON_EFFECT)
	local g=Duel.SelectMatchingCard(tp,c249001162.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,lv+c:GetOriginalLevel())
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
function c249001162.spcon2(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0,nil)<Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE,nil)
end
