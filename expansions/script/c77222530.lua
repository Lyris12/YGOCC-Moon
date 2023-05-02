--Oniritron Device - Assault Orb
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.xyzfilter(c,e,tp)
	return c:IsSetCard(0x721) and c:IsType(TYPE_XYZ) and c:IsRank(1) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.attachfilter(c,e)
	return c:IsFaceup() and not c:IsImmuneToEffect(e) and c:IsType(TYPE_XYZ)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not xyz then return end
	Duel.SpecialSummonStep(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
	Duel.SpecialSummonComplete()
	xyz:CompleteProcedure()
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		tc=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_MZONE,0,1,1,nil,e):GetFirst()
		e:GetHandler():CancelToGrave()
		Duel.Overlay(tc,e:GetHandler())
	end
end
