--created by Zolanark, coded by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	c:EnableReviveLimit()
	local p1=Effect.CreateEffect(c)
	p1:SetType(EFFECT_TYPE_FIELD)
	p1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	p1:SetRange(LOCATION_PZONE)
	p1:SetTargetRange(LOCATION_MZONE,0)
	p1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_PENDULUM))
	p1:SetValue(1)
	c:RegisterEffect(p1)
	local p2=Effect.CreateEffect(c)
	p2:SetDescription(aux.Stringid(id,0))
	p2:SetCategory(CATEGORY_TODECK)
	p2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	p2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	p2:SetCode(EVENT_TO_GRAVE)
	p2:SetRange(LOCATION_PZONE)
	p2:SetCountLimit(1)
	p2:SetCondition(cid.tdcon)
	p2:SetTarget(cid.tdtg)
	p2:SetOperation(cid.tdop)
	c:RegisterEffect(p2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cid.desreptg)
	e1:SetValue(cid.desrepval)
	e1:SetOperation(cid.desrepop)
	c:RegisterEffect(e1)
end
function cid.cfilter(c,tp)
	return (c:IsSetCard(0x89f) or c:IsPreviousSetCard(0x89f)) and c:GetPreviousControler()==tp and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function cid.tdfilter(c)
	return c:IsSetCard(0x89f) and c:IsAbleToDeck()
end
function cid.thfilter(c)
	return c:IsSetCard(0x89f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cid.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x89f) and bit.band(c:GetType(),0x81)==0x81
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function cid.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.cfilter,1,nil,tp)
end
function cid.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cid.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,cid.tdfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function cid.tdop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg<=0 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		local g=Duel.GetMatchingGroup(cid.thfilter,tp,LOCATION_DECK,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
function cid.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(cid.repfilter,1,nil,tp)
		and Duel.IsPlayerCanDiscardDeck(tp,1) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function cid.desrepval(e,c)
	return cid.repfilter(c,e:GetHandlerPlayer())
end
function cid.desrepop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	Duel.Hint(HINT_CARD,1-tp,id)
end
