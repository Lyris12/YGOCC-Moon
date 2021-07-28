--Mage From the Forbidden Timeline
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c,false)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,2,2)
	--atk/def up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_SPELLCASTER))
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(1075)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	e3:SetCountLimit(1,id)
	c:RegisterEffect(e3)
	--pendulum place
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.pencon)
	e4:SetOperation(s.penop)
	c:RegisterEffect(e4)
end
function s.matfilter(c)
	return c:IsRace(RACE_SPELLCASTER)
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),LOCATION_MZONE,0,nil)*100
end
function s.negfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsLocation(LOCATION_MZONE)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bool,tg=Duel.GetOperationInfo(ev,CATEGORY_DISABLE)
	if not bool or c:GetFlagEffect(id)>0 then return end
	if tg:IsExists(s.negfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		if Duel.NegateEffect(ev) then Duel.Destroy(c,REASON_EFFECT) end
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
function s.spcostfilter(c,e,tp)
	return c:IsAbleToRemoveAsCost() and c:IsRace(RACE_SPELLCASTER)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	Duel.SpecialSummonComplete()
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsPreviousLocation(LOCATION_ONFIELD) and tp==c:GetPreviousControler()
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then return end
	if (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
