--Doomsday Artifice Fünf
--Scripted by Zerry
function c67864745.initial_effect(c)
--On Summon
local e1=Effect.CreateEffect(c)
e1:SetCategory(CATEGORY_TO_HAND)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e1:SetCode(EVENT_SUMMON_SUCCESS)
e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
e1:SetCountLimit(1,67864745)
e1:SetTarget(c67864745.thtg)
e1:SetOperation(c67864745.thop)
c:RegisterEffect(e1)
local e2=e1:Clone()
e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
c:RegisterEffect(e2)
local e3=e1:Clone()
e3:SetCode(EVENT_SPSUMMON_SUCCESS)
c:RegisterEffect(e3)
local e4=Effect.CreateEffect(c)
e4:SetDescription(aux.Stringid(678646451,1))
e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
e4:SetCode(EVENT_TO_GRAVE)
e4:SetCountLimit(1,67864745+100)
e4:SetCondition(c67864745.spcon)
e4:SetTarget(c67864745.sptg)
e4:SetOperation(c67864745.spop)
c:RegisterEffect(e4)
--special summon
local e5=Effect.CreateEffect(c)
e5:SetType(EFFECT_TYPE_FIELD)
e5:SetCode(EFFECT_SPSUMMON_PROC)
e5:SetProperty(EFFECT_FLAG_UNCOPYABLE)
e5:SetRange(LOCATION_HAND+LOCATION_GRAVE)
e5:SetCountLimit(1,67864945)
e5:SetCondition(c67864745.spcon1)
e5:SetOperation(c67864745.spop1)
c:RegisterEffect(e5)
end
function c67864745.filter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
function c67864745.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c67864745.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c67864745.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c67864745.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c67864745.spcon(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
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