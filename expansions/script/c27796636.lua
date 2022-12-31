--Abysslym Masterline
--Script by TaxingCorn117
function c27796636.initial_effect(c)
     --send up to 3 Abysslym to grave
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(27796636,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,27796636)
    e1:SetTarget(c27796636.tgtg)
    e1:SetOperation(c27796636.tgop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
    --add a Abysslym Spell
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(27796636,1))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetCountLimit(1)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCost(c27796636.thcost)
    e4:SetTarget(c27796636.thtg)
    e4:SetOperation(c27796636.thop)
    c:RegisterEffect(e4)
end
function c27796636.tgfilter(c)
    return c:IsSetCard(0x49c) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function c27796636.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_DECK) and chkc:IsControler(tp) and c27796636.tgfilter(chkc) end
    if chk==0 then return Duel.IsExistingMatchingCard(c27796636.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c27796636.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,c27796636.tgfilter,tp,LOCATION_DECK,0,1,3,nil)
    if g:GetCount()>0 then 
        Duel.SendtoGrave(g,nil,REASON_EFFECT)
    end
end
function c27796636.thcfilter(c)
    return c:IsSetCard(0x49c) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function c27796636.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c27796636.thcfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,c27796636.thcfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c27796636.filter(c)
    return c:IsSetCard(0x49c) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function c27796636.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c27796636.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c27796636.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c27796636.filter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end