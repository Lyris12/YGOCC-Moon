--ロスト・ブルー・ブレイカー
function c400007.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95231062,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c400007.condition)
	e1:SetTarget(c400007.target)
	e1:SetOperation(c400007.operation)
	e1:SetCountLimit(1,400007)
	c:RegisterEffect(e1)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(400001,0))
	e5:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,1400017+EFFECT_COUNT_CODE_OATH)
	e5:SetCondition(c400007.con)
	e5:SetTarget(c400007.tg)
	e5:SetOperation(c400007.op)
	c:RegisterEffect(e5)
end
function c400007.cfilter(c)
	return c:IsSetCard(0x246) and c:IsType(TYPE_QUICKPLAY)
end
function c400007.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c400007.cfilter,tp,LOCATION_GRAVE,0,3,nil)
end
function c400007.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c400007.sfilter(c,e,tp)
	return c:IsCode(400008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c400007.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():IsReleasableByEffect()
		and Duel.IsExistingMatchingCard(c400007.sfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function c400007.operation(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.Release(e:GetHandler(),REASON_EFFECT)>0) then return end
	local sc=Duel.SelectMatchingCard(tp,c400007.sfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if sc and Duel.GetLocationCountFromEx(tp)>0 then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c400007.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and re:GetHandler():IsType(TYPE_QUICKPLAY) and re:GetHandler():IsSetCard(0x246) and rp==tp
end
function c400007.spfilter(c,e,tp)
	return c:IsSetCard(0x246) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function c400007.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingMatchingCard(c400007.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
end
function c400007.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(c400007.filter1,tp,LOCATION_DECK,0,1,nil)
	if Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g0=Duel.SelectMatchingCard(c400007.filter2,tp,LOCATION_DECK,0,1,nil,g:GetFirst():GetCode())
	Duel.SendtoHand(g0,nil,REASON_EFFECT)
end
