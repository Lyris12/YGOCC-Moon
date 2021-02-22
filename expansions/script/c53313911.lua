--Mysterious Runner
function c53313911.initial_effect(c)
	--spsummon proc
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53313911,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c53313911.spcon)
	e1:SetOperation(c53313911.spop)
	c:RegisterEffect(e1)
	--spin
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53313911,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetTarget(c53313911.tdtg)
	e2:SetOperation(c53313911.tdop)
	c:RegisterEffect(e2)
	--mill top card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53313911,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE+CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c53313911.milltg)
	e3:SetOperation(c53313911.millop)
	c:RegisterEffect(e3)
end
--filters
function c53313911.cfilter(c)
	return c:IsSetCard(0xcf6) and c:IsAbleToDeckOrExtraAsCost() and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end
--spsummon proc
function c53313911.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c53313911.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
end
function c53313911.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c53313911.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
--spin
function c53313911.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Group.FromCards(e:GetHandler(),Duel.GetAttacker())
	Duel.GetAttacker():CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
function c53313911.tdop(e,tp,eg,ep,ev,re,rp)
	local g=Group.FromCards(e:GetHandler(),Duel.GetAttacker()):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end
end
--mill top card
function c53313911.milltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function c53313911.millop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	local tc=g:GetFirst()
	if tc then
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xcf6) and tc:IsAbleToHand() then
			Duel.ConfirmCards(1-tp,tc)
			if Duel.SelectYesNo(tp,aux.Stringid(53313911,3)) then
				if c:IsRelateToEffect(e) then
					local lv=c:GetLevel()
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_CHANGE_LEVEL)
					e1:SetValue(lv*2)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					c:RegisterEffect(e1)
				end
				Duel.SendtoHand(tc,tp,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc)
			end
		else
			if tc:IsAbleToRemove() and not tc:IsLocation(LOCATION_REMOVED) then
				Duel.ConfirmCards(1-tp,tc)
				Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
			end
		end
	end
end