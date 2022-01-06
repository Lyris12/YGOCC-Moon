--Tempovocazione di Zextra
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddCodeList(c,8017345)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
end
--ACTIVATE
--filters
function cid.dfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_PANDEMONIUM) and c:IsType(TYPE_MONSTER) and c:IsDestructable(e)
end
function cid.filter(c,e,tp,m)
	if (c:IsLocation(LOCATION_SZONE) and (not c:IsFaceup() or c:GetFlagEffect(726)<=0)) or (not c:IsCode(8017345) and not c:IsLevel(7)) 
	or ((c:IsLocation(LOCATION_SZONE) and bit.band(aux.GetOriginalPandemoniumType(c),TYPE_MONSTER+TYPE_RITUAL+TYPE_EFFECT+TYPE_PANDEMONIUM)~=TYPE_MONSTER+TYPE_RITUAL+TYPE_EFFECT+TYPE_PANDEMONIUM)
	or bit.band(c:GetType(),TYPE_MONSTER+TYPE_RITUAL+TYPE_EFFECT+TYPE_PANDEMONIUM)~=TYPE_MONSTER+TYPE_RITUAL+TYPE_EFFECT+TYPE_PANDEMONIUM)
	or ((c:IsLocation(LOCATION_SZONE) and (not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true) or not Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),0,aux.GetOriginalPandemoniumType(c)|TYPE_PANDEMONIUM,c:GetTextAttack(),c:GetTextDefense(),c:GetOriginalLevel(),c:GetOriginalRace(),c:GetOriginalAttribute()))) 
	or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)) then 
		return false 
	end
	local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
	local dg=Duel.GetMatchingGroup(cid.dfilter,tp,LOCATION_EXTRA,0,nil,e)
	mg:Merge(dg)
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	else
		mg:RemoveCard(c)
	end
	aux.GCheckAdditional=aux.RitualCheckAdditional(c,c:GetLevel(),"Equal")
	local res=mg:CheckSubGroup(cid.fselect,1,c:GetLevel(),c)
	aux.GCheckAdditional=nil
	return res
end
function cid.fselect(g,mc)
	return aux.RitualCheck(g,tp,mc,mc:GetLevel(),"Equal") and g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=1
end
-----------
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp)
		return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,nil,e,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_SZONE)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local m=Duel.GetRitualMaterial(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.filter),tp,LOCATION_HAND+LOCATION_SZONE,0,1,1,nil,e,tp,m)
	local tc=tg:GetFirst()
	if tc then
		local mg=m:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		local dg=Duel.GetMatchingGroup(cid.dfilter,tp,LOCATION_EXTRA,0,nil,e)
		mg:Merge(dg)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
		local mat=mg:SelectSubGroup(tp,cid.fselect,false,1,tc:GetLevel(),tc)
		aux.GCheckAdditional=nil
		if not mat or mat:GetCount()==0 then return end
		tc:SetMaterial(mat)
		local dmat=mat:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
		if dmat:GetCount()>0 then
			mat:Sub(dmat)
			Duel.Destroy(dmat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		end
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		local ignorechk=tc:IsLocation(LOCATION_SZONE) and true
		if ignorechk then
			tc:AddMonsterAttribute(aux.GetOriginalPandemoniumType(tc)|TYPE_PANDEMONIUM)
		end
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,ignorechk,true,POS_FACEUP)
		tc:CompleteProcedure()
		if tc:IsSetCard(0xf78) or tc:IsSetCard(0xf79) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(0,1)
			e1:SetCondition(cid.actlimcon)
			e1:SetValue(1)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function cid.actlimcon(e)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
--SPSUMMON
--filters
function cid.spfilter(c,e,tp)
	if (c:IsLocation(LOCATION_SZONE) and (not c:IsFaceup() or c:GetFlagEffect(726)<=0)) or not c:IsType(TYPE_RITUAL) then return false end
	if (c:IsLocation(LOCATION_SZONE) and bit.band(aux.GetOriginalPandemoniumType(c),TYPE_MONSTER+TYPE_RITUAL+TYPE_PANDEMONIUM)==0) or bit.band(c:GetType(),TYPE_MONSTER+TYPE_RITUAL+TYPE_PANDEMONIUM)==0 then return false end
	if c:IsLocation(LOCATION_SZONE) and (not c:IsCanBeSpecialSummoned(e,0,tp,true,false) or not Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),0,aux.GetOriginalPandemoniumType(c)|TYPE_PANDEMONIUM,c:GetTextAttack(),c:GetTextDefense(),c:GetOriginalLevel(),c:GetOriginalRace(),c:GetOriginalAttribute())) then return false end
	if not c:IsCanBeSpecialSummoned(e,0,tp,true,false) then return false end
	return true
end
function cid.efilter(e,re)
	return e:GetOwnerPlayer()==re:GetOwnerPlayer() and e:GetHandler()~=re:GetHandler()
end
function cid.econ(e)
	return e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
----------
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_GRAVE+LOCATION_SZONE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_SZONE)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.spfilter),tp,LOCATION_GRAVE+LOCATION_SZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		local ignorechk=tc:IsLocation(LOCATION_SZONE) and true
		if ignorechk then
			tc:AddMonsterAttribute(aux.GetOriginalPandemoniumType(tc)|TYPE_PANDEMONIUM)
		end
		if Duel.SpecialSummonStep(tc,0,tp,tp,ignorechk,false,POS_FACEUP) then
			local e0=Effect.CreateEffect(c)
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetCode(EFFECT_DISABLE)
			e0:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e0,true)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE_EFFECT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetCode(EFFECT_IMMUNE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(cid.efilter)
			e2:SetOwnerPlayer(tp)
			tc:RegisterEffect(e2,true)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_SET_BASE_ATTACK)
			e3:SetValue(4000)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3,true)
			local e4=Effect.CreateEffect(e:GetHandler())
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_NO_BATTLE_DAMAGE)
			e4:SetOwnerPlayer(tp)
			e4:SetCondition(cid.econ)
			e4:SetValue(1)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e4,true)
		end
		Duel.SpecialSummonComplete()
	end
end