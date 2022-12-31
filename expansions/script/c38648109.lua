--Torrefloreale Elyriana
--Script by XGlitchy30
function c38648109.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,38648109)
	e1:SetCost(c38648109.cost)
	e1:SetTarget(c38648109.target)
	e1:SetOperation(c38648109.operation)
	c:RegisterEffect(e1)
end
--filters
function c38648109.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
function c38648109.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
--search
function c38648109.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c38648109.cfilter,1,nil) end
	local cg=Duel.SelectReleaseGroup(tp,c38648109.cfilter,1,1,nil)
	Duel.Release(cg,REASON_COST)
end
function c38648109.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c38648109.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
end
function c38648109.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,c38648109.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end