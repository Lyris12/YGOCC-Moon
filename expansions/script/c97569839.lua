--Safe Travels Under The Silent Star
--Scripted by Zerry
function c97569839.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,97569839)
	e1:SetCondition(c97569839.condition)
	e1:SetTarget(c97569839.target)
	e1:SetOperation(c97569839.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)	
    e2:SetCountLimit(1,97569839)
    e2:SetCondition(c97569839.spcon)
    e2:SetTarget(c97569839.target2)
    e2:SetOperation(c97569839.activate2)
    c:RegisterEffect(e2)
end
function c97569839.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldCard(tp,LOCATION_FZONE,0)==nil
end
function c97569839.filter1(c,tp)
    return c:IsCode(97569827) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function c97569839.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c97569839.filter1,tp,LOCATION_DECK,0,1,nil,tp) end
    if not Duel.CheckPhaseActivity() then e:SetLabel(1) else e:SetLabel(0) end
end
function c97569839.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(97569839,0))
    if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,97569839,RESET_CHAIN,0,1) end
    local tc=Duel.SelectMatchingCard(tp,c97569839.filter1,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
    Duel.ResetFlagEffect(tp,c97569839)
    if tc then
        local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
        if fc then
            Duel.SendtoGrave(fc,REASON_RULE)
            Duel.BreakEffect()
        end
        Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
        local te=tc:GetActivateEffect()
        te:UseCountLimit(tp,1,true)
        local tep=tc:GetControler()
        local cost=te:GetCost()
        if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
        Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
    end
end
function c97569839.filter(c,e,tp)
    return c:IsSetCard(0xd0a1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c97569839.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsEnvironment(97569827,PLAYER_ALL,LOCATION_FZONE)
end
function c97569839.target2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c97569839.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c97569839.activate2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c97569839.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
    end
end