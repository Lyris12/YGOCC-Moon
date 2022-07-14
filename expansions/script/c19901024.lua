--Geneseed Surprise Attack
local cid,id=GetID()
function cid.initial_effect(c)
	 --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER+TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e1:SetCondition(aux.dscon)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--change attack 
end
function cid.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x57b)
		and (Duel.IsExistingMatchingCard(cid.atkfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,c:GetAttack())
		   )
end
function cid.atkfilter(c,atk)
	return c:IsFaceup() and not c:IsAttack(atk)
end

function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cid.cfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(cid.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,cid.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		local g=Duel.GetMatchingGroup(cid.atkfilter,tp,0,LOCATION_MZONE,nil,atk,def)
		local cc=g:GetFirst()
		while cc do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			cc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	 e2:SetValue(def)
	cc:RegisterEffect(e2)
			cc=g:GetNext()

	  --pierce
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_PIERCE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x57b))
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
end
end