--Steinitz's Check Call
--Script by XGlitchy30
function c25386876.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c25386876.cost)
	e1:SetTarget(c25386876.target)
	e1:SetOperation(c25386876.activate)
	c:RegisterEffect(e1)
end
--filters
function c25386876.costfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x63d0)
		and Duel.IsExistingMatchingCard(c25386876.clfilter,tp,0,LOCATION_MZONE,1,nil,c,tp)
end
function c25386876.clfilter(c,tg,tp)
	local g=tg:GetColumnGroup()
	return g:IsContains(c) and c:GetControler()~=tp 
end
--Activate
function c25386876.cost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c25386876.costfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(c25386876.costfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and Duel.CheckLPCost(tp,1000)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c25386876.costfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.PayLPCost(tp,1000)
end
function c25386876.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=Duel.GetFirstTarget()
	local g=tc:GetColumnGroup()
	local t1=g:Filter(Card.IsType,nil,TYPE_MONSTER)
	local t2=t1:Filter(Card.IsControler,nil,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,t2,t2:GetCount(),0,0)
end
function c25386876.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local g=tc:GetColumnGroup()
		local t1=g:Filter(Card.IsType,nil,TYPE_MONSTER)
		local t2=t1:Filter(Card.IsControler,nil,1-tp)
		if t2:GetCount()>0 then
			Duel.Destroy(t2,REASON_EFFECT)
		end
	end
end