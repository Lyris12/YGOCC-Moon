--
function c39405.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c39405.descon)
	e1:SetCost(c39405.descost)
	e1:SetTarget(c39405.destg)
	e1:SetOperation(c39405.desop)
	c:RegisterEffect(e1)
end
function c39405.descon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if d==nil then return end
	if a:IsControler(tp) then
		return a:IsFaceup() and a:IsSetCard(0x300) and a:IsRelateToBattle() and d and d:IsRelateToBattle()
	else
		return d and d:IsFaceup() and d:IsSetCard(0x300) and d:IsRelateToBattle() and a and a:IsRelateToBattle()
	end
end
function c39405.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c39405.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabelObject(Group.FromCards(Duel.GetAttacker(),Duel.GetAttackTarget()))
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,Group.FromCards(Duel.GetAttacker(),Duel.GetAttackTarget()),2,0,0)
end
function c39405.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if g:FilterCount(Card.IsRelateToBattle,nil)~=2 then return end
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
