--[[
Automatyrant Soldier
Automatiranno Soldato
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If this card is Normal or Special Summoned: You can Special Summon 1 Level 5 "Automatyrant" monster from your hand or GY in Defense Position,
	and if you do, send the top card of your Deck to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.sptg,s.spop)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[Once per turn, if a card(s) is sent from the Deck to the GY (except during the Damage Step): You can destroy 1 card your opponent controls.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetLabelObject(aux.AddThisCardInMZoneAlreadyCheck(c))
	e2:OPT()
	e2:SetFunctions(s.descon,nil,s.destg,s.desop)
	c:RegisterEffect(e2)
	--If this card is sent to the GY: You can target 3 other cards in your GY; shuffle them into the Deck, and if you do, draw 1 card.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_TODECK|CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetFunctions(nil,nil,s.tdtg,s.tdop)
	c:RegisterEffect(e3)
end
--E1
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_AUTOMATYRANT) and c:IsLevel(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) and Duel.IsPlayerCanDiscardDeck(tp,1)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		Duel.DiscardDeck(tp,1,REASON_EFFECT)
	end
end

--E2
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(aux.AlreadyInRangeFilter(e,Card.IsPreviousLocation),1,nil,LOCATION_DECK)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end

--E3
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc~=aux.ExceptThis(c) and chkc:IsAbleToDeck() end
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,3,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,3,3,aux.ExceptThis(c))
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards()
	if #tg>0 and Duel.ShuffleIntoDeck(tg)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end