--[[
Anastasia, Empress of the Scales
Anastasia, Imperatrice della Bilancia
Card Author: Swag
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31987203)
	--[[If this card is Normal or Special Summoned: You can add 1 "Harvest Angel of Doom" or 1 Fairy monster with "Counter Trap" in its text from your Deck to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		xgl.SearchTarget(s.thfilter),
		xgl.SearchOperation(s.thfilter)
	)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[If this card is sent to the GY, or banished, to activate a Counter Trap: You can Special Summon this card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetFunctions(
		s.spcon,
		nil,
		xgl.SpecialSummonSelfTarget(),
		xgl.SpecialSummonSelfOperation()
	)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
	--[[During the Main or Battle Phase, if you negated the activation of a card or effect this turn (Quick Effect): You can, immediately after this effect resolves, Time Leap Summon 1 Fairy Time
	Leap Monster using this card you control as material.]]
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,2)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:HOPT()
	e4:SetRelevantTimings()
	e4:SetFunctions(
		s.tlcon,
		nil,
		s.tltg,
		s.tlop
	)
	c:RegisterEffect(e4)
	local mat=Effect.CreateEffect(c)
	mat:SetType(EFFECT_TYPE_FIELD)
	mat:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CANNOT_DISABLE)
	mat:SetCode(EFFECT_MUST_BE_TIMELEAP_MATERIAL)
	mat:SetRange(LOCATION_MZONE)
	mat:SetTargetRange(1,1)
	mat:SetCondition(function() return s.ActivationLegalityCheck end)
	c:RegisterEffect(mat)
	aux.GlobalCheck(s,function()
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_NEGATED)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.has_text_type = TYPE_COUNTER

if not s.CounterTrapMonsterMentionList then
	s.CounterTrapMonsterMentionList={
		[16261341]=true; [24857466]=true; [20951752]=true; [65282484]=true; [47013502]=true; [85399281]=true; [98301564]=true; [53666449]=true; [32296881]=true;
		[49905576]=true; [11522479]=true; [67468948]=true; 
	} 
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_PLAYER)
    if dp and math.abs(dp)<=1 then
		Duel.RegisterFlagEffect(dp,id,RESET_PHASE|PHASE_END,0,1)
	end
end

--E1
function s.thfilter(c)
	return c:IsCode(31987203) or (c:IsRace(RACE_FAIRY) and (aux.IsTypeInText(c,TYPE_COUNTER) or s.CounterTrapMonsterMentionList[c:GetOriginalCode()]==true))
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetActiveType()&(TYPE_TRAP|TYPE_COUNTER)==TYPE_TRAP|TYPE_COUNTER
end

--E4
function s.tlcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.IsMainPhase() or Duel.IsBattlePhase()) and Duel.PlayerHasFlagEffect(tp,id)
end
function s.tlfilter(c,e,tp,mc)
	if not c:IsMonster(TYPE_TIMELEAP) or not c:IsRace(RACE_FAIRY) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_TIMELEAP,tp,false,false) then return false end
	local mg=Duel.GetMatchingGroup(Card.IsCanBeTimeleapMaterial,tp,LOCATION_MZONE,0,nil,c)
	local mg2=Duel.GetMatchingGroup(Auxiliary.TimeleapExtraFilter,tp,0xff,0xff,nil,nil,c,tp)
	mg:Merge(mg2)
	if not mg:IsContains(mc) or Duel.GetLocationCountFromEx(tp,tp,mg,c)<=0 then return false end
	local res=false
	local eset=c:GetEffects()
	for i,ce in ipairs(eset) do
		if ce:GetCode()==EFFECT_SPSUMMON_PROC then
			local ev=ce:Evaluate(c)
			local ec=ce:GetCondition()
			if ev and ev&SUMMON_TYPE_TIMELEAP==SUMMON_TYPE_TIMELEAP and (not ec or ec(ce,c,mg)) then
				return true
			end
		end
	end
	return res
end
function s.tltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		s.ActivationLegalityCheck=true
		local res=Duel.IsExists(false,s.tlfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
		s.ActivationLegalityCheck=false
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.tlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	s.ActivationLegalityCheck=true
	local res=Duel.IsExists(false,s.tlfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
	if res then
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.tlfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		if #g>0 then
			local tc=g:GetFirst()
			local mat=Effect.CreateEffect(c)
			mat:SetType(EFFECT_TYPE_FIELD)
			mat:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CANNOT_DISABLE)
			mat:SetCode(EFFECT_MUST_BE_TIMELEAP_MATERIAL)
			mat:SetRange(LOCATION_MZONE)
			mat:SetTargetRange(1,1)
			mat:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			c:RegisterEffect(mat)
			local e0=Effect.CreateEffect(c)
			e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
			e0:SetCode(EVENT_SPSUMMON)
			e0:SetOperation(function(_e,_tp,_eg,_ep,_ev,_re,_r,_rp)
				if aux.GetValueType(_eg)=="Card" and _eg==tc or (aux.GetValueType(_eg)=="Group" and _eg:IsContains(tc)) then
					mat:Reset()
					_e:Reset()
				end
			end
			)
			Duel.RegisterEffect(e0,tp)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
			e1:SetCode(EVENT_SPSUMMON_SUCCESS)
			e1:SetCondition(aux.TimeleapSummonedCond)
			e1:SetOperation(function(_e,_tp,_eg,_ep,_ev,_re,_r,_rp)
				if not mat:WasReset() then
					mat:Reset()
				end
				_e:Reset()
			end
			)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD)
			tc:RegisterEffect(e1,true)
			Duel.SpecialSummonRule(tp,tc,SUMMON_TYPE_TIMELEAP)
			if Duel.SetSummonCancelable then Duel.SetSummonCancelable(false) end
		end
	end
	s.ActivationLegalityCheck=false
end