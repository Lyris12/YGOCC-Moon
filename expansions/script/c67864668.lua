--VECTOR Frame: Tyrfing
--Scripted by Zerry
function c67864668.initial_effect(c)
--Synchro material
aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x2a6),aux.NonTuner(Card.IsSetCard,0x2a6),1)
c:EnableReviveLimit()
--Equip
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(67864665,0))
e1:SetCategory(CATEGORY_EQUIP)
e1:SetType(EFFECT_TYPE_IGNITION)
e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
e1:SetRange(LOCATION_MZONE)
e1:SetCountLimit(1,67864668+100)
e1:SetTarget(c67864668.target)
e1:SetOperation(c67864668.operation)
c:RegisterEffect(e1)
--Special Summon
local e2=Effect.CreateEffect(c)
e2:SetDescription(aux.Stringid(67864665,1))
e2:SetCategory(CATEGORY_DISABLE)
e2:SetType(EFFECT_TYPE_QUICK_O)
e2:SetCode(EVENT_FREE_CHAIN)
e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
e2:SetRange(LOCATION_MZONE)
e2:SetCountLimit(1,67864668)
e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
e2:SetTarget(c67864668.sptg)
e2:SetOperation(c67864668.spop)
c:RegisterEffect(e2)
end
--Equip
function c67864668.eqfilter(c,e,tp,ec)
    return c:IsSetCard(0x2a6) and c:IsType(TYPE_MONSTER)
end
function c67864668.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c67864668.eqfilter(chkc,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>(e:GetHandler():IsLocation(LOCATION_SZONE) and 0 or 1)
        and Duel.IsExistingTarget(c67864668.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectTarget(tp,c67864668.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function c67864668.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if not Duel.Equip(tp,tc,c,false) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c67864668.eqlimit)
		tc:RegisterEffect(e1)
	end
end
function c67864668.eqlimit(e,c)
	return e:GetOwner()==c
end

--Special Summon
function c67864668.spfilter2(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c67864668.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c67864668.spfilter2(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c67864668.spfilter2,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c67864668.spfilter2,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c67864668.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end