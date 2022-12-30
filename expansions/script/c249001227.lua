--Light Crusader Ardent Initiate
function c249001227.initial_effect(c)
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75878039,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,2490012271)
	e1:SetTarget(c249001227.target)
	e1:SetOperation(c249001227.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--draw
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(80794697,0))
	e4:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,2490012272)
	e4:SetTarget(c249001227.target2)
	e4:SetOperation(c249001227.operation2)
	c:RegisterEffect(e4)
end
function c249001227.filter(c)
	return c:IsSetCard(0x233) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(249001227)
end
function c249001227.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001227.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c249001227.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c249001227.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c249001227.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x233)
end
function c249001227.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001227.tgfilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249001227.operation2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardHand(tp,c249001227.tgfilter,1,1,REASON_EFFECT+REASON_DISCARD)~=0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end