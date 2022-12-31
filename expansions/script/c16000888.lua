--Lara, Plant Tamer of Gust Vine
function c16000888.initial_effect(c)	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c16000888.operation)
	c:RegisterEffect(e1)

end
function c16000888.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,16000888)==0 then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(16000888,0))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC_G)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(0xff)
		--e1:SetCountLimit(1)
		e1:SetLabel(LOCATION_EXTRA)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCondition(c16000888.tg)
		e1:SetOperation(c16000888.fs)
		e1:SetValue(SUMMON_TYPE_FUSION)
		e1:SetReset(RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetDescription(aux.Stringid(16000888,1))
		e2:SetLabel(LOCATION_GRAVE)
		c:RegisterEffect(e2)
		Duel.RegisterFlagEffect(tp,16000888,RESET_PHASE+PHASE_END,0,1)
	end
end


function c16000888.filter1(c,e)
	return  c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function c16000888.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x885a) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function c16000888.tg(e,c)
	if c==nil then return true end
	local tp=e:GetOwner():GetControler()
	local chkf=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and PLAYER_NONE or tp
	local mg1=Duel.GetMatchingGroup(c16000888.filter1,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,e)
	local res=Duel.IsExistingMatchingCard(c16000888.filter2,tp,e:GetLabel(),0,1,nil,e,tp,mg1,nil,chkf)
	if not res then
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			res=Duel.IsExistingMatchingCard(c16000888.filter2,tp,e:GetLabel(),0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	return res
end
function c16000888.fs(e,tp,eg,ep,ev,re,r,rp,c,sg)
	Duel.Hint(HINT_CARD,0,16000888)
	local chkf=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and PLAYER_NONE or tp
	local mg1=Duel.GetMatchingGroup(c16000888.filter1,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,e)
	local sg1=Duel.GetMatchingGroup(c16000888.filter2,tp,e:GetLabel(),0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(c16000888.filter2,tp,e:GetLabel(),0,nil,e,tp,mg2,mf,chkf)
	end
	local sg3=sg1:Clone()
	if sg2 then sg3:Merge(sg2) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=sg3:Select(tp,1,1,nil)
	local tc=tg:GetFirst()
	if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
		local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
		tc:SetMaterial(mat1)
		Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:AddCard(tc)
	else
		local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
		local fop=ce:GetOperation()
		fop(ce,e,tp,tc,mat2)
	end
	tc:CompleteProcedure()
end
