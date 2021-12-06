--Vert
--coded by Concordia
function c68709328.initial_effect(c)
	--pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	--tohand
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(68709328,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCountLimit(1,68709328)
    e2:SetCondition(c68709328.thcon)
    e2:SetTarget(c68709328.thtg)
    e2:SetOperation(c68709328.thop)
    c:RegisterEffect(e2)
end
function c68709328.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT)
end
function c68709328.thfilter(c)
    return c:IsSetCard(0xf08) and c:IsType(TYPE_MONSTER) and not c:IsCode(68709328) and c:IsAbleToHand()
end
function c68709328.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c68709328.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c68709328.thop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(c68709328.thfilter,tp,LOCATION_DECK,0,nil)
    if g:GetClassCount(Card.GetCode)>=1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g1=g:Select(tp,1,1,nil)
        g:Remove(Card.IsCode,nil,g1:GetFirst():GetCode())
        if Duel.IsExistingMatchingCard(c68709328.thfilter,tp,LOCATION_DECK,0,1,nil) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g2=g:Select(tp,1,1,nil)
            g1:Merge(g2)
        end
        Duel.SendtoHand(g1,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g1)
    end
end