--created & coded by Lyris
--スピード・ストライプ・リーレ・ドラゴン
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigRelayType(c)
	aux.AddRelayProc(c)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(cid.condition2)
	e2:SetOperation(cid.operation2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(cid.evcon)
	e3:SetTarget(cid.sumtg)
	e3:SetOperation(cid.sumop)
	c:RegisterEffect(e3)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(cid.ntcon)
	e1:SetOperation(cid.ntop)
	e1:SetValue(SUMMON_TYPE_NORMAL)
	c:RegisterEffect(e1)
	e3:SetLabelObject(e1)
end
function cid.condition2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	local a=e:GetHandler()
	local d=a:GetBattleTarget()
	return d~=nil and (d:IsLevelAbove(1) or d:IsRankAbove(1) or d:GetDimensionNo()>0 or d:GetFuture()>0)
		and (a:IsRelateToBattle() or d:IsRelateToBattle())
end
function cid.operation2(e,tp,eg,ep,ev,re,r,rp)
	local a=e:GetHandler()
	local d=a:GetBattleTarget()
	if not d:IsRelateToBattle() or d:IsImmuneToEffect(e) or not a:IsRelateToBattle() or not a:IsRelateToEffect(e) then return end
	local e3=Effect.CreateEffect(a)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	e3:SetValue(Duel.ReadCard(d,CARDDATA_LEVEL)*100)
	a:RegisterEffect(e3)
end
function cid.cfilter(c,tp)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:GetSummonPlayer()~=tp
end
function cid.evcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.cfilter,1,nil,tp)
end
function cid.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local e3=e:GetLabelObject()
	if chk==0 then return c:IsSummonable(true,e3) or c:IsMSetable(true,e3) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,0,0)
end
function cid.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local e3=e:GetLabelObject()
	local pos=0
	if c:IsSummonable(true,e3) then pos=pos+POS_FACEUP_ATTACK end
	if c:IsMSetable(true,e3) then pos=pos+POS_FACEDOWN_DEFENSE end
	if pos==0 then return end
	if Duel.SelectPosition(tp,c,pos)==POS_FACEUP_ATTACK then
		Duel.Summon(tp,c,true,e3)
	else
		Duel.MSet(tp,c,true,e3)
	end
end
function cid.filter(c)
	return c:IsType(TYPE_RELAY) or c:IsAttribute(ATTRIBUTE_FIRE)
end
function cid.ntcon(e,c,minc)
	if c==nil then return true end
	return minc<=1 and (Duel.CheckTribute(c,0) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.CheckTribute(tp,1,1,Duel.GetMatchingGroup(cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)))
end
function cid.ntop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if Duel.CheckTribute(c,1,1,mg) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local g=Duel.SelectTribute(tp,c,1,1,mg)
		c:SetMaterial(g)
		Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
		e:SetValue(SUMMON_TYPE_ADVANCE)
	elseif Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		e:SetValue(SUMMON_TYPE_NORMAL)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
		e1:SetValue(-600)
		c:RegisterEffect(e1)
	end
end
