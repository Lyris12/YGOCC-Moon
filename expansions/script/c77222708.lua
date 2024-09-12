--Anbionic Companion Triceratops?!
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,s.matfilter,2,s.matcheck)
	--If you Summon a monster(s) that you can place a Charge Counter on, place 1 Charge Counter on each.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.ctcon)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--If an "Anbionic" card(s) you control would be destroyed by battle or card effect, you can destroy 1 Token you control instead.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.reptg)
	e4:SetValue(s.repval)
	e4:SetOperation(s.repop)
	c:RegisterEffect(e4)
	--(Quick Effect): You can remove 2 Charge Counters from your field; Special Summon 1 "Anbionic" monster from your GY
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e5:SetCountLimit(1,{id,0})
	e5:SetCost(s.spcost)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
function s.matfilter(c)
	return s.matfilter1(c) or
		s.matfilter2(c)
end
function s.matfilter1(c)
	return c:IsNegative() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.matfilter2(c)
	return (c:IsPositive() or c:IsNegative()) and c:IsType(TYPE_TOKEN)
end
function s.matfilter3(c)
	return s.matfilter1(c) and not c:IsType(TYPE_TOKEN)
end
function s.matcheck(g,c,tp)
	return g:IsExists(s.matfilter1,1,nil) and g:IsExists(s.matfilter2,1,nil) and not g:IsExists(s.matfilter3,2,nil)
end
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsCanHaveCounter(0x157) and Duel.IsCanAddCounter(tp,0x157,1,c)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	for tc in aux.Next(eg) do
		if s.cfilter(tc,tp) then
			tc:AddCounter(0x157,1)
		end
	end
end
function s.filter1(c,tp)
	return not c:IsReason(REASON_REPLACE) and c:IsLocation(LOCATION_ONFIELD) and c:IsControler(tp)
		and c:IsFaceup() and c:IsSetCard(0xe57) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.filter2(c,e)
	return c:IsType(TYPE_TOKEN) and c:IsFaceup() and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.filter1,nil,tp)
	local tg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_ONFIELD,0,nil,e)
	if chk==0 then return #g>0 and #tg>0 end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local xg=tg:Select(tp,1,1,nil)
		Duel.SetTargetCard(xg)
		xg:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function s.repval(e,c)
	return s.filter1(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local tc=Duel.GetFirstTarget()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x157,2,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x157,2,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xe57) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
			--but it cannot be used as Bigbang Material this turn.
			local tc=g:GetFirst()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetCode(EFFECT_CANNOT_BE_BIGBANG_MATERIAL)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
			tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
		end
	end
end