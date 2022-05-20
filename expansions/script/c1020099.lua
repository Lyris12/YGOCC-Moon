--created by Jake
--A Bushido Beast's Recruitment
function c1020099.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,1020099)
	e1:SetTarget(c1020099.target)
	e1:SetOperation(c1020099.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1020099,2))
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,1120099)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c1020099.tetg)
	e2:SetOperation(c1020099.teop)
	c:RegisterEffect(e2)
end
function c1020099.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x39c) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function c1020099.tefilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK) and c:IsAbleToDeck()
end
function c1020099.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_EXTRA) and c1020099.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c1020099.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c1020099.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local op=0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	if tc:IsAbleToHand() and (tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp)>0) then
		op=Duel.SelectOption(tp,aux.Stringid(1020099,0),aux.Stringid(1020099,1))
	elseif tc:IsAbleToHand() then
		op=Duel.SelectOption(tp,aux.Stringid(1020099,1))+1
	elseif tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp)>0 then
		op=Duel.SelectOption(tp,aux.Stringid(1020099,0))
	else return end
	e:SetLabel(op)
	if op==0 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
function c1020099.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local op=e:GetLabel()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		if op==0 then
			if Duel.GetLocationCountFromEx(tp)<=0 then return end
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
function c1020099.tetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c1020099.tefilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c1020099.tefilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c1020099.tefilter,tp,LOCATION_GRAVE,0,1,1,nil)
end
function c1020099.teop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if tc:IsAbleToDeck() and not tc:IsHasEffect(EFFECT_NECRO_VALLEY) then
			Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
		end
	end
end