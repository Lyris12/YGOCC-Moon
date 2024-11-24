--Ignitronix Ignition
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects;
	--● Add 1 "Ignitronix Engine" from your Deck to your hand.
	--● Decrease the Energy of your Engaged "Ignitronix Engine" by 3; Special Summon 1 Positive and 1 Negative "Ignitronix" monster from your GY and/or banishment
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --You can banish this card from your GY, then target 1 face-up monster on the field; switch its current ATK and DEF until the end of this turn.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.swptg)
    e2:SetOperation(s.swpop)
    c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	local en=Duel.GetEngagedCard(tp)
    local b1=(Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp))
    local b2=(en and en:IsMonster(TYPE_DRIVE) and en:IsCode(77222587) and en:IsCanUpdateEnergy(-3,tp,REASON_COST)) and rg:CheckSubGroup(s.fgoal,2,2,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
    if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=0
	else
		op=1
	end
    e:SetLabel(op)
	if op==0 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
    if op==1 then
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE+LOCATION_REMOVED)
        en:UpdateEnergy(-3,tp,REASON_COST,true,e:GetHandler())
    end
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x725) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsPositive() or c:IsNegative())
end
function s.fgoal(sg,e,tp)
	return sg:FilterCount(Card.IsPositive,nil)==1 and sg:FilterCount(Card.IsNegative,nil)==1
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if e:GetLabel()==0 then
        local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
    else
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        if ft<2 then return end
		local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
		if rg:CheckSubGroup(s.fgoal,2,2,e,tp) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=rg:SelectSubGroup(tp,s.fgoal,false,2,2,e,tp)
			if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)==2 then
				--Cannot Special Summon from Extra Deck except FIRE
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
				e1:SetDescription(aux.Stringid(id,2))
				e1:SetTargetRange(1,0)
				e1:SetTarget(s.splimit)
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,tp)
			end
		end
    end
end
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLocation(LOCATION_EXTRA)
end
function s.swpfilter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
function s.swptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.swpfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.swpfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.swpop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local atk=tc:GetAttack()
        local def=tc:GetDefense()
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(def)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
        e2:SetValue(atk)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e2)
    end
end