--Cyberdark Core
function c212705.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,c212705.mfilter,1,1)
	c:EnableReviveLimit()
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(212705,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,212705)
	e1:SetCondition(c212705.thcon)
	e1:SetTarget(c212705.thtg)
	e1:SetOperation(c212705.thop)
	c:RegisterEffect(e1)
	--Search
	local e2=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(212705,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,212706)
	e2:SetTarget(c212705.thtgi)
	e2:SetOperation(c212705.thopi)
	c:RegisterEffect(e2)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c212705.atkval)
	c:RegisterEffect(e3)
end
function c212705.mfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkSetCard(0x4093)
end
function c212705.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c212705.thfilter(c)
	return c:IsCode(44352516) and c:IsAbleToHand()
end
function c212705.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c212705.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c212705.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c212705.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c212705.thfilteri(c)
	return c:IsSetCard(0x4093) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
function c212705.thtgi(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c212705.thfilteri,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c212705.thopi(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c212705.thfilteri),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c212705.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x4093) and c:GetBaseAttack()>=0
end
function c212705.atkval(e,c)
	local lg=c:GetLinkedGroup():Filter(c212705.atkfilter,nil)
	return lg:GetSum(Card.GetBaseAttack)
end