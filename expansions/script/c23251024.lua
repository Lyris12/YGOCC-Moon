--The Weighing of the Heart
local id,cod=23251024,c23251024
function cod.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(cod.target1)
	e1:SetOperation(cod.operation)
	c:RegisterEffect(e1)
	--Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetCost(cod.cost2)
	e2:SetTarget(cod.target2)
	e2:SetOperation(cod.operation)
	c:RegisterEffect(e2)
	--Draw
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(cod.drcon)
	e3:SetOperation(cod.drop)
	c:RegisterEffect(e3)
	--LP Cost
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCondition(cod.sdescon)
	e4:SetOperation(cod.sdesop)
	c:RegisterEffect(e4)
end
function cod.cfilter(c)
	return c:IsAbleToGraveAsCost() and
		Duel.IsExistingMatchingCard(cod.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,c:GetType())
end
function cod.dfilter(c,type)
	return c:IsType(type) and c:IsFaceup()
end
function cod.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsDestructable() end
	if chk==0 then return true end
	local cg=Duel.GetDecktopGroup(tp,1)
	if cg:FilterCount(cod.cfilter,nil)>0
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.SendtoGrave(cg,REASON_COST)
		e:SetLabel(cg:GetFirst():GetType())
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,1)
	end
end
function cod.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=Duel.GetDecktopGroup(tp,1)
	Debug.Message(cg:FilterCount(cod.cfilter,nil))
	if chk==0 then return cg:FilterCount(cod.cfilter,nil)>0 end
	Duel.SendtoGrave(cg,REASON_COST)
	e:SetLabel(cg:GetFirst():GetType())
end
function cod.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsDestructable() end
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,1)
end
function cod.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetLabel()==nil then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,cod.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function cod.drcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY+REASON_EFFECT+REASON_COST)~=0 and rp~=tp
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
function cod.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dt=Duel.GetDrawCount(tp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_DRAW_COUNT)
--  e1:SetRange(LOCATION_GRAVE)
	e1:SetTargetRange(1,0)
	e1:SetValue(dt+1)
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END,3)
	else
		e1:SetReset(RESET_PHASE+PHASE_END,2)
	end
	Duel.RegisterEffect(e1,tp)
end
function cod.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function cod.sdesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.CheckLPCost(tp,250) then
		Duel.PayLPCost(tp,250)
	else 
		Duel.Destroy(c,REASON_COST)
	end
end