--Tri-Brigade Ambush
function c99900205.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,999000205)
	e1:SetCondition(c99900205.condition)
	e1:SetTarget(aux.nbtg)
	e1:SetOperation(c99900205.activate)
	c:RegisterEffect(e1)
	--Set to field from gy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(999000205,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,999000206)
	e2:SetCondition(c99900205.resetCon)
	e2:SetTarget(c99900205.resetTrg)
	e2:SetOperation(c99900205.resetOp)
	c:RegisterEffect(e2)
end

--negate function
function c99900205.negfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsType(TYPE_LINK)
end
function c99900205.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c99900205.negfilter,1,nil)
end
function c99900205.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end

--reset functions
function c99900205.cfilter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsFaceup() and c:IsType(TYPE_LINK)
end

function c99900205.resetCon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c99900205.cfilter,1,nil)
end

function c99900205.resetTrg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end

function c99900205.resetOp(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SSet(tp,c)
	end
end