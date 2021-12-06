--HDD Uni
--scripted by concordia
function c68709338.initial_effect(c)
 	--link summon
    aux.AddLinkProcedure(c,c68709338.lfilter,2,2)
    c:EnableReviveLimit()
  	--special summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(68709338,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,68709338)
    e1:SetCondition(c68709338.spcon)
    e1:SetTarget(c68709338.sptg)
    e1:SetOperation(c68709338.spop)
    c:RegisterEffect(e1)
end
function c68709338.lfilter(c)
    return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0xf08) or c:IsSetCard(0xf09))
end
function c68709338.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c68709338.filter(c,e,tp,zone)
    return c:IsSetCard(0xf08) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function c68709338.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local zone=e:GetHandler():GetLinkedZone(tp)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c68709338.filter(chkc,e,tp,zone) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(c68709338.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,c68709338.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c68709338.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local zone=c:GetLinkedZone(tp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,zone) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+0x1fe0000)
        tc:RegisterEffect(e1,true)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT+0x1fe0000)
        tc:RegisterEffect(e2,true)
        Duel.SpecialSummonComplete()
        local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e3:SetReset(RESET_PHASE+PHASE_END)
		e3:SetTargetRange(1,0)
		e3:SetTarget(c68709338.splimit)
		Duel.RegisterEffect(e3,tp)
	end
end
function c68709338.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsSetCard(0xf09)) and c:IsLocation(LOCATION_EXTRA)
end