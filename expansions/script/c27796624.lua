--Abaddon, Spiritualist of the Black Lotus
--Script by TaxingCorn117
function c27796624.initial_effect(c)
    --draw
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(27796624,0))
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,27796624)
    e1:SetCost(c27796624.drcost)
    e1:SetTarget(c27796624.drtg)
    e1:SetOperation(c27796624.drop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
    Duel.AddCustomActivityCounter(27796624,ACTIVITY_SPSUMMON,c27796624.counterfilter)
    --banish
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(27796624,1))
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetCountLimit(1,20796624)
    e4:SetCondition(c27796624.rmcon)
    e4:SetCost(c27796624.rmcost)
    e4:SetOperation(c27796624.rmop)
    c:RegisterEffect(e4)
end
--filters
function c27796624.counterfilter(c)
    return c:IsSetCard(0x42d)
end
function c27796624.drfilter(c,e,tp)
    return c:IsSetCard(0x42d) and c:IsAbleToDeck()
end
function c27796624.filter(c)
    return c:IsCode(27796627) and c:IsAbleToHand()
end
--draw
function c27796624.drcost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c27796624.drfilter(chkc) end
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(c27796624.drfilter,tp,LOCATION_GRAVE,0,3,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,c27796624.drfilter,tp,LOCATION_GRAVE,0,3,3,nil)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
    Duel.SendtoDeck(tg,nil,0,REASON_COST)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(c27796624.splimit)
    Duel.RegisterEffect(e1,tp)
end
function c27796624.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not c:IsSetCard(0x42d)
end
function c27796624.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c27796624.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end
--banish
function c27796624.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c27796624.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c27796624.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c27796624.filter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_COST)
        Duel.ConfirmCards(1-tp,g)
    end
end
function c27796624.rmop(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemove() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end