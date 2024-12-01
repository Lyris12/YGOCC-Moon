--[[
Coded-Eyes Warfare Dragon
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,s.ffilter,s.xyzcheck,2,2)
	--attach
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetCustomCategory(CATEGORY_ATTACH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT(true)
	e1:SetCondition(aux.XyzSummonedCond)
	e1:SetTarget(s.xyztg)
	e1:SetOperation(s.xyzop)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT(true)
	e2:SetCost(aux.DetachSelfCost())
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT(true)
	e3:SetCondition(s.atkcon)
	e3:SetCost(aux.DetachSelfCost())
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
function s.ffilter(c,xyzc)
	return c:IsXyzType(TYPE_MONSTER) and c:IsSetCard(ARCHE_CODE_JAKE) and c:IsXyzLevel(xyzc,7)
end
function s.xyzcheckfilter(c)
	return c:IsXyzType(TYPE_MONSTER) and c:IsSetCard(ARCHE_CODED_EYES)
end
function s.xyzcheck(g)
	return g:IsExists(s.xyzcheckfilter,1,nil)
end

--E1
function s.xyzfilter(c,xyzc,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(ARCHE_CODE_JAKE) and c:IsCanBeAttachedTo(xyzc,e,tp,REASON_EFFECT)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_GRAVE,0,1,nil,c,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,nil,1,tp,LOCATION_GRAVE,c)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsType(TYPE_XYZ) or not c:IsRelateToChain() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.xyzfilter),tp,LOCATION_GRAVE,0,1,1,nil,c,e,tp)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Attach(g,c,false,e,REASON_EFFECT,tp)
	end
end

--E2
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xded)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,0,c)
	if chk==0 then return ct>0 and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,ct,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

--E3
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a,d=Duel.GetBattleMonsters(tp)
	return a and d and a~=e:GetHandler() and a:IsFaceup() and a:IsSetCard(ARCHE_CODE_JAKE) and a:IsRelateToBattle() and d:IsFaceup() and d:IsRelateToBattle()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local a=Duel.GetBattleMonster(tp)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,a,1,0,0,-2,OPINFO_FLAG_HALVE)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetBattleMonster(tp)
	if a and a:IsFaceup() and a:IsSetCard(ARCHE_CODE_JAKE) and a:IsRelateToBattle() then
		local c=e:GetHandler()
		local e1=a:HalveATK(true,{c,true})
		if not a:IsImmuneToEffect(e1) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
			a:RegisterEffect(e1)
		end
	end
end