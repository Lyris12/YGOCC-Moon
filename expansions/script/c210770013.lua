--Gate Guardian Ritual
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,25955164,62340868,98434877,25833572,210770012)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --Activate it from hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
    --Immune
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id+100)
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.immtg)
    e3:SetOperation(s.immop)
    c:RegisterEffect(e3)
end
function s.spfilter(c,e,tp)
    return c:IsCode(25955164,62340868,98434877) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.tzfilter(c)
    return c:IsCode(25955164,62340868,98434877) --and not c:IsForbidden()
end
function s.thfilter(c)
    return c:IsCode(25833572) or aux.IsCodeListed(c,25833572) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local ft1=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),3)
    local ft2=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),3)
    local b1=ft1>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
    local b2=ft2>0 and Duel.IsExistingMatchingCard(s.tzfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
    local op
    if b1 then op=1 end
    if b2 then op=0 end
    if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,0)) end
	e:SetLabel(op)
    if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
    end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    if op==1 then
        local ft1=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),3)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,ft1,nil,e,tp,ft1)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
        end
    else
        local ft2=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),3)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tzfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,ft2,nil,e,tp,ft2)
        for tc in aux.Next(g) do
            Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
            e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
            tc:RegisterEffect(e1)
        end
    end
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g:Select(tp,1,1,nil)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
    end
end

function s.actcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,210770012),e:GetHandlerPlayer(),LOCATION_FZONE,0,1,nil)
end

function s.immfilter(c)
    return c:IsFaceup() and c:IsCode(25833572) or aux.IsCodeListed(c,25833572)
end
function s.immtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.immfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.immop(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.immfilter,tp,LOCATION_MZONE,0,nil)
    for tc in aux.Next(g) do
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_IMMUNE_EFFECT)
        e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e3:SetRange(LOCATION_MZONE)
        e3:SetValue(s.efilter)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,Duel.IsTurnPlayer(tp) and 2 or 1)
        tc:RegisterEffect(e3)
    end
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActivated() and not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end