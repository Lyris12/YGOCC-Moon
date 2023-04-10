--Naturia Solarenix
local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,5,s.sumcon,s.tlfilter)
	c:EnableReviveLimit()
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,aux.FALSE)
	--When your opponent activates a card or effect: You can send the top 2 cards of your Deck to the GY, and if you do, 
	--if a card of the same type (Monster, Spell or Trap) as your opponent's activated card was sent to the GY by this effect, negate the activation, and if you do that, destroy that card.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--If this card is in your GY: You can banish 1 Plant and 1 Insect monster from your GY; Special Summon this card.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.sumcon(e,c)
	local tp=c:GetControler()
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>1
end
function s.tlfilter(c,e,mg)
	local tp=c:GetControler()
	local ef=e:GetHandler():GetFuture()
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevelBelow(ef-1)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and rp==1-tp and Duel.IsChainDisablable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	rtype=re:GetActiveType()&(TYPE_SPELL|TYPE_MONSTER|TYPE_TRAP)
	--Debug.Message(rtype)
	Duel.DiscardDeck(tp,2,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	local i=g:GetFirst()
	local match=0
	while i do
		--Debug.Message(i:GetType()&rtype)
		if (i:GetType()&rtype)==rtype and i:IsLocation(LOCATION_GRAVE) then match=match+1 end
		i=g:GetNext()
	end
	if match>0 then
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
function s.cfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsRace(RACE_PLANT|RACE_INSECT)
end
function s.cfilter1(c,g)
	return c:IsRace(RACE_PLANT) and g:IsExists(Card.IsRace,1,c,RACE_INSECT)
end
function s.check(g)
	return g:IsExists(s.cfilter1,1,nil,g)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,c)
	if chk==0 then return g:CheckSubGroup(s.check,2,2) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:SelectSubGroup(tp,s.check,false,2,2)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then 
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end		
end
