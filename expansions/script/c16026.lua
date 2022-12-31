--Paracyclis Counterswipe
--incomplete implementation
--Automate ID
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate1)
	e1:SetLabel(1)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetLabel(2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
function s.tgfilter(c)
	return c:IsSetCard(0x308) and c:IsDiscardable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.tgfilter,1,1,REASON_COST,nil)
end
function s.filter(c,tp,typ)
	return c:GetSummonPlayer()~=tp and c:GetSummonLocation()&LOCATION_EXTRA~=0
		and c:IsAbleToDeck() and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsType(typ)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local n=e:GetLabel()
	if n==1 then
		typ=TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_PENDULUM
	elseif n==2 then
		typ=TYPE_LINK+TYPE_EVOLUTE
	else
		return
	end
	local g=eg:Filter(s.filter,nil,tp,typ)
	local ct=g:GetCount()
	if chk==0 then return ct>0 and (n~=1 or Duel.IsPlayerCanDraw(tp,1)) end
	if n==1 then
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(1)
		e:SetCategory(CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end

function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.filter,nil,tp,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_PENDULUM)
	if #g>0 then
		if Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)~=0 then
			Duel.BreakEffect()
			local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
			Duel.Draw(p,d,REASON_EFFECT)
		end
	end
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.filter,nil,tp,TYPE_LINK+TYPE_EVOLUTE)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_MUST_USE_MZONE)
		e1:SetTargetRange(0xff,0xff)
		e1:SetValue(s.frcval(tc:GetCode(),tc:GetSequence()))
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,1-tp)
	end
	Duel.SendtoGrave(g,nil,REASON_EFFECT)
end
function s.frcval(code,seq)
	return function(e,c,fp,rp,r)
		local zone=1
		if seq>0 then zone=bit.lshift(zone,seq) end
		if rp==e:GetHandlerPlayer() and c:IsCode(code) then return ~zone else return false end
	end
end
function s.handfilter(e)
	return e:IsSetCard(0x308) and e:IsFaceup()
end
function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	return #Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)<#Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
end
