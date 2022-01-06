--Naval Gears - U-47
local cid,id=GetID()
function cid.initial_effect(c)
	--If set in back row: sp summon from deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_MOVE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(0xff)
    e1:SetCountLimit(1,id)
    e1:SetCondition(cid.tfcon)
    e1:SetTarget(cid.thtg)
    e1:SetOperation(cid.thop)
    c:RegisterEffect(e1)
	  -- Negate
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(88890001,2))
    e2:SetCategory(CATEGORY_NEGATE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(cid.negcon)
    e2:SetTarget(cid.negtg)
    e2:SetOperation(cid.negop)
    c:RegisterEffect(e2)
end
-- Negate
function cid.negcon(e,tp,eg,ep,ev,re,r,rp)
    return  Duel.IsChainNegatable(ev) and re:IsActiveType(TYPE_MONSTER)
end
function cid.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    end
function cid.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetCode(EFFECT_CHANGE_TYPE)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+0x1fc0000)
        e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
        c:RegisterEffect(e1)
        if Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 then
            Duel.MoveToField(c,1-tp,1-tp,LOCATION_SZONE,POS_FACEUP,true)
        else
            Duel.SendtoGrave(c,REASON_EFFECT)
        end
    end
end

--If set in back row: sp summon from deck
function cid.tfcon(e,tp,eg,ep,ev,re,r,rp)
return eg:IsExists(cid.condfilter,1,nil,e:GetHandler())
end
function cid.condfilter(c,card)
    return c==card and c:IsLocation(LOCATION_SZONE) and not c:IsPreviousLocation(LOCATION_SZONE)
end
function cid.thfilter(c,e,tp)
return c:IsSetCard(0x700) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsType(TYPE_LINK)
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
    end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(cid.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function cid.splimit(e,c,tp,sumtp,sumpos)
	return c:GetRace()~=RACE_MACHINE
end