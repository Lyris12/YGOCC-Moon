--created by Walrus, coded by Lyris
--Voidictator Servant - Gate Attendant
local s,id,o=GetID()
function s.initial_effect(c)
	aux.CannotBeEDMaterial(c,nil,LOCATION_MZONE)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetCountLimit(1,id+100)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re and re:GetHandler():IsSetCard(0xc97) and e:GetHandler():IsReason(REASON_EFFECT) end)
	e4:SetCost(s.cost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.filter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_DECK)) and c:IsSetCard(0x3c97) and c:IsType(TYPE_PANDEMONIUM+TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil):SelectSubGroup(tp,aux.dncheck,false,2,2)
	if #g==2 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Damage(tp,1000,REASON_COST)
end
function s.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc97) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_PZONE)>1
		and Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil):GetClassCount(Card.GetCode)>1 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_PZONE)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil):SelectSubGroup(tp,aux.dncheck,false,2,2)
	if #g==2 then for tc in aux.Next(g) do Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) end end
end
