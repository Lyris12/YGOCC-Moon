--Aeonstride
--Marciaeoni in Marcia
--Scripted by: XGlitchy30

local s,id=GetID()
Duel.LoadScript("glitchylib_helper.lua")
Duel.LoadScript("glitchylib_aeonstride.lua")
function s.initial_effect(c)
	aux.SpawnGlitchyHelper(GLITCHY_HELPER_TURN_COUNT_FLAG)
	aux.RaiseAeonstrideEndOfTurnEvent(c)
	--[[Special Summon 1 "Aeonstride" monster from your hand or face-up Extra Deck, then, immediately after this effect resolves,
	you can Time Leap Summon 1 Time Leap monster, using that monster you control as material, ignoring the Time Leap Limit, and if you do, move the Turn Count forwards by 1 turn.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,nil,s.target,s.operation(0))
	c:RegisterEffect(e1)
	--[[If the Turn Count moves forwards, while this card is banished or in your GY (except during the Damage Step):
	You can add this card to your hand, then move the Turn Count forwards or backwards by 1 turn.]]
	local RMChk=aux.AddThisCardBanishedAlreadyCheck(c,Effect.SetLabelObjectObject,Effect.GetLabelObjectObject)
	local GYChk=aux.AddThisCardInGraveAlreadyCheck(c)
	RMChk:SetLabelObject(GYChk)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TURN_COUNT_MOVED)
	e2:SetRange(LOCATION_GB)
	e2:SetLabelObject(GYChk)
	e2:SetFunctions(s.gycon,nil,s.gytg,s.gyop)
	c:RegisterEffect(e2)
	aux.RegisterTurnCountTriggerEffectFlag(c,e2)
end
--FE1
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsMonster() and c:IsSetCard(ARCHE_AEONSTRIDE) and Duel.GetMZoneCountFromLocation(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tlfilter(c,e,tp,mg)
	if not c:IsMonster(TYPE_TIMELEAP) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_TIMELEAP,tp,false,false) or Duel.GetLocationCountFromEx(tp,tp,mg,c)<=0 then return false end
	local et=global_card_effect_table[c]
	for _,e in ipairs(et) do
		if e:GetCode()==EFFECT_SPSUMMON_PROC then
			local ev=e:Evaluate(c)
			local ec=e:GetCondition()
			if ev and ev&SUMMON_TYPE_TIMELEAP==SUMMON_TYPE_TIMELEAP and (not ec or ec(e,c)) then
				return true
			end
		end
	end
	return false
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.operation(mode)
	if mode==0 then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local c=e:GetHandler()
					local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_HAND|LOCATION_EXTRA,0,1,1,nil,e,tp)
					if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT) then
						local ign=Duel.IgnoreTimeleapHOPT(c,tp)
						local mat=Effect.CreateEffect(c)
						mat:SetType(EFFECT_TYPE_FIELD)
						mat:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE)
						mat:SetCode(EFFECT_MUST_BE_TIMELEAP_MATERIAL)
						mat:SetRange(LOCATION_MZONE)
						mat:SetTargetRange(1,0)
						mat:SetReset(RESET_EVENT|RESETS_STANDARD)
						g:GetFirst():RegisterEffect(mat,true)
						local tg=Duel.Group(s.tlfilter,tp,LOCATION_EXTRA,0,nil,e,tp,g)
						if #tg>0 and c:AskPlayer(tp,2) then
							Duel.HintMessage(tp,HINTMSG_SPSUMMON)
							local sg=tg:Select(tp,1,1,nil)
							if #sg>0 then
								local sc=sg:GetFirst()
								local e0=Effect.CreateEffect(c)
								e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
								e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
								e0:SetCode(EVENT_SPSUMMON)
								e0:SetOperation(function(_e,_tp,_eg,_ep,_ev,_re,_r,_rp)
									ign:Reset()
									mat:Reset()
									_e:Reset()
								end
								)
								Duel.RegisterEffect(e0,tp)
								local e1=Effect.CreateEffect(c)
								e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
								e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
								e1:SetCode(EVENT_SPSUMMON_SUCCESS)
								e1:SetCondition(aux.TimeleapSummonedCond)
								e1:SetOperation(function(_e,_tp,_eg,_ep,_ev,_re,_r,_rp)
									ign:Reset()
									mat:Reset()
									s.operation(1)(e,tp,eg,ep,ev,re,r,rp,_e)
									_e:Reset()
								end
								)
								e1:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD)
								sc:RegisterEffect(e1,true)
								Duel.SpecialSummonRule(tp,sc,SUMMON_TYPE_TIMELEAP)
								if Duel.SetSummonCancelable then Duel.SetSummonCancelable(false) end
							end
						else
							ign:Reset()
							mat:Reset()
						end
					end
				end
	
	elseif mode==1 then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					if Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT) then
						Duel.MoveTurnCountCustom(1,e,tp,REASON_EFFECT)
					end
				end
	end
end

--E2
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	if not (se==nil or not re or re~=se) then return false end
	if aux.TurnCountMovedDueToTurnEnd then
		return r&REASON_RULE==0
	else
		return ev>0
	end
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if c:HasFlagEffect(id) or not c:IsAbleToHand() then return false end
		for i=-1,1,2 do
			if Duel.IsPlayerCanMoveTurnCount(i,e,tp,REASON_EFFECT) then
				return true
			end
		end
		return false
	end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SearchAndCheck(c,tp) then
		local nums={}
		for i=-1,1,2 do
			if Duel.IsPlayerCanMoveTurnCount(i,e,tp,REASON_EFFECT) then
				table.insert(nums,i)
			end
		end
		if #nums==0 then return end
		Duel.HintMessage(tp,STRING_INPUT_MOVE_TURN_COUNT)
		local ct=Duel.AnnounceNumber(tp,table.unpack(nums))
		Duel.BreakEffect()
		Duel.MoveTurnCountCustom(ct,e,tp,REASON_EFFECT)
	end
end