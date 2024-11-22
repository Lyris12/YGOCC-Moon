--[[
Manaseal Supplicant
Supplicante Manasigillo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MANASEAL_RUNE_WEAVING)
	--[[If this card is in your hand or GY: You can target 1 face-up Spell on the field; send that target to the GY, and if you do, Special Summon this card, then send 1 "Manaseal Word" Normal Trap
	from your Deck to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[If you control a face-up DARK "Number" Xyz Monster or "Manaseal Rune Weaving" (Quick Effect): You can Tribute this monster; negate the effects of all face-up Spells on the field, and if you
	do, shuffle them into the Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DISABLE|CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		aux.LocationGroupCond(s.cfilter,LOCATION_ONFIELD,0,1),
		aux.TributeSelfCost,
		s.distg,
		s.disop
	)
	c:RegisterEffect(e2)
end
--E1
function s.tgfilter1(c,tp)
	return c:IsFaceup() and c:IsSpell() and c:IsAbleToGrave() and Duel.GetMZoneCount(tp,c)>0
end
function s.tgfilter2(c)
	return c:IsSetCard(ARCHE_MANASEAL_WORD) and c:IsNormalTrap() and c:IsAbleToGrave()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.tgfilter1(chkc,tp) end
	if chk==0 then
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExists(true,s.tgfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp)
			and Duel.IsExists(false,s.tgfilter2,tp,LOCATION_DECK,0,1,nil)
	end
	local g=Duel.Select(HINTMSG_TOGRAVE,true,tp,s.tgfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,2,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsSpell() and Duel.SendtoGraveAndCheck(tc) then
		local c=e:GetHandler()
		if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
			local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter2,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	end
end

--E2
function s.cfilter(c)
	return c:IsFaceup() and (c:IsCode(CARD_MANASEAL_RUNE_WEAVING) or (c:IsLocation(LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsSetCard(ARCHE_NUMBER) and c:IsType(TYPE_XYZ)))
end
function s.disfilter(c,tp)
	return c:IsSpell() and aux.NegateAnyFilter(c) and (not tp or s.tdfilter(c,tp))
end
function s.tdfilter(c,tp)
	return c:IsAbleToDeck() or (c:IsStatus(STATUS_LEAVE_CONFIRMED) and not c:IsHasEffect(EFFECT_CANNOT_TO_DECK) and Duel.IsPlayerCanSendtoDeck(tp,c))
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tp)
	if chk==0 then return #g>0 end
	Duel.SetCardOperationInfo(g,CATEGORY_DISABLE)
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Group(s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local dg=g:Filter(Card.IsCanBeDisabledByEffect,nil,e)
	if #g>0 and Duel.Negate(g,e,nil,false,false,TYPE_SPELL)>0 then
		g=Duel.Group(s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tp):Filter(aux.Faceup(Card.IsSpell),nil)
		if #g>0 then
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT,tp,true)
		end
	end
end