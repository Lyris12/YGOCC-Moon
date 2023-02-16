--Brush with the Deptheavens
local ref,id=GetID()
Duel.LoadScript("Deptheaven.lua")
function ref.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetCondition(ref.actcon)
	e1:SetCost(ref.actcost)
	e1:SetTarget(ref.acttg)
	e1:SetOperation(ref.actop)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,ref.chainfilter)
	--Recurr
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCondition(ref.setcon)
	e2:SetTarget(ref.settg)
	e2:SetOperation(ref.setop)
	c:RegisterEffect(e2)
end
function ref.chainfilter(re,tp,cid)
	local rc=re:GetHandler()
	local loc=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)
	return not (re:IsActiveType(TYPE_MONSTER) and not rc:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_WATER)) --rc:IsRace(RACE_FAIRY+RACE_FISH+RACE_WYRM))
end
function ref.actcon(e,tp,eg,ep,ev,re,r,rp)
	local szones=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_SZONE) then szones=szones+1 end
	return not (e:IsHasType(EFFECT_TYPE_ACTIVATE) and szones<3
		and (szones<2 or Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_TOFIELD,Deptheaven.LeftRightZones)<1))
end
function ref.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetValue(ref.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function ref.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not rc:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_WATER)
end
function ref.pfilter(c) return c:IsType(TYPE_PENDULUM) and Deptheaven.Is(c) and not (c:IsForbidden() or c:IsCode(id)) end
function ref.setfilter(c) return Deptheaven.Is(c) and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable() and not c:IsCode(id) end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function ref.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,ref.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SSet(tp,g) and Deptheaven.LeftRightCheck(g:GetFirst())
	and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
	and Duel.IsExistingMatchingCard(ref.pfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local pc=Duel.SelectMatchingCard(tp,ref.pfilter,tp,LOCATION_DECK,0,1,1,nil)
		Duel.MoveToField(pc:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function ref.actopold(e,tp,eg,ep,ev,re,r,rp)
	if not ((Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(ref.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)) then return false end
	local no=aux.SequenceToGlobal(tp,LOCATION_SZONE,1)+aux.SequenceToGlobal(tp,LOCATION_SZONE,2)+aux.SequenceToGlobal(tp,LOCATION_SZONE,3)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sc=Duel.SelectMatchingCard(tp,ref.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if Duel.MoveToField(sc:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEDOWN,true,Deptheaven.LeftRightZones) then
		Duel.RaiseEvent(sc:GetFirst(),EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
		Duel.SSet(tp,sc:GetFirst())
		Duel.ConfirmCards(1-tp,sc)
		if (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and Duel.IsExistingMatchingCard(ref.pfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local pc=Duel.SelectMatchingCard(tp,ref.pfilter,tp,LOCATION_DECK,0,1,1,nil)
			Duel.MoveToField(pc:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end

--Recurr
function ref.setcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,0,1,nil)
end
function ref.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():IsSSetable()
	end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function ref.setop(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.GetLocationCount(tp,LOCATION_SZONE)>0) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then Duel.SSet(tp,c) end
end
