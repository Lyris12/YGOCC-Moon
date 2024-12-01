--[[
CODEWOMAN: Machthena
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT(true)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--effect gain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(s.efcon)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
end
--E1
function s.atkcheck(c)
	return not c:IsAttack(c:GetBaseAttack())
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,RACE_MACHINE),tp,LOCATION_MZONE,0,nil)
	return #g>=2 and g:IsExists(s.atkcheck,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	Duel.SpecialSummonRedirect(e,c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end

--E2
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return rc and rc:IsSetCard(ARCHE_CODE_JAKE) and rc:IsPreviousLocation(LOCATION_EXTRA)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	rc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,1)
	e1:SetCategory(CATEGORY_DISABLE|CATEGORY_DESTROY|CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.discon)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1)
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
function s.tfilter(c,tp)
	return c:IsFaceup() and c:IsOnField() and c:IsSetCard(ARCHE_CODE_JAKE) and c:IsControler(tp)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainDisablable(ev) or not aux.ExceptOnDamageCalc() then return false end
	if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		local tg1=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		if tg1 and tg1:IsExists(s.tfilter,1,nil,tp) then
			return true
		end
	end
	if re:IsHasCategory(CATEGORY_NEGATE) and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then
		return false
	end
	local ex,tg2,ct=Duel.GetOperationInfo(ev,CATEGORY_REMOVE)
	return ex and tg2 and (ct+tg2:FilterCount(s.tfilter,nil,tp)-#tg2)>0
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToChain(ev) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		local c=e:GetHandler()
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,0,0,1000)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		if c:IsRelateToChain() and c:IsFaceup() then
			c:UpdateATK(1000,RESET_PHASE|PHASE_END,c)
		end
	end
end