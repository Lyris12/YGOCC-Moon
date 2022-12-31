--Ritmi Mistici - Dragone Encore
--Script by XGlitchy30
function c76565319.initial_effect(c)
	c:EnableCounterPermit(0x1555)
	--spsummon proc
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,76565319)
	e0:SetCondition(c76565319.sprcon)
	e0:SetOperation(c76565319.sprop)
	c:RegisterEffect(e0)
	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c76565319.thcon)
	e1:SetTarget(c76565319.thtg)
	e1:SetOperation(c76565319.thop)
	c:RegisterEffect(e1)
end
--filters
function c76565319.sprfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x7555) and c:GetCounter(0x1555)<=3 and c:IsCanTurnSet()
end
function c76565319.cfilter(c,tp)
	return c:IsPreviousSetCard(0x7555) and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_ONFIELD)
		and not c:IsLocation(LOCATION_DECK+LOCATION_HAND)
end
function c76565319.thfilter(c,tp)
	return c:IsAbleToHand() and c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x7555) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
--spsummon proc
function c76565319.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c76565319.sprfilter,tp,LOCATION_SZONE,0,1,nil)
end
function c76565319.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c76565319.sprfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.ChangePosition(g,POS_FACEDOWN)
	Duel.RaiseEvent(g,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+76565319,e,0,tp,tp,0)
end
--to hand
function c76565319.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c76565319.cfilter,1,nil,tp)
end
function c76565319.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c76565319.thfilter,1,nil,tp) end
	local clone=eg:Clone()
	e:SetLabelObject(clone)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,clone,1,0,0)
end
function c76565319.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=eg:FilterSelect(tp,c76565319.thfilter,1,1,nil,tp)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
