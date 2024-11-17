--[[
Chain Rejuvenation
Ringiovanimento a Catena
Card Author: Lyris
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Activate only as Chain Link 2 or higher; immediately after this Chain resolves, draw cards equal to its highest Chain Link number, then place cards from your hand on the bottom of the Deck
	equal to the Chain Link number of this card. You cannot activate this card if multiple cards/effects with the same name are in that Chain. ]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DRAW|CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()>0 and Duel.CheckChainUniqueness()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ch=Duel.GetCurrentChain()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(id,1)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetLabel(ch-1)
	e1:SetOperation(s.updatemax)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
	e:SetLabelObject(e1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ch)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,ch,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,1)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_END)
	e1:SetLabel(e:GetLabelObject():GetLabel(),Duel.GetCurrentChain())
	e1:SetOperation(s.applyop)
	Duel.RegisterEffect(e1,tp)
end
function s.updatemax(e)
	e:SetLabel(e:GetLabel()+1)
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local ct1,ct2=e:GetLabel()
	if Duel.Draw(tp,ct1,REASON_EFFECT)>0 then
		Duel.ShuffleHand(tp)
		local g=Duel.Select(HINTMSG_TODECK,false,tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,ct2,ct2,nil)
		if #g>0 then
			aux.PlaceCardsOnDeckBottom(tp,g,REASON_EFFECT)
		end
	end
	e:Reset()
end