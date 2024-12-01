--[[
Galactic CODEMAN: Fused Zero
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.EnablePendulumAttribute(c,false)
	aux.AddFusionProcFunFunRep(c,s.ffilter,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),2,2,true)
	--control only 1
	c:SetUniqueOnField(1,0,id,LOCATION_MZONE)
	--negate
	local p1=Effect.CreateEffect(c)
	p1:SetType(EFFECT_TYPE_FIELD)
	p1:SetCode(EFFECT_DISABLE)
	p1:SetRange(LOCATION_PZONE)
	p1:SetTargetRange(0,LOCATION_MZONE)
	p1:SetCondition(s.discon)
	p1:SetTarget(s.distg)
	c:RegisterEffect(p1)
	--rank
	local p2=Effect.CreateEffect(c)
	p2:SetDescription(id,0)
	p2:SetType(EFFECT_TYPE_IGNITION)
	p2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	p2:SetRange(LOCATION_PZONE)
	p2:HOPT()
	p2:SetCondition(s.condition)
	p2:SetTarget(s.target)
	p2:SetOperation(s.operation)
	c:RegisterEffect(p2)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(s.actval)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
	--atk 2
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT(true)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	--pendulum place
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,3)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.pencon)
	e4:SetTarget(s.pentg)
	e4:SetOperation(s.penop)
	c:RegisterEffect(e4)
end
function s.ffilter(c)
	return c:IsFusionSetCard(ARCHE_CODEMAN) and not c:IsAttack(c:GetBaseAttack())
end

--P1
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,ARCHE_CODEMAN),tp,LOCATION_MZONE,0,1,nil)
end
function s.distg(e,c)
	return c:IsType(TYPE_FUSION) and (c:IsType(TYPE_EFFECT) or c:IsOriginalType(TYPE_EFFECT))
end

--P2
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_CODE_JAKE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
		--extra atk
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		--cannot activate
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ATTACK_ANNOUNCE)
		e1:SetOperation(s.inop)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.inop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end

--E1
function s.val(e)
	local base=e:GetHandler():GetBaseAttack()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if #g==0 then return 0 end
	local _,atk=g:GetMinGroup(Card.GetAttack)
	return math.floor(0.5 + math.abs(base-atk)/2)
end

--E2
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	local g=Group.CreateGroup()
	if Duel.GetAttacker() then g:AddCard(Duel.GetAttacker()) end
	if Duel.GetAttackTarget() then g:AddCard(Duel.GetAttackTarget()) end
	return #g>0 and g:IsExists(aux.AND(Card.IsSetCard,Card.IsFaceup),1,nil,ARCHE_CODEMAN)
end
function s.actval(e,re)
	return re:GetHandler()~=e:GetHandler()
end

--E3
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=eg:GetFirst()
	return rc:IsRelateToBattle() and rc:IsStatus(STATUS_OPPO_BATTLE)
		and rc:IsFaceup() and rc:IsSetCard(ARCHE_CODEMAN) and rc:IsControler(tp)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsFaceup() and chkc:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c~=chkc end
	local tc=eg:GetFirst():GetBattleTarget()
	local val=tc:GetAttack()
	if chk==0 then return val>0 and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,c)
	tc:CreateEffectRelation(e)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0,math.floor(0.5+val/2))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() then
		local des=eg:GetFirst()
		if des:IsRelateToEffect(e) then
			local val=math.floor(0.5+des:GetAttack()/2)
			if val>0 then
				tc:UpdateATK(val,RESET_PHASE|PHASE_END,{e:GetHandler(),true})
			end
		end
	end
end

--E4
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
	local c=e:GetHandler()
	if c:IsInGY() then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
	end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
