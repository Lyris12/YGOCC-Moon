local cid,id=GetID()
--融合解除
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
function cid.filter(c)
	if c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) then
		return c:IsFaceup() and c:IsAbleToExtra()
	elseif c:IsType(TYPE_RITUAL) then
		return c:IsFaceup() and c:IsAbleToHand()
	end
end
function cid.thfilter(c)
	return c:IsSetCard(0x617) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(cid.thfilter2,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,c:GetCode())
end
function cid.thfilter2(c,code)
	return c:IsSetCard(0x617) and c:IsType(TYPE_MONSTER) and c:GetCode()~=code and c:IsAbleToHand()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and cid.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,cid.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g1=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil):GetFirst()
		local g2=Duel.SelectMatchingCard(tp,cid.thfilter2,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,g1:GetCode()):GetFirst()
		local g=Group.FromCards(g1,g2)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(cid.splimit)
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_PHASE+PHASE_END,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END,3)
		end
		e1:SetLabel(bit.band(tc:GetType(),TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK))
		Duel.RegisterEffect(e1,tp)
	end
end
function cid.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsType(e:GetLabel()) and c:IsLocation(LOCATION_EXTRA)
end
