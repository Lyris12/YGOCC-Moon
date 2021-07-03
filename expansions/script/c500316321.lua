--Evolute Priestess
	local cid,id=GetID()
function cid.initial_effect(c)
	 aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
  aux.AddEvoluteProc(c,nil,6,cid.filter1,1)  
		local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	--e1:SetCondition(cid.drcon)
	e1:SetCost(cid.drcost)
	e1:SetTarget(cid.drtg)
	e1:SetOperation(cid.drop)
	c:RegisterEffect(e1)
			--swap
	local e4=Effect.CreateEffect(c)
   --- e4:SetDescription(aux.Stringid(4066,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,id+1000)
	e4:SetCost(cid.negcost)
	--e4:SetTarget(cid.distg)
	e4:SetCondition(cid.drcon)
	e4:SetOperation(cid.swapop)
	c:RegisterEffect(e4)
end
function cid.filter1(c,ec,tp)
	return c:IsRace(RACE_SPELLCASTER) or c:IsAttribute(ATTRIBUTE_LIGHT)
end
function cid.cfilter(c,tp)
 return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
function cid.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,cid.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
function cid.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,6,REASON_COST) end
	e:GetHandler():RemoveEC(tp,6,REASON_COST)
end
function cid.filter2(c,ec,tp)
	return c:IsRace(RACE_FAIRY) or c:IsAttribute(ATTRIBUTE_LIGHT)
end
function cid.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
function cid.drcon(e,tp,eg,ep,ev,re,r,rp)
	return  Duel.IsExistingMatchingCard(cid.cfilter2,tp,LOCATION_ONFIELD,0,1,nil)
end
function cid.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function cid.filter(c,e,tp)
	return c:IsSetCard(0xc53) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.drop(e,tp,eg,ep,ev,re,r,rp)
if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
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
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e3:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e3,true)
		Duel.SpecialSummonComplete()
	end
end
function cid.filterneg(c,e,tp)
	return not c:IsDisabled() and c:IsType(TYPE_MONSTER)
end
function cid.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.filterneg,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(aux.filterneg,tp,0,LOCATION_MZONE,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
 function cid.swapop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
   local g=Duel.GetMatchingGroup(cid.filterneg,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
  local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetTargetRange(0,LOCATION_MZONE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e2,tp)
			 local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetTargetRange(0,LOCATION_MZONE)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetReset(RESET_PHASE+PHASE_END,2)
		e3:SetValue(-1000)
		Duel.RegisterEffect(e3,tp)
  
		tc=g:GetNext()
	
	end
end

	