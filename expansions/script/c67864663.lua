--VECTOR Legion Aerial Assault
--Scripted by Zerry and Remnance
function c67864663.initial_effect(c)
    --spsummon
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67864663,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,67864663)
	e1:SetCondition(c67864663.spcon)
	e1:SetTarget(c67864663.sptg)
	e1:SetOperation(c67864663.spop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67864663,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,67864663+100)
	e2:SetTarget(c67864663.tg1)
	e2:SetOperation(c67864663.op1)
	c:RegisterEffect(e2)
    --lv change
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(67864663,2))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,67864663+200)
	e3:SetCondition(c67864663.con)
    e3:SetTarget(c67864663.tg)
    e3:SetOperation(c67864663.op)
    c:RegisterEffect(e3)
end
--filters
function c67864663.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x52a6) and c:GetOriginalType()&TYPE_UNION==TYPE_UNION
end
function c67864663.spfilter1(c,e)
    return c:IsType(TYPE_UNION) and c:IsSetCard(0x52a6) and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) or c:IsAbleToHand())
end
--spsummon
function c67864663.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c67864663.spfilter,tp,LOCATION_SZONE,0,1,nil)
end
function c67864663.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c67864663.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
--special summon
function c67864663.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c67864663.spfilter1(chkc,e,tp) end
	if chk==0 then return true end
	if Duel.IsExistingTarget(c67864663.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(c67864663.op1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,c67864663.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,0,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,0,0,0)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
function c67864663.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and not tc:IsHasEffect(EFFECT_NECRO_VALLEY)
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			else
			if aux.CheckUnionEquip(tc,e:GetHandler()) and Duel.Equip(tp,tc,e:GetHandler()) then
   	 		aux.SetUnionState(tc)
			end
		end
	end
end
--lv change
function c67864663.con(e)
    local c=e:GetHandler()
    local eg=c:GetEquipGroup()
    return #eg>0 and eg:IsExists(Card.IsType,1,nil,TYPE_UNION)
end
function c67864663.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local lv=e:GetHandler():GetLevel()
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(67864663,1))
    e:SetLabel(Duel.AnnounceLevel(tp,1,6,lv))
end
function c67864663.op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_CHANGE_LEVEL)
        e3:SetValue(e:GetLabel())
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
        c:RegisterEffect(e3)
    end
end