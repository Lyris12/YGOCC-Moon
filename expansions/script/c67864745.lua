--Doomsday Artifice Fünf
--Scripted by Zerry
function c67864745.initial_effect(c)
--On Summon
local e4=Effect.CreateEffect(c)
e4:SetDescription(aux.Stringid(678646451,1))
e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
e4:SetCode(EVENT_BE_MATERIAL)
e4:SetCountLimit(1,67864745)
e4:SetCondition(c67864745.spcon)
e4:SetTarget(c67864745.sptg)
e4:SetOperation(c67864745.spop)
c:RegisterEffect(e4)
--special summon
local e5=Effect.CreateEffect(c)
e5:SetType(EFFECT_TYPE_FIELD)
e5:SetCode(EFFECT_SPSUMMON_PROC)
e5:SetProperty(EFFECT_FLAG_UNCOPYABLE)
e5:SetRange(LOCATION_HAND)
e5:SetCountLimit(1,67864745+100)
e5:SetCondition(c67864745.spcon1)
e5:SetOperation(c67864745.spop1)
c:RegisterEffect(e5)
end
function c67864745.spcon(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
function c67864745.spfilter(c,e,tp)
  return c:IsRace(RACE_PSYCHO) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c67864745.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c67864745.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c67864745.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c67864745.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c67864745.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c67864745.spfilter1(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToRemoveAsCost() and not c:IsCode(67864745)
end
function c67864745.spcon1(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c67864745.spfilter1,tp,LOCATION_HAND,0,1,nil)
end
function c67864745.spop1(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c67864745.spfilter1,tp,LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end