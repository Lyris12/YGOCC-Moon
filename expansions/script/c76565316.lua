--Ritmi Mistici - Bassista
--Script by XGlitchy30
function c76565316.initial_effect(c)
	c:EnableCounterPermit(0x1555)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,76565316)
	e1:SetCost(c76565316.sccost)
	e1:SetTarget(c76565316.sctg)
	e1:SetOperation(c76565316.scop)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,76165316)
	e2:SetCondition(c76565316.thcon)
	e2:SetTarget(c76565316.thtg)
	e2:SetOperation(c76565316.thop)
	c:RegisterEffect(e2)
end
--filters
function c76565316.costfilter(c)
	return c:IsSetCard(0x7555) and c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsCanRemoveCounter(c:GetControler(),0x1555,1,REASON_COST)
end
function c76565316.filter(c)
	return c:IsSetCard(0x7555) and c:GetLevel()>=4 and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c76565316.thfilter(c)
	return c:IsSetCard(0x7555) and c:IsFaceup()
end
--search
function c76565316.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c76565316.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,c76565316.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
	if g:GetCount()>0 then
		g:GetFirst():RemoveCounter(tp,0x1555,1,REASON_COST)
	end
end
function c76565316.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c76565316.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c76565316.scop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c76565316.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--draw
function c76565316.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
function c76565316.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c76565316.thfilter,tp,LOCATION_SZONE,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,1) 
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_SZONE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c76565316.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,c76565316.thfilter,tp,LOCATION_SZONE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end