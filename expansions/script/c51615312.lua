--created by LeonDuvall, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetLabel(1)
	e2:SetCondition(cid.con)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UNRELEASABLE_SUM)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetLabel(2)
	e4:SetCondition(cid.con)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1cfd))
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_IMMUNE_EFFECT)
	e6:SetValue(aux.TargetBoolFunction(aux.NOT(Effect.IsHasProperty),EFFECT_FLAG_CARD_TARGET))
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_UPDATE_ATTACK)
	e7:SetRange(LOCATION_FZONE)
	e7:SetTargetRange(LOCATION_MZONE,0)
	e7:SetLabel(3)
	e7:SetCondition(cid.con)
	e7:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xcfd))
	e7:SetValue(500)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e8)
end
function cid.mfilter(c,tp,sc)
	return c:IsCanBeTimeleapMaterial(sc) and c:GetLevel()==sc:GetFuture()-1 and Duel.GetLocationCountFromEx(tp,tp,c,TYPE_TIMELEAP)>0
end
function cid.spfilter(c,e,tp)
	if not Duel.IsExistingMatchingCard(cid.mfilter,tp,LOCATION_MZONE,0,1,nil,tp,c) or not c:IsSetCard(0xcfd)
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_TIMELEAP,tp,false,false) then return false end
	local et=global_card_effect_table[c]
	local res=false
	for _,e in ipairs(et) do
		if e:GetCode()==EFFECT_SPSUMMON_PROC then
			local ev=e:GetValue()
			local ec=e:GetCondition()
			if ev and (aux.GetValueType(ev)=="function" and ev(ef,c) or ev==SUMMON_TYPE_TIMELEAP) and (not ec or ec(e,c)) then res=true end
		end
	end
	return res
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetFlagEffect(tp,id)>0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=-1 then return end
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetCode(EFFECT_IGNORE_TIMELEAP_HOPT)
	ge1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	ge1:SetTargetRange(LOCATION_EXTRA,LOCATION_EXTRA)
	ge1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_TIMELEAP))
	Duel.RegisterEffect(ge1,0)
	local g=Duel.GetMatchingGroup(cid.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #g>0 and Duel.SelectEffectYesNo(tp,c) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		local tl=Duel.GetFlagEffect(tp,828)==0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON)
		e1:SetOperation(function() if tl then Duel.ResetFlagEffect(tp,828) end ge1:Reset() e1:Reset() end)
		Duel.RegisterEffect(e1,0)
		Duel.SpecialSummonRule(tp,sc)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	else ge1:Reset() end
end
function cid.con(e,tp)
	return Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,nil,0x1cfd):GetClassCount(Card.GetCode)>e:GetLabel()
end
