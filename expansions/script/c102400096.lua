--created & coded by Lyris
--S・VINEの零天使ラグナクライッシャ(アナザー宙)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigSpatialType(c)
	aux.AddSpatialProc(c,s.mcheck,4,s.mfilter,1,1,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),1)
	local ae3=Effect.CreateEffect(c)
	ae3:SetCategory(CATEGORY_REMOVE)
	ae3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	ae3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	ae3:SetCode(EVENT_TO_GRAVE)
	ae3:SetRange(LOCATION_MZONE)
	ae3:SetCondition(s.condition)
	ae3:SetTarget(s.target)
	ae3:SetOperation(s.operation)
	c:RegisterEffect(ae3)
end
function s.mfilter(c)
	return c:IsSetCard(0x85a,0x85b) and c:IsAttribute(ATTRIBUTE_WATER)
end
function s.mcheck(sg)
	local sg=sg:Clone()
	local vg=sg:Filter(function(c) return c:IsSetCard(0x85a,0x85b) end,nil)
	if #vg==#sg then return true end
	sg:Sub(vg)
	return vg:GetFirst():GetAttack()>sg:GetFirst():GetAttack()
end
function s.cfilter(c)
	return c:IsLevelAbove(1) and c:IsSetCard(0x285b)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsType,nil,TYPE_MONSTER)
	if #g==0 then return false end
	local tc=g:GetFirst()
	e:SetLabel(tc:GetLevel())
	return #g==1 and s.cfilter(tc)
end
function s.filter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x285b)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_REMOVED)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_REMOVED,0,1,e:GetLabel(),nil),REASON_EFFECT+REASON_RETURN)
end
