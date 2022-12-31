--Sarah The K , Pirncess of Gust Vine
function c500311003.initial_effect(c)
aux.AddOrigEvoluteType(c)
	aux.AddEvoluteProc(c,nil,7,c500311003.filter1,2)
	c:EnableReviveLimit()
		--cannot be target
	   --atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(c500311003.atkval)
	c:RegisterEffect(e1)
   --pierce
 local e4=Effect.CreateEffect(c)
   e4:SetType(EFFECT_TYPE_SINGLE)
 e4:SetCode(EFFECT_PIERCE)
   c:RegisterEffect(e4)

	--Activate
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(500311003,0))
	e7:SetCategory(CATEGORY_TODECK+CATEGORY_DAMAGE)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetRange(LOCATION_MZONE)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCode(EVENT_TOGRAVE)
	--e7:SetCountLimit(1,500311003)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetCondition(c500311003.descon)
	e7:SetCost(c500311003.eqcost)
	e7:SetTarget(c500311003.destg)
	e7:SetOperation(c500311003.desop)
	e7:SetLabelObject(e1)
	c:RegisterEffect(e7)


end
function c500311003.atkval(e)
	return Duel.GetMatchingGroupCount(Card.IsAttribute,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,ATTRIBUTE_WIND)*100
end
function c500311003.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) or c:IsRace(RACE_PLANT)
end


function c500311003.cfilter(c)
	return c:IsSetCard(0x885a) and c:IsType(TYPE_MONSTER) and c:IsReason(REASON_EFFECT)
end
function c500311003.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c500311003.cfilter,1,nil)
end
function c500311003.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	local tc=g:GetFirst()
	if tc and tc:IsAbleToRemove() then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,tc,1,0,0)
		if tc:IsFaceup() and tc:GetSummonLocation()==LOCATION_EXTRA and not tc:IsType(TYPE_FUSION)  then
			Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
		end
	end
end

function c500311003.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,4,REASON_COST) end
	e:GetHandler():RemoveEC(tp,2,REASON_COST)
end
function c500311003.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
		if tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) and tc:IsType(TYPE_MONSTER) and tc:GetSummonLocation()==LOCATION_EXTRA  and not tc:IsType(TYPE_FUSION) then
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
	end
end
