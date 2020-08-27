--created & coded by Lyris
--F・HEROの出会い
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cid.reg)
	c:RegisterEffect(e1)
end
function cid.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	c:SetTurnCounter(0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE_START+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetOperation(cid.ctop)
	Duel.RegisterEffect(e1,tp) 
end
function cid.filter1(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function cid.filter2(c,m)
	return c:IsFusionSummonableCard() and c:CheckFusionMaterial(m)
end
function cid.filter3(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function cid.procfilter(c,code,e,tp)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function cid.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	if ct>=2 then
		c:SetTurnCounter(0)
		e:Reset()
		return
	end
	if Duel.GetTurnPlayer()~=tp then return end
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==1 then
		local mg=Duel.GetFusionMaterial(tp)+Duel.GetMatchingGroup(cid.filter1,tp,0,LOCATION_MZONE,nil,e)
		local sg=Duel.GetMatchingGroup(cid.filter2,tp,LOCATION_EXTRA,0,nil,mg)
		if #sg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			Duel.ConfirmCards(1-tp,tc)
			local code=tc:GetCode()
			local mat=Duel.SelectFusionMaterial(tp,tc,mg)
			mat:KeepAlive()
			Duel.SendtoGrave(mat,REASON_EFFECT)
			e:SetLabel(code)
			e:SetLabelObject(mat)
			Duel.ShuffleExtra(tp)
		end
	elseif ct==2 then
		if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
		local code=e:GetLabel()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,cid.procfilter,tp,LOCATION_EXTRA,0,1,1,nil,code,e,tp)
		local tc=g:GetFirst()
		if not tc then return end
		tc:SetStatus(STATUS_FUTURE_FUSION,true)
		tc:SetMaterial(e:GetLabelObject())
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
