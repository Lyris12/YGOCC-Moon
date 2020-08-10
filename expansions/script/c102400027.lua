--created & coded by Lyris
--S・VINEの零天使ラグナクライッシャ
local cid,id=GetID()
cid.spt_other_space=id+69
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigSpatialType(c,false,true)
	aux.AddSpatialProc(c,cid.mcheck,4,cid.mfilter,1,1,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),1)
	local ae3=Effect.CreateEffect(c)
	ae3:SetCategory(CATEGORY_REMOVE)
	ae3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	ae3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	ae3:SetCode(EVENT_TO_GRAVE)
	ae3:SetRange(LOCATION_MZONE)
	ae3:SetCondition(cid.condition)
	ae3:SetTarget(cid.target)
	ae3:SetOperation(cid.operation)
	c:RegisterEffect(ae3)
end
function cid.mfilter(c)
	return c:IsSetCard(0x85a,0x85b) and c:IsAttribute(ATTRIBUTE_WATER)
end
function cid.mcheck(sg)
	local sg=sg:Clone()
	local vg=sg:Filter(function(c) return c:IsSetCard(0x85a,0x85b) end,nil)
	if #vg==#sg then return true end
	sg:Sub(vg)
	return vg:GetFirst():GetAttack()>sg:GetFirst():GetAttack()
end
function cid.cfilter(c)
	return c:IsLevelAbove(1) and c:IsSetCard(0x285b)
end
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsType,nil,TYPE_MONSTER)
	if #g==0 then return false end
	local tc=g:GetFirst()
	e:SetLabel(tc:GetLevel())
	return #g==1 and cid.cfilter(tc)
end
function cid.filter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x285b) and c:IsAbleToRemove()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.Remove(Duel.SelectMatchingCard(tp,cid.filter2,tp,LOCATION_DECK,0,1,e:GetLabel(),nil),POS_FACEUP,REASON_EFFECT)
end
