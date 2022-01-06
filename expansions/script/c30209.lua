--Mantra's Soul
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:GetCode()>30200 and tc:GetCode()<30230 end)
	c:SetUniqueOnField(1,0,s_id)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Recover
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(scard.condition)
	e1:SetTarget(scard.target)
	e1:SetOperation(scard.activate)
	e1:SetCountLimit(1,s_id)
	c:RegisterEffect(e1)
end
function scard.somefilter(c,e,tp)
	return (c:IsReason(REASON_EFFECT) or c:IsReason(REASON_COST))
	and c:IsAttribute(ATTRIBUTE_DARK)
	and c:IsMantra()
	and c:GetPreviousControler()==tp
	and c:GetPreviousLocation()==LOCATION_HAND
	and c:IsCanBeEffectTarget(e)
end
function scard.condition(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsHasType(0xFFD)
end
function scard.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return eg:IsContains(chkc) and scard.somefilter(chkc,e,tp) end
    if chk==0 then return eg:IsExists(scard.somefilter,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=eg:FilterSelect(tp,scard.somefilter,1,1,nil,e,tp)
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function scard.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then return end
end
