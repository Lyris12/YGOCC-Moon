--Allure Rose Maiden
function c16000228.initial_effect(c)
		aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
  aux.AddEvoluteProc(c,nil,3,c16000228.filter2,1,1)
	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16000228,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,16000228)
	e1:SetCost(c16000228.drcost)
	e1:SetTarget(c16000228.thtg)
	e1:SetOperation(c16000228.thop)
	c:RegisterEffect(e1)
	--immune
	--local e2=Effect.CreateEffect(c)
   -- e2:SetType(EFFECT_TYPE_FIELD)
	--e2:SetCode(EFFECT_IMMUNE_EFFECT)
   -- e2:SetRange(LOCATION_MZONE)
   -- e2:SetTargetRange(LOCATION_MZONE,0)
   -- e2:SetTarget(c16000228.etarget)
   -- e2:SetValue(c16000228.efilter)
   -- c:RegisterEffect(e2)  
end



function c16000228.filter2(c,ec,tp)
	return c:IsRace(RACE_PLANT) or c:IsAttribute(ATTRIBUTE_WATER)
end

function c16000228.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c16000228.discfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and c:IsAbleToGraveAsCost() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function c16000228.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	   if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) and Duel.IsExistingMatchingCard(c16000228.discfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,c) end
	e:GetHandler():RemoveEC(tp,3,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c16000228.discfilter,tp,LOCATION_ONFIELD,0,1,1,c)
	Duel.SendtoGrave(g,REASON_COST)
end
function c16000228.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

function c16000228.etarget(e,c)
	return c:IsRace(RACE_PLANT) and c:IsPosition (POS_FACEUP_DEFENSE)
end
function c16000228.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetOwnerPlayer()
end
