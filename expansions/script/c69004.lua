--Peach Beach Late-Nighter, Vamp
function c69004.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(69004,0))
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_IGNITION)
    e1:SetCategory(CATEGORY_RECOVER)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EVENT_PHASE+PHASE_MAIN1)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,69004)
    e1:SetCondition(c69004.reccon)
    e1:SetCost(c69004.reccost)
    e1:SetTarget(c69004.rectg)
    e1:SetOperation(c69004.recop)
    c:RegisterEffect(e1)
	--special summon
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e2:SetCountLimit(1,69004+100)
    e2:SetRange(LOCATION_HAND)
    e2:SetCondition(c69004.spcon)
    c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(69004,0))
    e3:SetCategory(CATEGORY_RECOVER)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCountLimit(1,69004+200)
    e3:SetTarget(c69004.rectg2)
    e3:SetOperation(c69004.recop2)
	e3:SetCondition(c69004.reccon2)
    c:RegisterEffect(e3)
end
function c69004.reccon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end
function c69004.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not e:GetHandler():IsPublic() end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_PUBLIC)
    e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
    e:GetHandler():RegisterEffect(e1)
end
function c69004.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(500)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function c69004.recop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Recover(p,d,REASON_EFFECT)
end
function c69004.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x6969)
end
function c69004.spcon(e,tp,eg,ep,ev,re,r,rp)
    local tp=e:GetHandler():GetControler()
    return Duel.IsExistingMatchingCard(c69004.cfilter,tp,LOCATION_MZONE,0,2,e:GetHandler()) 
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
function c69004.rectg2(e,tp,eg,ep,ev,re,r,rp,chk)
    local rec=Duel.GetMatchingGroupCount(aux.TRUE,1-tp,LOCATION_MZONE,0,nil)*500
    if chk==0 then return rec>0 end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(rec)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
function c69004.recop2(e,tp,eg,ep,ev,re,r,rp)
    local rec=Duel.GetMatchingGroupCount(aux.TRUE,1-tp,LOCATION_MZONE,0,nil)*500
    local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
    Duel.Recover(p,rec,REASON_EFFECT)
end
function c69004.reccon2(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end