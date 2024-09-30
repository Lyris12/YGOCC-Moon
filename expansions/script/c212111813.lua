--created by Slick, coded by Lyris
--Kronologistic Paradox
local s,id,o = GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,212111806,212111807,212111811)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SHOPT()
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SHOPT()
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.rvtg)
	e3:SetOperation(s.rvop)
	c:RegisterEffect(e3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x44a,TYPES_EFFECT_TRAP_MONSTER,2600,2600,8,RACE_MACHINE,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x44a,TYPES_EFFECT_TRAP_MONSTER,2600,2600,8,RACE_MACHINE,ATTRIBUTE_DARK)) then return end
	c:AddMonsterAttribute(TYPE_EFFECT)
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end
function s.spcon(e,tp)
	return Duel.IsEnvironment(212111811,tp)
end
function s.cfilter(c,tc,e,tp)
	return c:IsFaceupEx() and c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,tc,c)
end
function s.filter(c,e,tp,...)
	return c:IsCode(212111806,212111807) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,Group.CreateGroup(...),TYPE_SYNCHRO)>0
end
function s.spcost(e,tp,_,_,_,_,_,_,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c,c,e,tp)
		and c:IsAbleToGraveAsCost() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.Remove(Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,c,c,e,tp),POS_FACEUP,REASON_COST)
	Duel.BreakEffect()
	Duel.SendtoGrave(c,REASON_COST)
end
function s.sptg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return e:IsCostChecked()
		or Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not tc or Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)<1 then return end
	tc:CompleteProcedure()
end
function s.rfilter(c,e,tp)
	return c:IsCode(212111806,212111807,212111808) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rvtg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.rvop(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)
end
