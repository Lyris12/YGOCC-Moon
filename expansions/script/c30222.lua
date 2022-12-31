--Mantra Spider
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:GetCode()>30200 and tc:GetCode()<30230 end)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(scard.descon)
	e1:SetCost(scard.descost)
	e1:SetTarget(scard.destg)
	e1:SetCountLimit(1,s_id)
	e1:SetOperation(scard.desop)
	c:RegisterEffect(e1)
end
function scard.descon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if a:IsControler(tp) then
		e:SetLabelObject(d)
		return a:IsFaceup() and a:IsMantra() and a:IsRelateToBattle() and d and d:IsRelateToBattle()
	else
		e:SetLabelObject(a)
		return d and d:IsFaceup() and d:IsMantra() and d:IsRelateToBattle() and a and a:IsRelateToBattle()
	end
end
function scard.desfilter(c)
	return c:IsDiscardable() and c:IsMantra() and c:IsType(TYPE_MONSTER)
end
function scard.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(scard.desfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,scard.desfilter,1,1,REASON_COST+REASON_DISCARD)
end
function scard.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetLabelObject()
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
function scard.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() then
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
