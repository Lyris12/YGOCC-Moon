--Mysterious Dimension
function c53313927.initial_effect(c)
	--When this card is activated: You can add 1 "Mysterious" monster from your Deck to your hand. (HOPT1)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c53313927.activate)
	c:RegisterEffect(e1)
	--When you Special Summon a "Mysterious" monster from the Extra Deck (except during the Damage Step): You can draw 1 card. (HOPT2)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,53313930)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetCondition(c53313927.drcon)
	e5:SetTarget(c53313927.drtg)
	e5:SetOperation(c53313927.drop)
	c:RegisterEffect(e5)
	--Once per turn: You can Banish 1 card from your Graveyard: add 1 other banished cards to your Hand. (HOPT3)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCountLimit(1,53313931)
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetTarget(c53313927.thtg)
	e6:SetOperation(c53313927.thop)
	c:RegisterEffect(e6)
end
function c53313927.afilter(c)
	return c:IsSetCard(0xcf6) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c53313927.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetFlagEffect(tp,53313927)>0 then return end
	local g=Duel.GetMatchingGroup(c53313927.afilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,1109) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		Duel.RegisterFlagEffect(tp,53313927,RESET_PHASE+PHASE_END,0,1)
	end
end
function c53313927.cfilter(c,tp)
	return c:GetSummonPlayer()==tp and c:IsFaceup() and c:IsSetCard(0xcf6) and c:GetSummonLocation()==LOCATION_EXTRA
end
function c53313927.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53313927.cfilter,1,nil,tp)
end
function c53313927.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c53313927.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function c53313927.thcfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(c53313927.thfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,c)
end
function c53313927.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xcf6) and c:IsAbleToHand()
end
function c53313927.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313927.thcfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c53313927.thcfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c53313927.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c53313927.thfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,e:GetLabelObject())
	if g:GetCount()>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
