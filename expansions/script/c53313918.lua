--Mysterious Cosmicfly
function c53313918.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	--P: Once per turn, if you control 2 or more Pandemonium monsters: You can destroy this card, then add 1 card from your Extra Deck to your Hand. (OPT1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e1:SetDescription(1006)
	e1:SetCondition(aux.PandActCheck)
	e1:SetCost(c53313918.cost)
	e1:SetTarget(c53313918.tg1)
	e1:SetOperation(c53313918.op1)
	c:RegisterEffect(e1)
	--P: Once per turn, if you control 2 or more Pandemonium monsters: You can destroy this card, then draw 1 card. (OPT1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetDescription(1000)
	e2:SetCost(c53313918.cost)
	e2:SetTarget(c53313918.tg2)
	e2:SetOperation(c53313918.op2)
	c:RegisterEffect(e2)
	aux.EnablePandemoniumAttribute(c,e1,e2,true,TYPE_EFFECT+TYPE_TUNER)
	--M: When this card is Pandemonium summoned from your hand: You can Special Summon 1 level 4 or lower Pandemonium monster from your Deck, Extra Deck or GY.
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c53313918.spcon)
	e3:SetTarget(c53313918.sptg)
	e3:SetOperation(c53313918.spop)
	c:RegisterEffect(e3)
	--M: Once per turn: You can target 1 monster on the field, its level becomes 1.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetTarget(c53313918.target)
	e4:SetOperation(c53313918.operation)
	c:RegisterEffect(e4)
end
function c53313918.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable() and Duel.IsExistingMatchingCard(aux.AND(aux.FilterBoolFunction(Card.IsFaceup),aux.FilterBoolFunction(Card.IsType,TYPE_PANDEMONIUM)),tp,LOCATION_MZONE,0,2,nil) and c:GetFlagEffect(53313918)==0 end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription()) end
	c:RegisterFlagEffect(53313918,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,1)
end
function c53313918.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function c53313918.op1(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or Duel.Destroy(e:GetHandler(),REASON_EFFECT)==0 then return end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c53313918.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c53313918.op2(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or Duel.Destroy(e:GetHandler(),REASON_EFFECT)==0 then return end
	Duel.BreakEffect()
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function c53313918.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SPECIAL+726) and c:IsPreviousLocation(LOCATION_HAND) and c:GetPreviousControler()==c:GetControler()
end
function c53313918.filter(c,e,tp)
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	return c:IsLevelBelow(4) and c:IsType(TYPE_PANDEMONIUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (not ect or ect>0 or c:IsLocation(LOCATION_GRAVE+LOCATION_DECK))
end
function c53313918.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_GRAVE+LOCATION_DECK end
	if Duel.GetLocationCountFromEx(tp)>0 then loc=loc+LOCATION_EXTRA end
	if chk==0 then return loc~=0 and Duel.IsExistingMatchingCard(c53313918.filter,tp,loc,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function c53313918.spop(e,tp,eg,ep,ev,re,r,rp)
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_GRAVE end
	if Duel.GetLocationCountFromEx(tp)>0 then loc=loc+LOCATION_EXTRA end
	if loc==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c53313918.filter),tp,loc,0,1,1,nil,e,tp)
	local tc1=g1:GetFirst()
	if tc1 then
		Duel.SpecialSummon(tc1,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c53313918.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(2)
end
function c53313918.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c53313918.lvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c53313918.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c53313918.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function c53313918.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
	end
end
