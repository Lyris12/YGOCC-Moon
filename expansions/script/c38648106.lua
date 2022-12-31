--Inseguitore dei Cieli Elyriano
--Script by XGlitchy30
function c38648106.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,38648106)
	e1:SetCost(c38648106.cost)
	e1:SetTarget(c38648106.target)
	e1:SetOperation(c38648106.operation)
	c:RegisterEffect(e1)
end
--filters
function c38648106.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
function c38648106.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0xe841) and c:IsAbleToHand()
end
--search
function c38648106.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c38648106.cfilter,1,nil) end
	local cg=Duel.SelectReleaseGroup(tp,c38648106.cfilter,1,1,nil)
	Duel.Release(cg,REASON_COST)
end
function c38648106.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c38648106.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c38648106.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c38648106.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end