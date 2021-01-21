--Moonvale Strategist
function c10505085.initial_effect(c)
	--ritual level
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_RITUAL_LEVEL)
	e1:SetValue(c10505085.rlevel)
	c:RegisterEffect(e1)
	--tohand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,10505085)
	e2:SetCondition(c10505085.setcon)
	e2:SetTarget(c10505085.settg)
	e2:SetOperation(c10505085.setop)
	c:RegisterEffect(e2)
end
function c10505085.rlevel(e,c)
	local lv=e:GetHandler():GetLevel()
	if c:IsSetCard(0x1a4) then
		local clv=c:GetLevel()
		return lv*65536+clv
	else return lv end
end
function c10505085.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_RITUAL)
end
function c10505085.filter(c)
	return c:IsSetCard(0x1a5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function c10505085.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(c10505085.filter,tp,LOCATION_DECK,0,1,nil) end
end
function c10505085.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c10505085.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then Duel.SSet(tp,g:GetFirst()) end
end
