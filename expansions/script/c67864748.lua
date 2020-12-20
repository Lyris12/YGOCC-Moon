--The Dawn of Doomsday
--Scripted by Zerry
function c67864748.initial_effect(c)
--Imagine a card with only one effect
local e1=Effect.CreateEffect(c)
e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetCode(EVENT_FREE_CHAIN)
e1:SetCountLimit(1,67864748)
e1:SetCost(c67864748.cost)
e1:SetTarget(c67864748.sptg)
e1:SetOperation(c67864748.spop)
c:RegisterEffect(e1)
end
function c67864748.spfilter1(c,e,tp)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToRemoveAsCost()
end
function c67864748.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c67864748.spfilter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c67864748.spfilter1,tp,LOCATION_DECK,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c67864748.filter1(c,e,tp)
	return c:IsRace(RACE_PSYCHO) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c67864748.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c67864748.filter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function c67864748.spop(e,tp,eg,ep,ev,re,r,rp)
if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
local tc=Duel.SelectMatchingCard(tp,c67864748.filter1,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e1:SetValue(ATTRIBUTE_DARK)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)
end
Duel.SpecialSummonComplete()
local e2=Effect.CreateEffect(e:GetHandler())
e2:SetType(EFFECT_TYPE_FIELD)
e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
e2:SetTargetRange(1,0)
e2:SetTarget(c67864748.splimit)
e2:SetReset(RESET_PHASE+PHASE_END)
Duel.RegisterEffect(e2,tp)
end
function c67864748.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
