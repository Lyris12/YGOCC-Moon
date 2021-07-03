--Lovely Paintress Goghi
local cid,id=GetID()
function cid.initial_effect(c)
 aux.AddOrigEvoluteType(c)
  aux.AddEvoluteProc(c,nil,5,aux.FilterBoolFunction(Card.IsType,TYPE_NORMAL),2)
	c:EnableReviveLimit()
		--atk
	local e99=Effect.CreateEffect(c)
	e99:SetDescription(aux.Stringid(id,1))
	e99:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e99:SetType(EFFECT_TYPE_QUICK_O)
	e99:SetCode(EVENT_FREE_CHAIN)
	e99:SetRange(LOCATION_MZONE)
	e99:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e99:SetHintTiming(0,0x1e0)
	e99:SetCountLimit(1)
	e99:SetCost(cid.cost)
	e99:SetTarget(cid.target)
	e99:SetOperation(cid.operation)
	c:RegisterEffect(e99)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(cid.sscon)
	e2:SetCost(cid.cost2)
	e2:SetTarget(cid.target2)
	e2:SetOperation(cid.operation2)
	c:RegisterEffect(e2)

end

function cid.costfilter(c)
	return c:IsAbleToRemoveAsCost() and not c:IsType(TYPE_EFFECT) and (c:IsType(TYPE_PENDULUM) and c:IsFaceup())
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,2,REASON_COST)  and Duel.IsExistingMatchingCard(cid.costfilter,tp,LOCATION_EXTRA,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cid.costfilter,tp,LOCATION_EXTRA,0,1,1,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	 e:GetHandler():RemoveEC(tp,2,REASON_COST)
end
function cid.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsDisabled()
end
function cid.filtersex(c)
	return c:IsFaceup()  and not c:IsDisabled()
end
function cid.sscon(e,tp,eg,ep,ev,re,r,rp)
return aux.exccon(e) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and cid.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsDisabled()  then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e2)
	end
end

function cid.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function cid.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and cid.filtersex(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.filtersex,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cid.filtersex,tp,0,LOCATION_ONFIELD,1,1,nil)
end


function cid.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsDisabled() and tc:IsControler(1-tp) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end