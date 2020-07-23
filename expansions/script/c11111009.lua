--Unchain
function c11111009.initial_effect(c)
--Effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,11111009+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c11111009.spcost)
	e1:SetTarget(c11111009.sptg)
	e1:SetOperation(c11111009.spop)
	c:RegisterEffect(e1)
end
function c11111009.afilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function c11111009.spfilter(c,e,tp)
	return c:IsSetCard(0x223) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c11111009.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11111009.afilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c11111009.afilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c11111009.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11111009.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c11111009.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c11111009.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local sc=g:GetFirst()
	if not sc then return end
	if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
		if sc:IsType(TYPE_XYZ) then
			e:GetHandler():CancelToGrave()
			local mg=e:GetHandler():GetOverlayGroup()
			if mg:GetCount()~=0 then
				Duel.SendtoGrave(mg,REASON_RULE)
			end
			Duel.Overlay(sc,Group.FromCards(e:GetHandler()))
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		sc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end