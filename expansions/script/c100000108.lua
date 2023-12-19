--Aeonstrider Warden - Janus
--Custode Marciaeoni - Janus
--Scripted by: XGlitchy30

local s,id,o=GetID()
Duel.LoadScript("glitchylib_helper.lua")
Duel.LoadScript("glitchylib_aeonstride.lua")
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,7,s.TLcon,s.TLmaterial,{s.TLop,s.TLval})
	aux.SpawnGlitchyHelper(GLITCHY_HELPER_TURN_COUNT_FLAG)
	aux.RaiseAeonstrideEndOfTurnEvent(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	--[[Cannot be targeted or destroyed by your opponent's card effects.]]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetValue(aux.tgoval)
	c:RegisterEffect(e0)
	local e0x=Effect.CreateEffect(c)
	e0x:SetType(EFFECT_TYPE_SINGLE)
	e0x:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0x:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e0x:SetRange(LOCATION_MZONE)
	e0x:SetValue(s.indval)
	c:RegisterEffect(e0x)
	--[[ Once per turn, if this card is Time Leap Summoned, or the Turn Count moves forwards: You can target 1 card on the field; banish it until your next End Phase.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:OPT(true)
	e1:SetFunctions(aux.TimeleapSummonedCond,nil,s.rmtg,s.rmop)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1x:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e1x:SetCode(EVENT_TURN_COUNT_MOVED)
	e1x:SetRange(LOCATION_MZONE)
	e1x:SetCondition(s.rmcon)
	c:RegisterEffect(e1x)
	aux.RegisterTurnCountTriggerEffectFlag(c,e1x)
	--[[Once per turn (Quick Effect): You can move the Turn Count forwards by 1 turn, and if you do,
	all monsters your opponent currently controls lose ATK/DEF equal to the current Turn Count x 100, until the end of the turn.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORIES_ATKDEF)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:OPT()
	e3:SetRelevantTimings(TIMING_DAMAGE_STEP)
	e3:SetCondition(aux.ExceptOnDamageCalc)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end

--PROC
function s.TLcon(e,c)
	return Duel.GetTurnCount(nil,true)>=3
end
function s.TLmaterial(c,e)
	return c:IsSetCard(ARCHE_AEONSTRIDE)
end
function s.TLval(c,e,tp)
	if c:IsMonster(TYPE_PENDULUM) then
		return c:IsAbleToExtra()
	else
		return c:IsAbleToRemove()
	end
end
function s.TLop(e,tp,eg,ep,ev,re,r,rp,c,g)
	local pg=g:Filter(Card.IsType,nil,TYPE_PENDULUM)
	if #pg>0 then
		g:Sub(pg)
		Duel.SendtoExtraP(pg,nil,REASON_MATERIAL|REASON_TIMELEAP)
	end
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP)
	end
	aux.TimeleapHOPT(tp)
end

--E1
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if aux.TurnCountMovedDueToTurnEnd then
		return r&REASON_RULE==0
	else
		return ev>0
	end
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	if chk==0 then
		return Duel.IsExists(true,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	local g=Duel.Select(HINTMSG_REMOVE,true,tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_REMOVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		Duel.BanishUntil(tc,e,tp,nil,PHASE_END|RESET_SELF_TURN,id,1,true,e:GetHandler(),REASON_EFFECT)
	end
end

--FILTERS E2
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT)
	end
	local g=Duel.Group(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		local val=(Duel.GetTurnCount(nil,true)+1)*-100
		Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,g,#g,1-tp,LOCATION_MZONE,val)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.MoveTurnCountCustom(1,e,tp,REASON_EFFECT)~=0 then
		local c=e:GetHandler()
		local g=Duel.Group(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local val=Duel.GetTurnCount(nil,true)*-100
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(val)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1)
			e1:UpdateDefenseClone(tc)
		end
	end
end