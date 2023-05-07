--Secluded Monkastery
local ref,id=GetID()
Duel.LoadScript("Monkastery.lua")
function ref.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Set
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetTarget(ref.settg)
	e2:SetOperation(ref.setop)
	c:RegisterEffect(e2)
	----Activate from GY
	--Effect to Grant
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_DRAW_PHASE)
	e3:SetTarget(ref.acttg)
	e3:SetOperation(ref.actop)
	--Grant
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e4:SetTargetRange(LOCATION_HAND+LOCATION_GRAVE+LOCATION_SZONE,0)
	e4:SetTarget(ref.eftg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end

--Set
function ref.setcfilter(c,e)
	return Monkastery.Is(c) and c:IsType(TYPE_TRAP) and c:IsCanBeEffectTarget(e)
		and Duel.IsExistingMatchingCard(ref.setfilter,e:GetHandlerPlayer(),LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function ref.setfilter(c,code)
	return Monkastery.Is(c) and c:IsType(TYPE_TRAP+TYPE_SPELL) and c:IsSSetable() and not c:IsCode(code)
end
function ref.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and ref.setcfilter(chkc,e) end
	if chk==0 then return eg:IsExists(ref.setcfilter,1,nil,e) and Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=eg:Filter(ref.setcfilter,nil,e):Select(tp,1,1,nil)
	Duel.SetTargetCard(g)
	g:GetFirst():CreateEffectRelation(e)
end
function ref.setop(e,tp,eg) local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,ref.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tc:GetCode())
		if #g>0 and Duel.SSet(tp,g)~=0 then
			local e0=Effect.CreateEffect(c)
			e0:SetType(EFFECT_TYPE_FIELD)
			e0:SetCode(EFFECT_CANNOT_SSET)
			e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e0:SetTargetRange(1,0)
			e0:SetTarget(ref.setlimit)
			e0:SetLabel(g:GetFirst():GetCode())
			e0:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e0,tp)
			if g:GetFirst():IsType(TYPE_TRAP) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetCondition(ref.setactcon)
				g:GetFirst():RegisterEffect(e1)
			end
		end
	end
end
function ref.setlimit(e,c,tp,re)
	return c:IsCode(e:GetLabel()) and re and re:GetHandler():IsCode(id)
end
function ref.setactcon(e)
	return Duel.GetFieldGroupCount(e:GetOwnerPlayer(),0,LOCATION_MZONE)>0
end

----GY Activate
--Effect to Grant
function ref.filter(c,tp)
	return Monkastery.Is(c) and c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.filter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(id,1))
end
function ref.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(ref.filter),tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end
--Grant
function ref.eftg(e,c)
	return c:GetType()==TYPE_TRAP
end
