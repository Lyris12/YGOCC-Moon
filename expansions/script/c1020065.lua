--Divinità Bushido Fenice Evoluta Speranzosa
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c,false)
	c:SetUniqueOnField(id,1,0)
	c:EnableReviveLimit()
	c:MustBeSSedByOwnProcedure()
	--multitype
	local r1=Effect.CreateEffect(c)
	r1:SetType(EFFECT_TYPE_SINGLE)
	r1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	r1:SetCode(EFFECT_ORIGINAL_LEVEL_RANK_DUALITY)
	c:RegisterEffect(r1)
	local r2=Effect.CreateEffect(c)
	r2:SetType(EFFECT_TYPE_SINGLE)
	r2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	r2:SetCode(EFFECT_XYZ_LEVEL)
	r2:SetValue(s.constantlyupdate)
	c:RegisterEffect(r2)
	local r3=r2:Clone()
	r3:SetCode(EFFECT_ALLOW_SYNCHRO_KOISHI)
	r3:SetValue(0)
	c:RegisterEffect(r3)
	--ssproc
	local e0=Effect.CreateEffect(c)
	e0:Desc(0)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.hspcon)
	e0:SetTarget(s.hsptg)
	e0:SetOperation(s.hspop)
	c:RegisterEffect(e0)
	--pendulum effect
	c:SummonedFieldTrigger(s.cfilter,false,false,true,false,1,CATEGORY_SPECIAL_SUMMON,nil,LOCATION_PZONE,true,
		nil,
		s.spcost,
		aux.SSTarget(SUBJECT_THIS_CARD,nil,nil,nil,nil,nil,nil,true),
		aux.SSOperation(SUBJECT_THIS_CARD,nil,nil,nil,nil,nil,nil,nil,true)
	)
	--protection
	c:UnaffectedProtection(PROTECTION_FROM_OPPONENT)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.discon)
	e1:SetCost(aux.ToDeckCost(s.costfilter,LOCATION_REMOVED))
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--slifer
	c:SummonedFieldTrigger(s.cfilter2,true,false,true,false,3,CATEGORY_ATKCHANGE,true,LOCATION_MZONE,nil,
		nil,
		nil,
		s.slitg,
		s.sliop
	)
	--pendulum
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,4))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DDD)
	e4:SetCondition(s.pencon)
	e4:SetTarget(s.pentg)
	e4:SetOperation(s.penop)
	c:RegisterEffect(e4)
end
function s.constantlyupdate(e,c)
	return c:GetRank()
end

function s.hspfilter(c,e,tp)
	return c:NotOnFieldOrFaceup() and c:IsSetCard(0x14b0) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and c:IsAbleToRemoveAsCost()
end
function s.check(g,tp)
	return Duel.GetMZoneCount(tp,g)>0 and g:GetClassCount(function(c) return c:GetType()&(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) end)==#g
end
function s.hspcon(e,c)
	if c==nil then return true end
	if c:IsFaceup() then return false end
	local tp=c:GetControler()
	local g=Duel.Group(s.hspfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	return #g>2 and g:CheckSubGroup(s.check,3,3,tp)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.Group(s.hspfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	local mg1=g:SelectSubGroup(tp,s.check,true,3,3,tp)
	if mg1 and #mg1==3 then
		mg1:KeepAlive()
		e:SetLabelObject(mg1)
		return true
	end
	return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_MATERIAL)
	g:DeleteGroup()
end

function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsAttackAbove(3000) and c:GetSummonPlayer()==1-tp
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(Card.IsFaceup,tp,LOCATION_ONFIELD,0,c)
	if chk==0 then return #g>=3 and not g:IsExists(aux.NOT(Card.IsAbleToRemoveAsCost),1,nil) end
	local sg=g:Filter(Card.IsAbleToRemoveAsCost,nil)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL) and Duel.IsChainNegatable(ev)
end
function s.costfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(0x4b0)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToChain(ev) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,LOCATION_MZONE,eg:GetFirst():GetBaseAttack())
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev)
		and Duel.Destroy(eg,REASON_EFFECT)>0 and c:IsRelateToChain() and c:IsFaceup() then
		c:UpdateATK(eg:GetFirst():GetBaseAttack(),true)
	end
end

function s.cfilter2(c,_,tp)
	return c:IsFaceup() and c:GetSummonPlayer()==1-tp
end
function s.slitg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToChain() end
	Duel.SetTargetCard(eg:Filter(s.cfilter2,nil,nil,tp))
end
function s.sliop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards():Filter(Card.IsFaceup,nil)
	if #g==0 then return end
	local dg=Group.CreateGroup()
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		local preatk=tc:GetAttack()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if preatk~=0 and tc:GetAttack()==0 then dg:AddCard(tc) end
	end
	if #dg==0 then return end
	Duel.BreakEffect()
	Duel.Destroy(dg,REASON_EFFECT)
end

function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if #g>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
	if e:GetHandler():IsRelateToChain() and Duel.CheckPendulumZones(tp) then
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end