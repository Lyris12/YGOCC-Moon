--Vertex Melody Chorus
--Script by Zerry
function c11111311.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_CONTROL)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e1:SetTarget(c11111311.target)
    e1:SetOperation(c11111311.activate)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c11111311.handcon)
	c:RegisterEffect(e2)
end
function c11111311.filter1(c)
    return c:IsFaceup() and c:IsSetCard(0x5a3) and c:IsAbleToChangeControler()
end
function c11111311.filter2(c)
    return c:IsAbleToChangeControler()
end
function c11111311.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then return Duel.IsExistingTarget(c11111311.filter2,tp,0,LOCATION_MZONE,1,nil)
        and Duel.IsExistingTarget(c11111311.filter1,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g2=Duel.SelectTarget(tp,c11111311.filter2,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g1=Duel.SelectTarget(tp,c11111311.filter1,tp,LOCATION_MZONE,0,1,1,nil)
    g1:Merge(g2)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
function c11111311.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    local a=g:GetFirst()
    local b=g:GetNext()
    if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) then
        Duel.SwapControl(a,b)
    end
end
function c11111311.actfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x5a3) and c:IsType(TYPE_FUSION) and c:IsLevel(6)
end
function c11111311.handcon(e)
	return Duel.IsExistingMatchingCard(c11111311.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end