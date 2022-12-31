--Dracosis Syowar
function c39415.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,c39415.mfilter,c39415.xyzcheck,2,2,c39415.alt,aux.Stringid(39415,0))
	--todeck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82633039,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,82633039)
	e2:SetCost(c39415.tdcost)
	e2:SetTarget(c39415.tdtg)
	e2:SetOperation(c39415.tdop)
	c:RegisterEffect(e2)
end
function c39415.mfilter(c,xyzc)
	return c:GetLevel()==4 and c:IsSetCard(0x300)
end
function c39415.xyzcheck(g)
	local sg=g:Filter(function(c) return c:GetLevel()==4 end,nil)
	return sg:GetClassCount(Card.GetRace)>=2 or sg:GetClassCount(Card.GetAttribute)>=2
end
function c39415.alt(c)
	return c:IsSetCard(0x300) and c:GetLevel()==6
end
function c39415.cfilter(c)
	return c:IsSetCard(0x300) and not c:IsPublic()
end
function c39415.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		and Duel.IsExistingMatchingCard(c39415.cfilter,tp,LOCATION_HAND,0,1,nil) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,c39415.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	g:KeepAlive()
	e:SetLabelObject(g)
end
function c39415.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	g:AddCard(e:GetLabelObject():GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
function c39415.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=e:GetLabelObject()
	local ct=tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
	tg:AddCard(Duel.GetFirstTarget())
	if tg:FilterCount(Card.IsRelateToEffect,nil,e)==1 and ct==1 then
		Duel.SendtoDeck(tg,nil,2,REASON_EFFECT)
	end
end
