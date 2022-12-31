--That's a Fake Trap, Right?
function c160006969.initial_effect(c)
	  --copy trap
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0x1e1,0x1e1)
	e1:SetCondition(c160006969.condition)
	e1:SetCountLimit(1,160006969+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c160006969.cost)
	e1:SetTarget(c160006969.target)
	e1:SetOperation(c160006969.operation)
	c:RegisterEffect(e1)  
end
function c160006969.cfilter(c)
	return c:IsFaceup()
		and not c:IsType(TYPE_EFFECT)
end
function c160006969.cfilter(c)
	return  c:IsType(TYPE_NORMAL) and c:IsAbleToRemoveAsCost()
end
function c160006969.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c160006969.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c160006969.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c160006969.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c160006969.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c160006969.filter(c)
	return c:GetType()==0x4 and not c:IsCode(160006969) and c:CheckActivateEffect(false,true,false)~=nil
end
function c160006969.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,1,true)
	end
	if chk==0 then return Duel.IsExistingTarget(c160006969.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(160006969,0))
	local g=Duel.SelectTarget(tp,c160006969.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	if not g then return false end
	local te,eg,ep,ev,re,r,rp=g:GetFirst():CheckActivateEffect(false,true,true)
	e:SetLabelObject(te)
	Duel.ClearTargetCard()
	local tg=te:GetTarget()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,0,0)
end
function c160006969.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
