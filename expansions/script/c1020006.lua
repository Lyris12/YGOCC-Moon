--Zero Survival
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(aux.dscon)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
end
function s.filter1(c,e)
	local tp=c:GetControler()
	return c:IsFaceup() and c:IsSetCard(0xded) and c:IsAttackAbove(1) and (not e or c:IsCanBeEffectTarget(e))
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsRace),tp,LOCATION_MZONE,0,1,c,RACE_MACHINE)
end
function s.filter2(c,e)
	local tp=c:GetControler()
	return c:IsFaceup() and c:IsSetCard(0xded) and (not e or c:IsCanBeEffectTarget(e))
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,IsAttackAbove),tp,LOCATION_MZONE,0,1,c,1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_MZONE,0,nil,e)
	local g2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,nil,e)
	if chkc then return (e:GetLabel()==0 and g1:IsContains(chkc,e)) or (e:GetLabel()==1 and g2:IsContains(chkc,e)) end
	if chk==0 then return #g1>0 or #g2>0 end
	local g=Group.CreateGroup()
	g:Merge(g1)
	g:Merge(g2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tg=g:Select(tp,1,1,nil)
	Duel.SetTargetCard(tg)
	local tc=tg:GetFirst()
	local a,b=s.filter1(tc),s.filter2(tc)
	local op=0
	if a and b then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	else
		op=a and 0 or 1
	end
	e:SetLabel(op)
	if op==0 then e:SetOperation(s.activate0) else e:SetOperation(s.activate1) end
end
function s.activate0(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e1)
		if not tc:IsImmuneToEffect(e1) then
			local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsRace),tp,LOCATION_MZONE,0,tc,RACE_MACHINE)
			for c in aux.Next(g) do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				e1:SetValue(math.ceil(atk/2))
				c:RegisterEffect(e1)
			end
		end
	end
end
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,IsAttackAbove),tp,LOCATION_MZONE,0,tc,1)
	local og=Group.CreateGroup()
	og:KeepAlive()
	for c in aux.Next(g) do
		local atk=c:GetAttack()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(atk/2))
		c:RegisterEffect(e1,true)
		if not c:IsImmuneToEffect(e1) then
			og:AddCard(c)
			tc:CreateRelation(c,RESET_EVENT+RESETS_STANDARD)
			c:CreateRelation(tc,RESET_EVENT+RESETS_STANDARD)
		end
	end
	if #og>0 and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(s.indescon)
		e1:SetLabelObject(og)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end
function s.indesfilter(c,tc)
	return c:IsRelateToCard(tc) and tc:IsRelateToCard(c)
end
function s.indescon(e)
	local g=e:GetLabelObject()
	return #g:Filter(s.indesfilter,nil,e:GetHandler())>0
end
