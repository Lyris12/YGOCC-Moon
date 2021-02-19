--Runecrafter's Fusion
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end

local id,cid=getID()

function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end



function cid.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end

function cid.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end

function cid.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xfe9) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end

function cid.cfilter(c)
	return c:GetSummonLocation()==LOCATION_EXTRA
end

function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp)
		if Duel.IsExistingMatchingCard(cid.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil) then
			local mg2=Duel.GetMatchingGroup(cid.filter0,tp,LOCATION_EXTRA,0,nil)
			mg1:Merge(mg2)
		end
		local res=Duel.IsExistingMatchingCard(cid.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(cid.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function cid.tgfilter(c,atk)
	return c:IsAbleToGrave() and c:IsSetCard(0x0ff5)
end

function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(cid.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil) then
		if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,1)) then
			local g=Duel.GetMatchingGroup(cid.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			local gc=g:GetFirst()
			e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tg=g:Select(tp,1,1,nil)
			local tgc=tg:GetFirst()

			if tgc:IsSetCard(0x1ff5) or tgc:IsSetCard(0x5ff5) or tgc:IsSetCard(0x7ff5) and tgc:GetAttack()>= 300 then
				e:GetHandler():RegisterFlagEffect(id+1,RESET_CHAIN,0,1)
			end 

			if tgc:IsSetCard(0x2ff5) or tgc:IsSetCard(0x3ff5) or tgc:IsSetCard(0x7ff5) and tgc:GetAttack()>= 400 then
				e:GetHandler():RegisterFlagEffect(id+2,RESET_CHAIN,0,1)
			end

			if tgc:IsSetCard(0x4ff5) or tgc:IsSetCard(0x6ff5) or tgc:IsSetCard(0x7ff5) and tgc:GetAttack()>= 300 then
				e:GetHandler():RegisterFlagEffect(id+3,RESET_CHAIN,0,1)
			end

			Duel.SendtoGrave(tg,REASON_EFFECT)
		end
	end
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(cid.filter1,nil,e)
	if e:GetHandler():GetFlagEffect(id) >= 1 then
		local mg2=Duel.GetMatchingGroup(cid.filter0,tp,LOCATION_EXTRA,0,nil)
		mg1:Merge(mg2)
	end
	local sg1=Duel.GetMatchingGroup(cid.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(cid.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
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
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		if e:GetHandler():GetFlagEffect(id+1) >= 1 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
			
		if e:GetHandler():GetFlagEffect(id+2) >= 1 then
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCountLimit(1)
			e2:SetValue(1)
			tc:RegisterEffect(e2)
		end

		if e:GetHandler():GetFlagEffect(id+3) >= 1 then
			tc:AddRuneslots(1)
		end
	end
end
