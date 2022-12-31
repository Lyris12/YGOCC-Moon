--Kitseki Nurturesse (UPDATED)
--Script by XGlitchy30
function c88523898.initial_effect(c)
	--link procedure
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x215a),2,2)
	c:EnableReviveLimit()
	--level/ctype change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88523898,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c88523898.chgcost)
	e1:SetOperation(c88523898.chgop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c88523898.effectcon)
	e2:SetOperation(c88523898.effectop)
	c:RegisterEffect(e2)
end
--filters
function c88523898.rvfilter1(c,tp)
	local lv1=c:GetLevel()
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x215a) and not c:IsPublic()
		and Duel.IsExistingMatchingCard(c88523898.rvfilter2,tp,LOCATION_HAND,0,1,c,lv1)
end
function c88523898.rvfilter2(c)
	local lv2=c:GetLevel()
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x215a) and not c:IsPublic()
end
--level/ctype change
function c88523898.chgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c88523898.rvfilter1,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g1=Duel.SelectMatchingCard(tp,c88523898.rvfilter1,tp,LOCATION_HAND,0,1,1,nil,tp)
	local lv1=g1:GetFirst():GetLevel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g2=Duel.SelectMatchingCard(tp,c88523898.rvfilter2,tp,LOCATION_HAND,0,1,1,g1:GetFirst())
	local lv2=g2:GetFirst():GetLevel()
	g1:Merge(g2)
	Duel.ConfirmCards(1-tp,g1)
	Duel.ShuffleHand(tp)
	e:SetLabel(lv1+lv2)
end
function c88523898.chgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Card.SetCardData(c,CARDDATA_TYPE,TYPE_MONSTER+TYPE_SYNCHRO+TYPE_EFFECT)
	Card.SetCardData(c,CARDDATA_LEVEL,e:GetLabel())
	Card.SetCardData(c,CARDDATA_DEFENSE,0)
	--leave field fixes
	local fx2=Effect.CreateEffect(c)
	fx2:SetDescription(aux.Stringid(40854197,0))
	fx2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	fx2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
	fx2:SetCode(EVENT_TO_GRAVE)
	fx2:SetOperation(c88523898.reboot)
	c:RegisterEffect(fx2)
	local fx3=fx2:Clone()
	fx3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(fx3)
	local fx4=fx2:Clone()
	fx4:SetCode(EVENT_TO_DECK)
	c:RegisterEffect(fx4)
end	
--gain effect
function c88523898.effectcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
function c88523898.effectop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sync=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88523898,1))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c88523898.deckcon)
	e1:SetTarget(c88523898.decktg)
	e1:SetOperation(c88523898.deckop)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	sync:RegisterEffect(e1)
end	
--deck destruction
function c88523898.deckcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function c88523898.decktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
function c88523898.deckop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(1-tp,2,REASON_EFFECT)
end	
--leave field
function c88523898.reboot(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Card.SetCardData(c,CARDDATA_TYPE,TYPE_MONSTER+TYPE_LINK+TYPE_EFFECT)
	Card.SetCardData(c,CARDDATA_LEVEL,2)
	Card.SetCardData(c,CARDDATA_LINK_MARKER,LINK_MARKER_BOTTOM_LEFT+LINK_MARKER_BOTTOM_RIGHT)
end