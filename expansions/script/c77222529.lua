--Oniritron Device - Swap Orb
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.xyzfilter(c,e,tp)
	return c:IsSetCard(0x721) and c:IsType(TYPE_XYZ) and c:IsRank(1) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and
		(not Duel.IsExistingMatchingCard(Card.IsCode,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetCode()) or Duel.IsExistingMatchingCard(s.xyzfilter2,c:GetControler(),LOCATION_MZONE,0,1,nil,c))
end
function s.xyzfilter2(c,xyz)
	return c:IsSetCard(0x721) and c:IsType(TYPE_XYZ) and c:IsFaceup() and (xyz==nil or not c:IsCode(xyz:GetCode()))
end
function s.attachfilter(c,e)
	return c:IsFaceup() and not c:IsImmuneToEffect(e) and c:IsType(TYPE_XYZ)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.xyzfilter2,tp,LOCATION_MZONE,0,1,nil,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.xyzfilter2(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not xyz then return end
	xm=Duel.SelectMatchingCard(tp,s.xyzfilter2,tp,LOCATION_MZONE,0,1,1,nil,xyz):GetFirst()
	--xyz:SetMaterial(xm)
	--Duel.Overlay(xyz,xm)
	--Duel.SpecialSummonStep(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
	--Duel.SpecialSummonComplete()
	--xyz:CompleteProcedure()
	if xyz then
		local mg=xm:GetOverlayGroup()
		if mg:GetCount()~=0 then
			Duel.Overlay(xyz,mg)
		end
		xyz:SetMaterial(Group.FromCards(xm))
		Duel.Overlay(xyz,Group.FromCards(xm))
		Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		xyz:CompleteProcedure()
	end
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		tc=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_MZONE,0,1,1,nil,e):GetFirst()
		e:GetHandler():CancelToGrave()
		Duel.Overlay(tc,e:GetHandler())
	end
end
