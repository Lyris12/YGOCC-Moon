--Vertex Melody Stan
--Scripted by Zerry
function c11111304.initial_effect(c)
local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_QUICK_O)
		e4:SetCategory(CATEGORY_DISABLE)
		e4:SetCode(EVENT_CHAINING)
		e4:SetRange(LOCATION_HAND)
		e4:SetCountLimit(1,11111304)
		e4:SetCondition(c11111304.ngcon)
		e4:SetCost(c11111304.ngcost)
		e4:SetTarget(c11111304.ngtg)
		e4:SetOperation(c11111304.ngop)
		c:RegisterEffect(e4)
local e3=Effect.CreateEffect(c)
	    e3:SetCategory(CATEGORY_TOHAND)
	    e3:SetType(EFFECT_TYPE_IGNITION)
	    e3:SetRange(LOCATION_GRAVE)
		e3:SetCountLimit(1,11111304+100)
	    e3:SetCost(c11111304.thcost)
	    e3:SetTarget(c11111304.thtg)
  	    e3:SetOperation(c11111304.thop)
    	c:RegisterEffect(e3)
end
function c11111304.cfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and ((c:IsType(TYPE_FUSION) and c:IsSetCard(0x5a3)) or c:IsCode(11111301))
end
function c11111304.ngcon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(c11111304.cfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
function c11111304.ngcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function c11111304.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function c11111304.ngop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function c11111304.thfilter(c)
	return c:IsAbleToGraveAsCost() and c:IsSetCard(0x5a3) or c:IsRace(RACE_PSYCHO)
end
function c11111304.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11111304.thfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c11111304.thfilter,1,1,REASON_COST)
end
function c11111304.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function c11111304.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end