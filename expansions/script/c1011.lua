--Ergoriesumazione Esecuzione Esefusione
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_ANONYMIZE)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--act from hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.hcon)
	c:RegisterEffect(e2)
end
function s.hcon(e,tp,eg,ep,ev,re,r,rp)
	local lab=e:GetLabel()
	e:SetLabel(1)
	local res=s.target(e,tp,eg,ep,ev,re,r,rp,0)
	e:SetLabel(lab)
	return res
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.filter1(c,e)
	return (not e or not c:IsImmuneToEffect(e))
end
function s.fcheck(tp,sg,fc)
	return sg:GetSum(Card.GetOriginalCode)==fc:GetOriginalCode()
end
function s.filter2(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	if e:GetLabel()==1 then
		aux.FCheckAdditional=s.fcheck
	end
	local res=c:CheckFusionMaterial(m,nil,chkf)
	aux.FCheckAdditional=nil
	return res
end
function s.lfilter(c,mg)
	return c:IsLinkSummonable(mg)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil)
	local res_fus=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res_fus then
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			res_fus=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end

	local mg=Duel.GetFieldGroup(tp,LOCATION_HAND+LOCATION_MZONE,0)
	local res_link=(e:GetLabel()==0 and Duel.IsExistingMatchingCard(s.lfilter,tp,LOCATION_EXTRA,0,1,nil,mg))
	
	if chk==0 then	
		return res_fus or res_link
	end
	local opt=false
	if res_fus and res_link then
		opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif res_fus then
		opt=Duel.SelectOption(tp,aux.Stringid(id,2))
	else
		opt=Duel.SelectOption(tp,aux.Stringid(id,3))+1
	end
	if not opt then return end
	Duel.SetTargetParam(opt)
	if opt==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TOGRAVE)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	if opt==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local check=false
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			if e:GetLabel()==1 then
				aux.FCheckAdditional=s.fcheck
			end
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				Duel.BreakEffect()
				if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
					check=true
					if e:GetLabel()==1 then
						local e1=Effect.CreateEffect(e:GetHandler())
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						e1:SetCode(EFFECT_EXTRA_ATTACK)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
						e1:SetValue(1)
						tc:RegisterEffect(e1)
					end
				end
			else
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
				check=true
			end
			tc:CompleteProcedure()
			if check and Duel.IsExistingMatchingCard(s.tgf,tp,LOCATION_ONFIELD+LOCATION_DECK,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local g=Duel.SelectMatchingCard(tp,s.tgf,tp,LOCATION_ONFIELD+LOCATION_DECK,LOCATION_ONFIELD,1,1,nil)
				if #g>0 then
					if g:GetFirst():IsOnField() then
						Duel.HintSelection(g)
					end
					Duel.SendtoGrave(g,REASON_EFFECT)
				end
			end
		end
		aux.FCheckAdditional=nil
		
	elseif opt==1 then
		local mg=Duel.GetFieldGroup(tp,LOCATION_HAND+LOCATION_MZONE,0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.lfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg)
		local lc=g:GetFirst()
		if lc then
			local e0=Effect.CreateEffect(e:GetHandler())
			e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e0:SetCode(EVENT_SPSUMMON_SUCCESS)
			e0:SetCondition(s.sumcon)
			e0:SetOperation(s.sumop)
			e0:SetLabel(tp)
			e0:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			lc:RegisterEffect(e0,true)
			Duel.LinkSummon(tp,lc,mg)
		end
	end
end
function s.tgf(c)
	return c:IsCode(CARD_ANONYMIZE) and c:IsAbleToGrave() and (c:IsFaceup() or not c:IsOnField())
end
function s.sumcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.sumop(e)
	local c=e:GetHandler()
	local tp=e:GetLabel()
	local val=c:GetOriginalCode()
	val=val-math.fmod(val,50)
	local lp=Duel.GetLP(tp)-val
	if lp<0 then lp=0 end
	Duel.SetLP(tp,lp)
	Duel.Readjust()
	if Duel.IsExistingMatchingCard(s.thf,tp,LOCATION_REMOVED,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thf,tp,LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
	e:Reset()
end