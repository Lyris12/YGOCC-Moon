--[[
Orbi the Circular Fairy
Orbi la Fata Circolare
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--If all monsters you control are Plant and/or Insect monsters (min. 1), you can Special Summon this card (from your hand).
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT(true)
	e1:SetCondition(s.sprcon)
	c:RegisterEffect(e1)
	--You can Tribute 1 other Level 5 or lower Plant or Insect monster; Special Summon 1 Plant or Insect Tuner from your Deck whose Level is 1 lower than the Tributed monster had on the field.
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCost(aux.DummyCost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_PLANT|RACE_INSECT)
end
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

--E2
function s.cfilter(c,e,tp)
	return c:IsLevelBelow(5) and c:IsRace(RACE_PLANT|RACE_INSECT) and (c:IsControler(tp) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,c,c:GetLevel(),e,tp)
end
function s.spfilter(c,lv,e,tp)
	return c:IsMonster(TYPE_TUNER) and c:IsRace(RACE_PLANT|RACE_INSECT) and c:IsLevel(lv-1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return e:IsCostChecked() and Duel.CheckReleaseGroup(tp,s.cfilter,1,c,e,tp)
	end
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,c,e,tp)
	e:SetLabel(g:GetFirst():GetLevel())
	Duel.Release(g,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,lv,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end