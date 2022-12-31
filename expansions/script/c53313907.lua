--Mysterious Starquid
function c53313907.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	--P-When an effect is activated: You can destroy this card, and change that effect to "Both players can add 1 Level 6 or lower Pandemonium monster from their Decks to their hands, except "Mysterious Starquid".". (HOPT1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TODECK)
	e1:SetCondition(aux.PandActCheck)
	e1:SetTarget(c53313907.chtg)
	e1:SetOperation(c53313907.chop)
	c:RegisterEffect(e1)
	aux.EnablePandemoniumAttribute(c,e1)
	--M-When this card is Summoned: You can add 1 "Mysterious" monster from your Deck, Extra Deck or GY to your Hand, except "Mysterious Starquid".
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetCost(c53313907.thcost)
	e2:SetTarget(c53313907.thtg)
	e2:SetOperation(c53313907.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	--M-When this card leaves the field: You can set 1 "Mysterious" Pandemonium monster directly from your Deck to your Spell & Trap card zone except "Mysterious Starquid".
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e5:SetTarget(c53313907.settg)
	e5:SetOperation(c53313907.setop)
	c:RegisterEffect(e5)
end
--filters
function c53313907.filter(c)
	return c:IsLevelBelow(6) and c:IsType(TYPE_PANDEMONIUM) and not c:IsCode(53313907)
end
function c53313907.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xcf6) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function c53313907.thcostfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xcf6) and c:IsAbleToRemoveAsCost()
end
function c53313907.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xcf6) and c:IsAbleToHand() and not c:IsCode(53313907)
end
function c53313907.setfilter(c)
	return c:IsSetCard(0xcf6) and c:IsType(TYPE_PANDEMONIUM) and not c:IsCode(53313907)
end
--change effect
function c53313907.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable()
		and Duel.IsExistingMatchingCard(c53313907.cfilter,tp,LOCATION_REMOVED,0,1,e:GetHandler())
		and Duel.IsExistingMatchingCard(c53313907.filter,tp,LOCATION_DECK,0,1,nil) and Duel.GetFlagEffect(tp,53313907)==0 
	end
	Duel.RegisterFlagEffect(tp,53313907,RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
end
function c53313907.chop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local tg=Duel.SelectMatchingCard(tp,c53313907.cfilter,tp,LOCATION_REMOVED,0,1,1,e:GetHandler())
		if tg:GetCount()<=0 then return end
		if Duel.SendtoDeck(tg,nil,2,REASON_EFFECT)~=0 then
			local g=Group.CreateGroup()
			Duel.ChangeTargetCard(ev,g)
			Duel.ChangeChainOperation(ev,c53313907.repop)
		end
	end
end
function c53313907.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsType(TYPE_EQUIP) and c:IsOnField() then
		c:CancelToGrave(false)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=Duel.SelectMatchingCard(tp,c53313907.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc1=g1:GetFirst()
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
	local g2=Duel.SelectMatchingCard(1-tp,c53313907.filter,tp,0,LOCATION_DECK,1,1,nil)
	local tc2=g2:GetFirst()
	g1:Merge(g2)
	Duel.SendtoHand(g1,nil,REASON_EFFECT)
	if tc1 then Duel.ConfirmCards(1-tp,tc1) end
	if tc2 then Duel.ConfirmCards(tp,tc2) end
end
--
function c53313907.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313907.thcostfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c53313907.thcostfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c53313907.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313907.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end
function c53313907.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c53313907.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--
function c53313907.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and aux.PandSSetCon(c53313907.setfilter,nil,LOCATION_DECK)(nil,e,tp,eg,ep,ev,re,r,rp)
		and Duel.IsExistingMatchingCard(c53313907.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c53313907.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not aux.PandSSetCon(c53313907.setfilter,nil,LOCATION_DECK)(nil,e,tp,eg,ep,ev,re,r,rp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,1601)
	local g=Duel.SelectMatchingCard(tp,aux.PandSSetFilter(c53313907.setfilter),tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		aux.PandSSet(tc,REASON_EFFECT)(e,tp,eg,ep,ev,re,r,rp)
		Duel.ConfirmCards(1-tp,tc)
	end
end
