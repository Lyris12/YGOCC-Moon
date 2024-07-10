--[[
Automatyrant Configure
Automatiranno Configura
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	--[[Target 1 Equip Card you control that is equipped to a Machine monster you control; destroy it, and if you do, add 1 Equip Spell or Machine Union monster from your Deck to your hand
	with a different original name.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is sent from your hand or Deck to the GY: You can send the top 3 cards of your Deck to the GY, and if you do, shuffle this card into the Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetFunctions(s.tdcon,nil,s.tdtg,s.tdop)
	c:RegisterEffect(e2)
end
--E1
function s.filter(c,tp,check)
	local ec=c:GetEquipTarget()
	return ec and ec:IsControler(tp) and ec:IsRace(RACE_MACHINE) and (not check or Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,nil,{c:GetOriginalCodeRule()}))
end
function s.thfilter(c,codes)
	return (c:IsSpell(TYPE_EQUIP) or (c:IsMonster(TYPE_UNION) and c:IsRace(RACE_MACHINE))) and not c:IsOriginalCodeRule(table.unpack(codes)) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.filter(chkc,tp,false) end
	if chk==0 then return Duel.IsExists(true,s.filter,tp,LOCATION_SZONE,0,1,nil,tp,true) end
	local g=Duel.Select(HINTMSG_DESTROY,true,tp,s.filter,tp,LOCATION_SZONE,0,1,1,nil,tp,true)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local codes={tc:GetOriginalCodeRule()}
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,codes)
			if #g>0 then
				Duel.Search(g)
			end
		end
	end
end

--E2
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_HAND|LOCATION_DECK)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToDeck() and Duel.IsPlayerCanDiscardDeck(tp,3)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardDeck(tp,3,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		if c:IsRelateToChain() then
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end