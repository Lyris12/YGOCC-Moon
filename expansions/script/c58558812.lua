--Flibbertyskizzlemizzlefizzlebadizzle
local cid,id=GetID()
function cid.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
	--e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e1:SetTarget(cid.target)
    e1:SetOperation(cid.activate)
    c:RegisterEffect(e1)
	--act in set turn
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCondition(cid.actcon)
	c:RegisterEffect(e3)
	if not cid.global_check then
		cid.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SSET)
		ge1:SetOperation(cid.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function cid.actcon(e)
	return e:GetHandler():GetFlagEffect(id)>0
end
function cid.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not re or not re:GetHandler():IsSetCard(0x5855) or re:GetHandler():IsCode(id) then return end
	local tc=eg:GetFirst()
	while tc do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
function cid.filter(c,tp)
	return (c:IsCode(58558810) and c:IsAbleToGraveAsCost()) and c:IsFacedown()
		and Duel.IsExistingMatchingCard(cid.filter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
end
function cid.sfilter(c,tp)
	return (c:IsCode(58558811) and c:IsAbleToGraveAsCost()) and c:IsFacedown()
		and Duel.IsExistingMatchingCard(cid.sfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
end
function cid.filter2(c)
	return c:IsCode(58558811) and c:IsSSetable()
end
function cid.sfilter2(c)
	return c:IsCode(58558810) and c:IsSSetable()
end
function cid.cfilter(c)
	return c:IsCode(58558810) and c:IsFacedown()
end
function cid.cfilter2(c)
	return c:IsCode(58558811) and c:IsFacedown()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_SZONE,0,1,nil,tp)
	local b2=Duel.IsExistingMatchingCard(cid.sfilter,tp,LOCATION_SZONE,0,1,nil,tp)
	local b3=Duel.GetCurrentPhase()~=PHASE_DAMAGE and Duel.GetFlagEffect(tp,id)==0
	if chk==0 then return b1 or b2 or b3 end
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(id,0)
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(id,2)
		opval[off-1]=3
		off=off+1
	end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op]
	e:SetLabel(sel)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==1 then
		local g=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_SZONE,0,1,1,nil)
		if g:GetCount()>0 and Duel.SendtoGrave(g:GetFirst(),REASON_EFFECT)~=0 then
			tg=Duel.SelectMatchingCard(tp,cid.filter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
			Duel.SSet(tp,tg:GetFirst())
		end	
	elseif sel==2 then
		local g=Duel.SelectMatchingCard(tp,cid.cfilter2,tp,LOCATION_SZONE,0,1,1,nil)
		if g:GetCount()>0 and Duel.SendtoGrave(g:GetFirst(),REASON_EFFECT)~=0 then
			tg=Duel.SelectMatchingCard(tp,cid.sfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
			Duel.SSet(tp,tg:GetFirst())
		end	
	else
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_DISEFFECT)
		e1:SetValue(cid.effectfilter)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
	if c:IsRelateToEffect(e) and c:IsCanTurnSet() and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.BreakEffect()
		c:CancelToGrave()
		Duel.ChangePosition(c,POS_FACEDOWN)
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
function cid.effectfilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	local tc=te:GetHandler()
	return tc:IsSetCard(0x5855)
end