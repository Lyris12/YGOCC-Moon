--[[
Power Vacuum Fatality
Fatalità Potere Vacuum
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id,CARD_POWER_VACUUM_ZONE,CARD_POWER_VACUUM_BLADE)
	--[[Target 1 monster your opponent controls, or up to 3 if you control "Power Vacuum Zone" or "Power Vacuum Blade"; their ATK/DEF becomes 0, or if their ATK/DEF is already 0, banish those
	targets face-down.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_ATKDEF|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is in your GY while you control a "Vacuous" monster: You can target 1 other card in your GY or banishment, except "Power Vacuum Fatality" (either a "Vacuous" monster, or a card
	that mentions "Power Vacuum Blade"); shuffle both it and this card into the Deck, and if you do, draw 1 card for each monster on the field with 0 ATK/DEF, then if you have 7 or more cards in
	your hand, shuffle random cards from your hand into the Deck until you have 5 cards left.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetFunctions(
		aux.LocationGroupCond(aux.FaceupFilter(Card.IsSetCard,ARCHE_VACUOUS),LOCATION_MZONE,0,1),
		nil,
		s.thtg,
		s.thop)
	c:RegisterEffect(e2)
end
--E1
function s.filter(c,tp)
	if not c:IsFaceup() then return false end
	if not c:IsStats(0,0) then
		return true
	else
		return c:IsAbleToRemove(tp,POS_FACEDOWN)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExists(true,s.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	local max=Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_ZONE,CARD_POWER_VACUUM_BLADE),tp,LOCATION_ONFIELD,0,1,nil) and 3 or 1
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,0,LOCATION_MZONE,1,max,nil,tp)
	local atkg=g:Filter(aux.NOT(aux.FilterBoolFunction(Card.IsStats,0,0)),nil)
	local rmg=g:Filter(aux.TRUE,atkg)
	if #atkg>0 then
		Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,atkg,#atkg,0,0,{0})
	end
	if #rmg>0 then
		Duel.SetCardOperationInfo(rmg,CATEGORY_REMOVE)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards():Filter(Card.IsFaceup,nil)
	if #g==0 then return end
	local atkg=g:Filter(aux.NOT(aux.FilterBoolFunction(Card.IsStats,0,0)),nil)
	local rmg=g:Filter(Card.IsAbleToRemove,atkg,tp,POS_FACEDOWN):Filter(Card.IsControler,nil,1-tp)
	for tc in aux.Next(atkg) do
		tc:ChangeATKDEF(0,0,true,{c,true})
	end
	if #rmg>0 then
		Duel.Remove(rmg,POS_FACEDOWN,REASON_EFFECT)
	end
end

--E2
function s.tdfilter(c)
	return c:IsFaceupEx() and ((c:IsMonster() and c:IsSetCard(ARCHE_VACUOUS)) or c:Mentions(CARD_POWER_VACUUM_BLADE)) and not c:IsCode(id) and c:IsAbleToDeck()
end
function s.thfilter(c)
	return c:IsSetCard(ARCHE_VACUOUS) and c:IsLevel(5,7) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GB) and chkc:IsControler(tp) and chkc~=c and s.tdfilter(chkc) end
	local g=Duel.Group(aux.FaceupFilter(Card.IsStats,0,0),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then
		return c:IsAbleToDeck() and Duel.IsExists(true,s.tdfilter,tp,LOCATION_GB,0,1,c)
			and #g>0 and Duel.IsPlayerCanDraw(tp,#g)
	end
	local g=Duel.Select(HINTMSG_TODECK,true,tp,s.tdfilter,tp,LOCATION_GB,0,1,1,c)
	g:AddCard(c)
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,#g)
	local val=Duel.GetHandCount(tp)+#g
	Duel.SetConditionalOperationInfo(val>=7,0,CATEGORY_TODECK,nil,val-5,tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and c:IsAbleToDeck() and tc:IsAbleToDeck() and Duel.ShuffleIntoDeck(Group.FromCards(c,tc))==2 then
		local g=Duel.Group(aux.FaceupFilter(Card.IsStats,0,0),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if #g>0 and Duel.Draw(tp,#g,REASON_EFFECT)>0 then
			local val=Duel.GetHandCount(tp)
			if val>=7 then
				Duel.ShuffleHand(tp)
				local tg=Duel.GetHand(tp):RandomSelect(tp,val-5)
				if #tg>0 then
					Duel.BreakEffect()
					Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
				end
			end
		end
	end
end