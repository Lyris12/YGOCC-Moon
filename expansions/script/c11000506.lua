--Shya Ghostblade
function c11000506.initial_effect(c)
	--atklimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11000506,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,11000506)
	e2:SetCondition(c11000506.spcon)
	e2:SetTarget(c11000506.sptg)
	e2:SetOperation(c11000506.spop)
	c:RegisterEffect(e2)
end
function c11000506.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:GetPreviousControler()==tp
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsSetCard(0x1FD)
		and c:IsType(TYPE_MONSTER)
end
function c11000506.spcon(e,tp,eg,ep,ev,re,r,rp)
--	local g=eg:Filter(c11000506.cfilter,nil,tp)
--	e:SetLabelObject(g:GetFirst())
--	return g:GetCount()>0
	return eg:IsExists(c11000506.cfilter,1,nil,tp)
end
function c11000506.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c11000506.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE)
		c:CompleteProcedure()
	end
end