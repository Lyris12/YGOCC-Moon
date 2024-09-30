--created by Slick, coded by Lyris
--The Spirit of Belgrade
local s,id,o = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,9,s.TLcon,{s.TLmat,true})
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,aux.FilterBoolFunction(aux.NOT(Card.IsSummonType),SUMMON_TYPE_DRIVE))
	aux.AddCodeList(c,212111811)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
function s.TLcon(e,c,tp)
	return Duel.IsEnvironment(212111811,tp,LOCATION_ONFIELD|LOCATION_GRAVE) and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)+Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_SPSUMMON)>0
end
function s.TLmat(c,e,mg,tl,tp)
	local alternate_material_check=false
	local isDriveMonster=c:IsMonster(TYPE_DRIVE)
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,212111811) then
		alternate_material_check = c:IsCode(id) or (isDriveMonster and c:IsLevelAbove(5))
	end
	return alternate_material_check or (isDriveMonster and aux.TimeleapMaterialFutureRequirement(c,tl))
end
function s.indval(e,c)
	return c:IsAttack(e:GetHandler():GetAttack())
end
function s.condition(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP)
end
function s.filter(c,tp)
	return c:IsCode(212111811) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.cfilter(c,tp,tc)
	return Duel.IsExistingMatchingCard(aux.NOT(Card.IsType),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,Group.FromCards(c,tc),TYPE_FIELD)
end
function s.target(e,tp,_,_,_,_,_,_,chk)
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
	local b2=Duel.IsEnvironment(212111811,tp,LOCATION_FZONE) and Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil,tp,e:GetHandler())
	if chk==0 then return b1 or b2 end
end
function s.operation(e,tp)
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,tp)
	local g2=Duel.IsEnvironment(212111811,tp,LOCATION_FZONE) and Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_MZONE,nil,tp,e:GetHandler())
	local op=aux.SelectFromOptions(tp,{#g1>0,aux.Stringid(id,0)},{g2 and #g2>0,1192})
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sg=g1:Select(tp,1,1,nil):GetFirst()
		if not tc then return end
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TARGET)
		Duel.Remove(Duel.GetMatchingGroup(aux.NOT(Card.IsType),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,g2:Select(1-tp,1,1,nil)+e:GetHandler(),TYPE_FIELD),POS_FACEUP,REASON_EFFECT)
	end
end
