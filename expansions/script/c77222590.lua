--Ignitronix Neutralizer
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects;
	--● Target 1 "Ignitronix" monster you control; Change its ATK/DEF to 0.
	--● Decrease the Energy of your Engaged "Ignitronix Engine" by 3; until the end of this turn, change the ATK/DEF of a face-up monster on the field to 0, also it has its effects negated.
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
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
function s.filter(c,negate)
	return c:IsFaceup() and (c:IsSetCard(0x725) or negate) and (c:GetAttack()>0 or c:GetDefense()>0 or (aux.NegateMonsterFilter(c) or not negate))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	local en=Duel.GetEngagedCard(tp)
    local b1=Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,false)
    local b2=(en and en:IsMonster(TYPE_DRIVE) and en:IsCode(77222587) and en:IsCanUpdateEnergy(-3,tp,REASON_COST)) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,true)
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
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
		Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,false)
	end
    if op==1 then
        e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DISABLE)
		en:UpdateEnergy(-3,tp,REASON_COST,true,e:GetHandler())
    end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=nil
	if e:GetLabel()==0 then
		tc=Duel.GetFirstTarget()
	else
		tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,true):GetFirst()
	end
	if tc:IsFaceup() and (tc:IsRelateToEffect(e) or e:GetLabel()==1) then
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_SET_ATTACK_FINAL)
		e0:SetValue(0)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e0)
		local e1=e0:Clone()
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e1)
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		if e:GetLabel()==1 then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetValue(RESET_TURN_SET)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
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