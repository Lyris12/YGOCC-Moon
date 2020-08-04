--created by Seth, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e0:SetCategory(CATEGORY_TOHAND)
	e0:SetTarget(cid.tg)
	e0:SetOperation(cid.op)
	c:RegisterEffect(e0)
end
function cid.filter(c,tp)
	local re=c:GetReasonEffect()
	if not re then return false end
	local rc,rp=re:GetHandler(),re:GetHandlerPlayer()
	return c:IsFaceup() and c:IsSetCard(0x83e) and rc:IsSetCard(0x83e) and rp==tp and c:IsAbleToHand()
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_REMOVED,0,2,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_REMOVED,0,2,2,nil,tp)
	if #g==2 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
