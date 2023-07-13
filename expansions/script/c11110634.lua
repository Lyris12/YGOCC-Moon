--Oscurion Type-2 ‹Sound Barrier›
--Oscurione Tipo-2 ‹Barriera del Suono›
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,8)
	--[[[-2]: Place 1 Pendulum Monster from your Extra Deck in your Pendulum Zone.]]
	c:DriveEffect(-2,0,nil,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.pztg,
		s.pzop
	)
	--[[[-3]: Discard 1 other "Oscurion" or "Idolescent" card; Special Summon 1 other "Oscurion" or "Idolescent" monster from your hand or GY,
	and if you do, if you Summoned an "Oscurion" monster, you can apply its effect that activates when it is Drive Summoned.]]
	local d2=c:DriveEffect(-3,1,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		s.spcost,
		s.sptg,
		s.spop
	)
	aux.RegisterOscurionDiscardCostEffectFlag(c,d2)
	--[[[OD]: Special Summon 1 "Oscurion" Time Leap monster from your Extra Deck.]]
	c:OverDriveEffect(3,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.tltg,
		s.tlop
	)
	--[[If this card is Drive or Pendulum Summoned: You can add 1 "Oscurion" or "Idolescent" card from your Deck to your hand, except "Oscurion Type-2 ‹Sound Barrier›".]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(4)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.OR(aux.DriveSummonedCond,aux.PendulumSummonedCond))
	e1:SetTarget(aux.SearchTarget(s.scfilter))
	e1:SetOperation(aux.SearchOperation(s.scfilter))
	c:RegisterEffect(e1)
	aux.RegisterOscurionDriveSummonEffectFlag(c,e1)
	--[[While this card is in the GY, face-up "Oscurion Type-0 ‹Cradle of the Universe(s)›" in your Monster Zones are also treated as "Idolescent" monsters.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ADD_SETCODE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,CARD_OSCURION_TYPE0))
	e2:SetValue(ARCHE_IDOLESCENT)
	c:RegisterEffect(e2)
end
--FILTERS D1
function s.pzfilter(c,tp)
	return c:IsMonster(TYPE_PENDULUM) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
--D1
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) and Duel.IsExistingMatchingCard(s.pzfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pzfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	if #g>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

--FILTERS D2
function s.dcfilter(c,e,tp)
	if not (c:IsSetCard(ARCHE_IDOLESCENT,ARCHE_OSCURION) and c:IsDiscardable()) then return false end
	if c:IsAbleToGraveAsCost() then
		c:SetLocationAfterCost(LOCATION_GRAVE)
		local res=c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		c:SetLocationAfterCost(0)
		if res then
			return true
		end
	end
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,Group.FromCards(c,e:GetHandler()),e,tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_IDOLESCENT,ARCHE_OSCURION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.checkeffect(c,tp,e)
	local egroup=c:GetEffects()
	for i,teh in ipairs(egroup) do
		if aux.GetValueType(teh)=="Effect" and not teh:WasReset() then
			if teh:GetCode()==CARD_OSCURION_TYPE2 then
				local te=teh:GetLabelObject()
				if aux.GetValueType(te)=="Effect" then
					local tg=te:GetTarget()
					Duel.SetProxyEffect(e,te)
					if (not tg or tg(e,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then
						Duel.ResetProxyEffect()
						return true
					end
					Duel.ResetProxyEffect()
				end
			end
		else
			aux.MarkResettedEffect(c,i)
		end
	end
	aux.DeleteResettedEffects(c)
	return false
end
--D2
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.dcfilter,tp,LOCATION_HAND,0,1,c,e,tp)
	end
	Duel.DiscardHand(tp,s.dcfilter,1,1,REASON_COST|REASON_DISCARD,c,e,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if Duel.GetMZoneCount(tp)<=0 then return false end
		if e:IsCostChecked() then return true end
		e:SetCostCheck(false)
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,c,e,tp)
	end
	if c:IsRelateToChain() and c:IsEngaged() then
		e:SetLabel(c:GetEngagedID())
	else
		e:SetLabel(0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	e:SetCostCheck(false)
	local c=e:GetHandler()
	local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,aux.ExceptThisEngaged(c,e:GetLabel()),e,tp)
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tc=sg:GetFirst()
		if not Duel.PlayerHasFlagEffect(tp,id) and tc:IsFaceup() and tc:IsSetCard(ARCHE_OSCURION) and s.checkeffect(tc,tp,e) and c:AskPlayer(tp,2) then
			Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1,nil)
			local egroup=tc:GetEffects()
			local te=nil
			local acd={}
			local ac={}
			for _,teh in ipairs(egroup) do
				if aux.GetValueType(teh)=="Effect" and teh:GetCode()==CARD_OSCURION_TYPE2 then
					local temp=teh:GetLabelObject()
					if aux.GetValueType(temp)=="Effect" then
						local tg=temp:GetTarget()
						Duel.SetProxyEffect(e,temp)
						if (not tg or tg(e,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then
							table.insert(ac,teh)
							table.insert(acd,temp:GetDescription())
						end
						Duel.ResetProxyEffect()
					end
				end
			end
			if #ac==1 then
				te=ac[1]
			elseif #ac>1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
				op=Duel.SelectOption(tp,table.unpack(acd))
				op=op+1
				te=ac[op]
			end
			if not te then return end
			Duel.ClearTargetCard()
			tc:CreateEffectRelation(e)
			local teh=te
			te=teh:GetLabelObject()
			local tg=te:GetTarget()
			if tg then
				Duel.SetProxyEffect(e,te)
				tg(e,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1)
				Duel.ResetProxyEffect()
			end
			if tc:IsRelateToEffect(e) then
				tc:CreateEffectRelation(e)
				Duel.BreakEffect()
				local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
				if g then
					for etc in aux.Next(g) do
						etc:CreateEffectRelation(e)
					end
				end
				local op=te:GetOperation()
				if op then
					Duel.SetProxyEffect(e,te)
					op(e,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1)
					Duel.ResetProxyEffect()
				end
				tc:ReleaseEffectRelation(e)
				if g then
					for etc in aux.Next(g) do
						etc:ReleaseEffectRelation(e)
					end
				end
			end
			Duel.ResetFlagEffect(tp,id)
		end
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
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end

--FILTERS E1
function s.scfilter(c)
	return c:IsSetCard(ARCHE_OSCURION,ARCHE_IDOLESCENT)
end