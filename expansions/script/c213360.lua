--Sigil Sunset
function c213360.initial_effect(c)
	aux.AddCodeList(c,213355)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c213360.condition)
	e1:SetTarget(c213360.target)
	e1:SetOperation(c213360.activate)
	c:RegisterEffect(e1)
	--todeck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(213360,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,213360)
	e2:SetCondition(c213360.tdcon)
	e2:SetTarget(c213360.tdtg)
	e2:SetOperation(c213360.tdop)
	c:RegisterEffect(e2)
end
function c213360.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,213355)
end
function c213360.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c213360.filter,tp,LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetRace)>=5
end
function c213360.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_TURN) end
end
function c213360.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_TURN)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	Duel.RegisterEffect(e1,tp)
end
function c213360.tdfilter(c)
	return c:IsFaceup() and c:IsCode(213355)
end
function c213360.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c213360.tdfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c213360.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function c213360.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end