--Pixie Hesperiidae of Fiber VINE 
function c160002525.initial_effect(c)
		   aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
  aux.AddEvoluteProc(c,nil,6,c160002525.filter1,2)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(160002525,0))
  e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
   -- e1:SetHintTiming(0,0x1e0)
	e1:SetCountLimit(1,160002526)
	e1:SetCost(c160002525.cost)
	e1:SetTarget(c160002525.target)
	e1:SetOperation(c160002525.operation)
	c:RegisterEffect(e1)
 --atkup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c160002525.val)
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(160002525,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,160002726)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(c160002525.descost)
	e3:SetTarget(c160002525.destg)
	e3:SetOperation(c160002525.desop)
	c:RegisterEffect(e3)
end


function c160002525.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) or c:IsRace(RACE_PLANT)
end
function c160002525.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x185a) and (c:IsType(TYPE_RITUAL) or c:IsType(TYPE_EVOLUTE) )
end
function c160002525.val(e,c)
	return Duel.GetMatchingGroupCount(c160002525.atkfilter,0,LOCATION_MZONE,LOCATION_MZONE,c)*300
end
function c160002525.filter(c,e,tp)
	return not  c:IsType(TYPE_EVOLUTE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function c160002525.cost(e,tp,eg,ep,ev,re,r,rp,chk)
   local c=e:GetHandler()
		 if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,4,REASON_COST) end
	e:GetHandler():RemoveEC(tp,4,REASON_COST)
end
function c160002525.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return   Duel.GetLocationCountFromEx(1-tp)>0 and
		 Duel.IsExistingMatchingCard(c160002525.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
   -- Duel.SetChainLimit(c160002525.chlimit)
end
function c160002525.chlimit(e,ep,tp)
	return tp==ep
end
function c160002525.operation(e,tp,eg,ep,ev,re,r,rp)
 if Duel.GetLocationCountFromEx(1-tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c160002525.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		  local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCountLimit(1)
		e3:SetOperation(c160002525.desxop)
		e3:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e3)
	tc:RegisterEffect(e3,true)
		Duel.SpecialSummonComplete()
	end
end
end

function c160002525.desxop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

function c160002525.descost(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function c160002525.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsDestructable() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c160002525.sipfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EVOLUTE) 
end
function c160002525.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
	if  Duel.Destroy(tc,REASON_EFFECT) ~=0 then
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,c160002525.sipfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if g:GetCount()>0 then
	  local tc=g:GetFirst()
	 tc:AddEC(3)
	end
end
	end
end
