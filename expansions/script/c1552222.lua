function c1552222.initial_effect(c)
	--destroy replace
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c1552222.reptg)
	e1:SetValue(c1552222.repval)
	e1:SetOperation(c1552222.repop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1552222,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c1552222.spcon)
	e2:SetTarget(c1552222.sptg)
	e2:SetOperation(c1552222.spop)
	c:RegisterEffect(e2)
	--banish hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1552222,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c1552222.destg)
	e3:SetOperation(c1552222.desop)
	c:RegisterEffect(e3)
end
function c1552222.repfilter(c,tp,e)
	return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
	 and c:IsReason(REASON_EFFECT) and c:GetFlagEffect(1552222)==0
end
function c1552222.desfilter(c,tp)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_ONFIELD) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
function c1552222.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c1552222.desfilter,tp,0,LOCATION_ONFIELD,1,nil,tp)
		and eg:IsExists(c1552222.repfilter,1,nil,tp,e) and e:GetHandler():GetFlagEffect(1552222)==0 end
	if Duel.SelectYesNo(tp,aux.Stringid(1552222,0)) then
		local g=eg:Filter(c1552222.repfilter,nil,tp,e)
		if g:GetCount()==1 then
			e:SetLabelObject(g:GetFirst())
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
			local cg=g:Select(tp,1,1,nil)
			e:SetLabelObject(cg:GetFirst())
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local tg=Duel.SelectMatchingCard(tp,c1552222.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
		Duel.HintSelection(tg)
		Duel.SetTargetCard(tg)
		tg:GetFirst():RegisterFlagEffect(1552222,RESET_EVENT+0x1fc0000+RESET_CHAIN,0,1)
		tg:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function c1552222.repval(e,c)
	return c==e:GetLabelObject()
end
function c1552222.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
	e:GetHandler():RegisterFlagEffect(1552222,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,1)
end
function c1552222.cfilter(c,tp)
	return (c:IsPreviousLocation(LOCATION_MZONE) or c:IsPreviousLocation(LOCATION_HAND)) and c:GetPreviousControler()==tp
		and c:IsReason(REASON_EFFECT) and c:IsSetCard(0x81)
end
function c1552222.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c1552222.cfilter,1,nil,tp)
end
function c1552222.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,eg:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c1552222.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(eg,POS_FACEDOWN,1,REASON_EFFECT)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	c:RegisterFlagEffect(1552223,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,0)
end
function c1552222.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 and c:GetFlagEffect(1552223)>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_HAND)
end
function c1552222.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local sg=g:RandomSelect(tp,1)
	Duel.Destroy(sg,REASON_EFFECT)
end