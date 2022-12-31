--Invasion of the Black Lotus
--Script by TaxingCorn117
function c27796628.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_PLAYER_TARGET)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(c27796628.cost)
    e1:SetTarget(c27796628.target)
    e1:SetOperation(c27796628.activate)
    c:RegisterEffect(e1)
    Duel.AddCustomActivityCounter(27796628,ACTIVITY_SPSUMMON,c27796628.counterfilter)
end
--filters
function c27796628.counterfilter(c)
    return c:IsSetCard(0x42d)
end
function c27796628.filter(c)
    return c:IsLevelBelow(4) and c:IsSetCard(0x42d) and c:IsAbleToHand()
end
--activate
function c27796628.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(c27796628.filter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,c27796628.filter,tp,LOCATION_GRAVE,0,1,1,nil)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsLevelBelow(4) and tc:IsSetCard(0x42d) then
        Duel.SendtoHand(tc,nil,REASON_COST)
    end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(c27796628.splimit)
    Duel.RegisterEffect(e1,tp)
end
function c27796628.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not c:IsSetCard(0x42d)
end
function c27796628.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.ShuffleDeck(tp)
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c27796628.activate(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end