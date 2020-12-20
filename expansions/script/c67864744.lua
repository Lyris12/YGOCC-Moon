--Doomsday Artifice Vier
--Scripted by Zerry
function c67864744.initial_effect(c)
--On Summon
local e1=Effect.CreateEffect(c)
e1:SetCategory(CATEGORY_REMOVE)
e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e1:SetCode(EVENT_SUMMON_SUCCESS)
e1:SetCountLimit(1,67864744)
e1:SetTarget(c67864744.rmtg)
e1:SetOperation(c67864744.rmop)
c:RegisterEffect(e1)
local e2=e1:Clone()
e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
c:RegisterEffect(e2)
local e3=e1:Clone()
e3:SetCode(EVENT_SPSUMMON_SUCCESS)
c:RegisterEffect(e3)
--Tag into Level 5
local e4=Effect.CreateEffect(c)
e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
e4:SetType(EFFECT_TYPE_IGNITION)
e4:SetRange(LOCATION_GRAVE)
e4:SetCountLimit(1,67864844)
e4:SetCost(c67864744.cost)
e4:SetTarget(c67864744.target)
e4:SetOperation(c67864744.operation)
c:RegisterEffect(e4)
end
function c67864744.filter1(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToRemove()
end
function c67864744.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c67864744.filter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function c67864744.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c67864744.filter1,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
function c67864744.filter(c,e,tp)
	return c:IsRace(RACE_PSYCHO) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c67864744.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c67864744.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c67864744.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c67864744.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c67864744.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c67864744.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c67864744.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end