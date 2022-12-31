--Orizzonte Maestà Nottesfumo
--Script by XGlitchy30
function c62613313.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62613313,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,62613313)
	e1:SetCondition(c62613313.condition)
	e1:SetTarget(c62613313.target)
	e1:SetOperation(c62613313.activate)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62613313,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,62613313)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c62613313.thtg)
	e2:SetOperation(c62613313.thop)
	c:RegisterEffect(e2)
end
--filters
function c62613313.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x6233)
end
function c62613313.targfilter(c,tp)
	return c:IsSetCard(0x6233) and ((c:IsAbleToRemove() and Duel.IsExistingTarget(c62613313.targfilter_alt,tp,LOCATION_GRAVE,0,2,c,1,tp,nil))
		or (c:IsAbleToDeck() and Duel.IsExistingTarget(c62613313.targfilter_alt,tp,LOCATION_GRAVE,0,1,c,2,tp,c)))
end
function c62613313.targfilter_alt(c,mode,tp,cc)
	if not mode then return false end
	if mode==1 then
		return c:IsSetCard(0x6233) and c:IsAbleToDeck() and (not cc or c~=cc)
	else
		return c:IsSetCard(0x6233) and c:IsAbleToRemove() and Duel.IsExistingTarget(c62613313.targfilter_alt,tp,LOCATION_GRAVE,0,1,c,1,tp,cc)
	end
end
function c62613313.thfilter(c)
	return c:IsSetCard(0x6233) and c:IsAbleToHand() and c:IsFaceup()
end
--Activate
function c62613313.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c62613313.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c62613313.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c62613313.targfilter(chkc,tp) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(c62613313.targfilter,tp,LOCATION_GRAVE,0,1,nil,tp) 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(c62613313.targfilter),tp,LOCATION_GRAVE,0,3,3,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c62613313.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<=0 then return end
	local rm=tg:Filter(Card.IsAbleToRemove,nil)
	if rm:GetCount()<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rmc=rm:Select(tp,1,1,nil)
	local td=tg:Filter(Card.IsAbleToDeck,rmc:GetFirst())
	if td:GetCount()<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tdc=td:Select(tp,2,2,nil)
	if Duel.Remove(rmc,POS_FACEUP,REASON_EFFECT)~=0 then
		local g1=Duel.GetOperatedGroup()
		local ct1=g1:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
		if ct1>0 and Duel.SendtoDeck(tdc,nil,0,REASON_EFFECT)~=0 then
			local g2=Duel.GetOperatedGroup()
			if g2:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
			local ct2=g2:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
			if ct2>0 then
				Duel.BreakEffect()
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end
end
--to hand
function c62613313.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c62613313.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	local g=Duel.GetMatchingGroup(c62613313.thfilter,tp,LOCATION_REMOVED,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c62613313.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c62613313.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		if Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
			Duel.ConfirmCards(1-tp,g)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetTarget(c62613313.sumlimit)
			e1:SetLabelObject(g:GetFirst())
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			Duel.RegisterEffect(e2,tp)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_CANNOT_ACTIVATE)
			e3:SetValue(c62613313.aclimit)
			Duel.RegisterEffect(e3,tp)
		end
	end
end
function c62613313.sumlimit(e,c)
	return c==e:GetLabelObject()
end
function c62613313.aclimit(e,re,tp)
	return re:GetHandler()==e:GetLabelObject()
end