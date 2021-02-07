--Change True Power of Elemental HERO - Elemental Fusion
function c249001156.initial_effect(c)
	return
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c249001156.condition)
	e1:SetTarget(c249001156.target)
	e1:SetOperation(c249001156.operation)
	c:RegisterEffect(e1)
end
function c249001156.actfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(249001155)
end
function c249001156.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249001156.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) and Duel.GetFlagEffect(tp,249001156)==0
end
function c249001156.rmfilter(c)
	return c:IsAbleToRemove() and c:IsSetCard(0x8)
end
function c249001156.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001156.rmfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
function c249001156.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,249001156)~=0 then return end
	Duel.RegisterFlagEffect(tp,249001156,0,0,0)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.SelectMatchingCard(tp,c249001156.rmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,3,3,nil)
	if g:GetCount()==3 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT) then
		local ac
		local cc
		repeat
			ac=Duel.AnnounceCard(tp,0x3008,OPCODE_ISSETCARD,TYPE_FUSION,OPCODE_ISTYPE,OPCODE_AND)
			cc=Duel.CreateToken(tp,ac)
		until cc:IsCanBeSpecialSummoned(e,0,tp,true,false)
		Duel.SendtoDeck(cc,nil,2,REASON_RULE)
		if Duel.SpecialSummonStep(cc,0,tp,tp,true,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TO_DECK)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			cc:RegisterEffect(e1,true)
		end
		Duel.SpecialSummonComplete()
	end
end
