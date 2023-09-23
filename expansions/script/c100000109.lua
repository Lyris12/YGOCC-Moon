--Aeonstrider Founder - Verdandi
--Fondatrice Marciaeoni - Verdandi
--Scripted by: XGlitchy30

local s,id,o=GetID()
xpcall(function() require("expansions/script/glitchylib_helper") end,function() require("script/glitchylib_helper") end)
xpcall(function() require("expansions/script/glitchylib_aeonstride") end,function() require("script/glitchylib_aeonstride") end)
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,6,s.TLcon,s.TLmaterial,{s.TLop,s,TLval})
	aux.SpawnGlitchyHelper(GLITCHY_HELPER_TURN_COUNT_FLAG)
	aux.RaiseAeonstrideEndOfTurnEvent(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	--[[If this card is Time Leap Summoned, or the Turn Count moves forwards: You can place 3 Chronus Counters on 1 "Aeonstride" card you control.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
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
	--[[Once per turn, when your opponent activates a card or effect (Quick Effect): You can remove 3 Chronus Counters from your field;
	negate the activation, and if you do, destroy it, then you can move the Turn Count forwards by 1 turn, then you can banish this card until the next Standby Phase.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_NEGATE|CATEGORY_DESTROY|CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:OPT()
	e3:SetFunctions(s.negcon,aux.RemoveCounterCost(COUNTER_CHRONUS,3),s.negtg,s.negop)
	c:RegisterEffect(e3)
end

--PROC
function s.TLcon(e,c)
	return Duel.IsExists(false,aux.Faceup(Card.IsMonster),e:GetHandlerPlayer(),LOCATION_EXTRA,0,2,nil)
end
function s.TLmaterial(c,e)
	return c:IsSetCard(ARCHE_AEONSTRIDE)
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
end
function s.TLval(c,e,tp)
	if c:IsMonster(TYPE_PENDULUM) then
		return c:IsAbleToExtra()
	else
		return c:IsAbleToRemove()
	end
end

--FE1
function s.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_AEONSTRIDE) and c:IsCanAddCounter(COUNTER_CHRONUS,3)
end
--E1
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if aux.TurnCountMovedDueToTurnEnd then
		return r&REASON_RULE==0
	else
		return ev>0
	end
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:HasFlagEffect(id) and Duel.IsExists(true,s.ctfilter,tp,LOCATION_ONFIELD,0,1,nil)
	end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,tp,LOCATION_ONFIELD)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_COUNTER,false,tp,s.ctfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		g:GetFirst():AddCounter(COUNTER_CHRONUS,3)
	end
end

--FILTERS E2
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsRelateToChain(ev) and rc:IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	local c=e:GetHandler()
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,c,1,c:GetControler(),c:GetLocation())
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) and Duel.Destroy(eg,REASON_EFFECT)>0 and Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT) and c:AskPlayer(tp,2) then
		Duel.BreakEffect()
		if Duel.MoveTurnCountCustom(1,e,tp,REASON_EFFECT)~=0 and c:IsRelateToChain() and c:IsAbleToRemove() and c:AskPlayer(tp,STRING_ASK_BANISH) then
			Duel.BreakEffect()
			Duel.BanishUntil(c,e,tp,nil,PHASE_STANDBY,id,1,true,c,REASON_EFFECT)
		end
	end
end