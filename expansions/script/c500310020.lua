--Sweethard Littlyla
function c500310020.initial_effect(c)
		--summon success
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_TOHAND)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_SUMMON_SUCCESS)
	e0:SetCountLimit(1,500310020)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetTarget(c500310020.thtg)
	e0:SetOperation(c500310020.thop)
	c:RegisterEffect(e0)
		local e1=e0:Clone()
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1)  
		--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(500310020,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,500310021)
	e2:SetCondition(c500310020.spcon2)
	e2:SetTarget(c500310020.sptg2)
	e2:SetOperation(c500310020.spop2)
	c:RegisterEffect(e2)
end
function c500310020.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xa34) and not c:IsCode(500310020) and c:IsAbleToHand()
end
function c500310020.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	 if chkc then return chkc:GetControler()==tp and chkc:GetLocation()==LOCATION_GRAVE and c500310020.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c500310020.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c500310020.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c500310020.thop(e,tp,eg,ep,ev,re,r,rp)
local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function c500310020.cfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousControler()==tp and bit.band(c:GetPreviousTypeOnField(),TYPE_EVOLUTE)~=0
		and c:IsPreviousSetCard(0xa34) and (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)))
end
function c500310020.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c500310020.cfilter,1,nil,tp,rp)
end
function c500310020.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c500310020.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end