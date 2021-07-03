--Overdriven
function c160002126.initial_effect(c)
		   aux.AddOrigEvoluteType(c)
  aux.AddEvoluteProc(c,nil,11,c160002126.filter1,3)
			local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(160002126,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
   e1:SetRange(LOCATION_MZONE)
	 e1:SetProperty(EFFECT_FLAG_DELAY)
   -- e1:SetHintTiming(0,0x1c0)
	e1:SetCountLimit(1,160002126)
	 e1:SetCondition(c160002126.condition)
	e1:SetCost(c160002126.cost2)
	e1:SetTarget(c160002126.target2)
	e1:SetOperation(c160002126.operation2)
	c:RegisterEffect(e1)
--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(160002126,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,0x11e0)
	e2:SetCost(c160002126.cost)
	e2:SetTarget(c160002126.target)
	e2:SetOperation(c160002126.operation)
	c:RegisterEffect(e2)
end

function c160002126.filter1(c,ec,tp)
	return c:IsRace(RACE_MACHINE) or c:IsAttribute(ATTRIBUTE_FIRE)
end


function c160002126.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	 local c=e:GetHandler()
if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST)  and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,3,c) and c:GetFlagEffect(160002126)==0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,3,3,e:GetHandler())
	Duel.SendtoDeck(g,nil,2,REASON_COST)
	 e:GetHandler():RemoveEC(tp,3,REASON_COST)
	c:RegisterFlagEffect(160002126,RESET_CHAIN,0,1)
end
function c160002126.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField()  end
	if chk==0 then return Duel.IsExistingTarget(Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c160002126.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function c160002126.cfilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function c160002126.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c160002126.cfilter,1,nil,1-tp)
end
function c160002126.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,5,REASON_COST)  and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,5,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,5,5,e:GetHandler())
	Duel.SendtoDeck(g,nil,2,REASON_COST)
	 e:GetHandler():RemoveEC(tp,5,REASON_COST)
	
end
function c160002126.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function c160002126.operation2(e,tp,eg,ep,ev,re,r,rp)
   local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
