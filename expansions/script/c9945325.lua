--Towards the Gates
function c9945325.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,9945325+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c9945325.target)
	e1:SetOperation(c9945325.activate)
	c:RegisterEffect(e1)
end
function c9945325.filter(c,e,tp)
	return c:IsSetCard(0x204F) and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false)
end
function c9945325.spfilter(c,e,tp)
	return c:IsSetCard(0x204F) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c9945325.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=(Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c9945325.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp))
	local b2=(Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c9945325.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp))
		if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(9945325,0),aux.Stringid(9945325,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(9945325,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(9945325,1))+1
	end
	e:SetLabel(op)
	if op==0 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	else
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
end
function c9945325.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local op=e:GetLabel()
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local pg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c9945325.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		local ptc=pg:GetFirst()
		if ptc then
			ptc:SetMaterial(nil)
			Duel.SpecialSummon(ptc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+0x47e0000)
			e1:SetValue(LOCATION_REMOVED)
			ptc:RegisterEffect(e1,true)
			ptc:CompleteProcedure()
		end
	else
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.GetMatchingGroup(c9945325.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if g:GetCount()~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,ft,nil)
		local tc=sg:GetFirst()
		while tc do
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			tc:RegisterFlagEffect(9945325,RESET_EVENT,0,1,fid)
			tc:RegisterFlagEffect(0,RESET_EVENT,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(9945325,2))
			end
			tc=sg:GetNext()
		end
		Duel.SpecialSummonComplete()
		sg:KeepAlive()
		local tg=sg:Select(tp,1,1,nil)
		local ttg=tg:GetFirst()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		ttg:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		ttg:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(sg)
		e3:SetCondition(c9945325.descon)
		e3:SetOperation(c9945325.desop)
		Duel.RegisterEffect(e3,tp)
	end
end
end
function c9945325.sdfilter(c,fid)
	return c:GetFlagEffectLabel(9945325)==fid
end
function c9945325.descon(e,tp,eg,ep,ev,re,r,rp)
	local sg=e:GetLabelObject()
	if not sg:IsExists(c9945325.sdfilter,1,nil,e:GetLabel()) then
		sg:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function c9945325.desop(e,tp,eg,ep,ev,re,r,rp)
	local sg=e:GetLabelObject()
	local tg=sg:Filter(c9945325.sdfilter,nil,e:GetLabel())
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
