--Cyber Flame Phoenix
function c160009955.initial_effect(c)
   aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
	aux.AddEvoluteProc(c,nil,5,c160009955.filter1,1) 
		--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(160009955,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c160009955.cost)
	e1:SetTarget(c160009955.target)
	e1:SetOperation(c160009955.operation)
	c:RegisterEffect(e1)
   --get effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetCondition(c160009955.condition)
	e2:SetValue(1)
	c:RegisterEffect(e2)
  --get effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(c160009955.condition)
	e3:SetValue(2100)
	c:RegisterEffect(e3)
  Duel.AddCustomActivityCounter(160009955,ACTIVITY_SPSUMMON,c160009955.counterfilter)
end
function c160009955.counterfilter(c)
	return c:GetSummonLocation()~=LOCATION_EXTRA
end
function c160009955.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,2,REASON_COST) and Duel.GetCustomActivityCount(160009955,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c160009955.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	 e:GetHandler():RemoveEC(tp,2,REASON_COST)
end
function c160009955.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_MACHINE)
end
function c160009955.filter(c,e,sp)
	return c:IsRace(RACE_MACHINE)  and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
function c160009955.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c160009955.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function c160009955.operation(e,tp,eg,ep,ev,re,r,rp)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c160009955.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c160009955.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_MACHINE) 
end
function c160009955.condition(e)
	return e:GetHandler():GetOriginalRace()==RACE_MACHINE
end
