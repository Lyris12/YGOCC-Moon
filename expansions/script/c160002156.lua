--Saber Yasmin of Gust VINE
function c160002156.initial_effect(c)
	  aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
  aux.AddEvoluteProc(c,nil,4,c160002156.filter1,2,2)
		--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c160002156.efilter)
	c:RegisterEffect(e1)
		--draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(160002156,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,160002156)
	e2:SetCondition(c160002156.drcon)
	e2:SetTarget(c160002156.drtg)
	e2:SetOperation(c160002156.drop)
	c:RegisterEffect(e2)
		--negate
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG2_XMDETACH+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c160002156.discon)
	e3:SetCost(c160002156.discost)
	e3:SetTarget(c160002156.distg)
	e3:SetOperation(c160002156.disop)
	c:RegisterEffect(e3)
	
end
function c160002156.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_PLANT) 
end
function c160002156.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER)
end

function c160002156.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function c160002156.discost(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x88,4,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x88,4,REASON_COST)
end
function c160002156.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c160002156.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function c160002156.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
function c160002156.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
function c160002156.drop(e,tp,eg,ep,ev,re,r,rp)
		Duel.DiscardDeck(tp,4,REASON_EFFECT)
end

