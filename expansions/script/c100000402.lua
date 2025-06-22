--[[
Unknown HERO Calling Card
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.RegisterCustomArchetype(id,CUSTOM_ARCHE_UNKNOWN_HERO)
	--Ritual Summon 1 "Unknown HERO" Ritual Monster from your hand, by Tributing monsters from your hand or field whose total Levels equal or exceed the Level of that Ritual Monster. If your opponent controls a monster that was Special Summoned from the Extra Deck, they cannot activate cards or effects in response to this effect's activation.
	local e1=aux.AddRitualProcGreater2(c,s.filter,LOCATION_HAND,nil,nil,false,nil,s.extratg)
	e1:SetDescription(id,0)
	e1:SetRelevantTimings()
	--If this card and an "Unknown HERO" Ritual Monster are in your GY: You can target 1 "Unknown HERO" Ritual Monster in your GY; shuffle both it and this card into the Deck, and if you do, draw 2 cards.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.tdtg,s.tdop)
	c:RegisterEffect(e2)
end

--E1
function s.filter(c,e,tp)
	return c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExists(false,Card.IsSpecialSummoned,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA) then
		Duel.SetChainLimit(s.chlimit)
	end
end
function s.chlimit(e,ep,tp)
	return tp==ep
end

--E2
function s.tdfilter(c)
	return c:IsMonster(TYPE_RITUAL) and c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc~=c and s.tdfilter(chkc) end
	if chk==0 then return c:IsAbleToDeck()
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,c) and Duel.IsPlayerCanDraw(tp,2) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() then
		local g=Group.FromCards(c,tc)
		if Duel.ShuffleIntoDeck(g)==2 then
			Duel.Draw(tp,2,REASON_EFFECT)
		end
	end
end