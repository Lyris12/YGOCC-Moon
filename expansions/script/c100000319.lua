--[[
Might of the Invernal
Forza degli Invernali
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--You can only control 1 "Sceluspecter Phantom Barrier".
	c:CanOnlyControlOne(id)
	--Activation
	c:Activation(true)
	--[[You can Normal Summon "Invernal" monsters without Tributing, but they cannot attack during the turn they are Summoned this way.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetCondition(s.ntcon)
	e2:SetTarget(s.nttg)
	e2:SetOperation(s.ntop)
	c:RegisterEffect(e2)
	--[[DARK "Number" Xyz Monsters you control in Attack Position cannot be destroyed by battle while they have material.]]
	c:CannotBeDestroyedByBattleField(1,LOCATION_SZONE,LOCATION_MZONE,0,s.target)
	--[[Each time an "Invernal" monster you control is destroyed by battle, immediately destroy 1 card your opponent controls.]]
	aux.RegisterMaxxCEffect(c,id,nil,LOCATION_SZONE,EVENT_BATTLE_DESTROYED,s.descon,s.desopOUT,s.desopIN)
end
--E1
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsSetCard(ARCHE_INVERNAL)
end
function s.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	c:CannotAttack(1,RESET_EVENT|RESETS_STANDARD_TOFIELD|RESET_PHASE|PHASE_END,c,nil,EFFECT_FLAG_IGNORE_IMMUNE)
end

--E2
function s.target(e,c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttackPos() and c:GetOverlayCount()>0
end

--E3
function s.cfilter(c,tp)
	return c:IsPreviousSetCard(ARCHE_INVERNAL) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.desopOUT(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if #g>0 then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.HintMessage(tp,HINTMSG_DESTROY)
		local tg=g:Select(tp,1,1,nil)
		Duel.HintSelection(tg)
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
function s.desopIN(e,tp,eg,ep,ev,re,r,rp,n)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if #g>0 then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.HintMessage(tp,HINTMSG_DESTROY)
		local ct=math.min(#g,n)
		local tg=g:Select(tp,ct,ct,nil)
		Duel.HintSelection(tg)
		Duel.Destroy(tg,REASON_EFFECT)
	end
end