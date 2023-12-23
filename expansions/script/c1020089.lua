--VIATRIX: Storm
--Script by XGlitchy30
function c1020089.initial_effect(c)
	--pendulum
	aux.EnablePendulumAttribute(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1020089,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_RELEASE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,1020089)
	e1:SetCondition(c1020089.tkcon)
	e1:SetTarget(c1020089.tktg)
	e1:SetOperation(c1020089.tkop)
	c:RegisterEffect(e1)
	--spsummon extra
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1020089,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,1120089)
	e2:SetCost(c1020089.spcost)
	e2:SetTarget(c1020089.sptg)
	e2:SetOperation(c1020089.spop)
	c:RegisterEffect(e2)
	--return to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1020089,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_RELEASE)
	e3:SetCountLimit(1,1220089)
	e3:SetCondition(c1020089.thcon)
	e3:SetTarget(c1020089.thtg)
	e3:SetOperation(c1020089.thop)
	c:RegisterEffect(e3)
end
--filters
function c1020089.tkfilter(c,tp)
	return bit.band(c:GetPreviousTypeOnField(),TYPE_MONSTER)>0 and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp and c:IsPreviousSetCard(0x39c)
end
function c1020089.cfilter(c,e,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsRace(RACE_CYBERSE) and c:IsFaceup()
		and Duel.IsExistingMatchingCard(c1020089.spfilter,tp,LOCATION_EXTRA,0,1,nil,c:GetCode(),e,tp)
			and Duel.GetLocationCountFromEx(tp,tp,c)>0
end
function c1020089.spfilter(c,code,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsRace(RACE_CYBERSE)
		and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--pendulum
function c1020089.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c1020089.tkfilter,1,nil,tp)
end
function c1020089.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,1120089,0x39c,0x4011,700,350,4,RACE_CYBERSE,ATTRIBUTE_WIND) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
function c1020089.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,1120089,0x39c,0x4011,700,350,4,RACE_CYBERSE,ATTRIBUTE_WIND) then return end
	local token=Duel.CreateToken(tp,1120089)
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
--spsummon extra
function c1020089.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function c1020089.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroup(REASON_COST,tp,c1020089.cfilter,1,e:GetHandler(),e,tp) 
	end
	local g=Duel.SelectReleaseGroup(REASON_COST,tp,c1020089.cfilter,1,1,e:GetHandler(),e,tp)
	Duel.Release(g,REASON_COST)
	local op=Duel.GetOperatedGroup()
	e:SetLabel(op:GetFirst():GetCode())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c1020089.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c1020089.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e:GetLabel(),e,tp)
	if g:GetCount()>0 then 
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--return to hand
function c1020089.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x39c) and re:IsHasType(0x7f0) and e:GetHandler():IsReason(REASON_COST)
end
function c1020089.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c1020089.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end