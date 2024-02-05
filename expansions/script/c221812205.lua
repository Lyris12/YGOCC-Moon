--[[
Viravolve Doom
Viravolve Destino
Original Script by: Lyris
Rescripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--counter
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.addct)
	e1:SetOperation(s.addc)
	c:RegisterEffect(e1)
	--destroy replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(s.desreptg)
	e4:SetOperation(s.desrepop)
	c:RegisterEffect(e4)
	--place counter on xyz
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_BE_MATERIAL)
	e5:SetCondition(s.efcon)
	e5:SetOperation(s.efop)
	c:RegisterEffect(e5)
	--damage
	aux.AddViravolveDamageEffect(c,id)
end
--E0
function s.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,e:GetHandler(),1,0,0x1c8c)
end
function s.addc(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		c:AddCounter(0x1c8c,1)
	end
end
--E4
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=Duel.GetBattleMonster(1-tp)
	if chk==0 then return bc and c:IsReason(REASON_BATTLE) and c:GetReasonCard()==bc and not c:IsReason(REASON_REPLACE) and c:IsCanRemoveCounter(tp,0x1c8c,1,REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	local ct=c:GetCounter(0x1c8c)
	if c:RemoveCounter(tp,0x1c8c,1,REASON_EFFECT) and ct>c:GetCounter(0x1c8c) then
		local bc=Duel.GetBattleMonster(1-tp)
		if bc then
			Duel.Destroy(bc,REASON_EFFECT)
		end
	end
end
--E5
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ and e:GetHandler():GetReasonCard():IsRace(RACE_CYBERSE)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if rc:IsCanAddCounter(0x1c8c,1) and rc:IsFaceup() and Duel.SelectYesNo(rc:GetControler(),STRING_ASK_PLACE_COUNTER) then
		rc:AddCounter(0x1c8c,1)
	end
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetTarget(s.reptg)
	e1:SetOperation(s.repop)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetBattleTarget() and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,id) and c:IsReason(REASON_BATTLE) and c:IsCanRemoveCounter(tp,0x1c8c,1,REASON_EFFECT) end
	return true
end
function s.repop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	local ct=c:GetCounter(0x1c8c)
	if c:RemoveCounter(tp,0x1c8c,1,REASON_EFFECT) and ct>c:GetCounter(0x1c8c) then
		local bc=c:GetBattleTarget()
		if bc then
			Duel.Destroy(bc,REASON_EFFECT)
		end
	end
end