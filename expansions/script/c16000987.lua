--Dahija, Dahlia Archer of Rose VINE
function c16000987.initial_effect(c)
		 aux.AddOrigEvoluteType(c)
  aux.AddEvoluteProc(c,nil,5,c16000987.filter2,2,2,function(ec,tp,g) return g:FilterCount(c16000987.filter1,nil)==1 end)
	c:EnableReviveLimit() 
 --immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetCondition(c16000987.immcon)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	 --immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetCondition(c16000987.immcon)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
		--tohand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16000987,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c16000987.condition)
	e3:SetCost(c16000987.cost)
	e3:SetTarget(c16000987.target)
	e3:SetOperation(c16000987.operation)
	c:RegisterEffect(e3)
end
function c16000987.filter1(c,ec,tp)
	return c:IsType(TYPE_NORMAL)
end
function c16000987.filter2(c,ec,tp)
	return c:IsRace(RACE_PLANT) or c:IsAttribute(ATTRIBUTE_FIRE) 
end
function c16000987.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+388) and e:GetHandler():IsLinkState()
end
function c16000987.condition(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsLinkState()
end
function c16000987.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,2,REASON_COST) end
	 e:GetHandler():RemoveEC(tp,2,REASON_COST)
	--local e1=Effect.CreateEffect(c)
  --  e1:SetType(EFFECT_TYPE_FIELD)
   -- e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
   -- e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
  --  e1:SetReset(RESET_PHASE+PHASE_END)
  --  e1:SetLabelObject(c)
  --  e1:SetTargetRange(1,0)
  --  e1:SetTarget(c50031569.splimit)
   -- Duel.RegisterEffect(e1,tp)
end
function c16000987.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
function c16000987.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16000987.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c16000987.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c16000987.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end