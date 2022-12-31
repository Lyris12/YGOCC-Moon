--Labolas, Lesser Fiend of the Black Lotus
--Script by TaxingCorn117
function c27796623.initial_effect(c)
    --tohand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(27796623,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,27796623)
    e1:SetCost(c27796623.tdcost)
    e1:SetTarget(c27796623.tdtg)
    e1:SetOperation(c27796623.tdop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
    Duel.AddCustomActivityCounter(27796623,ACTIVITY_SPSUMMON,c27796623.counterfilter)
    --draw
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(27796623,1))
    e4:SetCategory(CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetCountLimit(1,20796623)
    e4:SetCondition(c27796623.drcon)
    e4:SetTarget(c27796623.drtg)
    e4:SetOperation(c27796623.drop)
    c:RegisterEffect(e4)
end
--filters
function c27796623.counterfilter(c)
    return c:IsSetCard(0x42d)
end
function c27796623.filter(c)
    return c:IsSetCard(0x42d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
--tohand
function c27796623.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c27796623.filter,tp,LOCATION_DECK,0,1,nil)
        and Duel.GetCustomActivityCount(27796623,tp,ACTIVITY_SPSUMMON)==0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c27796623.filter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_COST)
        Duel.ConfirmCards(1-tp,g)
    end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(c27796623.splimit)
    Duel.RegisterEffect(e1,tp)
end
function c27796623.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not c:IsSetCard(0x42d)
end
function c27796623.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,e:GetHandler())
        and not Duel.IsExistingMatchingCard(Card.IsPublic,tp,LOCATION_HAND,0,1,e:GetHandler()) end
    Duel.SetTargetPlayer(tp)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function c27796623.tdop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0):Select(tp,1,1,nil)
    Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
end
--draw
function c27796623.drcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c27796623.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c27796623.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end