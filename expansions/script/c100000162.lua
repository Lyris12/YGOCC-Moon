--[[
Level Trade
Baratto di Livello
Card Author: greg501
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
    --[[Place 1 Level 5 or higher "LV" monster from your hand on the bottom of the Deck; draw 2 cards.]]
    local e1=Effect.CreateEffect(c)
	e1:Desc(0)
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetFunctions(nil,s.cost,s.target,s.activate)
    c:RegisterEffect(e1)
	--[[You can banish this card from your GY, then target up to 4 "LV" monsters in your GY; shuffle them into the Deck, then draw 1 card.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drawtg)
	e2:SetOperation(s.drawop)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_LV) and c:IsLevelAbove(5) and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end

--E2
function s.filter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_LV) and c:IsAbleToDeck()
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then
		local exc
		if e:IsCostChecked() then
			exc=e:GetHandler()
		end
		return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,exc)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,4,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local td=Duel.GetTargetCards()
	if #td<=0 then return end
	if Duel.ShuffleIntoDeck(td)>0 then
		if Duel.IsPlayerCanDraw(tp,1) then
			Duel.BreakEffect()
		end
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end