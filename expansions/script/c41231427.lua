--created by Jake, coded by XGlitchy30
--Dawn Blader - Bane & Sky
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DDD)
	e3:SetCode(EVENT_DISCARD)
	e3:HOPT()
	e3:SetCondition(s.dsccond)
	e3:SetTarget(s.dsctg)
	e3:SetOperation(s.dscop)
	c:RegisterEffect(e3)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(0x613) and c:IsDiscardable()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.thfilter(c)
	return c:IsSetCard(0x613) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end
function s.dsccond(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x613) and e:GetHandler():IsReason(REASON_EFFECT+REASON_COST)
end
function s.dsctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		c:RegisterEffect(e1,true)
		local e1x=e1:Clone()
		e1x:SetCode(EFFECT_CHANGE_LEVEL)
		e1x:SetValue(2)
		c:RegisterEffect(e1x,true)
		local e1y=e1:Clone()
		e1y:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1y:SetValue(ATTRIBUTE_LIGHT)
		c:RegisterEffect(e1y,true)
		local res=e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		e1:Reset()
		e1x:Reset()
		e1y:Reset()
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.dscop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c or not c:IsRelateToChain() or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local spchk=false
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(TYPE_TUNER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	c:RegisterEffect(e1,true)
	local e1x=e1:Clone()
	e1x:SetCode(EFFECT_CHANGE_LEVEL)
	e1x:SetValue(2)
	e1x:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE-RESET_TOFIELD)
	c:RegisterEffect(e1x,true)
	local e1y=e1:Clone()
	e1y:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1y:SetValue(ATTRIBUTE_LIGHT)
	e1y:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE-RESET_TOFIELD)
	c:RegisterEffect(e1y,true)
	if c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		spchk=true
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetValue(c:GetAttack()/2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE-RESET_TOFIELD)
		c:RegisterEffect(e2,true)
		local e2x=e2:Clone()
		e2x:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2x:SetValue(c:GetDefense()/2)
		c:RegisterEffect(e2x,true)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EFFECT_CANNOT_TRIGGER)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e3,true)
	end
	if not spchk then
		e1:Reset()
		e1x:Reset()
		e1y:Reset()
	end
	Duel.SpecialSummonComplete()
end
