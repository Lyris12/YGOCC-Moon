local cid,id=GetID()
--Epochborn Field of Dreams
function cid.initial_effect(c)
	--When this card is activated, you can: Immediately after this effect resolves, Time Leap Summon an "Epochborn" monster, ignoring the Time Leap Limit. You can only use this effect of "Epochborn Field of Dreams" once per turn.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
	--If you control 2+ "Epochborn Paragon" monsters with different names, This card cannot be targeted or destroyed by card effects.
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
	--If you control 3+ "Epochborn Paragon" monsters with different names, "Epochborn Paragon" monsters you control are unaffetced by card effects that do not target, also they cannot be Tributed.
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
	e6:SetValue(aux.TargetBoolFunction(Effect.IsHasProperty,EFFECT_FLAG_CARD_TARGET))
	c:RegisterEffect(e6)
	--If you control 4+ "Epochborn Paragon" monsters with different names, "Epochborn" monsters you control gain 500 ATK and DEF.
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
	return c:IsCanBeTimeleapMaterial(sc) and c:GetLevel()==sc:GetFuture()-1 and Duel.GetMZoneCount(tp,c)>0
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
			if ev and (aux.GetValueType(ev)=="function" and ev(ef,c) or ev&825==825) and (not ec or ec(e,c)) then res=true end
		end
	end
	return res
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetFlagEffect(tp,id)>0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=-1
		or not Duel.SelectEffectYesNo(tp,c) then return end
	local ef=Effect.CreateEffect(c)
	ef:SetType(EFFECT_TYPE_FIELD)
	ef:SetCode(EFFECT_EXTRA_TIMELEAP_SUMMON)
	ef:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ef:SetDescription(aux.Stringid(id,0))
	ef:SetTargetRange(1,0)
	ef:SetTarget(aux.TRUE)
	Duel.RegisterEffect(ef,tp)
	local g=Duel.GetMatchingGroup(cid.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		Duel.SpecialSummonRule(tp,sc)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
function cid.con(e,tp)
	return Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,nil,0x1cfd):GetClassCount(Card.GetCode)>e:GetLabel()
end
