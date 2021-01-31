--Psycho Gunner
--Scripted by Zerry
function c19251412.initial_effect(c)
--Special Summon
local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,19251412)
	e1:SetCondition(c19251412.spcon)
	e1:SetTarget(c19251412.sptg)
	e1:SetOperation(c19251412.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44335251,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,19251512)
	e2:SetCost(c19251412.cost)
	e2:SetTarget(c19251412.target)
	e2:SetOperation(c19251412.operation)
	c:RegisterEffect(e2)
end
function c19251412.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
function c19251412.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g>0 and #g==Duel.GetMatchingGroupCount(c19251412.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c19251412.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19251412.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c19251412.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c19251412.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end

function c19251412.desfilter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToRemoveAsCost()
end
function c19251412.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19251412.desfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c19251412.desfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c19251412.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_PSYCHO) and (c:IsAbleToRemove() or c:IsAbleToGrave())
end
function c19251412.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19251412.cfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c19251412.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,c19251412.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if tc and tc:IsAbleToRemove() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1192,1191)==0) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		else
		Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end