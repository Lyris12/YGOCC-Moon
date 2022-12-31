--ダイガスタ・エメラル
function c39418.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,c39418.mfilter,c39418.xyzcheck,2,2,c39418.alt,aux.Stringid(39415,0))
	--ret&draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(581014,1))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c39418.cost)
	e1:SetTarget(c39418.target1)
	e1:SetOperation(c39418.operation1)
	c:RegisterEffect(e1)
end
function c39418.mfilter(c,xyzc)
	return c:GetLevel()==4 and c:IsSetCard(0x300)
end
function c39418.xyzcheck(g)
	local sg=g:Filter(function(c) return c:GetLevel()==4 end,nil)
	return sg:GetClassCount(Card.GetRace)>=2 or sg:GetClassCount(Card.GetAttribute)>=2
end
function c39418.alt(c)
	return c:IsSetCard(0x300) and c:GetLevel()==6
end
function c39418.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c39418.filter1,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c39418.filter1,tp,LOCATION_GRAVE,0,2,5,nil)
	g:KeepAlive()
	Duel.SendtoDeck(g,nil,2,REASON_COST)
	e:SetLabelObject(g)
end
function c39418.filter1(c)
	return c:IsSetCard(0x300) and c:IsAbleToDeckAsCost()
end
function c39418.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c39418.operation1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
	Duel.BreakEffect()
	local g=Duel.GetOperatedGroup()
	local tc=g:GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	local typ=tc:GetType()
	local c=e:GetHandler()
	if typ&TYPE_MONSTER~=0 then
		--atkup
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
	if typ&TYPE_SPELL~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c39418.imfilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
	if typ&TYPE_TRAP~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetCountLimit(1)
		e1:SetValue(function(e,re,r) return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
function c39418.imfilter(e,re)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end	
