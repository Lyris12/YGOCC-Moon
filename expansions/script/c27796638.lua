--Abysslym - Ragnaline Susano'o
--Script by TaxingCorn117
function c27796638.initial_effect(c)
    --link summon
    aux.AddLinkProcedure(c,c27796638.matfilter,2,2)
    c:EnableReviveLimit()
    --draw
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(27796638,0))
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCondition(c27796638.condition)
    e1:SetTarget(c27796638.target)
    e1:SetOperation(c27796638.operation)
    c:RegisterEffect(e1)
    --destroy
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(c27796638.descost)
    e2:SetTarget(c27796638.destg)
    e2:SetOperation(c27796638.desop)
    c:RegisterEffect(e2)
end
function c27796638.matfilter(c)
    return c:IsLinkSetCard(0x49c) and not c:IsLinkCode(27796638)
end
function c27796638.condition(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c27796638.cfilter(c)
    return c:IsSetCard(0x49c) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function c27796638.target(e,tp,eg,ep,ev,re,r,rp,chk)
         if chk==0 then return Duel.IsExistingMatchingCard(c27796638.cfilter,tp,LOCATION_DECK,0,1,nil)
            and Duel.IsPlayerCanDraw(tp,1) end
         Duel.SetTargetPlayer(tp)
         Duel.SetTargetParam(1)
         Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
         Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c27796638.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,c27796638.cfilter,tp,LOCATION_DECK,0,1,2,nil)
    if g:GetCount()==0 then return end
    if Duel.SendtoGrave(g,REASON_COST)~=0 then
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end
function c27796638.rmfilter(c)
    return c:IsSetCard(0x49c) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function c27796638.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c27796638.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,c27796638.rmfilter,tp,LOCATION_GRAVE,0,1,math.min(Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD),3),nil)
    e:SetLabel(g:GetCount())
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c27796638.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c27796638.desop(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetLabel()
    if ct==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
    if g:GetCount()>0 then
        Duel.HintSelection(g)
        Duel.Destroy(g,REASON_EFFECT)
    end
end