--[[
Galactic CODEMAN: Overlay Zero
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+2
	end
	c:EnableReviveLimit()
	aux.EnablePendulumAttribute(c,false)
	aux.AddXyzProcedureLevelFree(c,s.mfilter,s.xyzcheck,2,2)
	aux.AddXyzProcedure(c,s.xyzmaterial,7,2)
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
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,EVENT_SPSUMMON_SUCCESS,s.evfilter,id,LOCATION_PZONE,nil,LOCATION_PZONE,nil,id+100)
	local p2=Effect.CreateEffect(c)
	p2:SetDescription(id,0)
	p2:SetCategory(CATEGORY_DESTROY)
	p2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	p2:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
	p2:SetCode(EVENT_CUSTOM+s.progressive_id)
	p2:SetRange(LOCATION_PZONE)
	p2:HOPT()
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
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id+1,EVENT_SPSUMMON_SUCCESS,s.evfilter2,id+200,LOCATION_MZONE,nil,LOCATION_MZONE,nil,id+300)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DISABLE|CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+s.progressive_id+1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(aux.DummyCost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	--pendulum place
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.pencon)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
end
s.pendulum_level=7

function s.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_MONSTER) and c:IsXyzLevel(xyzc,7) and c:IsRace(RACE_MACHINE)
end
function s.xyzcheck(g)
	return g:IsExists(s.atkcheck,1,nil)
end
function s.atkcheck(c)
	return not c:IsAttack(c:GetBaseAttack())
end

--P1
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,ARCHE_CODEMAN),tp,LOCATION_MZONE,0,1,nil)
end
function s.distg(e,c)
	return c:IsType(TYPE_XYZ) and (c:IsType(TYPE_EFFECT) or c:IsOriginalType(TYPE_EFFECT))
end

--P2
function s.evfilter(c,_,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.tgcheck(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRankAbove(1) and c:GetOverlayCount()>0 and c:IsCanBeEffectTarget(e)
end
function s.deschk(c)
	return c:GetRank()-c:GetOverlayCount()<=0
end
function s.rktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=eg:Filter(s.tgcheck,nil,e)
	if chk==0 then return #g>0 end
	local tg=aux.SelectSimultaneousEventGroup(g,tp,id+100,1,e,nil,nil,true)
	Duel.SetTargetCard(tg)
	local dg=tg:Filter(s.deschk,nil)
	if #dg>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
	else
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_MZONE)
	end
end
function s.rkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dg=Duel.GetTargetCards():Filter(Card.IsFaceup,nil)
	local tg=Group.CreateGroup()
	for tc in aux.Next(dg) do
		local ct=tc:GetOverlayCount()
		if ct>0 then
			local prerank=tc:GetRank()
			local e1,diff=tc:UpdateRank(-ct,true,{c,true})
			if not tc:IsImmuneToEffect(e1) and prerank>0 and prerank-ct<=0 and diff<=0 and tc:IsRank(1) then
				tg:AddCard(tc)
			end
		end
	end
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
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
function s.evfilter2(c,_,tp)
	return c:IsFaceup() and c:IsSummonPlayer(1-tp) and c:IsAttackAbove(2500)
end
function s.disfilter2(c,tp)
	return aux.NegateMonsterFilter(c) and c:IsSetCard(ARCHE_CODEMAN) and c:IsAttackAbove(1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.disfilter2,tp,LOCATION_MZONE,0,c)
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tg=g:Select(tp,1,1,nil)
	Duel.HintSelection(tg)
	local tc=tg:GetFirst()
	local _,_,res=Duel.Negate(tc,e,0,false,true,TYPE_MONSTER,nil,EFFECT_FLAG_IGNORE_IMMUNE)
	
	local e1,oatk,natk,diff=tc:ChangeATK(0,true,{c,true},nil,nil,EFFECT_FLAG_IGNORE_IMMUNE)
	if res and natk==0 and diff~=0 then
		Duel.SetTargetParam(math.abs(diff))
	else
		Duel.SetTargetParam(0)
	end
	local sg=aux.SelectSimultaneousEventGroup(eg,tp,id+300,1,e,id+400)
	Duel.SetTargetCard(sg)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local val=Duel.GetTargetParam()
	if val==0 then return end
	local c=e:GetHandler()
	local g=Duel.GetTargetCards():Filter(Card.IsFaceup,nil)
	local ng=Group.CreateGroup()
	for tc in aux.Next(g) do
		local preatk=tc:GetAttack()
		local e1,diff=tc:UpdateATK(-val,true,{c,true})
		if not tc:IsImmuneToEffect(e1) and preatk>0 and tc:IsAttack(0) and diff<=0 and aux.NegateMonsterFilter(tc) and tc:IsCanBeDisabledByEffect(e,true) then
			ng:AddCard(tc)
		end
	end
	if #ng>0 then
		Duel.Negate(ng,e,0,false,false,TYPE_MONSTER)
	end
end

--E3
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsFaceup()
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
