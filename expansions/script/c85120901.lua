--created by LeonDuvall, coded by Lyris, fixed by XGlitchy30
--Helios - Majesty of Dawn
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_HELIOS_THE_PRIMORDIAL_SUN,CARD_SPARK_OF_THE_PRIMORDIAL_SUN,CARD_HELIOS_DUO_MEGISTUS)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(s.adval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
	aux.EnableChangeCode(c,CARD_HELIOS_THE_PRIMORDIAL_SUN,LOCATION_HAND|LOCATION_MZONE|LOCATION_REMOVED)
	local e3=Effect.CreateEffect(c)
	e3:Desc(0)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCost(s.spscost)
	e3:SetTarget(s.spstg)
	e3:SetOperation(s.spsop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:Desc(1)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_REMOVE)
	e4:HOPT()
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_RELEASE)
	c:RegisterEffect(e5)
end
function s.adval(e,c)
	return Duel.GetFieldGroupCount(0,LOCATION_REMOVED,LOCATION_REMOVED)*100
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsCode(CARD_SPARK_OF_THE_PRIMORDIAL_SUN) and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToRemoveAsCost()
end
function s.spscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.filter(c,e,tp)
	return c:IsMonster() and c:IsCode(CARD_HELIOS_DUO_MEGISTUS) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
end
