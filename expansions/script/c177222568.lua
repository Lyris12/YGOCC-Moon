--Oniritron Orb Devices Cannon
local s,id=GetID()
function s.initial_effect(c)
	--Target up to 6 of your "Oniritron" cards that are banished and/or in your GY; shuffle them into the Deck, and if you do, choose 1 "Oniritron" Xyz Monster you control,
	--and attach 1 card your opponent controls to it for every 2 cards returned to the Deck or Extra Deck by this effect.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--If this card is in your GY: You can target 1 "Oniritron" Xyz Monster you control; attach this card to it as material.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.atchtg)
	e2:SetOperation(s.atchop)
	c:RegisterEffect(e2)
end
function s.filter(c,e)
	return c:IsFaceup() and not c:IsImmuneToEffect(e) and c:IsSetCard(0x721) and c:IsType(TYPE_XYZ)
end
function s.tdfilter(c)
	return c:IsSetCard(0x721) and c:IsAbleToDeck()
end
function s.atchfilter(c)
	return not c:IsType(TYPE_TOKEN) and c:IsAbleToChangeControler()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,nil) 
		and Duel.IsExistingMatchingCard(s.atchfilter,tp,0,LOCATION_ONFIELD,1,nil) 
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	g=Duel.GetMatchingGroup(s.atchfilter,tp,0,LOCATION_ONFIELD,nil)
	local mc=math.min(6,#g*3)
	local g2=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,mc,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g2,#g2,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		local td=Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if td>1 then
			g=Duel.GetMatchingGroup(s.atchfilter,tp,0,LOCATION_ONFIELD,nil)
			local mc=math.min(td//3,#g)
			local xyz=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e):GetFirst()
			local mats=Duel.SelectMatchingCard(tp,s.atchfilter,tp,0,LOCATION_ONFIELD,mc,mc,nil)
			Duel.Overlay(xyz,mats,true)
		end
	end
end
function s.atchtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.atchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(tc,c)
	end
end
