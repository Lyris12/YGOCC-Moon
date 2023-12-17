--Aeonstrider Discovery
--Scoperta Marciaeoni
--Scripted by: XGlitchy30

local s,id=GetID()
xpcall(function() require("expansions/script/glitchylib_helper") end,function() require("script/glitchylib_helper") end)
xpcall(function() require("expansions/script/glitchylib_aeonstride") end,function() require("script/glitchylib_aeonstride") end)
function s.initial_effect(c)
	aux.SpawnGlitchyHelper(GLITCHY_HELPER_TURN_COUNT_FLAG)
	aux.RaiseAeonstrideEndOfTurnEvent(c)
	--[[Add 1 "Aeonstride" card from your Deck to your hand, except "Aeonstrider Discovery".]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetTarget(aux.SearchTarget(s.thfilter))
	e1:SetOperation(aux.SearchOperation(s.thfilter))
	c:RegisterEffect(e1)
	--[[If the Turn Count moves forwards, while this card is banished or in your GY (except during the Damage Step):
	You can shuffle this card into the Deck; distribute Chronus Counters among "Aeonstride" cards you control equal to the current Turn Count,
	then you can Set 1 "Aeonstride" Spell/Trap directly from your Deck.]]
	local RMChk=aux.AddThisCardBanishedAlreadyCheck(c,Effect.SetLabelObjectObject,Effect.GetLabelObjectObject)
	local GYChk=aux.AddThisCardInGraveAlreadyCheck(c)
	RMChk:SetLabelObject(GYChk)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TURN_COUNT_MOVED)
	e2:SetRange(LOCATION_GB)
	e2:HOPT()
	e2:SetLabelObject(GYChk)
	e2:SetFunctions(s.gycon,aux.ToDeckSelfCost,s.gytg,s.gyop)
	c:RegisterEffect(e2)
	aux.RegisterTurnCountTriggerEffectFlag(c,e2)
end
--FE1
function s.thfilter(c)
	return c:IsSetCard(ARCHE_AEONSTRIDE) and not c:IsCode(id)
end

--FE2
function s.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_AEONSTRIDE)
end
function s.setfilter(c)
	return c:IsST() and c:IsSetCard(ARCHE_AEONSTRIDE) and c:IsSSetable()
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
	local g=Duel.Group(s.ctfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then
		local turnct=Duel.GetTurnCount(nil,true)
		return #g>0 and g:CheckSubGroup(aux.DistributeCountersGroupCheck(COUNTER_CHRONUS),1,math.min(#g,turnct),turnct)
	end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,tp,LOCATION_ONFIELD)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.ctfilter,tp,LOCATION_ONFIELD,0,nil)
	if #g==0 then return end
	local turnct=Duel.GetTurnCount(nil,true)
	Duel.DistributeCounters(tp,COUNTER_CHRONUS,turnct,g,id)
	if conjunction_success and Duel.IsExists(false,s.setfilter,tp,LOCATION_DECK,0,1,nil) and e:GetHandler():AskPlayer(tp,2) then
		local g=Duel.Select(HINTMSG_SET,false,tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SSet(tp,g)
		end
	end
end