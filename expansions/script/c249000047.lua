--Dark Flare Paladin
function c249000047.initial_effect(c)
	--damage reduce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c249000047.damval)
	c:RegisterEffect(e3)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(502)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c249000047.descost)
	e2:SetTarget(c249000047.destg)
	e2:SetOperation(c249000047.desop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13722870,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c249000047.spcon)
	e3:SetTarget(c249000047.sptg)
	e3:SetOperation(c249000047.spop)
	c:RegisterEffect(e3)
end
function c249000047.damval(e,re,val,r,rp,rc)
	local c=e:GetHandler()
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 and c:GetFlagEffect(249000047)==0 then
		c:RegisterFlagEffect(249000047,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		return 0
	end
	return val
end
function c249000047.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function c249000047.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c249000047.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function c249000047.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
function c249000047.spfilter(c,e,tp)
	return c:IsCode(49217579) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function c249000047.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c249000047.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
function c249000047.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c249000047.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		if Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP) then
			--cannot remove
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetCode(EFFECT_CANNOT_REMOVE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			g:GetFirst():RegisterEffect(e1)	
			g:GetFirst():CompleteProcedure()
		end
	end
end