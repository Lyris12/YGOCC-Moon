--created & coded by Lyris, art from Yu-Gi-Oh! Arc-V Episode 125
--Parasite Integration
local s,id,o=GetID()
function s.initial_effect(c)
	if not s.global_check then
		s.global_check=true
		local chkfmat=Card.CheckFusionMaterial
		Card.CheckFusionMaterial=function(fc,mg,gc,chkf)
			if not chkf then chkf=PLAYER_NONE end
			if mg then
				local pg=Duel.GetMatchingGroup(s.pfilter,tp,LOCATION_DECK,0,1,nil,fc)
				mg:Merge(pg)
			end
			return chkfmat(fc,mg,gc,chkf)
		end
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
function s.pfilter(c,fc)
	return c:GetFlagEffect(id)>0 and c:IsCanBeFusionMaterial(fc)
end
function s.filter(c,e,tp)
	local fe=c:IsHasEffect(EVENT_SPSUMMON_SUCCESS)
	if not (c:IsCode(6205579) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and fe) then return false end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
	c:RegisterEffect(e1)
	local res=getmetatable(c).sptg(fe,tp,_,_,_,_,_,_,0)
	c:ResetFlagEffect(id)
	e1:Reset()
	return res
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.fftilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
function s.eqfilter(c,tid)
	return c:IsCode(6205579) and not c:IsForbidden()
		and c:GetReason()&(REASON_FUSION+REASON_MATERIAL)==(REASON_FUSION+REASON_MATERIAL) and c:GetTurnID()==tid
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanSpecialSummonCount(tp,2) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.BreakEffect()
		getmetatable(tc).spop(tc:IsHasEffect(EVENT_SPSUMMON_SUCCESS),tp)
		local tid=Duel.GetTurnCount()
		local qg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.eqfilter),tp,0xff,0xff,nil,tid)
		local g=Duel.GetMatchingGroup(s.ffilter,tp,LOCATION_MZONE,0,nil)
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and #g>0 and #qg>0 and Duel.SelectEffectYesNo(tp,c) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local ec=qg:Select(tp,1,1,nil):GetFirst()
			local fg=g:Select(tp,1,1,nil)
			Duel.HintSelection(fg)
			local fc=fg:GetFirst()
			if not Duel.Equip(tp,ec,fc) then return end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			e1:SetLabelObject(fc)
			ec:RegisterEffect(e1)
		end
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.eqrep(c,e,eg)
	return c:IsFaceup() and c:IsCode(6205579) and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsContains(c:GetEquipTarget())
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=c:IsAbleToRemove()
	local b2=Duel.IsExistingMatchingCard(s.eqrep,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e,eg)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and (b1 or b2) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		if b2 and (not b1 or Duel.SelectYesNo(tp,1100)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
			local g=Duel.SelectMatchingCard(tp,s.eqrep,tp,LOCATION_MZONE,0,1,1,nil,e,eg)
			Duel.SetTargetCard(g)
			g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		else
			Duel.SetTargetCard(c)
		end
		return true
	else return false end
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if tc~=e:GetHandler() then
		tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
		Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
	else Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) end
end
