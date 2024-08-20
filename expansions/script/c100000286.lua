--[[
Spellbook of Concentration
Libro di Magia della Concentrazione
Card Author: Moterius
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[When this card is activated: Shuffle both this card and all "Spellbook" Spells from your hand, face-up field and GY into the Deck (min. 1),
	then draw 2 cards. For the rest of the turn after this card resolves, you cannot activate "Spellbook" Spell Cards.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
end
--E1
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsSpell() and c:IsSetCard(ARCHE_SPELLBOOK,true) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.tdfilter,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE,0,c)
	if chk==0 then
		if not (e:IsHasType(EFFECT_TYPE_ACTIVATE) and c:IsAbleToDeck() and #g>0 and Duel.IsPlayerCanDraw(tp,2)) then return false end
		local res=true
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_TO_DECK) then
			c:SetLocationAfterCost(LOCATION_SZONE)
			res=c:IsAbleToDeck()
			c:SetLocationAfterCost(nil)
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g+1,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE)
	aux.DrawInfo(tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(id,1)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
	if not c:IsRelateToChain() or c:IsHasEffect(EFFECT_CANNOT_TO_DECK) or not Duel.IsPlayerCanSendtoDeck(tp,c) then return false end
	local g=Duel.Group(s.tdfilter,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE,0,c)
	if #g==0 then return end
	c:CancelToGrave()
	g:AddCard(c)
	if Duel.ShuffleIntoDeck(g)>0 then
		if Duel.IsPlayerCanDraw(tp,2) then
			Duel.BreakEffect()
		end
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:IsSetCard(ARCHE_SPELLBOOK)
end