--[[
Superdimensional Gardna
Gardna Superdimensionale
Card Author: Xarc
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If a card(s) you control leaves the field because of an opponent's card: You can Special Summon this card from your hand or banishment.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetRange(LOCATION_HAND|LOCATION_REMOVED)
	e1:HOPT()
	e1:SetLabelObject(aux.AddThisCardBanishedAlreadyCheck(c))
	e1:SetFunctions(
		s.spcon,
		nil,
		xgl.SpecialSummonSelfTarget(),
		xgl.SpecialSummonSelfOperation()
	)
	c:RegisterEffect(e1)
	--[[If this card is Normal or Special Summoned: You can target 1 card on the field; during the End Phase of this turn, apply the following effect.
	● Banish it, then you can Time Leap Summon 1 Time Leap Monster.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_REMOVE|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		nil,
		s.rmtg,
		s.rmop
	)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
end
--E1
function s.cfilter(c,tp)
	return c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (not eg:IsContains(c) or c:IsLocation(LOCATION_HAND)) and eg:IsExists(aux.AlreadyInRangeFilter(e,s.cfilter),1,nil,tp)
end

--E2
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then
		return Duel.IsExists(true,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	local g=Duel.Select(HINTMSG_REMOVE,true,tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local fid=e:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,2))
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(id,3)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE|PHASE_END)
		e1:OPT()
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetFunctions(s.epcon,nil,nil,s.epop)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.epcon(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local tc=e:GetLabelObject()
	if not tc or not tc:HasFlagEffectLabel(id,fid) then
		e:Reset()
		return false
	end
	return true
end
function s.epop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local tc=e:GetLabelObject()
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) and Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then
		local sc=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		Duel.BreakEffect()
		Duel.SpecialSummonRule(tp,sc,SUMMON_TYPE_TIMELEAP)
		if Duel.SetSummonCancelable then Duel.SetSummonCancelable(false) end
	end
end
function s.spfilter(c,e,tp)
	if not c:IsType(TYPE_TIMELEAP) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_TIMELEAP,tp,false,false) then return false end
	local res=false
	local eset=c:GetEffects()
	for i,ce in ipairs(eset) do
		if ce:GetCode()==EFFECT_SPSUMMON_PROC then
			local ev=ce:Evaluate(c)
			local ec=ce:GetCondition()
			if ev and ev&SUMMON_TYPE_TIMELEAP==SUMMON_TYPE_TIMELEAP and (not ec or ec(ce,c,nil)) then
				return true
			end
		end
	end
	return res
end