--Multitask Inizializzato
--Script by XGlitchy30
function c86433611.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,86433611)
	e1:SetCondition(c86433611.spcon)
	e1:SetTarget(c86433611.sptg)
	e1:SetOperation(c86433611.spop)
	c:RegisterEffect(e1)
	--force Link Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,86433611)
	e2:SetCondition(c86433611.lkcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c86433611.lktg)
	e2:SetOperation(c86433611.lkop)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(86433611,ACTIVITY_SPSUMMON,c86433611.counterfilter)
end
--filters
function c86433611.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x86f)
end
function c86433611.filter(c,e,tp)
	return c:IsSetCard(0x86f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and Duel.IsExistingMatchingCard(c86433611.filter2,tp,LOCATION_DECK,0,1,c,e,tp,c:GetCode())
end
function c86433611.filter2(c,e,tp,code)
	return c:IsSetCard(0x86f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and not c:IsCode(code)
end
function c86433611.desfilter(c,fid)
	return c:GetFlagEffectLabel(86433611)==fid
end
function c86433611.excfilter(c)
	return c:IsSetCard(0x86f) and c:IsType(TYPE_LINK) and c:IsFaceup()
end
function c86433611.counterfilter(c)
	return not c:IsSummonType(SUMMON_TYPE_LINK)
end
--Activate
function c86433611.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c86433611.confilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c86433611.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsExistingMatchingCard(c86433611.filter,tp,LOCATION_DECK,0,1,nil,e,tp) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function c86433611.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g=Duel.GetMatchingGroup(c86433611.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,1,nil)
	local g2=Duel.GetMatchingGroup(c86433611.filter2,tp,LOCATION_DECK,0,nil,e,tp,sg:GetFirst():GetCode())
	if g2:GetCount()<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg2=g2:Select(tp,1,1,nil)
	sg:Merge(sg2)
	sg:KeepAlive()
	if sg:GetCount()>=2 then
		local fid=e:GetHandler():GetFieldID()
		local tc=sg:GetFirst()
		while tc do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			tc:RegisterFlagEffect(86433611,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			local e0=Effect.CreateEffect(e:GetHandler())
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetCode(EFFECT_CANNOT_ATTACK)
			e0:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e0)
			tc=sg:GetNext()
		end
		Duel.SpecialSummonComplete()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(sg)
		e1:SetCondition(c86433611.descon)
		e1:SetOperation(c86433611.desop)
		Duel.RegisterEffect(e1,tp)
	end
end
function c86433611.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c86433611.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function c86433611.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c86433611.desfilter,nil,e:GetLabel())
	Duel.Destroy(tg,REASON_EFFECT)
end
--force Link Summon
function c86433611.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c86433611.excfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c86433611.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroup(tp,0,LOCATION_MZONE):IsExists(Card.IsFaceup,1,nil) end
	local ctype={TYPE_TOON,TYPE_SPIRIT,TYPE_UNION,TYPE_DUAL,TYPE_FLIP}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	local op=Duel.SelectOption(tp,aux.Stringid(86433597,0),aux.Stringid(86433597,1),aux.Stringid(86433597,2),aux.Stringid(86433597,3),aux.Stringid(86433597,4))
	e:SetLabel(ctype[op+1])
end
function c86433611.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetValue(e:GetLabel())
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e2,tp)
end
-- function c86433611.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- return Duel.GetCustomActivityCount(86433611,1-tp,ACTIVITY_SPSUMMON)==0
-- end
-- function c86433611.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- if not Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) then return end
	-- if not Duel.SelectYesNo(tp,aux.Stringid(86433611,2)) then return end
	-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- if g:GetCount()>0 then
		-- Duel.HintSelection(g)
		-- Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	-- end
-- end