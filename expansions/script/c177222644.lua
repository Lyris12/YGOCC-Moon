--Ignitronix Town
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--During your Main Phase: You can add 1 "Ignitronix Engine" from your Deck to your hand. You can only use this effect of "Ignitronix Town" once per Duel.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--If this card would be destroyed by a card effect, you can decrease the Energy of your Engaged "Ignitronix Engine" by 1 instead.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTarget(s.desreptg)
	e3:SetOperation(s.desrepop)
	c:RegisterEffect(e3)
	--If "Ignitronix Engine" is sent to your GY due to it having 0 Energy: You can add it to your hand, and if you do, Engage it.
	local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_FZONE)
    e4:SetCondition(s.thcon2)
    e4:SetTarget(s.thtg2)
    e4:SetOperation(s.thop2)
    c:RegisterEffect(e4)
end
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsCode(77222587)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
	if chk==0 then return not e:GetHandler():IsReason(REASON_RULE)
		and en and en:IsMonster(TYPE_DRIVE) and en:IsCode(77222587) and en:IsCanUpdateEnergy(-1,tp,REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local en=Duel.GetEngagedCard(tp)
	en:UpdateEnergy(-1,tp,REASON_EFFECT,true,e:GetHandler())
end
function s.thfilter2(c,tp)
    return c:HasFlagEffect(FLAG_ZERO_ENERGY) and c:IsCode(77222587) and c:IsMonster(TYPE_DRIVE) and c:IsAbleToHand() and c:IsCanEngage(tp) and c:IsControler(tp)
end
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.thfilter2,1,nil,tp)
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=eg:Filter(s.thfilter2,nil,tp):GetFirst()
    if chk==0 then return c:IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
    local c=eg:Filter(s.thfilter2,nil,tp):GetFirst()
    if Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND) then
        c:Engage(e,tp)
    end
end
