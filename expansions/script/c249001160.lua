--Change True Power of Masked HERO - Donning the Mask
function c249001160.initial_effect(c)
	return
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCondition(c249001160.condition)
	e1:SetTarget(c249001160.target)
	e1:SetOperation(c249001160.operation)
	c:RegisterEffect(e1)
end
function c249001160.actfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(249001155)
end
function c249001160.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249001160.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) and Duel.GetFlagEffect(tp,249001160)==0
end
function c249001160.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function c249001160.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,249001160)~=0 then return end
	Duel.RegisterFlagEffect(tp,249001160,0,0,0)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if Duel.SendtoGrave(tc,REASON_EFFECT)==0 then return end
	local ac
	local cc
	repeat
		ac=Duel.AnnounceCard(tp,0xA008,OPCODE_ISSETCARD,TYPE_MONSTER,OPCODE_ISTYPE,OPCODE_AND)
		cc=Duel.CreateToken(tp,ac)
	until cc:IsCanBeSpecialSummoned(e,0,tp,true,false)
	Duel.SpecialSummon(cc,0,tp,tp,true,false,POS_FACEUP)
end