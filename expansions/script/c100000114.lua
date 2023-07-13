--Aeonstrider Armageddon
--Armageddon Marciaeoni
--Scripted by: XGlitchy30

local s,id,o=GetID()
xpcall(function() require("expansions/script/glitchylib_helper") end,function() require("script/glitchylib_helper") end)
xpcall(function() require("expansions/script/glitchylib_aeonstride") end,function() require("script/glitchylib_aeonstride") end)
function s.initial_effect(c)
	aux.SpawnGlitchyHelper(GLITCHY_HELPER_TURN_COUNT_FLAG)
	aux.RaiseAeonstrideEndOfTurnEvent(c)
	--[[If the turn count is 3+: Move the Turn Count backwards by 2 turns; destroy up to 2 cards your opponent controls, and if you do,
	place 1 "Aeonstride" Pendulum Monster you control in your Extra Deck, face-up, until the end of the 2nd turn after this effect resolves.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetFunctions(s.condition,s.cost,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If the Turn Count moves forwards, while this card is banished or in your GY (except during the Damage Step): You can Set this card, then move the Turn Count forwards by 1 turn.]]
	local RMChk=aux.AddThisCardBanishedAlreadyCheck(c,Effect.SetLabelObjectObject,Effect.GetLabelObjectObject)
	local GYChk=aux.AddThisCardInGraveAlreadyCheck(c)
	RMChk:SetLabelObject(GYChk)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TURN_COUNT_MOVED)
	e2:SetRange(LOCATION_GB)
	e2:SetLabelObject(GYChk)
	e2:SetFunctions(s.gycon,nil,s.gytg,s.gyop)
	c:RegisterEffect(e2)
	aux.RegisterTurnCountTriggerEffectFlag(c,e2)
	local BRChk=aux.AddThisCardInBackrowAlreadyCheck(c,POS_FACEDOWN)
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_TURN_COUNT_MOVED)
	ge1:SetLabelObject(BRChk)
	ge1:SetFunctions(s.regcon,nil,nil,s.regop)
	Duel.RegisterEffect(ge1,0)
	--[[If the Turn Count was moved forwards while this card was Set in the Spell & Trap Zone, it can be activated the turn it was Set.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e3:SetCondition(s.handcon)
	c:RegisterEffect(e3)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	if not c:IsInBackrow(POS_FACEDOWN) then return false end
	local se=e:GetLabelObject():GetLabelObject()
	if not (se==nil or not re or re~=se) then return false end
	return aux.TurnCountMovedDueToTurnEnd or ev>0
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetOwner():RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
end
--FILTERS E1
function s.tefilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_PENDULUM) and c:IsSetCard(ARCHE_AEONSTRIDE) and c:IsAbleToExtra()
end
--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount(nil,true)>=3
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanMoveTurnCount(-2,e,tp,REASON_COST) end
	Duel.MoveTurnCountCustom(-2,e,tp,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then
		return #g>0 and Duel.IsExists(false,s.tefilter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,1-tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_DESTROY,false,tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,2,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.Destroy(g,REASON_EFFECT)>0 then
			local sg=Duel.Select(HINTMSG_FACEUP,false,tp,s.tefilter,tp,LOCATION_MZONE,0,1,1,nil)
			if #sg>0 then
				Duel.HintSelection(sg)
				local ct,e1=Duel.ToExtraUntil(sg,e,tp,PHASE_END,id,2,false,e:GetHandler(),REASON_EFFECT,false,1)
				if e1 then
					local c=e:GetHandler()
					c:SetTurnCounter(0)
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
					e1:SetCode(EVENT_PHASE_START|PHASE_DRAW)
					e1:SetReset(RESET_PHASE|PHASE_END,2)
					e1:SetCountLimit(1)
					e1:SetCondition(s.turncon)
					e1:SetOperation(s.turnop)
					Duel.RegisterEffect(e1,tp)
					c:RegisterFlagEffect(CARD_PYRO_CLOCK,RESET_PHASE|PHASE_END,0,2)
					s[c]=e1
				end
			end
		end
	end
end
function s.turncon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	return c:GetFlagEffect(CARD_PYRO_CLOCK)~=0
end
function s.turnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct>1 then
		c:ResetFlagEffect(CARD_PYRO_CLOCK)
		e:Reset()
	end
end

--E2
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	if not (se==nil or not re or re~=se) then return false end
	if aux.TurnCountMovedDueToTurnEnd then
		return r&REASON_RULE==0
	else
		return ev>0
	end
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsSSetable() and Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT)
	end
	if c:IsInGY() then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
	end
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SSet(tp,c)>0 and Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT) then
		Duel.BreakEffect()
		Duel.MoveTurnCountCustom(1,e,tp,REASON_EFFECT)
	end
end

--E3
function s.handcon(e)
	return e:GetHandler():HasFlagEffect(id+100)
end