--Vert
--coded by Concordia
function c68709363.initial_effect(c)
	--pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	--tohand
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(68709363,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCountLimit(1,68709363)
    e2:SetTarget(c68709363.thtg)
    e2:SetOperation(c68709363.thop)
    c:RegisterEffect(e2)
end
function c68709363.thfilter(c)
    return c:IsSetCard(0xf08) and c:IsType(TYPE_MONSTER) and not c:IsCode(68709363) and c:IsAbleToHand()
end
function c68709363.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c68709363.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c68709363.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c68709363.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end