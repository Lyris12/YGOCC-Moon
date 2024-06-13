--[[
Curseflame Bartering
Baratto Fiammaledetta
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--If you control a face-up "Curseflame" monster: Remove Curseflame Counters from anywhere on the field in multiples of 3 (max. 15); draw 1 card for every 3 Curseflame counters removed this way. For the rest of this turn after this effect resolves, you cannot add cards from your Deck to your hand, except by drawing them. During the End Phase of the turn you activated this effect, if you removed 15 Curseflame counters this way, and you have 7 or more cards in your hand, banish your entire hand, face-down, also skip your next Draw Phase.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetFunctions(s.condition,aux.DummyCost,s.target,s.activate)
	c:RegisterEffect(e1)
	--If this card is in your GY, except the turn it was sent there: You can remove 5 Curseflame Counters from anywhere on the field; shuffle as many of your banished cards as possible into the Deck, and if you do, banish this card, then draw cards until you have 5 in your hand.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_REMOVE|CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetFunctions(
		aux.exccon,
		aux.RemoveCounterCost(COUNTER_CURSEFLAME,5,1,1),
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_CURSEFLAME)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.drawchk(i,tp)
	return Duel.IsCanRemoveCounter(tp,1,1,COUNTER_CURSEFLAME,i,REASON_COST) and Duel.IsPlayerCanDraw(tp,i/3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not e:IsCostChecked() then return false end
		for i=3,15,3 do
			if s.drawchk(i,tp) then
				return true
			end
		end
		return false
	end
	local n=Duel.AnnounceNumberMinMax(tp,3,15,s.drawchk,3)
	if not n or n==0 then return end
	local ct0=Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)
	Duel.RemoveCounter(tp,1,1,COUNTER_CURSEFLAME,n,REASON_COST)
	local remct=ct0-Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(remct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,math.floor(remct/3))
	if remct==15 then
		e:SetCategory(CATEGORY_DRAW|CATEGORY_REMOVE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
	else
		e:SetCategory(CATEGORY_DRAW)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p,remct=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,math.floor(remct/3),REASON_EFFECT)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetTargetRange(LOCATION_DECK,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,p)
	Duel.RegisterHint(p,nil,PHASE_END,1,id,1)
	if e:IsActivated() and remct==15 then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE|PHASE_END)
		e2:OPT()
		e2:SetReset(RESET_PHASE|PHASE_END)
		e2:SetCondition(s.discon)
		e2:SetOperation(s.disop)
		Duel.RegisterEffect(e2,p)
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetHandCount(tp)>=7
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(Card.IsAbleToRemoveFacedown,tp,LOCATION_HAND,0,nil,tp) 
	if #g>0 then
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_DRAW|RESET_SELF_TURN,Duel.GetNextPhaseCount(PHASE_DRAW,tp))
	Duel.RegisterEffect(e1,tp)
end

--E2
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=Duel.GetHandCount(tp)
	if chk==0 then
		return ct<5 and Duel.IsPlayerCanDraw(tp,5-ct) and Duel.IsExists(false,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,nil) and c:IsAbleToRemove()
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
	Duel.SetCardOperationInfo(c,CATEGORY_REMOVE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,5-ct)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,nil)
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 then
		local c=e:GetHandler()
		if c:IsRelateToChain() and c:IsAbleToRemove() and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 then
			local ct=Duel.GetHandCount(tp)
			if ct<5 then
				Duel.BreakEffect()
				Duel.Draw(Duel.GetTargetPlayer(),5-ct,REASON_EFFECT)
			end
		end
	end
end