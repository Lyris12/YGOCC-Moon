--Unnamed thing
--Automate s_id

local scard,s_id=GetID()

function scard.initial_effect(c)
	c:SetUniqueOnField(1,0,s_id)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:IsSetCard(0x7d0) or (tc:GetCode()>30200 and tc:GetCode()<30230) end)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--non-activated effects
	local e1x=Effect.CreateEffect(c)
	e1x:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1x:SetProperty(EFFECT_FLAG_DELAY)
	e1x:SetCode(EVENT_TO_GRAVE)
	e1x:SetRange(LOCATION_SZONE)
	e1x:SetCondition(scard.notactcon)
	e1x:SetOperation(scard.op1)
	c:RegisterEffect(e1x)
	--activated effects (register sent cards)
	local e1y=Effect.CreateEffect(c)
	e1y:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1y:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1y:SetCode(EVENT_TO_GRAVE)
	e1y:SetRange(LOCATION_SZONE)
	e1y:SetCondition(scard.regcon)
	e1y:SetOperation(scard.regop)
	c:RegisterEffect(e1y)
	--activated effects (execute operation)
	local e1z=Effect.CreateEffect(c)
	e1z:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1z:SetCode(EVENT_CHAIN_SOLVED)
	e1z:SetRange(LOCATION_SZONE)
	e1z:SetCondition(scard.actcon)
	e1z:SetOperation(scard.op2)
	c:RegisterEffect(e1z)
end
function scard.drawfilter(c,tp,re,r)
	if not c:IsReason(r) then return false end
	local rc=re:GetHandler()
	return rc and rc:IsMantra() and re:IsActiveType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_HAND) and c:GetPreviousControler()==tp and c:IsType(TYPE_MONSTER) and c:IsMantra()
end
function scard.notactcon(e,tp,eg,ep,ev,re,r,rp)
	return re and (not re:IsHasType(EFFECT_TYPE_ACTIONS) or re:IsHasType(EFFECT_TYPE_CONTINUOUS)) and eg:IsExists(scard.drawfilter,1,nil,tp,re,REASON_EFFECT|REASON_COST)
end
function scard.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_HAND,nil)
	if #g<=0 then return end
	local ct=eg:FilterCount(scard.drawfilter,nil,tp,re,REASON_EFFECT)
	if ct<=0 then return end
	Duel.Hint(HINT_CARD,tp,s_id)
	local n=math.min(#g,ct)
	local sg=g:Select(1-tp,n,n,nil)
	if #sg>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end

function scard.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsHasType(EFFECT_TYPE_ACTIONS) and not re:IsHasType(EFFECT_TYPE_CONTINUOUS) and eg:IsExists(scard.drawfilter,1,nil,tp,re,REASON_EFFECT|REASON_COST)
end
function scard.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(scard.drawfilter,nil,tp,re,REASON_EFFECT|REASON_COST)
	if ct<=0 then return end
	if not Duel.PlayerHasFlagEffect(tp,s_id) then
		Duel.RegisterFlagEffect(tp,s_id,RESET_CHAIN,0,1,0)
	end
	Duel.UpdateFlagEffectLabel(tp,s_id,ct)
end

function scard.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.PlayerHasFlagEffect(tp,s_id) and Duel.GetFlagEffectLabel(tp,s_id)>0
end
function scard.op2(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFlagEffectLabel(tp,s_id)
	Duel.ResetFlagEffect(tp,s_id)
	if not ct or ct<=0 then return end
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_HAND,nil,REASON_EFFECT)
	if #g<=0 then return end
	Duel.Hint(HINT_CARD,tp,s_id)
	local n=math.min(#g,ct)
	local sg=g:Select(1-tp,n,n,nil)
	if #sg>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
