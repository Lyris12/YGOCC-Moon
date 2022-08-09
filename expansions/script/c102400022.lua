--created by Lyris
--トラップマ・スワロー
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetTarget(s.sstg)
	e1:SetOperation(s.ssop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o*10)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(function() return c:IsPreviousLocation(LOCATION_ONFIELD) end)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
function s.cfilter(c,tp)
	local a,d,l=0,0,1
	if c:IsFaceup() then a=c:GetAttack()
		if c:IsDefenseAbove(0) then d=c:GetDefense() end
		if c:IsLevelAbove(1) then l=c:GetLevel() end
	end
	return Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,0x11,a,d,l,RACE_WINDBEAST,ATTRIBUTE_WIND)
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp):GetFirst()
	if tc then
		local a,d,l=0,0,1
		if tc:IsFaceup() then a=tc:GetAttack()
			if tc:IsDefenseAbove(0) then d=tc:GetDefense() end
			if tc:IsLevelAbove(1) then l=tc:GetLevel() end
		end
		local c=e:GetHandler()
		c:AddMonsterAttribute(TYPE_NORMAL+TYPE_SPELL,0,0,l,a,d)
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
	end
end
function s.filter(c)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(0xf43) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then Duel.SSet(tp,tc) end
end
