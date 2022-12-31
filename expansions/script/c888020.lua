--Asmitala Night Queen
local m=888020
local cm=_G["c"..m]
function cm.initial_effect(c)
    aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xffa),8,2)
    c:EnableReviveLimit()
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(58481572,0))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_HAND)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(2,m)
    e2:SetCondition(cm.hdcon)
    e2:SetCost(cm.negcost)
    e2:SetTarget(cm.hdtg)
    e2:SetOperation(cm.hdop)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(67865534,2))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCondition(cm.xyzcon)
    e3:SetTarget(cm.xyztg)
    e3:SetOperation(cm.xyzop)
    c:RegisterEffect(e3)    
end
function cm.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
    local ct=Duel.GetOperatedGroup():GetFirst()
    e:SetLabelObject(ct)
end
function cm.cfilter(c,tp)
    return c:IsControler(tp)
end
function cm.hdcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(cm.cfilter,1,nil,1-tp)
end
function cm.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end
function cm.hdop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
    if g:GetCount()>0 then
        local sg=g:RandomSelect(tp,1)
        Duel.Destroy(sg,REASON_EFFECT)
    end
end
function cm.xyzcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
function cm.xyzfilter(c)
    return c:IsSetCard(0xffa) and c:IsFaceup()
end
function cm.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_EXTRA) and cm.xyzfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(cm.xyzfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(67865534,4))
    local g=Duel.SelectTarget(tp,cm.xyzfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function cm.xyzop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
        Duel.Overlay(c,Group.FromCards(tc))
    end
end