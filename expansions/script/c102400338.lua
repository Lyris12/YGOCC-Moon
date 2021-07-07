--created & coded by Lyris
--リージル・リキャント
local s,id=GetID()
function s.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainNegatable(ev) then return false end
	local te=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT)
	return rp~=tp and te and te:GetHandler():IsSetCard(0xaaa) and te:IsActiveType(TYPE_MONSTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local te=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>0 and te and (te:GetHandler():IsControler(tp) or te:GetHandler():IsControlerCanBeChanged()) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if not te:GetHandler():IsControler(tp) and te:GetHandler():IsControlerCanBeChanged() then
		Duel.SetTargetCard(te:GetHandler())
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.NegateActivation(ev) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then Duel.GetControl(tc,tp,PHASE_END,1) end
end
