--Gelatyna Sfera
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x296))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2x)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.condition)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	--
	c:SSCounter(s.counterfilter)
end
function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
function s.cf(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(0x296)
end
function s.condition(e,tp)
	return not Duel.IsExists(false,s.cf,tp,LOCATION_MZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return aux.ToGraveSelfCost(e,tp,eg,ep,ev,re,r,rp,chk) and aux.SSLimit()(e,tp,eg,ep,ev,re,r,rp,chk) end
	aux.SSLimit(s.counterfilter,1,true)(e,tp,eg,ep,ev,re,r,rp,chk)
	aux.ToGraveSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
end
function s.filter(c,e,tp)
	return c:NotBanishedOrFaceup() and c:IsMonster() and c:IsSetCard(0x296) and c:IsAttackBelow(1500) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local check = (e:GetLabel()==1 and e:GetHandler():IsInMMZ() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		return check and Duel.IsExists(false,s.filter,tp,LOCATION_DECK+LOCATION_GB,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GB)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GB,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end