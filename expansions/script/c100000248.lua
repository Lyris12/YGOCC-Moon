--[[
Denial Protocol
Protocollo di Negazione
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	--[[When your opponent activates a card or effect while you control a Special Summoned "Automatyrant" monster: Negate the activation, and if you do, banish it.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_NEGATE|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:HOPT()
	e1:SetFunctions(s.condition,nil,aux.nbtg,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is in your GY: You can target 5 other cards in your GY; shuffle those targets into the Deck, and if you do, Set this card, but banish it when it leaves the field.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetRelevantTimings()
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.settg,s.setop)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_AUTOMATYRANT) and c:IsSpecialSummoned()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsChainNegatable(ev) and rp==1-tp
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end

--E2
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc~=aux.ExceptThis(c) and chkc:IsAbleToDeck() end
	if chk==0 then
		return Duel.IsExists(true,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,5,c) and c:IsSSetable()
	end
	local g=Duel.Select(HINTMSG_TODECK,true,tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,5,5,aux.ExceptThis(c))
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
	Duel.SetCardOperationInfo(c,CATEGORY_LEAVE_GRAVE)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards():Filter(Card.IsControler,nil,tp)
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 then
		local c=e:GetHandler()
		if c:IsRelateToChain() and c:IsSSetable() then
			Duel.SSetAndRedirect(tp,c,e)
		end
	end
end