--[[
Curseflame Apotheosis
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If there are 10 or more Curseflame Counters on the field: Place 10 Curseflame Counters on each face-up card on the field. You must control a face-up "Curseflame" Ritual Monster, or a
	"Curseflame" monster that was Special Summoned from the Extra Deck, to activate and resolve this effect.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(
		s.condition,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[If this card is in your GY while all face-up cards your opponent controls have a Curseflame Counter(s) on them: You can banish this card and 1 Level 5 "Curseflame" monster from your GY; send
	cards from the top of your opponent's Deck to the GY, up to the number of face-up cards they control with a Curseflame Counter(s). Cards sent to the GY this way cannot activate their own effects
	during that same turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		s.millcon,
		s.millcost,
		s.milltg,
		s.millop
	)
	c:RegisterEffect(e2)
end

--E1
function s.cfilter(c)
	if not (c:IsFaceup() and c:IsSetCard(ARCHE_CURSEFLAME)) then return false end
	return c:IsType(TYPE_RITUAL) or c:IsSpecialSummoned(LOCATION_EXTRA)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)>=10 and Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,COUNTER_CURSEFLAME,10)
	if chk==0 then
		return #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,10,tp,COUNTER_CURSEFLAME)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	local g=Duel.Group(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ActivateException(e,nil),COUNTER_CURSEFLAME,10)
	for tc in aux.Next(g) do
		tc:AddCounter(COUNTER_CURSEFLAME,10)
	end
end

--E2
function s.millcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	return #g>0 and not g:IsExists(aux.NOT(Card.HasCounter),1,nil,COUNTER_CURSEFLAME)
end
function s.rcfilter(c)
	return c:IsSetCard(ARCHE_CURSEFLAME) and c:IsLevel(5) and c:IsAbleToRemoveAsCost()
end
function s.millcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemoveAsCost() and Duel.IsExists(false,s.rcfilter,tp,LOCATION_GRAVE,0,1,c)
	end
	local g=Duel.Select(HINTMSG_REMOVE,false,tp,s.rcfilter,tp,LOCATION_GRAVE,0,1,1,c)
	Duel.Remove(g+c,POS_FACEUP,REASON_COST)
end
function s.ctfilter(c,ct)
	return c:IsFaceup() and c:IsCanAddCounter(COUNTER_CURSEFLAME,ct)
end
function s.milltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.Group(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil):FilterCount(Card.HasCounter,nil,COUNTER_CURSEFLAME)
	if chk==0 then
		return ct>0 and Duel.IsPlayerCanDiscardDeck(1-tp,ct)
	end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,ct)
end
function s.millop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.Group(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil):FilterCount(Card.HasCounter,nil,COUNTER_CURSEFLAME)
	if ct<=0 then return end
	if Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		local og=Duel.GetGroupOperatedByThisEffect(e):Filter(Card.IsInGY,nil)
		for tc in aux.Next(og) do
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(STRING_CANNOT_TRIGGER)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end