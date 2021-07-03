--Frex
function c500316921.initial_effect(c)
	aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
   aux.AddEvoluteProc(c,nil,6,c500316921.filter1,1)
	--remove
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(500316921,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,500316921)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1e0)
	e1:SetCost(c500316921.discost)
	e1:SetTarget(c500316921.target)
	e1:SetOperation(c500316921.operation)
	c:RegisterEffect(e1)
end
function c500316921.filter1(c,ec,tp)
	return c:IsRace(RACE_FIEND) or c:IsAttribute(ATTRIBUTE_EARTH)
end
function c500316921.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	 if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) end
	e:GetHandler():RemoveEC(tp,3,REASON_COST)
end
function c500316921.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	--local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,e:GetHandler())
end
function c500316921.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local lp=Duel.GetLP(tp)
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		if tc:GetSummonLocation()==LOCATION_EXTRA then
			Duel.SetLP(1-tp,lp-1000)
		end
	end
end
