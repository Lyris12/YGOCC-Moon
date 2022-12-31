--Tengu della Lancia Battipalo
--Script by XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsType,TYPE_DRIVE),1,1)
	--destroy
	c:SummonedTrigger(false,false,true,false,0,CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK,EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY,{true,true},
		aux.SynchroSummonedCond,
		nil,
		aux.Target(s.tdfilter,LOCATION_GRAVE,0,1,1,nil,nil,CATEGORY_TODECK,nil,nil,aux.Info(CATEGORY_TOHAND,1,0,LOCATION_DECK)),
		s.thop
	)
	--return to hand
	c:BanishedTrigger(false,1,CATEGORY_TOHAND,EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY,{true,true},
		nil,
		nil,
		aux.Target(s.filter,LOCATION_GRAVE,0,1,1,nil,nil,CATEGORY_TOHAND),
		aux.SendToHandOperation(SUBJECT_IT)
	)
end
function s.tdfilter(c,_,tp)
	return c:IsMonster(TYPE_DRIVE) and c:IsAbleToDeck()
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c,c:GetLevel(),c:GetRace(),c:GetAttribute())
end
function s.thfilter(c,lv,rc,attr)
	return c:IsMonster(TYPE_DRIVE) and c:IsAbleToHand() and c:HasLevel() and not c:IsLevel(lv) and not c:IsAttribute(attr) and not c:IsRace(rc)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToChain() then return end
	local lv,rc,attr=tc:GetLevel(),tc:GetRace(),tc:GetAttribute()
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,lv,rc,attr)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		if tc:IsMonster(TYPE_DRIVE) and tc:IsRelateToChain() then
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end

function s.filter(c)
	return c:IsMonster(TYPE_DRIVE) and c:IsAbleToHand()
end