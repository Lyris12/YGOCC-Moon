--Ignitronix Blaster
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects;
	--● Target 1 "Ignitronix" monster you control and up to 2 cards your opponent controls; destroy them.
	--● Decrease the Energy of your Engaged "Ignitronix Engine" by 3; destroy up to 2 cards your opponent controls.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --You can banish this card from your GY, then target 1 face-up monster on the field; switch its current ATK and DEF until the end of this turn.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.swptg)
    e2:SetOperation(s.swpop)
    c:RegisterEffect(e2)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x725)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
    local b1=(Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil))
    local b2=(en and en:IsMonster(TYPE_DRIVE) and en:IsCode(77222587) and en:IsCanUpdateEnergy(-3,tp,REASON_COST)) and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
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
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g1=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,2,nil)
		g1:Merge(g2)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
	end
    if op==1 then
        en:UpdateEnergy(-3,tp,REASON_COST,true,e:GetHandler())
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=nil
	if e:GetLabel()==0 then
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		tg=g:Filter(Card.IsRelateToEffect,nil,e)
	else
		tg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,2,nil)
	end
	if tg:GetCount()>0 then
		if e:GetLabel()==1 then
			Duel.HintSelection(tg)
		end
		Duel.Destroy(tg,REASON_EFFECT)
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