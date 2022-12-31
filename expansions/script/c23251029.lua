--Pharaohnic Scribe
local id,cod=23251029,c23251029
function cod.initial_effect(c)
    --Indes.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e1:SetValue(cod.valcon)
    e1:SetCountLimit(1)
    c:RegisterEffect(e1)
    --Tohand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(function (e) return e:GetHandler():IsAttackPos() end)
    e2:SetTarget(cod.thtg)
    e2:SetOperation(cod.thop)
    c:RegisterEffect(e2)
end
function cod.valcon(e,re,r,rp)
    return bit.band(r,REASON_BATTLE)~=0
end
function cod.hfilter(c)
    return (c:IsCode(23251026) or c:IsCode(23251030) or c:IsCode(23251031) or c:IsCode(23251032) or c:IsCode(23251033)) and c:IsAbleToHand()
end
function cod.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return  chkc:IsLocation(LOCATION_DECK) and chkc:IsAbleToHand() and cod.hfilter(chkc) end
    if chk==0 then return Duel.IsExistingMatchingCard(cod.hfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cod.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,cod.hfilter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
        e1:SetReset(RESET_PHASE+PHASE_END)
        e:GetHandler():RegisterEffect(e1)
    end
end
