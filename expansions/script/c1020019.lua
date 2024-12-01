--[[
Galactic CODEMAN: Tuning Zero
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id+100
	else
		s.progressive_id=s.progressive_id+1
	end
	c:EnableReviveLimit()
	aux.EnablePendulumAttribute(c,false)
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,ARCHE_CODEMAN),s.mfilter,1,1)
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
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,{EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS},s.evfilter,id,LOCATION_PZONE,nil,LOCATION_PZONE,nil,id+100)
	local p2=Effect.CreateEffect(c)
	p2:SetDescription(id,0)
	p2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	p2:SetProperty(EFFECT_FLAG_DELAY)
	p2:SetCode(EVENT_CUSTOM+s.progressive_id)
	p2:SetRange(LOCATION_PZONE)
	p2:OPT()
	p2:SetTarget(s.rktg)
	p2:SetOperation(s.rkop)
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
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCountLimit(1)
	e2:SetTarget(s.indes)
	e2:SetValue(s.indesval)
	c:RegisterEffect(e2)
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
function s.mfilter(c)
	return c:IsLevel(7) and c:IsRace(RACE_MACHINE) and not c:IsAttack(c:GetBaseAttack())
end

--P1
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,ARCHE_CODEMAN),tp,LOCATION_MZONE,0,1,nil)
end
function s.distg(e,c)
	return c:IsType(TYPE_SYNCHRO) and (c:IsType(TYPE_EFFECT) or c:IsOriginalType(TYPE_EFFECT))
end

--P2
function s.evfilter(c,_,tp)
	return c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_HAND)
end
function s.tgcheck(c)
	return c:IsFaceup() and c:HasLevel()
end
function s.rktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,ARCHE_CODE_JAKE),tp,LOCATION_MZONE,0,nil)
	local g=eg:Filter(s.tgcheck,nil,e)
	if chk==0 then return ct>0 and #g>0 end
	local tg=aux.SelectSimultaneousEventGroup(g,tp,id+100,1,e)
	local b1=tg:IsExists(Card.IsLevelAbove,1,nil,1)
	local opt=aux.Option(tp,id,1,b1,true)==0 and -1 or 1
	Duel.SetTargetCard(tg)
	Duel.SetTargetParam(opt)
end
function s.rkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opt=Duel.GetTargetParam()
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,ARCHE_CODE_JAKE),tp,LOCATION_MZONE,0,nil)*opt
	if ct==0 then return end
	local dg=Duel.GetTargetCards():Filter(aux.FaceupFilter(Card.HasLevel),nil)
	if #dg==0 then return end
	for tc in aux.Next(dg) do
		tc:UpdateLevel(ct,true,{c,true})
	end
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
function s.indesval(e,re,r,rp)
	return r&(REASON_BATTLE|REASON_EFFECT)>0
end
function s.indes(e,c)
	if not (c~=e:GetHandler() and c:IsSetCard(ARCHE_CODEMAN) and c:IsAttackPos()) then return false end
	if c:IsReason(REASON_BATTLE) then
		return true
	else
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		return not g or not g:IsContains(c)
	end
end

--E4
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsFaceup()
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
