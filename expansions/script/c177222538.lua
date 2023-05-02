--Oniritron Reflector of the Rainbow
local s,id=GetID()
function s.initial_effect(c)
	--summon 1 onirtrion xyz when opponent special summons from extra deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--set oniritron trap
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
function s.xyzfilter(c,att)
	return c:IsSetCard(0x721) and c:IsType(TYPE_XYZ) and c:IsRank(1) and c:IsAttribute(att)
end
	--If opponent special summons from extra deck
function s.edfilter(c,tp,eg)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA) and (eg==nil or eg:IsContains(c))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.edfilter,1,nil,1-tp) and (Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local att=0
	for gc in aux.Next(Duel.GetMatchingGroup(s.edfilter,tp,0,LOCATION_MZONE,nil,1-tp,eg)) do
		att=att|gc:GetAttribute()
	end
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,att) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
local att=0
	for gc in aux.Next(Duel.GetMatchingGroup(s.edfilter,tp,0,LOCATION_MZONE,nil,1-tp,eg)) do
		att=att|gc:GetAttribute()
	end
	local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,att):GetFirst()
	if not xyz then return end
	Duel.SpecialSummonStep(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
	Duel.SpecialSummonComplete()
	xyz:CompleteProcedure()
	Duel.Overlay(xyz,e:GetHandler())
end
function s.setfilter(c)
	return c:IsSetCard(0x1721) and c:IsType(TYPE_SPELL) and c:IsSSetable() and not c:IsForbidden()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end