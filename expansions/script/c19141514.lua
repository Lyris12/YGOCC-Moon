--created by Windy Gurls, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetCondition(aux.AND(aux.exccon,function(e,tp) local ph=Duel.GetCurrentPhase() return Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) end))
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(cid.tg)
	e2:SetOperation(cid.operation)
	c:RegisterEffect(e2)
end
function cid.filter(c)
	return c:GetCounter(0x1015)>0
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cid.filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cid.filter,tp,0,LOCATION_MZONE,nil)
	Duel.Destroy(g)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetCondition(function() return tc:IsLocation(LOCATION_GRAVE) end)
		e1:SetReset(RESET_EVENT+0x17a0000)
		tc:RegisterEffect(e1)
	end
end
function cid.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0xa40) and c:IsAbleToHand()
		and not c:IsCode(id)
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
end
