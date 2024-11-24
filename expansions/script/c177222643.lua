--Ignitronix Stormbreaker Inductor
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,Card.IsNeutral,1,1,Card.IsPositive,1,1,Card.IsNegative,1,1)
	--While you have an Engaged "Ignitronix Engine", this card is unaffected by your opponent's Spell/Trap effects.
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetValue(s.efilter)
	e1:SetCondition(s.imcon)
    c:RegisterEffect(e1)
	--During the Main Phase (Quick Effect): You can decrease the Energy of your Engaged monster by 3, banish all Spells and Traps your opponent controls.
	local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,{id,0})
    e2:SetCondition(s.rmcon)
    e2:SetCost(s.rmcost)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)
	--If this card is destroyed by battle or card effect: You can add 1 "Ignitronix" card from Deck or GY to your hand.
	local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end
function s.imcon(e)
	local en=Duel.GetEngagedCard(e:GetHandlerPlayer())
    return en and en:IsMonster(TYPE_DRIVE) and en:IsCode(77222587)
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local en=Duel.GetEngagedCard(tp)
    if chk==0 then return en and en:IsMonster(TYPE_DRIVE) and en:IsCanUpdateEnergy(-3,tp,REASON_COST) end
    en:UpdateEnergy(-3,tp,REASON_COST,true,e:GetHandler())
end
function s.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT)
end
function s.thfilter(c)
	return c:IsSetCard(0x725) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end