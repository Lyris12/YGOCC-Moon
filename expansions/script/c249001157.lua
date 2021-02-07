--Change True Power of Destiny HERO - Future Selection
function c249001157.initial_effect(c)
	return
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(c249001157.condition)
	e1:SetTarget(c249001157.target)
	e1:SetOperation(c249001157.operation)
	c:RegisterEffect(e1)
end
function c249001157.actfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(249001155)
end
function c249001157.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c249001157.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) and Duel.GetFlagEffect(tp,249001157)==0
end
function c249001157.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,4) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(4)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,4)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,1)
end
function c249001157.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(p,249001157)~=0 then return end
	Duel.RegisterFlagEffect(p,249001157,0,0,0)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==4 then
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_HAND,0,nil)
		if g:GetCount()==0 then return end
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
		local sg=g:Select(p,1,1,nil)
		Duel.SendtoDeck(sg,nil,1,REASON_EFFECT)
	end
end