--created by Neo, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return c:IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO and re:GetHandler():IsSetCard(0x88f) end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsPlayerCanSpecialSummonMonster(tp,CARD_NEBULA_TOKEN,0x88f,0x4011,0,0,1,RACE_PYRO,ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<=1
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,CARD_NEBULA_TOKEN,0x88f,0x4011,0,0,1,RACE_PYRO,ATTRIBUTE_LIGHT) then return end
	local c,token,e1,e3,e4,e5,e6,e8,e9,ea=e:GetHandler()
	for i=0,1 do
		token=Duel.CreateToken(tp,CARD_NEBULA_TOKEN)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(1)
		token:RegisterEffect(e1)
		e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(function(e,c) if not c then return false end return not c:IsSetCard(0x88f) end)
		token:RegisterEffect(e3)
		e4=e3:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		token:RegisterEffect(e4)
		e5=e3:Clone()
		e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		token:RegisterEffect(e5)
		e6=e3:Clone()
		e6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		token:RegisterEffect(e6)
		e8=e3:Clone()
		e8:SetCode(EFFECT_CANNOT_BE_EVOLUTE_MATERIAL)
		token:RegisterEffect(e8)
		e9=e3:Clone()
		e9:SetCode(EFFECT_CANNOT_BE_POLARITY_MATERIAL)
		token:RegisterEffect(e9)
		ea=e3:Clone()
		ea:SetCode(EFFECT_CANNOT_BE_SPACE_MATERIAL)
		token:RegisterEffect(ea)
	end
	Duel.SpecialSummonComplete()
end
function s.spfilter(c,ft,tp)
	return c:IsCode(CARD_NEBULA_TOKEN) and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-2 and Duel.CheckReleaseGroup(tp,s.spfilter,2,nil,ft,tp) end
	local g=Duel.SelectReleaseGroup(tp,s.spfilter,2,2,nil,ft,tp)
	Duel.Release(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=100 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		e:SetLabel(0)
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
