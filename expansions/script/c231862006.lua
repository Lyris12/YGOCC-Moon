--created by ZEN, coded by TaxingCorn117
local cid,id=GetID()
function cid.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(math.floor(id/100),0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(cid.sumcon)
    e1:SetTarget(cid.sumtg)
    e1:SetOperation(cid.sumop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e3:SetCondition(cid.imcon)
    c:RegisterEffect(e3)
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(math.floor(id/100),0))
    e4:SetCategory(CATEGORY_DAMAGE)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(cid.damcon)
    e4:SetCost(cid.damcost)
    e4:SetTarget(cid.damtg)
    e4:SetOperation(cid.damop)
    c:RegisterEffect(e4)
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(math.floor(id/100),1))
    e5:SetCategory(CATEGORY_ATKCHANGE)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_MZONE)
    e5:SetHintTiming(0,TIMING_BATTLE_START)
    e5:SetCountLimit(1,id+17)
    e5:SetCondition(cid.atkcon)
    e5:SetTarget(cid.atktg)
    e5:SetOperation(cid.atkop)
    c:RegisterEffect(e5)
    if cid.counter==nil then
        cid.counter=true
        cid[0]=0
        cid[1]=0
        cid[2]=0
        cid[3]=0
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
        e2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
        e2:SetOperation(cid.resetcount)
        Duel.RegisterEffect(e2,0)
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
        e3:SetCode(EVENT_DAMAGE)
        e3:SetOperation(cid.addcount)
        Duel.RegisterEffect(e3,0)
    end
end
function cid.resetcount(e,tp,eg,ep,ev,re,r,rp)
    cid[0]=0 cid[1]=0 cid[2]=0 cid[3]=0
end
function cid.addcount(e,tp,eg,ep,ev,re,r,rp)
    cid[ep]=cid[ep]+1
    cid[2+ep]=cid[2+ep]+ev
end
function cid.sumcon(e,tp,eg,ep,ev,re,r,rp)
    return cid[tp]>4
end
function cid.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cid.sumop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end
function cid.imcon(e)
    return cid[2+e:GetHandlerPlayer()]>=2500
end
function cid.damcon(e,tp,eg,ep,ev,re,r,rp)
    return cid[tp]>0
end
function cid.dmfilter(c,tp)
    return c:IsReleasable()
end
function cid.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(1-tp,nil,1,nil) end
    local sg=Duel.SelectMatchingCard(tp,cid.dmfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
    e:SetLabel(sg:GetFirst():GetAttack())
    Duel.Release(sg,REASON_COST)
end
function cid.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(e:GetLabel())
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
function cid.damop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Damage(p,d,REASON_EFFECT)
end
function cid.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
function cid.atkfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x52f)
end
function cid.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function cid.atkop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetMatchingGroup(cid.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    if Duel.Damage(tp,500,REASON_EFFECT)~=0 and Duel.GetLP(tp)>0 and #tg>0 then
        local sc=tg:GetFirst()
        while sc do
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            e1:SetValue(1000)
            sc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_UPDATE_DEFENSE)
            sc:RegisterEffect(e2)
            sc=tg:GetNext()
        end
    end
end