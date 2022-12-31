--VIATRIX: Riavvio
--Script by XGlitchy30
function c1020200.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,1020200)
	e1:SetTarget(c1020200.target)
	e1:SetOperation(c1020200.activate)
	c:RegisterEffect(e1)
	--recycle
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1020200,2))
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,1020200)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c1020200.tetg)
	e2:SetOperation(c1020200.teop)
	c:RegisterEffect(e2)
end
--filters
function c1020200.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x39c) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function c1020200.tefilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK) and c:IsAbleToExtra()
end
--Activate
function c1020200.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_EXTRA) and chkc:IsControler(tp) and c1020200.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c1020200.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c1020200.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	--
	local tc=g:GetFirst()
	if not tc then return end
	local op=0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	if tc:IsAbleToHand() and (tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp)>0) then
		op=Duel.SelectOption(tp,aux.Stringid(1020200,0),aux.Stringid(1020200,1))
	elseif tc:IsAbleToHand() then
		op=Duel.SelectOption(tp,aux.Stringid(1020200,1))+1
	elseif tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp)>0 then
		op=Duel.SelectOption(tp,aux.Stringid(1020200,0))
	else return end
	--
	e:SetLabel(op)
	if op==0 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
function c1020200.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local op=e:GetLabel()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		if op==0 then
			if Duel.GetLocationCountFromEx(tp)<=0 then return end
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
--recycle
function c1020200.tetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c1020200.tefilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c1020200.tefilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.NecroValleyFilter(c1020200.tefilter),tp,LOCATION_GRAVE,0,1,1,nil)
end
function c1020200.teop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if tc:IsAbleToExtra() and not tc:IsHasEffect(EFFECT_NECRO_VALLEY) then
			Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
		end
	end
end