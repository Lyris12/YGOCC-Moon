--Ancient Seer of Temporal Visions
--Antica Veggente delle Visioni Temporali
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	--[[If this card is Synchro Summoned: You can target 1 of your banished monsters; Special Summon from your Extra Deck,
	1 Time Leap Monster with a Future equal to that target's Level +1, but banish it face-down during the End Phase.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.SynchroSummonedCond)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--[[If this leaves the field: You can target 1 of your face-down banished cards; shuffle it into the Deck]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:HOPT()
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
--FILTERS E1
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsMonster() and c:HasLevel() and Duel.IsExists(false,s.spfilter,tp,LOCATION_EXTRA,0,1,c,e,tp,c:GetLevel())
end
function s.spfilter(c,e,tp,lv)
	return c:IsMonster(TYPE_TIMELEAP) and c:GetFuture()==lv+1 and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--E1
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsBanished() and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then
		return Duel.IsExists(true,s.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
	end
	Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsFaceup() and tc:IsMonster() and tc:IsControler(tp) then
		local lv=tc:GetLevel()
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv)
		local tc=g:GetFirst()
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			local c=e:GetHandler()
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,2))
			local e1=Effect.CreateEffect(c)
			e1:Desc(3)
			e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE|PHASE_END)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.rmcon)
			e1:SetOperation(s.rmop)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc or not tc:HasFlagEffectLabel(id,e:GetLabel()) then
		e:Reset()
		return false
	end
	return true
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsAbleToRemove(tc,tp,POS_FACEDOWN) then
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end

--E2
function s.tdfilter(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsBanished() and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end