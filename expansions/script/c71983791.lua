--Miscelatore Matto
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:Ignition(0,CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON,false,LOCATION_HAND+LOCATION_MZONE,{1,0},nil,aux.LabelCost,s.tg,s.op)
end
function s.spfilter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
function s.spfilter2(c,e,tp,m,f,chkf)
	return (not f or f(c)) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.goalcheck(tp,sg,fc,sub,chkfnf)
	return sg:IsExists(s.mttg,1,nil,tp,fc,sub,true,sg,true)
end
function s.filter1(c,e,tp,chkf,rc)
	if not (not c:IsPublic() and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,true)) then return false end
	aux.FGoalCheckGlitchy = s.goalcheck
	aux.EnableOnlyGlitchyFusionProcs = true
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.mttg)
	e1:SetValue(s.mtval)
	Duel.RegisterEffect(e1,tp)
	--
	local mg=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,rc)
	local res=s.spfilter2(c,e,tp,mg,nil,chkf)
	if not res then
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			res=s.spfilter2(c,e,tp,mg,mf,chkf)
		end
	end
	aux.FGoalCheckGlitchy = nil
	aux.EnableOnlyGlitchyFusionProcs = false
	e1:Reset()
	return res
end
function s.mttg(c,tp,fc,sub,mg,sg,depth)
	if not c:IsFaceup() or c:IsControler(tp) or not c:IsLocation(LOCATION_MZONE) then return false end
	if not depth then return true end
	if not fc then return false end
	local funs=fc.material_funs
	if not funs then return false end
	for _,fun in ipairs(funs) do
		if mg and sg then
			if fun(c,fc,false,mg,sg,true) then
				if sub and not fun(c,fc,sub,mg,sg,true) then
					return true
				else
					return false
				end
			elseif not fun(c,fc,false,mg,sg,true) then
				return true
			elseif sub and not fun(c,fc,sub,mg,sg,true) then
				return true
			elseif not sub and not fun(c,fc,sub,mg,sg,true) then
				return false
			end
		end
	end
	return true
end
function s.mtval(e,c,tp)
	if not c then return false, 1 end
	return true, 1
end
function s.filter2(c,e,tp,fc)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and c:IsCode(table.unpack(fc.material))
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local chkf=PLAYER_NONE
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,chkf,c) and c:IsAbleToGraveAsCost()
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,chkf,c)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():CreateEffectRelation(e)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g:GetFirst(),1,0,0)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fc=e:GetLabelObject()
	if c and c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)>0 and c:IsLocation(LOCATION_GRAVE) and fc and fc:IsRelateToEffect(e) and fc:IsInExtra() then
		local chkf=tp
		aux.FGoalCheckGlitchy = s.goalcheck
		aux.EnableOnlyGlitchyFusionProcs = true
		local e1=Effect.CreateEffect(c)
		e1:Desc(2)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.mttg)
		e1:SetValue(s.mtval)
		e1:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e1,tp)
		--
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		local mgchk1=s.spfilter2(fc,e,tp,mg1,nil,chkf)
		local mg2=nil
		local mgchk2=false
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			mgchk2=s.spfilter2(fc,e,tp,mg2,mf,chkf)
		end
		local atk
		if mgchk1 or mgchk2 then
			if mgchk1 and (not mgchk2 or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				local mat1=Duel.SelectFusionMaterial(tp,fc,mg1,nil,chkf)
				fc:SetMaterial(mat1)
				Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				local tgchk=Duel.GetOperatedGroup():Filter(s.chkfil,nil,tp):GetFirst()
				if tgchk then
					atk=tgchk:GetTextAttack()
				end
				Duel.BreakEffect()
				Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				local mat2=Duel.SelectFusionMaterial(tp,fc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,fc,mat2)
			end
			fc:CompleteProcedure()
		end
		aux.FGoalCheckGlitchy = nil
		aux.EnableOnlyGlitchyFusionProcs = false
		e1:Reset()
		if fc:IsFaceup() and fc:IsLocation(LOCATION_MZONE) then
			Duel.Negate(fc,e,nil,nil,true)
			--
			if not atk then return end
			local fid=c:GetFieldID()
			fc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			local e1=Effect.CreateEffect(c)
			e1:Desc(1)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabel(atk)
			e1:SetLabelObject(fc)
			e1:SetValue(fid)
			e1:SetCondition(s.atkcon)
			e1:SetOperation(s.atkop)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.chkfil(c,tp)
	return c:IsPreviousControler(1-tp)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:GetFlagEffectLabel(id)==e:GetValue() then
		local val=e:GetLabel()
		local e1=Effect.CreateEffect(e:GetOwner())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	else
		e:Reset()
	end
end