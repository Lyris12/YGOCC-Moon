--Guardianuvola Elyriana
--Script by XGlitchy30
function c38648105.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,38648105)
	e1:SetCost(c38648105.cost)
	e1:SetTarget(c38648105.target)
	e1:SetOperation(c38648105.operation)
	c:RegisterEffect(e1)
end
--filters
function c38648105.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
function c38648105.filter(c,code)
	return c:IsType(TYPE_NORMAL) and c:GetLevel()>=3 and c:IsAbleToHand() and c:GetCode()~=code
end
--search
function c38648105.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c38648105.cfilter,1,nil) end
	local cg=Duel.SelectReleaseGroup(tp,c38648105.cfilter,1,1,nil)
	Duel.Release(cg,REASON_COST)
	local op=Duel.GetOperatedGroup():GetFirst()
	e:SetLabel(op:GetCode())
end
function c38648105.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c38648105.filter,tp,LOCATION_DECK,0,1,nil,e:GetLabel()) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c38648105.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c38648105.filter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end