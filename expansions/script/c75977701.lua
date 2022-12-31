--Infected Knight of Ivory
--Script by XGlitchy30
function c75977701.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,c75977701.matfilter,2,2)
	--mill 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75977701,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,75977701)
	e1:SetTarget(c75977701.milltg)
	e1:SetOperation(c75977701.millop)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e1x)
	local e1y=e1:Clone()
	e1y:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1y)
	--activate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75977701,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,75977701)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c75977701.actcon)
	e2:SetTarget(c75977701.acttg)
	e2:SetOperation(c75977701.actop)
	c:RegisterEffect(e2)
	--tohand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(75977701,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,75977701)
	e3:SetTarget(c75977701.thtg)
	e3:SetOperation(c75977701.thop)
	c:RegisterEffect(e3)
end
--filters
function c75977701.matfilter(c)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM
end
function c75977701.millfilter(c)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM and c:IsAbleToGrave()
end
function c75977701.actcfilter(c,tp,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsFaceup() and c:IsControler(tp) and ec:GetLinkedGroup():IsContains(c)
	else
		return c:IsPreviousPosition(POS_FACEUP)
			and c:GetPreviousControler()==tp and bit.extract(ec:GetLinkedZone(tp),c:GetPreviousSequence())~=0
	end
end
function c75977701.actfilter(c,tp)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()))
		and not c:IsForbidden() and not Duel.IsExistingMatchingCard(c75977701.excfilter,tp,LOCATION_SZONE,0,1,c)
end
function c75977701.excfilter(c)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM and c:IsFaceup()
end
function c75977701.thfilter(c)
	return c:IsFaceup() and c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM and c:IsAbleToHand()
end
--mill 1
function c75977701.milltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c75977701.millfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c75977701.millop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c75977701.millfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
--activate
function c75977701.actcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c75977701.actcfilter,1,nil,tp,e:GetHandler())
end
function c75977701.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c75977701.actfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,tp) end
end
function c75977701.actop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c75977701.actfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		Card.SetCardData(tc,CARDDATA_TYPE,TYPE_TRAP+TYPE_CONTINUOUS)
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		if not tc:IsLocation(LOCATION_SZONE) then
			local edcheck=0
			if tc:IsLocation(LOCATION_EXTRA) then edcheck=TYPE_PENDULUM end
			Card.SetCardData(tc,CARDDATA_TYPE,TYPE_MONSTER+TYPE_EFFECT+edcheck+aux.GetOriginalPandemoniumType(tc))
		else
			tc:RegisterFlagEffect(726,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CANNOT_DISABLE,1)
			tc:RegisterFlagEffect(725,RESET_PHASE+PHASE_END,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
		end
	end
end
--tohand
function c75977701.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c75977701.thfilter,tp,LOCATION_EXTRA,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function c75977701.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c75977701.thfilter,tp,LOCATION_EXTRA,0,2,2,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end