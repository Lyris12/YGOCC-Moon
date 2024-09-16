--[[
Dynastygian Beacon
Faro Dinastigiano
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Add 1 "Dynastygian" monster from your Deck to your hand, then, if your opponent activated a "Dynastygian" Normal Trap this turn, you can apply the following effect.
	● Draw 2 cards, then discard 1 random card.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_DRAW|CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
	--[[If this card is in your GY while you control a "Dynastygian" monster: You can target 1 of your banished "Dynastygian" Traps; shuffle both it and this card into the Deck, then draw 1 card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetFunctions(
		aux.LocationGroupCond(aux.FaceupFilter(Card.IsSetCard,ARCHE_DYNASTYGIAN),LOCATION_MZONE,0,1),
		nil,
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e2)
end
function s.chainfilter(re,rp,cid)
	return not (re:GetActiveType()==TYPE_TRAP and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsSetCard(ARCHE_DYNASTYGIAN))
end

--E1
function s.filter(c)
	return c:IsSetCard(ARCHE_DYNASTYGIAN) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SearchAndCheck(g) and Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0 and Duel.IsPlayerCanDraw(tp,2) and Duel.SelectYesNo(tp,STRING_ASK_DRAW) then
		Duel.BreakEffect()
		if Duel.Draw(tp,2,REASON_EFFECT)==2 then
			Duel.ShuffleHand(tp)
			local sg=Duel.GetHand(tp):RandomSelect(tp,1)
			if #sg>0 then
				Duel.BreakEffect()
				Duel.SendtoGrave(sg,REASON_EFFECT|REASON_DISCARD)
			end
		end
	end
end

--E2
function s.thfilter(c)
	return c:IsFaceup() and c:IsTrap() and c:IsSetCard(ARCHE_DYNASTYGIAN) and c:IsAbleToDeck()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsBanished() and chkc:IsControler(tp) and s.thfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToDeck() and Duel.IsExists(true,s.thfilter,tp,LOCATION_REMOVED,0,1,nil) and Duel.IsPlayerCanDraw(tp,1)
	end
	local g=Duel.Select(HINTMSG_TODECK,true,tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g+c,2,0,0)
	aux.DrawInfo(tp,1)
end
function s.tgchk(c)
	return c:IsRelateToChain() and c:IsAbleToDeck()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local g=Group.FromCards(c,tc):Filter(s.tgchk,nil)
	if #g==2 and Duel.ShuffleIntoDeck(g)==2 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end