--Oscurion Type-8 ‹Gilded Vanity›
--Oscurione Tipo-8 ‹Vanità Indorata›
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,22)
	--[[[-7]: Send 1 "Golden Skies Treasure" from your Deck to your GY, and if you do, Special Summon 1 other "Golden Skies" monster from your hand.]]
	c:DriveEffect(-7,0,CATEGORY_TOGRAVE|CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.sptg,
		s.spop
	)
	--[[[-7]: Discard 1 other "Oscurion" or "Golden Skies" card; destroy 1 monster on the field.]]
	local d2=c:DriveEffect(-7,1,CATEGORY_DESTROY,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		aux.DiscardCost(s.dcfilter,1,1,true),
		s.destg,
		s.desop
	)
	aux.RegisterOscurionDiscardCostEffectFlag(c,d2)
	--[[[OD]: Special Summon 1 "Oscurion" Time Leap monster from your Extra Deck.]]
	c:OverDriveEffect(2,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.tltg,
		s.tlop
	)
	--[[If this card is Drive Summoned, or Special Summoned by the effect of "Golden Skies Treasure of Welfare":
	You can Fusion Summon 1 Fusion Monster from your Extra Deck, using monsters from your hand or field as Fusion Material.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(3)
	e1:SetCategory(CATEGORIES_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(s.fuscon)
	e1:SetTarget(s.fustg)
	e1:SetOperation(s.fusop)
	c:RegisterEffect(e1)
	aux.RegisterOscurionDriveSummonEffectFlag(c,e1)
	if not s.TriggeringSetcodeCheck then
		s.TriggeringSetcodeCheck=true
		s.TriggeringSetcode={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	local rc=re:GetHandler()
	if rc:IsOriginalCode(CARD_GOLDEN_SKIES_TREASURE_OF_WELFARE) then
		s.TriggeringSetcode[cid]=true
		return
	end
	s.TriggeringSetcode[cid]=false
end

--FILTERS D1
function s.tgfilter(c,e,tp,nocheck)
	return c:IsCode(CARD_GOLDEN_SKIES_TREASURE) and c:IsAbleToGrave()
		and (nocheck or (Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,Group.FromCards(c,e:GetHandler()),e,tp)))
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_GOLDEN_SKIES) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--D1
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	aux.RememberEngagedID(e:GetHandler(),e)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g==0 then
		g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,true)
	end
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0 then
		local c=e:GetHandler()
		local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_HAND,0,1,1,aux.ExceptThisEngaged(c,e:GetLabel()),e,tp)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

--FILTERS D2
function s.dcfilter(c)
	return c:IsSetCard(ARCHE_GOLDEN_SKIES,ARCHE_OSCURION)
end
--D2
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(0,LOCATION_MZONE,LOCATION_MZONE)
	if chk==0 then
		return #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,PLAYER_ALL,LOCATION_MZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(0,LOCATION_MZONE,LOCATION_MZONE)
	if #g==0 then return end
	Duel.HintMessage(tp,HINTMSG_DESTROY)
	local sg=g:Select(tp,1,1,nil)
	if #sg>0 then
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end

--FILTERS D3
function s.tlfilter(c,e,tp)
	return c:IsMonster(TYPE_TIMELEAP) and c:IsSetCard(ARCHE_OSCURION) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--D3
function s.tltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tlfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.tlop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.tlfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:Desc(4)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_ADD_SETCODE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(ARCHE_GOLDEN_SKIES)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		sg:GetFirst():RegisterEffect(e2)
	end
end

--FILTERS E1
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.filter2(c,e,tp,m,f)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,tp)
end
--E1
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
	if aux.DriveSummonedCond(e) then return true end
	if not re then return false end
	local rc=re:GetHandler()
	if re:IsActivated() then
		local ch=Duel.GetCurrentChain()
		local cid=Duel.GetChainInfo(ch,CHAININFO_CHAIN_ID)
		return s.TriggeringSetcode[cid]==true
		
	elseif re:IsHasCustomCategory(nil,CATEGORY_FLAG_DELAYED_RESOLUTION) and re:IsHasCheatCode(CHEATCODE_SET_CHAIN_ID) then
		local cid=re:GetCheatCodeValue(CHEATCODE_SET_CHAIN_ID)
		return s.TriggeringSetcode[cid]==true
		
	else
		return rc:IsOriginalCode(CARD_GOLDEN_SKIES_TREASURE_OF_WELFARE)
	end
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,tp)
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,tp)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end