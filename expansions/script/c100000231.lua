--[[
Myra, Speculomiric Reflector
Myra, Riflettore Speculomirico
Card Author: Xarc
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	--You can send this card from your hand or field to the GY, then target 2 face-up monsters on the field; the Type, Attribute and ATK of the first target becomes the same as the second target's.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e1:HOPT()
	e1:SetFunctions(nil,aux.ToGraveSelfCost,s.target,s.operation)
	c:RegisterEffect(e1)
	--You can banish this card from your GY and discard 1 card; Fusion Summon 1 "Speculomiric" Fusion Monster from your Extra Deck, using monsters from your hand or either field as material.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(nil,s.fuscost,s.fustg,s.fusop)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter1(c,tp)
	return c:IsFaceup() and Duel.IsExists(true,s.cfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c)
end
function s.cfilter2(c1,c2)
	if not c1:IsFaceup() then return false end
	return c1:GetRace()~=c2:GetRace() or c1:GetAttribute()~=c2:GetAttribute() or c1:GetAttack()~=c2:GetAttack()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		local exc=e:IsCostChecked() and e:GetHandler() or nil
		return Duel.IsExists(true,s.cfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,exc,tp)
	end
	local tc1=Duel.Select(HINTMSG_TARGET,true,tp,s.cfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp):GetFirst()
	tc1:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,0,1)
	local tc2=Duel.Select(HINTMSG_TARGET,true,tp,s.cfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc1,tc1):GetFirst()
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,tc1,1,0,0,{tc2:GetAttack()})
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards():Filter(Card.IsFaceup,nil)
	if #g~=2 then return end
	local c=e:GetHandler()
	local tc1=g:Filter(Card.HasFlagEffect,nil,id):GetFirst()
	local tc2=g:Filter(aux.TRUE,tc1):GetFirst()
	local attr,race,atk=tc2:GetAttribute(),tc2:GetRace(),tc2:GetAttack()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetValue(attr)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc1:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(race)
	tc1:RegisterEffect(e2)
	tc1:ChangeATK(atk,0,{c,true})
end

--E2
function s.fcfilter(c,e,tp,h)
	return c:IsDiscardable() and s.fcheck(e,tp,Group.FromCards(c,h))
end
function s.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
			and Duel.IsExistingMatchingCard(s.fcfilter,tp,LOCATION_HAND,0,1,nil,e,tp,e:GetHandler())
	end
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.DiscardHand(tp,s.fcfilter,1,1,REASON_COST|REASON_DISCARD,nil,e,tp,e:GetHandler())
end
function s.filter1(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(ARCHE_SPECULOMIRIC) and (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(m,nil,chkf)
end
function s.filter3(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.fcheck(e,tp,exc)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter3,exc,e)
	local mg2=Duel.GetMatchingGroup(s.filter1,tp,0,LOCATION_MZONE,exc,e)
	mg1:Merge(mg2)
	local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,exc,e,tp,mg1,nil,chkf)
	if not res then
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg3=fgroup(ce,e,tp):Filter(aux.TRUE,exc)
			local mf=ce:GetValue()
			res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,exc,e,tp,mg3,mf,chkf)
		end
	end
	return res
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() or s.fcheck(e,tp,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter3,nil,e)
	local mg2=Duel.GetMatchingGroup(s.filter1,tp,0,LOCATION_MZONE,nil,e)
	mg1:Merge(mg2)
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
	