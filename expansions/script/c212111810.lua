--created by Slick, coded by Lyris
--Belgrade Under
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,212111811)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.act)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetOperation(s.repop)
	e2:SetValue(aux.TargetBoolFunction(s.rfilter))
	c:RegisterEffect(e2)
end
function s.filter(c,tp)
	return (c:IsCode(212111811) or Duel.IsEnvironment(212111811,tp,LOCATION_FZONE) and c:IsType(TYPE_DRIVE)
		and c:IsSetCard(0x44a) and c:IsLocation(LOCATION_DECK)) and c:IsAbleToHand()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.act(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if not tc or Duel.SendtoHand(tc,nil,REASON_EFFECT)<1 or not tc:IsLocation(LOCATION_HAND) then return end
	Duel.ConfirmCards(1-tp,tc)
	if not (tc:IsCanEngage(tp) and tc:IsType(TYPE_DRIVE)
		and Duel.SelectEffectYesNo(tp,tc,aux.Stringid(id,0))) then return end
	Duel.BreakEffect()
	tc:Engage(e,tp)
end
function s.rfilter(c)
	return c:IsFaceupEx() and c:IsCode(212111811) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:FilterCount(s.rfilter,nil)==1 and c:IsAbleToRemove() end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,eg:Filter(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND))
end
