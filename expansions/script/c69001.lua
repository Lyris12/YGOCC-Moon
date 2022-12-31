---Peach Beach Beauty, Cerb
function c69001.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(69001,0))
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_IGNITION)
    e1:SetCategory(CATEGORY_RECOVER)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EVENT_PHASE+PHASE_MAIN1)
    e1:SetCountLimit(1,69001)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(c69001.reccon)
    e1:SetCost(c69001.reccost)
    e1:SetTarget(c69001.rectg)
    e1:SetOperation(c69001.recop)
    c:RegisterEffect(e1)
    --special summon
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e2:SetCountLimit(1,69001+100)
    e2:SetRange(LOCATION_HAND)
    e2:SetCondition(c69001.spcon)
    c:RegisterEffect(e2)
	 local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(69001,0))
    e3:SetCategory(CATEGORY_RECOVER+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,69001+200)
    e3:SetTarget(c69001.rectg2)
    e3:SetOperation(c69001.recop2)
    c:RegisterEffect(e3)
end
function c69001.reccon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end
function c69001.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not e:GetHandler():IsPublic() end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_PUBLIC)
    e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
    e:GetHandler():RegisterEffect(e1)
end
function c69001.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(500)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function c69001.recop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Recover(p,d,REASON_EFFECT)
end
function c69001.spcon(e,c)
    if c==nil then return true end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local tp=c:GetControler()
    return (Duel.GetLP(tp)-1000)>=Duel.GetLP(1-tp)
end
function c69001.thfilter(c)
    return c:IsSetCard(0x6969) and c:IsAbleToHand()
end
function c69001.recfilter2(c,self)
    return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x6969) and not(c:GetFieldID()==self)
end
function c69001.rectg2(e,tp,eg,ep,ev,re,r,rp,chk) 
    local self=e:GetHandler():GetFieldID()
    if chk==0 then 
    return Duel.IsExistingMatchingCard(c69001.recfilter2,tp,LOCATION_MZONE,0,1,nil,self)and
    Duel.IsExistingMatchingCard(c69001.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,500)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c69001.recop2(e,tp,eg,ep,ev,re,r,rp)
    local self=e:GetHandler():GetFieldID()
    if Duel.IsExistingMatchingCard(c69001.recfilter2,tp,LOCATION_MZONE,0,1,nil,self) then
        Duel.Recover(tp,500,REASON_EFFECT)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c69001.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end    
end