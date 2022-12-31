--Psy-Smokai, Magma Gas Dragon
function c160008460.initial_effect(c)
   aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
  aux.AddEvoluteProc(c,nil,7,c160008460.filter1,2)   
	--attack up
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetDescription(aux.Stringid(160008460,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1e0)
	e1:SetCost(c160008460.cost)
	e1:SetTarget(c160008460.target)
	e1:SetOperation(c160008460.operation)
	c:RegisterEffect(e1)

  local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(160008460,3))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	 e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
   e2:SetCondition(c160008460.spcon)
	e2:SetTarget(c160008460.sptg)
	e2:SetOperation(c160008460.spop)
	c:RegisterEffect(e2)
end
function c160008460.filter1(c,ec,tp)
	return c:IsRace(RACE_WYRM) or c:IsAttribute(ATTRIBUTE_FIRE)
end

function c160008460.cost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST)  end
 e:GetHandler():RemoveEC(tp,3,REASON_COST)
end

function c160008460.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	 if chkc then return chkc:IsControler(tp) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c160008460.operation(e,tp,eg,ep,ev,re,r,rp)
	 local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function c160008460.cfilter2(c,tp,zone) 
return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousControler()==tp and c:IsSetCard(0xa69)
	  
end
function c160008460.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c160008460.cfilter2,1,nil,tp,rp)
end

function c160008460.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	  if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function c160008460.rmfilter(c)
	return c:IsAbleToRemove() and c:IsFaceup()
end
function c160008460.spop(e,tp,eg,ep,ev,re,r,rp)
	  Duel.Damage(1-tp,500,REASON_EFFECT)
	local sg=Duel.GetMatchingGroup(c160008460.rmfilter,tp,0,LOCATION_MZONE,nil)
	if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(160008460,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local tg=sg:Select(tp,1,1,nil)
		Duel.BreakEffect()
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end