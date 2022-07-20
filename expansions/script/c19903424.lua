--Sinnamon Illusion
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,310109+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(cid.condition)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
--Activate
function cid.counterfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK)
end
function cid.cfilter(c)
	return not c:IsSetCard(0xa34) or c:IsFacedown()
end
function cid.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xa34) and c:IsAbleToDeck()
end
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 and not Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		if re:GetHandler():IsType(TYPE_MONSTER) then
			Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
		end
	end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		local tc=Duel.GetOperatedGroup():GetFirst()
		if tc:GetPreviousTypeOnField()&TYPE_MONSTER>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_GRAVE,0,1,1,nil)
			if #g>0 then
				Duel.SendtoDeck(g,nil,0,REASON_EFFECT)
			end
		end
	end
end