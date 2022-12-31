--Maeira, Kitseki Soul Stealer
--Script by XGlitchy30
function c88523897.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x215a),aux.NonTuner(c88523897.nontuner),1)
	c:EnableReviveLimit()
	--deck destruction
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88523897,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c88523897.deckcon)
	e1:SetTarget(c88523897.decktg)
	e1:SetOperation(c88523897.deckop)
	c:RegisterEffect(e1)
end
--materials
function c88523897.nontuner(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_BEASTWARRIOR)
end
--filters
function c88523897.namefilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x215a)
end
--deck destruction
function c88523897.deckcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function c88523897.decktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c88523897.namefilter,tp,LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	if chk==0 then return ct>=2 and Duel.IsPlayerCanDiscardDeck(1-tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,1)
end
function c88523897.deckop(e,tp,eg,ep,ev,re,r,rp)
	--name check
	local g=Duel.GetMatchingGroup(c88523897.namefilter,tp,LOCATION_GRAVE,0,nil)
	if g:GetCount()<=1 then return end
	local ct=g:GetClassCount(Card.GetCode)
	----------
	local fix=0
	if math.fmod(ct,2)~=0 then 
		fix=ct-1
	else
		fix=ct
	end
	local discard=fix/2
	Duel.DiscardDeck(1-tp,discard,REASON_EFFECT)
end