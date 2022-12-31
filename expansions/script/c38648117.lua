--Antico Codice di Elyria
--Script by XGlitchy30
function c38648117.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38648117+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c38648117.target)
	e1:SetOperation(c38648117.activate)
	c:RegisterEffect(e1)
end
--filters
function c38648117.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xe841) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function c38648117.lpfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe841)
end
--Activate
function c38648117.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c38648117.filter,tp,LOCATION_EXTRA,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function c38648117.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c38648117.filter,tp,LOCATION_EXTRA,0,2,2,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c38648117.lpop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	Duel.RegisterEffect(e3,tp)
end
function c38648117.lpop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c38648117.lpfilter,nil)
	if g:GetCount()>0 then
		Duel.Recover(tp,g:GetCount()*500,REASON_EFFECT)
	end
end