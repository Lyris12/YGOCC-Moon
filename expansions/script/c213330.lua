--Sigil Fairy - Va'iol
function c213330.initial_effect(c)
	aux.AddCodeList(c,213355)
	c:EnableReviveLimit()
	--hand link
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,213330)
	e1:SetValue(c213330.matval)
	c:RegisterEffect(e1)
	--pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c213330.ptg)
	c:RegisterEffect(e2)
	--atkup
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(213330,0))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c213330.target)
	e3:SetOperation(c213330.operation)
	c:RegisterEffect(e3)
	--todeck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(213330,1))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,213331)
	e4:SetCondition(c213330.tdcon)
	e4:SetTarget(c213330.tdtg)
	e4:SetOperation(c213330.tdop)
	c:RegisterEffect(e4)
end
function c213330.mfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsLevel(1) and c:IsFaceup()
end
function c213330.exmfilter(c)
	return c:IsLocation(LOCATION_HAND) and c:IsCode(213330)
end
function c213330.matval(e,lc,mg,c,tp)
	return true,not mg or mg:IsExists(c213330.mfilter,1,nil) and not mg:IsExists(c213330.exmfilter,1,nil)
end
function c213330.ptg(e,c)
	return aux.IsCodeListed(c,213355) and c:IsType(TYPE_MONSTER)
end
function c213330.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function c213330.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_RITUAL)
end
function c213330.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(c213330.cfilter,nil)
	if ct==0 then return end
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
function c213330.tdfilter(c)
	return c:IsFaceup() and c:IsCode(213355)
end
function c213330.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c213330.tdfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c213330.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function c213330.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end