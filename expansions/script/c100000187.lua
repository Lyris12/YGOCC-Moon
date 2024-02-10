--[[
Pixieradish the Circular Druid
Pixieravanello il Druido Circolare
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can target 1 of your Insect or Plant monsters that is banished or in your GY; Special Summon it, but banish it when it leaves the field.
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
	e1:HOPT()
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--If this card you control would be used as Synchro Material for an Insect or Plant monster, you can treat it as a non-Tuner.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_NONTUNER)
	e2:SetValue(s.ntval)
	c:RegisterEffect(e2)
end
--E1
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_PLANT|RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GB) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GB,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GB,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SpecialSummonRedirect(e,tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.ntval(e,c)
	return e:GetHandler():IsControler(c:GetControler()) and c:IsRace(RACE_PLANT|RACE_INSECT)
end