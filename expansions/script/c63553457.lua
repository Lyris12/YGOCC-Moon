--Avanzata Inferioringranaggio
--Script by XGlitchy30
function c63553457.initial_effect(c)
	c:EnableCounterPermit(0x1554)
	c:SetUniqueOnField(1,0,63553457)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--counter
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(c63553457.ctcon)
	e2:SetOperation(c63553457.ctop)
	c:RegisterEffect(e2)
	--direct attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetCondition(c63553457.atkcon)
	e3:SetTarget(c63553457.atktg)
	c:RegisterEffect(e3)
	--nuke field
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(63553457,0))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c63553457.nukecon)
	e5:SetCost(c63553457.nukecost)
	e5:SetTarget(c63553457.nuketg)
	e5:SetOperation(c63553457.nukeop)
	c:RegisterEffect(e5)
	--switch position
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(63553457,1))
	e6:SetCategory(CATEGORY_POSITION+CATEGORY_DRAW)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetCountLimit(1)
	e6:SetCost(aux.bfgcost)
	e6:SetTarget(c63553457.postg)
	e6:SetOperation(c63553457.posop)
	c:RegisterEffect(e6)
	--track counters
	local ge0=Effect.CreateEffect(c)
	ge0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	ge0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
	ge0:SetCode(EVENT_ADD_COUNTER+0x4554)
	ge0:SetRange(LOCATION_SZONE)
	ge0:SetLabelObject(e5)
	ge0:SetOperation(c63553457.ctcop)
	c:RegisterEffect(ge0)
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_PHASE+PHASE_DRAW)
	ge1:SetCountLimit(1)
	ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	ge1:SetRange(LOCATION_SZONE)
	ge1:SetLabelObject(ge0)
	ge1:SetOperation(c63553457.trackop)
	c:RegisterEffect(ge1)
	local ge2=Effect.CreateEffect(c)
	ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge2:SetCode(EVENT_PHASE+PHASE_END)
	ge2:SetCountLimit(1)
	ge2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	ge2:SetRange(LOCATION_SZONE)
	ge2:SetLabelObject(ge0)
	ge2:SetOperation(c63553457.trackreset)
	c:RegisterEffect(ge2)
end
--global check: track counters
function c63553457.ctcop(e,tp,eg,ep,ev,re,r,rp)
	local count=e:GetLabel()-e:GetHandler():GetCounter(0x1554)
	if e:GetLabel()<e:GetHandler():GetCounter(0x1554) and count<=-4 then
		e:GetLabelObject():SetLabel(100)
	end
end
function c63553457.trackop(e,tp)
	local ct=e:GetHandler():GetCounter(0x1554)
	e:GetLabelObject():SetLabel(ct)
end
function c63553457.trackreset(e,tp)
	e:GetLabelObject():SetLabel(0)
	e:GetLabelObject():GetLabelObject():SetLabel(0)
end
--filters
function c63553457.ctfilter(c)
	return c:GetCounter(0x1554)>0
end
function c63553457.posfilter(c)
	return c:IsCanChangePosition()
end
--counter
function c63553457.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c63553457.ctop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()~=tp then return end
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if e:GetHandler():GetCounter(0x1554)>=12 then return end
	local g=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if g>12-e:GetHandler():GetCounter(0x1554) then g=12-e:GetHandler():GetCounter(0x1554) end
	e:GetHandler():AddCounter(0x1554,g)
end
--direct attack
function c63553457.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x1554)>=10
end
function c63553457.atktg(e,c)
	return c:IsFaceup()
end
--nuke field
function c63553457.nukecon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()~=100
		and Duel.GetTurnPlayer()==tp
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function c63553457.nukecost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetCounter(0x1554)>=10 end
	c:RemoveCounter(tp,0x1554,10,REASON_COST)
end
function c63553457.nuketg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
function c63553457.nukeop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.Destroy(sg,REASON_EFFECT)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e2,tp)
end
--switch position
function c63553457.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c63553457.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local ft=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	local sum=0
	for tc in aux.Next(g) do
		local ctct=tc:GetCounter(0x1554)
		sum=sum+ctct
	end
	if sum>ft then
		sum=ft
	end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and sum>0 and Duel.IsExistingMatchingCard(c63553457.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,sum,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c63553457.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c63553457.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local ft=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	local sum=0
	for tc in aux.Next(g) do
		local ctct=tc:GetCounter(0x1554)
		sum=sum+ctct
	end
	if sum<=0 then return end
	if sum>ft then
		sum=ft
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c63553457.posfilter,tp,0,LOCATION_MZONE,sum,sum,nil)
	if g:GetCount()>0 then
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end