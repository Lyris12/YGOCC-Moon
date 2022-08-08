--Geneseed Kunocherry
local cid,id=GetID()
function cid.initial_effect(c)
c:EnableReviveLimit()
   aux.AddOrigConjointType(c)
	aux.EnableConjointAttribute(c,1)
	   aux.AddOrigEvoluteType(c)
	 aux.AddEvoluteProc(c,nil,6,aux.OR(cid.filter1,cid.filter2),2,99)  
	 local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCondition(cid.discon)
	e3:SetCost(cid.discost)
	e3:SetTarget(cid.distg)
	e3:SetOperation(cid.disop)
	c:RegisterEffect(e3)
   --Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e4:SetCountLimit(1,id+1000)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(cid.sumcon)
	e4:SetTarget(cid.sumtg)
	e4:SetOperation(cid.sumop)
	c:RegisterEffect(e4)
end


function cid.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) 
end
function cid.filter2(c,ec,tp)
	return c:IsRace(RACE_PLANT) 
end
function cid.discost(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,4,REASON_COST) end
	e:GetHandler():RemoveEC(tp,4,REASON_COST)
end
function cid.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return  re:IsActiveType(TYPE_MONSTER)
		and Duel.IsChainNegatable(ev)
end

function cid.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function cid.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.BreakEffect()
			 Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
function cid.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function cid.filter(c,e,tp)
	return c:IsSetCard(0x57b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function cid.sumop(e,tp,eg,ep,ev,re,r,rp)
	  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end